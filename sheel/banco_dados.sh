#!/bin/bash

# Configurações do MySQL
DB_NAME="projetoSemente"
DB_USER="projetoSemente"
DB_PASS="urubu100"
SQL_DIR="sustentare-data" # Diretório onde estão os arquivos SQL

# Verifica se o comando mysql está disponível
if ! command -v mysql &> /dev/null; then
    echo "Erro: MySQL não está instalado ou configurado no PATH."
    exit 1
fi

# Verifica se o diretório de scripts SQL existe
if [ ! -d "$SQL_DIR" ]; then
    echo "Erro: Diretório $SQL_DIR não encontrado!"
    exit 1
fi

# Verifica se o banco de dados existe e cria caso não exista
echo "Verificando existência do banco de dados $DB_NAME..."
if ! mysql -u "$DB_USER" -p"$DB_PASS" -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"; then
    echo "Erro ao acessar o MySQL ou criar o banco de dados. Verifique o usuário e a senha."
    exit 1
fi
echo "Banco de dados $DB_NAME verificado/criado com sucesso."

# Verifica se há arquivos SQL no diretório
SQL_FILES=("$SQL_DIR"/*.sql)
if [ ! -e "${SQL_FILES[0]}" ]; then
    echo "Nenhum arquivo SQL encontrado no diretório $SQL_DIR."
    exit 1
fi

# Executa todos os arquivos SQL no diretório
echo "Executando scripts SQL do diretório $SQL_DIR..."
for script in "$SQL_DIR"/*.sql; do
    echo "Executando $script..."
    if mysql -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$script"; then
        echo "Arquivo $script executado com sucesso."
    else
        echo "Erro ao executar $script. Verifique o arquivo."
        echo "Conteúdo do arquivo $script:"
        cat "$script"
        exit 1
    fi
done

echo "Todos os scripts foram executados com sucesso!"
