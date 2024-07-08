# Automação Nginx

Este projeto contém um script Bash que automatiza o processo de instalação e configuração do Nginx em um servidor Ubuntu. Ele inclui a criação de um site básico e a verificação do status do servidor Nginx.

## Descrição

O script realiza as seguintes tarefas:
1. Atualiza a lista de pacotes do sistema.
2. Instala o Nginx, se não estiver instalado.
3. Cria um arquivo de configuração do site no diretório `/etc/nginx/sites-available`.
4. Cria o diretório do site em `/var/www/meusite`.
5. Cria um arquivo `index.html` básico para o site.
6. Ativa a configuração do site criando um link simbólico em `/etc/nginx/sites-enabled`.
7. Remove a configuração padrão do Nginx, se existir.
8. Reinicia o serviço Nginx para aplicar as mudanças.
9. Verifica se o serviço Nginx está em execução.
10. Verifica se o site está sendo servido corretamente.

## Pré-requisitos

- Ubuntu Server
- Permissões de superusuário (root)

## Como Usar

1. Clone este repositório ou baixe o script `deployNginx.sh`:

    ```bash
    git clone https://github.com/MuriloGomesMunhoz/automacaoNginx.git
    cd automacaoNginx
    ```

2. Dê permissão de execução ao script:

    ```bash
    chmod +x deployNginx.sh
    ```

3. Execute o script:

    ```bash
    sudo ./deployNginx.sh
    ```

## Verificação

Após a execução do script, você pode verificar se o Nginx está operando e se o site está sendo servido corretamente:

- Verifique o status do Nginx:

    ```bash
    sudo systemctl status nginx
    ```

- Verifique a resposta do site:

    ```bash
    curl -I http://localhost
    ```

## Conteúdo do Script

```bash
#!/bin/bash

# Função para exibir mensagens informativas
info() {
    echo "[INFO] $1"
}

# Verifica se o script está sendo executado como root
if [ "$EUID" -ne 0 ]; then
    echo "Por favor, execute como root"
    exit 1
fi

# Atualizando pacotes
info "Atualizando pacotes..."
sudo apt-get update -y

# Instalando o Nginx, se não estiver instalado
if ! dpkg -l | grep -qw nginx; then
    info "Instalando o Nginx..."
    sudo apt-get install nginx -y
else
    info "Nginx já está instalado"
fi

# Inicialização de variáveis
diretorio_configuracao="/etc/nginx/sites-available/meusite"
diretorio_site="/var/www/meusite"

# Criando arquivo de configuração
info "Criando arquivo de configuração do site..."
sudo tee $diretorio_configuracao > /dev/null <<EOF
server {
    listen 80;
    server_name meusite.com www.meusite.com;

    root $diretorio_site;
    index index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF

# Criando diretório do site 
info "Criando diretório do site..."
sudo mkdir -p $diretorio_site

# Criando arquivo index.html simples
info "Criando arquivo index.html..."
echo "<h1>Bem-vindo ao Meu Site!</h1>" | sudo tee $diretorio_site/index.html

# Ativando a configuração do site
info "Ativando a configuração do site..."
sudo ln -sf $diretorio_configuracao /etc/nginx/sites-enabled/

# Remove a configuração padrão do Nginx, se existir
if [ -L /etc/nginx/sites-enabled/default ]; then
    info "Removendo configuração padrão do Nginx..."
    sudo rm /etc/nginx/sites-enabled/default
fi

# Reinicia o Nginx para aplicar as mudanças
info "Reiniciando o Nginx..."
sudo systemctl restart nginx

# Verifica o status do Nginx
if pgrep nginx &> /dev/null; then
    info "Nginx está operando"
else
    info "Nginx está fora"
fi

# Verifica se o Nginx está servindo o site corretamente
info "Verificando se o site está sendo servido..."
curl -I http://localhost

