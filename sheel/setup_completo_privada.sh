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
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'urubu100';"
sudo mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;"
sudo mysql -e "FLUSH PRIVILEGES;"

# Criando o usuário 'projetoSemente' com a mesma senha e privilégios
sudo mysql -e "CREATE USER 'projetoSemente'@'localhost' IDENTIFIED BY 'urubu100';"
sudo mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'projetoSemente'@'localhost' WITH GRANT OPTION;"
sudo mysql -e "FLUSH PRIVILEGES;"

# Criando banco de dados de exemplo
echo "Criando o banco de dados 'exemplo_db'..."
sudo mysql -e "CREATE DATABASE exemplo_db;"

# Teste de conexão MySQL
echo "Testando conexões com MySQL..."
mysql -u root -purubu100 -e "SHOW DATABASES;"
mysql -u projetoSemente -purubu100 -e "SHOW DATABASES;"

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
git clone https://github.com/Grupo-2-Sustentare/sustentare-api.git
git clone https://github.com/Grupo-2-Sustentare/sustentare-data.git

# Mensagem de sucesso
echo "Instalação e configuração concluídas! Verifique os componentes:"
echo "1. Java instalado e configurado: $(java -version)"
echo "2. Spring Boot disponível: $(spring --version)"
echo "3. MySQL instalado e rodando."
echo "4. Git configurado com sucesso: $(git config --global --list)"
echo "5. Repositórios clonados com sucesso."

# Executando o arquivo banco_dados.sh
if [ -f "./banco_dados.sh" ]; then
    echo "Executando o arquivo banco_dados.sh..."
    chmod +x ./banco_dados.sh
    ./banco_dados.sh
else
    echo "Arquivo banco_dados.sh não encontrado. Pule esta etapa."
fi

# Ativando aplicação .jar
# if [ -d "sustentare-api" ]; then
#     echo "Verificando arquivos .jar no repositório sustentare-api..."
#     cd sustentare-api
#     JAR_FILE=$(find . -name "*.jar" | head -n 1)

#     if [ -f "$JAR_FILE" ]; then
#         echo "Iniciando o arquivo $JAR_FILE..."
#         #java -jar "$JAR_FILE" &
#         echo "Aplicação iniciada com sucesso."
#     else
#         echo "Nenhum arquivo .jar encontrado no diretório sustentare-api."
#     fi
#     cd ..
# else
#     echo "Repositório sustentare-api não encontrado. Pule esta etapa."
# fi

echo "Script concluído!"
