# Use a imagem oficial do Node.js como base
FROM node:14

# Crie um diretório de trabalho dentro do contêiner
WORKDIR /usr/src/app

# Copie o arquivo package.json e package-lock.json para o diretório de trabalho
COPY package*.json ./

# Instale as dependências
RUN npm install

# Copie o restante dos arquivos para o diretório de trabalho
COPY . .

# Exponha a porta que o aplicativo irá escutar
EXPOSE 3000

# Comando para iniciar o aplicativo
CMD ["node", "app.js"]

