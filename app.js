const express = require('express');
const app = express();
const PORT = 3000; // Pode ser qualquer número de porta que você preferir


app.get('/', (req, res) => {
  res.send('Bem-vindos ao mundo Levinux');
});

// Rota para a criação de usuário
app.get('/user', (req, res) => {
  // Lógica para criar um novo usuário
  res.send('Rota de criação de usuário');
});

// Rota de login
app.get('/login', (req, res) => {
  // Lógica para autenticação e login do usuário
  res.send('Rota de login');
});

// Rota de logout
app.get('/logout', (req, res) => {
  // Lógica para logout do usuário
  res.send('Rota de logout');
});

// Iniciar o servidor
app.listen(PORT, () => {
  console.log(`Servidor rodando em http://localhost:${PORT}`);
});
