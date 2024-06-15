## multiplex log
Demonstração do uso do tmux para multiplexar o log de um container.
A saída é legível de um terminal, mas **não** é capturável/legível
em um arquivo de texto.
Se entrar no container, e atachar na sessão, o log para de ser atualizado na saida
do kubectl. Ao sair (detach) do tmux, o log volta a atualizar.
Se fizer ssh, e atachar na sessão, o log **não** volta a ser atualizado na sáida do kubectl mesmo após o detach.
