/**
 * Adapter Totvs - Simulação de Consulta de Pedidos
 * 
 * Este módulo simula as respostas que seriam retornadas pelo sistema Totvs.
 * Na integração real, este adapter faria chamadas HTTP para a API do Totvs.
 */

/**
 * Simula a consulta de um pedido no sistema Totvs
 * 
 * @param {string} ordemVenda - Número da ordem de venda
 * @returns {Promise<Object>} Dados do pedido simulados
 */
export async function consultarPedido(ordemVenda) {
  // Simulando delay de rede (50-150ms)
  await new Promise(resolve => setTimeout(resolve, Math.random() * 100 + 50));

  // Log da consulta simulada
  console.log('🔍 [TOTVS ADAPTER] Consultando pedido:', ordemVenda);

  // Dados simulados baseados no exemplo da documentação
  const pedidoSimulado = {
    OrdemVenda: ordemVenda,
    ItemOv: "000010",
    LojaSaida: "G001",
    Fatura: "93171836",
    NNotaFiscal: "000470236",
    TipoOv: "VENDA",
    Status: "Faturado",
    ValorTotal: 1890.50,
    origem: "TOTVS_SIMULADO"
  };

  console.log('✅ [TOTVS ADAPTER] Pedido encontrado:', {
    OrdemVenda: pedidoSimulado.OrdemVenda,
    Status: pedidoSimulado.Status,
    ValorTotal: pedidoSimulado.ValorTotal
  });

  return pedidoSimulado;
}

/**
 * Exemplo de função para simular erro (caso necessário para testes)
 * 
 * @param {string} ordemVenda - Número da ordem de venda
 * @returns {Promise<Object>} Erro simulado
 */
export async function consultarPedidoComErro(ordemVenda) {
  throw new Error(`Pedido ${ordemVenda} não encontrado no sistema Totvs`);
}
