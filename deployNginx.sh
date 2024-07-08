#!/bin/bash

# Verifica se o script está sendo executado como root
if [ "$EUID" -ne 0 ]; then
    echo "Por favor, execute como root"
    exit 1
fi

# Atualizando pacotes
info "Atualizando pacotes!"
sudo apt-get update -y

# Instalando o Nginx, se não estiver instalado
if ! dpkg -l | grep -qw nginx; then
    info "Instalando o Nginx!"
    sudo apt-get install nginx -y
else
    info "Nginx já está instalado!"
fi

# Inicialização de variáveis
diretorio_configuracao="/etc/nginx/sites-available/meusite"
diretorio_site="/var/www/meusite"

# Criando arquivo de configuração
info "Criando arquivo de configuração do site!"
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
info "Criando diretório do site!"
sudo mkdir -p $diretorio_site

# Criando arquivo index.html simples
info "Criando arquivo index.html!"
echo "<h1>Bem-vindo ao Meu Site!</h1>" | sudo tee $diretorio_site/index.html

# Ativando a configuração do site
info "Ativando a configuração do site!"
sudo ln -sf $diretorio_configuracao /etc/nginx/sites-enabled/

# Remove a configuração padrão do Nginx, se existir
if [ -L /etc/nginx/sites-enabled/default ]; then
    info "Removendo configuração padrão do Nginx!"
    sudo rm /etc/nginx/sites-enabled/default
fi

# Reinicia o Nginx para aplicar as mudanças
info "Reiniciando o Nginx!"
sudo systemctl restart nginx

# Verifica o status do Nginx
if pgrep nginx &> /dev/null; then
    info "Nginx está operando!"
else
    info "Nginx está fora!"
fi

# Verifica se o Nginx está servindo o site corretamente
info "Verificando se o site está sendo servido!"
curl -I http://localhost

