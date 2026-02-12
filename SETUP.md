# POC API Gateway - Salesforce ↔ Totvs

## 🎯 Visão Geral

Esta é uma Prova de Conceito (POC) de um middleware API Gateway que atua como intermediário entre o Salesforce e o sistema Totvs. O objetivo é demonstrar a viabilidade técnica de uma integração sem necessidade de refatoração estrutural no Salesforce.

## 📐 Arquitetura

### Arquitetura Atual (Produção)
```
Salesforce → Skyone → Totvs
```

### Arquitetura POC (Demonstração)
```
Salesforce → API Gateway (Node.js - Render) → Totvs Simulado
```

**Mudança necessária:** Apenas atualizar a URL da Named Credential no Salesforce.

## 🔑 Características Principais

- ✅ **Zero mudanças no código Apex** existente
- ✅ **Compatibilidade total** com payload atual
- ✅ **Autenticação** via Bearer Token
- ✅ **Logs estruturados** de todas as requisições
- ✅ **Simulação Totvs** para validação do conceito
- ✅ **Pronto para deploy** no Render (Free Tier)

## 🛠️ Stack Tecnológica

- **Runtime:** Node.js 18+
- **Framework:** Express.js
- **Deploy:** Render
- **Autenticação:** Bearer Token
- **Configuração:** Environment Variables

## 📁 Estrutura do Projeto

```
poc-api-gateway-salesforce-totvs/
├── src/
│   ├── server.js              # Servidor Express principal
│   ├── routes.js              # Definição de rotas/endpoints
│   ├── middleware/
│   │   └── auth.js            # Autenticação Bearer Token + Logging
│   └── services/
│       └── totvsAdapter.js    # Adapter de simulação Totvs
├── package.json               # Dependências do projeto
├── .env.example              # Exemplo de variáveis de ambiente
├── .gitignore                # Arquivos ignorados pelo Git
├── SETUP.md                  # Guia de instalação e configuração
├── SALESFORCE_CONFIG.md      # Guia de configuração Salesforce
└── README.md                 # Este arquivo
```

## 🚀 Quick Start

### 1. Instalação

```bash
# Clone o repositório
git clone https://github.com/driihcoutinho/POC-API-GATEWAY.git
cd POC-API-GATEWAY

# Instale as dependências
npm install

# Configure as variáveis de ambiente
cp .env.example .env
# Edite o arquivo .env e configure o BEARER_TOKEN
```

### 2. Configuração

Edite o arquivo `.env`:

```env
PORT=3000
BEARER_TOKEN=seu_token_seguro_aqui
NODE_ENV=development
```

### 3. Executar Localmente

```bash
# Modo desenvolvimento (com watch mode)
npm run dev

# Modo produção
npm start
```

O servidor estará disponível em: `http://localhost:3000`

## 📡 Endpoints Disponíveis

### Health Check
```http
GET /health
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

### Consultar Pedido
```http
GET /pedido/:ordemVenda
Authorization: Bearer {token}
```

**Exemplo:**
```bash
curl -H "Authorization: Bearer seu_token_aqui" \
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

## 🔐 Autenticação

A API utiliza autenticação Bearer Token:

```http
Authorization: Bearer seu_token_secreto_aqui
```

**Respostas de erro:**

- `401 Unauthorized` - Token não fornecido
- `403 Forbidden` - Token inválido

## 🌐 Deploy no Render

### Passo a Passo:

1. **Criar conta no Render:** https://render.com

2. **Criar novo Web Service:**
   - Conecte seu repositório GitHub
   - Selecione o repositório `driihcoutinho/driihcoutinho`
   - Configurações:
     - **Name:** `poc-api-salesforce-totvs`
     - **Environment:** `Node`
     - **Build Command:** `npm install`
     - **Start Command:** `npm start`
     - **Plan:** `Free`

3. **Configurar Environment Variables:**
   - `BEARER_TOKEN`: seu_token_seguro_gerado
   - `NODE_ENV`: `production`

4. **Deploy:**
   - O Render fará deploy automaticamente
   - URL gerada: `https://poc-api-gateway.onrender.com`

5. **Testar:**
   ```bash
   curl https://poc-api-gateway.onrender.com/health
   ```

## 🔧 Configuração no Salesforce

Consulte o arquivo [SALESFORCE_CONFIG.md](./SALESFORCE_CONFIG.md) para instruções detalhadas sobre:

- Como atualizar a Named Credential
- Como configurar Remote Site Settings
- Como adicionar autenticação Bearer no código Apex
- Exemplos de código e testes

## 📊 Logs e Monitoramento

A API registra automaticamente:

- ✅ Todas as requisições recebidas
- ✅ Tempo de resposta
- ✅ Status codes
- ✅ Erros e exceções
- ✅ Consultas ao adapter Totvs

**Exemplo de log:**

```
📥 [REQUEST] {
  timestamp: '2026-02-12T12:00:00.000Z',
  method: 'GET',
  url: '/pedido/2981977',
  userAgent: 'Salesforce.com HTTP Client'
}

🔍 [TOTVS ADAPTER] Consultando pedido: 2981977
✅ [TOTVS ADAPTER] Pedido encontrado: { OrdemVenda: '2981977', Status: 'Faturado' }

📤 [RESPONSE] {
  timestamp: '2026-02-12T12:00:00.123Z',
  method: 'GET',
  url: '/pedido/2981977',
  statusCode: 200,
  duration: '123ms'
}
```

## 🧪 Testando a API

### Com cURL:

```bash
# Health check
curl http://localhost:3000/health

# Consultar pedido (com token)
curl -H "Authorization: Bearer seu_token" \
     http://localhost:3000/pedido/2981977

# Teste de erro - sem token
curl http://localhost:3000/pedido/2981977

# Teste de erro - token inválido
curl -H "Authorization: Bearer token_errado" \
     http://localhost:3000/pedido/2981977
```

### Com Postman:

1. **GET** `http://localhost:3000/pedido/2981977`
2. Aba **Headers:**
   - Key: `Authorization`
   - Value: `Bearer seu_token_aqui`
3. Enviar request

## 🔄 Fluxo de Integração

```
1. Salesforce executa callout
   ↓
2. Named Credential aponta para API Gateway
   ↓
3. API valida Bearer Token
   ↓
4. API consulta adapter Totvs (simulado)
   ↓
5. Adapter retorna dados do pedido
   ↓
6. API retorna resposta para Salesforce
   ↓
7. Apex processa resposta normalmente
```

## 🎓 Conceitos Demonstrados

Esta POC demonstra:

1. **Desacoplamento:** Salesforce não depende diretamente do Totvs
2. **Flexibilidade:** Mudança de middleware sem alterar endpoints
3. **Observabilidade:** Logs centralizados de todas as integrações
4. **Segurança:** Autenticação via Bearer Token
5. **Escalabilidade:** Arquitetura preparada para crescimento

## 📝 Próximos Passos

Para transformar esta POC em produção:

1. **Implementar integração real com Totvs**
   - Substituir `totvsAdapter.js` simulado por chamadas HTTP reais
   - Implementar tratamento de erros específicos do Totvs
   - Adicionar retry logic e circuit breaker

2. **Adicionar mais endpoints**
   - Criar pedido
   - Atualizar pedido
   - Consultar estoque
   - etc.

3. **Melhorias de segurança**
   - Rate limiting
   - IP whitelist
   - OAuth2 em vez de Bearer Token simples
   - Criptografia de dados sensíveis

4. **Monitoramento avançado**
   - Integração com New Relic, DataDog ou similar
   - Alertas automáticos
   - Dashboards de métricas

5. **Performance**
   - Implementar cache (Redis)
   - Connection pooling
   - Otimização de queries

## 🤝 Contribuindo

Esta é uma POC. Para sugestões ou melhorias:

1. Fork o projeto
2. Crie uma branch (`git checkout -b feature/melhoria`)
3. Commit suas mudanças (`git commit -m 'Adiciona melhoria X'`)
4. Push para a branch (`git push origin feature/melhoria`)
5. Abra um Pull Request

## 📄 Licença

MIT License - veja o arquivo LICENSE para detalhes

## 👤 Autora

**Adri Coutinho**

- Instagram: [@driihcoutinho](https://www.instagram.com/driihcoutinho/)
- LinkedIn: [Adri Coutinho](https://www.linkedin.com/in/adricoutinho/)
- GitHub: [@driihcoutinho](https://github.com/driihcoutinho)

## 📞 Suporte

Para dúvidas ou problemas:

1. Consulte a [documentação de setup](./SETUP.md)
2. Consulte a [configuração Salesforce](./SALESFORCE_CONFIG.md)
3. Abra uma issue no GitHub
4. Entre em contato via LinkedIn

---

**Desenvolvido com ❤️ para demonstrar viabilidade técnica de integração Salesforce ↔ Totvs**
