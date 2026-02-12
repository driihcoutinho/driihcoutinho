/**
 * Servidor Express - POC API Gateway
 * 
 * Middleware para integração Salesforce ↔ Totvs
 * Este servidor recebe requisições do Salesforce e simula respostas do Totvs
 */

import 'dotenv/config';
import express from 'express';
import routes from './routes.js';
import { logRequest } from './middleware/auth.js';

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware global para parsing de JSON
app.use(express.json());

// Middleware global para logging de requisições
app.use(logRequest);

// Adiciona headers CORS (se necessário)
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, Authorization');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  
  // Responde às requisições preflight
  if (req.method === 'OPTIONS') {
    return res.sendStatus(200);
  }
  
  next();
});

// Registra as rotas
app.use('/', routes);

// Tratamento global de erros
app.use((err, req, res, next) => {
  console.error('💥 [ERROR]', err.stack);
  
  res.status(err.status || 500).json({
    erro: 'Erro interno do servidor',
    mensagem: err.message,
    timestamp: new Date().toISOString()
  });
});

// Inicia o servidor
app.listen(PORT, () => {
  console.log('');
  console.log('🚀 ========================================');
  console.log('🚀 POC API Gateway - Salesforce ↔ Totvs');
  console.log('🚀 ========================================');
  console.log('');
  console.log(`✅ Servidor rodando na porta: ${PORT}`);
  console.log(`🌍 URL local: http://localhost:${PORT}`);
  console.log('');
  console.log('📋 Endpoints disponíveis:');
  console.log(`   GET  /health`);
  console.log(`   GET  /pedido/:ordemVenda`);
  console.log('');
  console.log('🔐 Autenticação: Bearer Token');
  console.log(`   Token configurado: ${process.env.BEARER_TOKEN ? '✓ Sim' : '✗ Não (usando padrão)'}`);
  console.log('');
  console.log('========================================');
  console.log('');
});

export default app;
