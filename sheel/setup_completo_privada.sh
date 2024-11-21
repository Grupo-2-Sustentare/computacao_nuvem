#!/bin/bash

# Atualiza pacotes do sistema
echo "Atualizando pacotes..."
sudo apt update && sudo apt upgrade -y

# Instalação do Java
echo "Instalando Java..."
sudo apt install openjdk-17-jdk -y
echo "Java instalado com sucesso:"
java -version

# Configurando variável JAVA_HOME
JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
echo "JAVA_HOME=$JAVA_HOME" | sudo tee -a /etc/environment
source /etc/environment
echo "JAVA_HOME configurado como: $JAVA_HOME"

# Instalando SDKMAN!
echo "Instalando SDKMAN..."
curl -s https://get.sdkman.io | bash

# Carregar SDKMAN!
source "$HOME/.sdkman/bin/sdkman-init.sh"

# Instalando o Spring Boot CLI usando o SDKMAN!
echo "Instalando Spring Boot CLI..."
sdk install springboot

# Verificando a instalação do Spring Boot CLI
echo "Spring Boot CLI instalado. Versão:"
spring --version

# Instalação do MySQL
echo "Instalando MySQL Server e Cliente..."
sudo apt install mysql-server mysql-client -y
echo "MySQL instalado com sucesso."
sudo systemctl enable mysql
sudo systemctl start mysql

# Configurando usuários no MySQL
echo "Configurando usuários no MySQL..."

# Configurando o usuário 'root' com senha 'urubu100'
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'urubu100';"
sudo mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;"

# Criando o usuário 'sustentare' com a mesma senha e privilégios
sudo mysql -e "CREATE USER 'projetoSemente'@'localhost' IDENTIFIED WITH mysql_native_password BY 'urubu100';"
sudo mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'projetoSemente'@'localhost' WITH GRANT OPTION;"

# Criando banco de dados de exemplo
echo "Criando o banco de dados 'exemplo_db'..."
sudo mysql -e "CREATE DATABASE exemplo_db;"

# Instalação do Git
echo "Instalando Git..."
sudo apt install git -y
echo "Git instalado com sucesso:"
git --version

# Configurando Git com username e useremail
echo "Configurando Git..."
git config --global user.name "Julia-Justino"
git config --global user.email "stephany.justino@sptech.school"
echo "Configuração do Git concluída:"
git config --global --list

# Clonando repositórios do Git
echo "Clonando repositórios do Git..."
git clone https://github.com/Grupo-2-Sustentare/repo-teste-jar.git
git clone https://github.com/Grupo-2-Sustentare/sustentare-data.git


# Mensagem de sucesso
echo "Instalação e configuração concluídas! Verifique os componentes:"
echo "1. Java instalado e configurado: $(java -version)"
echo "2. Spring Boot disponível: $(spring --version)"
echo "3. MySQL instalado e rodando."
echo "4. Git configurado com sucesso: $(git config --global --list)"
echo "5. Repositórios clonados com sucesso."
echo "6. Aplicação .jar ativada."

# Executando o arquivo banco_dados.sh
echo "Executando o arquivo banco_dados.sh..."
chmod +x sustentare-data/banco_dados.sh
./sustentare-data/banco_dados.sh

# Executando o arquivo .jar
echo "Ativando o arquivo .jar..."
cd repo-teste-jar
JAR_FILE=$(find . -name "*.jar" | head -n 1)

if [ -f "$JAR_FILE" ]; then
    echo "Iniciando o arquivo $JAR_FILE..."
    java -jar "$JAR_FILE" &
    echo "Aplicação iniciada com sucesso."
else
    echo "Nenhum arquivo .jar encontrado no diretório repo-teste-jar."
fi

