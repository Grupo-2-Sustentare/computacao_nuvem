#!/bin/bash

# Atualizando pacotes do sistema
echo "Atualizando pacotes..."
sudo apt update && sudo apt upgrade -y

# Instalando o Node.js
echo "Instalando Node.js..."
sudo apt install -y nodejs

# Verificando a instalação do Node.js
echo "Node.js versão instalada:"
node -v

# Verificando a versão do NPM
echo "NPM versão instalada:"
sudo apt install npm -y
npm -v

# Clonando os repositórios
echo "Clonando repositórios do GitHub..."

# Repositório Sustentare Web
git clone https://github.com/Grupo-2-Sustentare/sustentare-web.git

# Repositório Sustentare Dashboard
git clone https://github.com/Grupo-2-Sustentare/sustentare-dashboard.git

echo "Repositórios clonados com sucesso!"

# Mensagem de sucesso
echo "Instalação e configuração concluídas!"
echo "1. Node.js versão: $(node -v)"
echo "2. NPM versão: $(npm -v)"
echo "3. Repositórios clonados com sucesso!"

# Entrar em cada repositório e instalar dependências
echo "Instalando dependências dos repositórios clonados..."

# Lista de repositórios
repos=("sustentare-web" "sustentare-dashboard")

for repo in "${repos[@]}"; do
    if [ -d "$repo" ]; then
        echo "Entrando na pasta $repo..."
        cd "$repo"
        
        echo "Instalando dependências com npm..."
        npm install
        
        echo "Dependências instaladas em $repo."
        cd .. # Voltar para o diretório anterior
    else
        echo "Repositório $repo não encontrado! Verifique se foi clonado corretamente."
    fi
done

echo "Instalação de dependências concluída para todos os repositórios."
