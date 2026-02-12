/**
 * Middleware de Autenticação - Bearer Token
 * 
 * Valida o token de autenticação enviado no header Authorization
 * Formato esperado: Authorization: Bearer {token}
 */

export function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

  // Token esperado (em produção, usar variável de ambiente)
  const expectedToken = process.env.BEARER_TOKEN || 'token_padrao_desenvolvimento';

  if (!token) {
    return res.status(401).json({
      erro: 'Token de autenticação não fornecido',
      mensagem: 'O header Authorization com Bearer token é obrigatório'
    });
  }

  if (token !== expectedToken) {
    return res.status(403).json({
      erro: 'Token inválido',
      mensagem: 'O token fornecido não é válido'
    });
  }

  // Token válido, continua para a rota
  next();
}

/**
 * Middleware de Logging
 * 
 * Registra informações sobre cada requisição
 */
export function logRequest(req, res, next) {
  const timestamp = new Date().toISOString();
  const { method, url, headers } = req;
  
  console.log('📥 [REQUEST]', {
    timestamp,
    method,
    url,
    userAgent: headers['user-agent'],
    origin: headers['origin'] || headers['host']
  });

  // Captura o tempo de resposta
  const startTime = Date.now();
  
  res.on('finish', () => {
    const duration = Date.now() - startTime;
    console.log('📤 [RESPONSE]', {
      timestamp: new Date().toISOString(),
      method,
      url,
      statusCode: res.statusCode,
      duration: `${duration}ms`
    });
  });

  next();
}
