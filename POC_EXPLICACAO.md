# POC API Gateway - Salesforce ↔ Totvs

## 📖 Explicação Passo a Passo

Esta POC (Prova de Conceito) demonstra como implementar um middleware entre Salesforce e Totvs sem necessidade de refatorar o código Apex existente.

### 🎯 O Problema que Resolvemos

**Situação Atual:**
```
Salesforce → Skyone → Totvs
```

O Salesforce já possui código Apex pronto que integra com Totvs através da Skyone. Queremos testar uma nova arquitetura sem reescrever código.

**Solução POC:**
```
Salesforce → API Gateway (Node.js) → Totvs (Simulado)
```

**Mudança necessária:** Apenas 1 URL no Salesforce (Named Credential).

---

## 🔧 O que Foi Implementado

### 1. **Servidor Node.js** (`src/server.js`)

O servidor Express que:
- Escuta requisições HTTP na porta 3000 (ou variável PORT do Render)
- Carrega configurações do arquivo `.env`
- Aplica middleware de logging em todas as requisições
- Trata erros globalmente
- Habilita CORS para aceitar requisições do Salesforce

**Por que Express?**
- Framework leve e rápido
- Fácil de configurar e manter
- Grande comunidade e documentação

### 2. **Rotas da API** (`src/routes.js`)

Define 2 endpoints:

#### a) `GET /health` - Health Check
```bash
curl http://localhost:3000/health
```
**Resposta:**
```json
{
  "status": "online",
  "timestamp": "2026-02-12T12:00:00.000Z",
  "servico": "POC API Gateway - Salesforce ↔ Totvs",
  "versao": "1.0.0"
}
```

**Para que serve?**
- Verificar se o servidor está funcionando
- Usado pelo Render para health checks
- Não requer autenticação

#### b) `GET /pedido/:ordemVenda` - Consultar Pedido
```bash
curl -H "Authorization: Bearer TOKEN" \
     http://localhost:3000/pedido/2981977
```

**Resposta:**
```json
{
  "OrdemVenda": "2981977",
  "ItemOv": "000010",
  "LojaSaida": "G001",
  "Fatura": "93171836",
  "NNotaFiscal": "000470236",
  "TipoOv": "VENDA",
  "Status": "Faturado",
  "ValorTotal": 1890.50,
  "origem": "TOTVS_SIMULADO"
}
```

**Para que serve?**
- Endpoint principal que o Salesforce chamará
- Retorna dados do pedido (simulados nesta POC)
- Requer autenticação Bearer Token

### 3. **Middleware de Autenticação** (`src/middleware/auth.js`)

Contém 2 middlewares:

#### a) `authenticateToken`
- Verifica se o header `Authorization: Bearer TOKEN` está presente
- Valida se o token corresponde ao configurado
- Retorna erro 401 se token ausente
- Retorna erro 403 se token inválido
- Permite continuar se token válido

**Como funciona:**
```javascript
const authHeader = req.headers['authorization'];
const token = authHeader && authHeader.split(' ')[1]; // Extrai "TOKEN" de "Bearer TOKEN"

if (token !== expectedToken) {
  return res.status(403).json({ erro: 'Token inválido' });
}

next(); // Continua para a rota
```

#### b) `logRequest`
- Registra todas as requisições no console
- Mostra: timestamp, método HTTP, URL, user agent
- Calcula tempo de resposta
- Essencial para debugging e monitoramento

**Exemplo de log:**
```
📥 [REQUEST] { method: 'GET', url: '/pedido/2981977' }
📤 [RESPONSE] { statusCode: 200, duration: '123ms' }
```

### 4. **Adapter Totvs** (`src/services/totvsAdapter.js`)

Simula o sistema Totvs:

```javascript
export async function consultarPedido(ordemVenda) {
  // Simula delay de rede
  await new Promise(resolve => setTimeout(resolve, 50-150ms));
  
  // Retorna dados simulados
  return {
    OrdemVenda: ordemVenda,
    ItemOv: "000010",
    // ... outros campos
  };
}
```

**Na produção real:**
Este arquivo seria substituído por chamadas HTTP reais ao Totvs:
```javascript
export async function consultarPedido(ordemVenda) {
  const response = await fetch(`https://totvs-api.com/pedido/${ordemVenda}`, {
    headers: { 'Authorization': 'Bearer TOTVS_TOKEN' }
  });
  return response.json();
}
```

---

## 🔄 Fluxo Completo da Requisição

Vamos seguir uma requisição do início ao fim:

### 1. **Salesforce faz callout**
```apex
HttpRequest req = new HttpRequest();
req.setEndpoint('callout:TotvsEndpoint/pedido/2981977');
req.setMethod('GET');
req.setHeader('Authorization', 'Bearer test_token_poc_2026');
HttpResponse res = new Http().send(req);
```

### 2. **Named Credential resolve URL**
- `callout:TotvsEndpoint` → `https://poc-api-gateway.onrender.com`
- URL final: `https://poc-api-gateway.onrender.com/pedido/2981977`

### 3. **Requisição chega no Express**
```
📥 [REQUEST] {
  method: 'GET',
  url: '/pedido/2981977',
  headers: { authorization: 'Bearer test_token_poc_2026' }
}
```

### 4. **Middleware de logging registra**
- Timestamp da requisição
- Método e URL
- Headers relevantes

### 5. **Router identifica rota**
- Rota: `GET /pedido/:ordemVenda`
- Parâmetro: `ordemVenda = "2981977"`

### 6. **Middleware de autenticação valida token**
```javascript
// Extrai token do header
token = "test_token_poc_2026"

// Compara com token esperado
if (token === process.env.BEARER_TOKEN) {
  next(); // ✅ Permite continuar
} else {
  res.status(403).json({ erro: 'Token inválido' }); // ❌ Bloqueia
}
```

### 7. **Handler da rota executa**
```javascript
const { ordemVenda } = req.params; // "2981977"
const pedido = await consultarPedido(ordemVenda);
res.json(pedido);
```

### 8. **Adapter consulta Totvs (simulado)**
```
🔍 [TOTVS ADAPTER] Consultando pedido: 2981977
✅ [TOTVS ADAPTER] Pedido encontrado
```

### 9. **Resposta enviada ao Salesforce**
```json
{
  "OrdemVenda": "2981977",
  "ItemOv": "000010",
  "LojaSaida": "G001",
  "Fatura": "93171836",
  "NNotaFiscal": "000470236",
  "TipoOv": "VENDA",
  "Status": "Faturado",
  "ValorTotal": 1890.50,
  "origem": "TOTVS_SIMULADO"
}
```

### 10. **Salesforce processa resposta**
```apex
Map<String, Object> pedido = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
System.debug('Status: ' + pedido.get('Status')); // "Faturado"
```

---

## ⚙️ O que Configurar no Salesforce

### 1. **Named Credential**

**O que é?**
- Configuração que armazena URL e credenciais de API externa
- Permite usar `callout:NomeCredencial` em vez de URL hardcoded
- Facilita mudança de ambiente (dev, staging, prod)

**Como configurar:**

1. Setup → Named Credentials
2. Editar a Named Credential existente (`TotvsEndpoint`)
3. Alterar URL de:
   ```
   https://skyone-api.com (antiga)
   ```
   Para:
   ```
   https://poc-api-gateway.onrender.com (POC)
   ```
4. Salvar

**Pronto!** O código Apex não precisa mudar.

### 2. **Remote Site Settings**

**O que é?**
- Lista de URLs que o Salesforce pode acessar
- Segurança: evita callouts para sites maliciosos

**Como configurar:**

1. Setup → Remote Site Settings
2. New Remote Site
3. Configurar:
   - Name: `TotvsAPI_POC`
   - URL: `https://poc-api-gateway.onrender.com`
   - Active: ✅
4. Salvar

### 3. **Código Apex (mínima alteração)**

**Adicionar apenas o header de autenticação:**

```apex
// ANTES (pode ter erro de autenticação)
HttpRequest req = new HttpRequest();
req.setEndpoint('callout:TotvsEndpoint/pedido/2981977');
req.setMethod('GET');

// DEPOIS (adicione apenas 1 linha)
HttpRequest req = new HttpRequest();
req.setEndpoint('callout:TotvsEndpoint/pedido/2981977');
req.setMethod('GET');
req.setHeader('Authorization', 'Bearer test_token_poc_2026'); // ← NOVA LINHA

// Resto do código permanece igual
HttpResponse res = new Http().send(req);
if (res.getStatusCode() == 200) {
    // Processa resposta normalmente
}
```

**IMPORTANTE:** Use o mesmo token configurado no Render (variável `BEARER_TOKEN`).

---

## 🧪 Testando Localmente

### 1. **Instalar dependências**
```bash
npm install
```

### 2. **Configurar variáveis de ambiente**
```bash
cp .env.example .env
# Editar .env e configurar BEARER_TOKEN
```

### 3. **Iniciar servidor**
```bash
npm start
```

Você verá:
```
🚀 ========================================
🚀 POC API Gateway - Salesforce ↔ Totvs
🚀 ========================================

✅ Servidor rodando na porta: 3000
🌍 URL local: http://localhost:3000

📋 Endpoints disponíveis:
   GET  /health
   GET  /pedido/:ordemVenda

🔐 Autenticação: Bearer Token
   Token configurado: ✓ Sim

========================================
```

### 4. **Testar endpoints**

```bash
# Test 1: Health Check
curl http://localhost:3000/health

# Test 2: Consultar Pedido (com token correto)
curl -H "Authorization: Bearer test_token_poc_2026" \
     http://localhost:3000/pedido/2981977

# Test 3: Sem token (deve retornar erro 401)
curl http://localhost:3000/pedido/2981977

# Test 4: Token errado (deve retornar erro 403)
curl -H "Authorization: Bearer token_errado" \
     http://localhost:3000/pedido/2981977
```

---

## 🌐 Deploy no Render

Siga o guia completo em [RENDER_DEPLOY.md](./RENDER_DEPLOY.md).

**Resumo:**
1. Criar conta no Render
2. Criar Web Service conectado ao GitHub
3. Configurar variáveis de ambiente (BEARER_TOKEN)
4. Deploy automático
5. Obter URL: `https://poc-api-gateway.onrender.com`
6. Testar endpoints

---

## 📊 Vantagens desta Arquitetura

### 1. **Desacoplamento**
- Salesforce não depende diretamente do Totvs
- Mudanças no Totvs não afetam Salesforce
- Podemos trocar Totvs por outro ERP facilmente

### 2. **Centralização**
- Um único ponto de integração
- Logs centralizados de todas as requisições
- Fácil debugging e monitoramento

### 3. **Flexibilidade**
- Adicionar cache sem mudar Salesforce
- Implementar retry logic no middleware
- Transformar dados conforme necessário

### 4. **Segurança**
- Token Bearer centralizado
- Não expõe credenciais do Totvs para Salesforce
- Pode adicionar rate limiting, IP whitelist, etc.

### 5. **Observabilidade**
- Logs estruturados de todas integrações
- Métricas de performance
- Alertas em caso de falha

---

## 🎓 Conceitos Importantes

### REST API
- Arquitetura de comunicação via HTTP
- Usa métodos: GET, POST, PUT, DELETE
- Responde com JSON
- Stateless: cada requisição é independente

### Bearer Token
- Tipo de autenticação simples
- Token enviado no header: `Authorization: Bearer TOKEN`
- Servidor valida token antes de processar requisição

### Middleware
- Funções que interceptam requisições
- Podem validar, logar, transformar dados
- Executam antes do handler da rota

### Adapter Pattern
- Camada que traduz entre sistemas diferentes
- Nesta POC: traduz Salesforce ↔ Totvs
- Isola detalhes de implementação

---

## 📚 Arquivos do Projeto

```
├── src/
│   ├── server.js              # Servidor principal Express
│   ├── routes.js              # Definição de rotas
│   ├── middleware/
│   │   └── auth.js            # Autenticação e logging
│   └── services/
│       └── totvsAdapter.js    # Simulação Totvs
├── package.json               # Dependências Node.js
├── .env.example              # Exemplo de configuração
├── .gitignore                # Arquivos ignorados
├── SETUP.md                  # Guia técnico
├── SALESFORCE_CONFIG.md      # Configuração Salesforce
├── RENDER_DEPLOY.md          # Deploy no Render
└── POC_EXPLICACAO.md         # Este arquivo
```

---

## 🤝 Próximos Passos

### Após Validar a POC:

1. **Implementar integração real com Totvs**
   - Substituir adapter simulado
   - Adicionar tratamento de erros específicos
   - Implementar retry logic

2. **Adicionar mais endpoints**
   - Criar pedido
   - Atualizar pedido
   - Consultar estoque
   - Listar produtos

3. **Melhorias de segurança**
   - OAuth2 em vez de Bearer Token simples
   - Rate limiting (ex: 100 requisições/minuto)
   - IP whitelist
   - HTTPS obrigatório

4. **Performance**
   - Implementar cache com Redis
   - Connection pooling para banco de dados
   - Compressão de respostas (gzip)

5. **Monitoramento**
   - Integrar com New Relic, DataDog ou similar
   - Configurar alertas automáticos
   - Dashboards de métricas (latência, erros, etc.)

---

## ❓ Perguntas Frequentes

### 1. Por que usar Node.js?
- Leve e rápido
- Excelente para APIs
- Grande comunidade
- Deploy fácil no Render

### 2. Por que simular o Totvs?
- POC focada em demonstrar viabilidade
- Evita dependência do ambiente Totvs
- Permite testes isolados
- Na produção, trocaremos por chamadas reais

### 3. É seguro usar Bearer Token?
- Para POC, sim
- Para produção, recomendamos OAuth2
- Sempre use HTTPS (Render já fornece)
- Rotacione tokens periodicamente

### 4. O que acontece se o Render dormir (cold start)?
- No Free Tier, serviço dorme após 15min inatividade
- Primeira requisição pode levar 30-60s
- Considere upgrade para $7/mês (sem cold start)
- Ou use cron job para manter ativo

### 5. Posso usar em produção?
- Esta POC é para validação
- Para produção, recomendamos:
  - Plano pago do Render ($7/mês mínimo)
  - Implementar integração real com Totvs
  - Adicionar monitoramento robusto
  - Implementar retry logic e circuit breaker
  - Configurar alertas

---

## 📞 Suporte

- **Documentação:** Leia [SETUP.md](./SETUP.md) e [SALESFORCE_CONFIG.md](./SALESFORCE_CONFIG.md)
- **Issues:** Abra uma issue no GitHub
- **Contato:** LinkedIn @adricoutinho

---

**Desenvolvido com ❤️ por Adri Coutinho**
