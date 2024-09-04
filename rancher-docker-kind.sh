#!/bin/bash
set -e

DOMAIN="${1}"
if [ -z $1 ]
then
    echo "domain null, exiting"
    exit 1
fi

cat > ./rancher-kind.yaml <<-EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  image: kindest/node:v1.28.7@sha256:9bc6c451a289cf96ad0bbaf33d416901de6fd632415b076ab05f5fa7e4f65c58
  extraPortMappings:
  - containerPort: 80
    hostPort: 60080
    protocol: TCP
  - containerPort: 443
    hostPort: 60443
    protocol: TCP
EOF

kind create cluster --name rancher-kind --config ./rancher-kind.yaml

kind get kubeconfig --name rancher-kind > rancher-kubeconfig

export KUBECONFIG=$(realpath $PWD/rancher-kubeconfig)

kubectl label nodes rancher-kind-control-plane 'node-role.kubernetes.io/etcd=true' 'node-role.kubernetes.io/worker=true'  'node-role.kubernetes.io/master=true'

kubectl taint node rancher-kind-control-plane node-role.kubernetes.io/control-plane:NoSchedule- || true


helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.kind=DaemonSet \
  --set controller.service.enabled=false \
  --set controller.hostPort.enabled=true \
  --set controller.hostPort.ports.http=80 \
  --set controller.hostPort.ports.https=443 \
  --set controller.ingressClassResource.default=true

kubectl rollout status -n ingress-nginx daemonset/ingress-nginx-controller


## -> https://ranchermanager.docs.rancher.com/getting-started/installation-and-upgrade/resources/add-tls-secrets
# Define o nome do domínio da CA raiz
ROOT_CA_DOMAIN="rootCA"

# Defina os nomes dos arquivos para a CA raiz
ROOT_KEY_FILE="${ROOT_CA_DOMAIN}.key"
ROOT_CERT_FILE="${ROOT_CA_DOMAIN}.crt"
ROOT_CONFIG_FILE="${ROOT_CA_DOMAIN}.cnf"

# Cria o arquivo de configuração do OpenSSL para a CA raiz
cat > $ROOT_CONFIG_FILE <<EOL
[req]
distinguished_name = req_distinguished_name
x509_extensions = v3_ca
prompt = no

[req_distinguished_name]
CN = $ROOT_CA_DOMAIN

[v3_ca]
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid:always,issuer
basicConstraints = CA:true
keyUsage = critical, digitalSignature, cRLSign, keyCertSign
EOL

# Gera a chave privada da CA raiz
openssl genpkey -algorithm RSA -out $ROOT_KEY_FILE -pkeyopt rsa_keygen_bits:2048

# Gera o certificado autoassinado da CA raiz
openssl req -new -x509 -key $ROOT_KEY_FILE -out $ROOT_CERT_FILE -days 3650 -config $ROOT_CONFIG_FILE

# Confirmação
echo "Chave privada e certificado da CA raiz gerados:"
echo "Chave privada: $ROOT_KEY_FILE"
echo "Certificado: $ROOT_CERT_FILE"

# Prepare para geração do secret tls-ca para o rancher
cp $ROOT_CERT_FILE ./cacerts.pem

# Remove o arquivo de configuração temporário
rm $ROOT_CONFIG_FILE

KEY_FILE="${DOMAIN}.key"
CSR_FILE="${DOMAIN}.csr"
CERT_FILE="${DOMAIN}.crt"
CONFIG_FILE="${DOMAIN}.cnf"

# Arquivos da CA raiz
ROOT_CA_DOMAIN="rootCA"
ROOT_KEY_FILE="${ROOT_CA_DOMAIN}.key"
ROOT_CERT_FILE="${ROOT_CA_DOMAIN}.crt"

# Cria o arquivo de configuração do OpenSSL
cat > $CONFIG_FILE <<EOL
[req]
distinguished_name = req_distinguished_name
req_extensions = req_ext
prompt = no

[req_distinguished_name]
CN = $DOMAIN

[req_ext]
subjectAltName = @alt_names

[alt_names]
DNS.1 = $DOMAIN
EOL

# Gera a chave privada
openssl genpkey -algorithm RSA -out $KEY_FILE -pkeyopt rsa_keygen_bits:2048

# Gera uma solicitação de assinatura de certificado (CSR)
openssl req -new -key $KEY_FILE -out $CSR_FILE -config $CONFIG_FILE

# Assina o certificado usando a CA raiz
openssl x509 -req -in $CSR_FILE -CA $ROOT_CERT_FILE -CAkey $ROOT_KEY_FILE -CAcreateserial -out $CERT_FILE -days 365 -extensions req_ext -extfile $CONFIG_FILE

# Confirmação
echo "Chave privada e certificado gerados:"
echo "Chave privada: $KEY_FILE"
echo "Certificado: $CERT_FILE"
echo "Certificado da CA raiz: $ROOT_CERT_FILE"

# Remove o arquivo de configuração temporário
rm $CONFIG_FILE

kubectl create namespace cattle-system

kubectl -n cattle-system create secret generic tls-ca --from-file=cacerts.pem

kubectl -n cattle-system create secret tls --cert=${1}.crt --key=${1}.key tls-rancher-ingress

helm upgrade --install rancher rancher \
    --repo https://releases.rancher.com/server-charts/stable \
    --namespace cattle-system \
    --create-namespace \
    --set antiAffinity=required \
    --set hostname="${1}" \
    --set bootstrapPassword=admin \
    --set ingress.tls.source=secret \
    --set ingress.ingressClassName=nginx \
    --set privateCA=true \
    --set replicas=1 \
    --set global.cattle.psp.enabled=false

kubectl rollout status -n cattle-system deployment/rancher
