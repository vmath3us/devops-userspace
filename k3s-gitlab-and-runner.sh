#!/bin/bash
set -ex

if [ $(whoami) != "root" ] ; then exit 1 ; fi

SUFFIX_DOMAIN="${1}"
if [ -z $1 ]
then
    echo "domain null, exiting"
    exit 1
fi

WORK_DIR=$(mktemp -d -p /tmp)

cd $WORK_DIR

curl -L "https://dl.k8s.io/release/v1.28.9/bin/linux/amd64/kubectl" -o /usr/local/bin/kubectl
chmod +x /usr/local/bin/kubectl

curl -L https://get.helm.sh/helm-v3.13.3-linux-amd64.tar.gz -o /tmp/helm.tar.gz
tar -C /usr/local/bin --strip-components=1 -xf /tmp/helm.tar.gz
chmod +x /usr/local/bin/helm

rm -r /tmp/helm.tar.gz


curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.28.9+k3s1 sh -s server --cluster-init --disable servicelb --disable traefik


install -Dm600 /etc/rancher/k3s/k3s.yaml /root/.kube/config

until kubectl get pods ; do sleep 1 ; done

helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --version='4.10.3' \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.kind=DaemonSet \
  --set controller.service.enabled=false \
  --set controller.hostPort.enabled=true \
  --set controller.hostPort.ports.http=80 \
  --set controller.hostPort.ports.https=443 \
  --set controller.ingressClassResource.default=true

kubectl rollout status -n ingress-nginx daemonset/ingress-nginx-controller

until curl localhost ; do sleep 1 ; done

cat > ./gitlab-compose-in-k3s.yaml <<-EOF
apiVersion: v1
kind: Namespace
metadata:
  name: gitlab-docker-deploy
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: gitlab-docker-gitlab-docker
  namespace: gitlab-docker-deploy
  annotations:
    app.kubernetes.io/name: gitlab-docker
    app.kubernetes.io/instance: gitlab-docker
spec:
  strategy:
    type: Recreate
  replicas: 1
  selector:
    matchLabels:
      app: gitlab-docker
      app.kubernetes.io/name: gitlab-docker
      app.kubernetes.io/instance: gitlab-docker
  template:
    metadata:
      labels:
        app: gitlab-docker
        app.kubernetes.io/name: gitlab-docker
        app.kubernetes.io/instance: gitlab-docker
    spec:
      terminationGracePeriodSeconds: 800
      volumes:
      - name: deployment-volume
        hostPath:
          path: /home/$SUFFIX_DOMAIN/gitlab-server-deploy
          type: DirectoryOrCreate
      - name: docker-volume
        hostPath:
          path: /home/$SUFFIX_DOMAIN/docker
          type: DirectoryOrCreate
      containers:
        - name: docker-in-kube-container
          lifecycle:
            preStop:
              exec:
                command: ["/bin/sh", "-c" , "cd /home/$SUFFIX_DOMAIN/gitlab-server-deploy ; docker compose down; kill -s SIGTERM \$(cat /var/run/docker.pid)"]
          image: "docker:dind"
          command: [ "/bin/sh" ]
          args:
          - '-xc'
          - |
            cd /home/$SUFFIX_DOMAIN/gitlab-server-deploy
            cat > ./docker-compose.yaml <<-IS_COMPOSE
            services:
              gitlab:
                image: 'gitlab/gitlab-ce'
                container_name: gitlab-container
                hostname: 'gitlab-$SUFFIX_DOMAIN'
                network_mode: host
                volumes:
                 - ./data_gitlab_config:/etc/gitlab
                 - ./data_gitlab_logs:/var/log/gitlab
                 - ./data_gitlab_data:/var/opt/gitlab
                restart: "unless-stopped"
                stop_signal: "SIGTERM"
                stop_grace_period: "600s"
                environment:
                  GITLAB_ROOT_PASSWORD: "5ynS1UGcRBl7GzJ24d6TEWh1WF1bpGHRZxKNUIXYGf6LGvvr8OMsaG5jcagt41VI"
                    ### -> https://docs.gitlab.com/ee/install/docker.html#install-gitlab-using-docker-compose
                    ### -> https://forum.gitlab.com/t/troubles-enabling-container-registry-behind-traefik-reverse-proxy/97005/4 
                  GITLAB_OMNIBUS_CONFIG: |
                    external_url= 'http://gitlab-$SUFFIX_DOMAIN'
                    nginx['enable'] = true
                    nginx['listen_port'] = 80
                    nginx['listen_https'] = false
                    nginx['redirect_http_to_https'] = false
                    nginx['real_ip_header'] = 'X-Forwarded-For'
                    nginx['real_ip_recursive'] = 'on'
                    letsencrypt['enable'] = false
                    lfs_enabled = true
                    registry_external_url 'http://registry-$SUFFIX_DOMAIN:5005'
                    gitlab_rails['registry_enabled'] = true
                    gitlab_rails['registry_host'] = 'registry-$SUFFIX_DOMAIN'
                    registry_nginx['listen_port'] = 5005
                    gitlab_rails['registry_api_url'] = "http://127.0.0.1:5000"
                    registry_nginx['listen_https'] = false
            IS_COMPOSE
            apk add util-linux
            setsid --fork sh -c 'export TINI_SUBREAPER=1 ; /usr/local/bin/dockerd-entrypoint.sh --tls=false --experimental'
            until docker ps ; do sleep 1 ; done
            docker run hello-world
            docker compose up -d
            docker compose logs -f
          volumeMounts:
          - name: deployment-volume
            mountPath: /home/$SUFFIX_DOMAIN/gitlab-server-deploy
          - name: docker-volume
            mountPath: /var/lib/docker
          securityContext:
            privileged: true
          ports:
          - containerPort: 80
            name: web
          - containerPort: 5005
            hostPort: 5005
            name: registry

---
apiVersion: v1
kind: Service
metadata:
  name: gitlab-docker-service
  namespace: gitlab-docker-deploy
spec:
  type: ClusterIP
  ports:
    - name: web
      port: 80
      protocol: TCP
      targetPort: 80
  selector:
    app: gitlab-docker
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: registrygitlab-docker-ingress
  namespace: gitlab-docker-deploy
  annotations:
    nginx.ingress.kubernetes.io/permanent-redirect: "http://registry-$SUFFIX_DOMAIN:5005"
spec:
  ingressClassName: "nginx"
  rules:
  - host: "registry-$SUFFIX_DOMAIN"
    http:
      paths:
      - backend:
          service:
            name: dummy-service-redirect
            port:
              number: 9000
        path: "/"
        pathType: ImplementationSpecific
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: gitlab-docker-ingress
  namespace: gitlab-docker-deploy
  annotations:
    nginx.ingress.kubernetes.io/proxy-body-size: '0'
spec:
  ingressClassName: "nginx"
  rules:
  - host: "gitlab-$SUFFIX_DOMAIN"
    http:
      paths:
      - backend:
          service:
            name: gitlab-docker-service
            port:
              number: 80
        path: "/"
        pathType: ImplementationSpecific
EOF

kubectl apply -f ./gitlab-compose-in-k3s.yaml

until curl registry-$SUFFIX_DOMAIN:5005 ; do sleep 1 ; done

until [ "$(curl -L -s -o /dev/null -w "%{http_code}" http://gitlab-$SUFFIX_DOMAIN )" = "200" ]; do
  sleep 1
done

SHARED_RUNNER_TOKEN=$(kubectl -n gitlab-docker-deploy exec --stdin --tty deployment/gitlab-docker-gitlab-docker -- docker exec -it gitlab-container bash -c 'gitlab-rails runner -e production "puts Gitlab::CurrentSettings.current_application_settings.runners_registration_token"')


helm repo add gitlab https://charts.gitlab.io
helm repo update
cat > ./values.yaml <<-EOF
gitlabUrl: "http://gitlab-$SUFFIX_DOMAIN"
runnerRegistrationToken: "$SHARED_RUNNER_TOKEN"
terminationGracePeriodSeconds: 0
serviceAccount:
  create: "true"
rbac:
  create: true
runners:
  config: |
    [[runners]]
      name = "kubernetes-develop"
      executor = "kubernetes"
      [runners.kubernetes]
        privileged = true
        namespace = "gitlab-runner"
        image = "docker:dind"
EOF
helm install gitlab-runner -f ./values.yaml gitlab/gitlab-runner --namespace gitlab-runner --create-namespace
until kubectl -n gitlab-runner logs -f deployment/gitlab-runner ; do sleep 1 ; done
