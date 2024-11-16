#!/bin/bash

# Atualizando pacotes do sistema
echo "Atualizando pacotes..."
sudo apt update && sudo apt upgrade -y

# Instalando dependências para adicionar repositórios externos
echo "Instalando dependências para repositórios..."
sudo apt install -y curl gnupg

# Adicionando repositório oficial do Node.js (alterando para versão mais recente)
echo "Adicionando repositório do Node.js..."
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -

# Instalando o Node.js
echo "Instalando Node.js..."
sudo apt-get install -y nodejs

# Verificando a instalação do Node.js
echo "Node.js versão instalada:"
node -v

# Verificando a versão do NPM
echo "NPM versão instalada:"
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
