/**
 * Rotas da API Gateway
 * 
 * Define os endpoints disponíveis para integração com Salesforce
 */

import express from 'express';
import { consultarPedido } from './services/totvsAdapter.js';
import { authenticateToken } from './middleware/auth.js';

const router = express.Router();

/**
 * Rota de Health Check
 * GET /health
 * 
 * Não requer autenticação
 */
router.get('/health', (req, res) => {
  res.json({
    status: 'online',
    timestamp: new Date().toISOString(),
    servico: 'POC API Gateway - Salesforce ↔ Totvs',
    versao: '1.0.0'
  });
});

/**
 * Endpoint principal: Consultar Pedido
 * GET /pedido/:ordemVenda
 * 
 * Requer autenticação via Bearer Token
 * 
 * Exemplo de uso no Salesforce:
 * req.setEndpoint('callout:TotvsEndpoint/pedido/2981977');
 */
router.get('/pedido/:ordemVenda', authenticateToken, async (req, res) => {
  try {
    const { ordemVenda } = req.params;

    // Validação do parâmetro
    if (!ordemVenda || ordemVenda.trim() === '') {
      return res.status(400).json({
        erro: 'Parâmetro inválido',
        mensagem: 'O número da ordem de venda é obrigatório'
      });
    }

    // Validação de formato (apenas números e letras, máximo 20 caracteres)
    if (!/^[a-zA-Z0-9]{1,20}$/.test(ordemVenda)) {
      return res.status(400).json({
        erro: 'Formato inválido',
        mensagem: 'O número da ordem de venda deve conter apenas letras e números (máximo 20 caracteres)'
      });
    }

    console.log('🔄 [API] Processando consulta de pedido:', ordemVenda);

    // Consulta o pedido através do adapter Totvs (simulado)
    const pedido = await consultarPedido(ordemVenda);

    // Retorna os dados do pedido
    res.json(pedido);

  } catch (error) {
    console.error('❌ [API] Erro ao consultar pedido:', error.message);
    
    res.status(500).json({
      erro: 'Erro ao consultar pedido',
      mensagem: error.message,
      timestamp: new Date().toISOString()
    });
  }
});

/**
 * Rota 404 - Endpoint não encontrado
 */
router.use('*', (req, res) => {
  res.status(404).json({
    erro: 'Endpoint não encontrado',
    mensagem: `A rota ${req.method} ${req.originalUrl} não existe`,
    endpointsDisponiveis: [
      'GET /health',
      'GET /pedido/:ordemVenda'
    ]
  });
});

export default router;
