#!/bin/bash

# Configurações do MySQL
DB_NAME="sustentare"
DB_USER="root"
DB_PASS="sptech"
SQL_DIR="sustentare-data" # Diretório onde estão os arquivos SQL

# Verifica se o diretório de scripts SQL existe
if [ ! -d "$SQL_DIR" ]; then
    echo "Erro: Diretório $SQL_DIR não encontrado!"
    exit 1
fi

# Verifica se o banco de dados existe e cria caso não exista
echo "Verificando banco de dados $DB_NAME..."
mysql -u $DB_USER -p$DB_PASS -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"

# Executa todos os arquivos SQL no diretório
echo "Executando scripts SQL do diretório $SQL_DIR..."
for script in "$SQL_DIR"/*.sql; do
    if [ -f "$script" ]; then
        echo "Executando $script..."
        mysql -u $DB_USER -p$DB_PASS $DB_NAME < "$script"
        if [ $? -eq 0 ]; then
            echo "$script executado com sucesso."
        else
            echo "Erro ao executar $script."
            exit 1
        fi
    else
        echo "Nenhum arquivo SQL encontrado em $SQL_DIR."
    fi
done

echo "Todos os scripts foram executados com sucesso!"
