# Guia de Deploy no Render

Este guia detalha como fazer o deploy da POC API Gateway no Render (Free Tier).

## 📋 Pré-requisitos

- Conta GitHub (o código já está no repositório)
- Conta no Render (criar em https://render.com - é grátis)

## 🚀 Passo a Passo do Deploy

### 1. Criar Conta no Render

1. Acesse https://render.com
2. Clique em **"Get Started"**
3. Faça login com sua conta GitHub
4. Autorize o Render a acessar seus repositórios

### 2. Criar Novo Web Service

1. No Dashboard do Render, clique em **"New +"**
2. Selecione **"Web Service"**
3. Conecte seu repositório:
   - Se for a primeira vez, clique em **"Connect GitHub"**
   - Autorize o Render a acessar o repositório `driihcoutinho/driihcoutinho`
   - Ou configure para "All repositories" se preferir

### 3. Configurar o Web Service

Preencha os campos da seguinte forma:

**Basic Configuration:**
- **Name:** `poc-api-salesforce-totvs` (ou outro nome de sua preferência)
- **Region:** Escolha a mais próxima (ex: `Ohio (US East)`)
- **Branch:** `copilot/create-middleware-poc` (ou `main` se já foi merged)
- **Root Directory:** deixe vazio (o código está na raiz)
- **Environment:** `Node`
- **Build Command:** `npm install`
- **Start Command:** `npm start`

**Instance Type:**
- Selecione **"Free"** (suficiente para POC)

### 4. Configurar Environment Variables

**IMPORTANTE:** Antes de fazer deploy, configure as variáveis de ambiente:

1. Na seção **"Environment Variables"**, clique em **"Add Environment Variable"**
2. Adicione as seguintes variáveis:

```
BEARER_TOKEN = [gere um token seguro - veja abaixo]
NODE_ENV = production
PORT = (deixe vazio - o Render define automaticamente)
```

#### Como Gerar um Token Seguro

Use um destes métodos:

**Opção 1: OpenSSL (Linux/Mac)**
```bash
openssl rand -base64 32
```

**Opção 2: Node.js**
```bash
node -e "console.log(require('crypto').randomBytes(32).toString('base64'))"
```

**Opção 3: Site Gerador**
- Acesse: https://www.uuidgenerator.net/api/guid
- Copie o UUID gerado

**IMPORTANTE:** Salve esse token! Você precisará dele para configurar no Salesforce.

### 5. Deploy

1. Revise todas as configurações
2. Clique em **"Create Web Service"**
3. O Render irá:
   - Fazer clone do repositório
   - Instalar dependências (`npm install`)
   - Iniciar o servidor (`npm start`)

**Tempo estimado:** 2-5 minutos

### 6. Obter a URL do Serviço

Após o deploy ser concluído:

1. A URL será exibida no topo da página
2. Formato: `https://poc-api-salesforce-totvs.onrender.com`
3. **Copie essa URL** - você precisará dela para configurar no Salesforce

### 7. Testar o Deploy

Use o terminal ou Postman para testar:

```bash
# Test 1: Health Check (sem autenticação)
curl https://poc-api-salesforce-totvs.onrender.com/health

# Resposta esperada:
# {
#   "status": "online",
#   "timestamp": "...",
#   "servico": "POC API Gateway - Salesforce ↔ Totvs",
#   "versao": "1.0.0"
# }

# Test 2: Consultar Pedido (com autenticação)
curl -H "Authorization: Bearer SEU_TOKEN_AQUI" \
     https://poc-api-salesforce-totvs.onrender.com/pedido/2981977

# Resposta esperada:
# {
#   "OrdemVenda": "2981977",
#   "ItemOv": "000010",
#   ...
# }
```

## ⚙️ Configurações Avançadas

### Auto-Deploy

O Render pode fazer deploy automático quando você faz push no GitHub:

1. No dashboard do serviço, vá em **"Settings"**
2. Em **"Build & Deploy"**, ative **"Auto-Deploy"**
3. Escolha a branch (ex: `main` ou `copilot/create-middleware-poc`)

Agora, cada push nessa branch irá disparar um novo deploy automaticamente.

### Logs

Para visualizar os logs do servidor:

1. No dashboard do serviço, clique em **"Logs"**
2. Você verá todos os logs do console, incluindo:
   - Requisições recebidas (📥)
   - Consultas ao adapter (🔍)
   - Respostas enviadas (📤)
   - Erros (❌)

### Monitoramento

O Render oferece métricas básicas gratuitamente:

1. Vá em **"Metrics"** no dashboard
2. Visualize:
   - CPU usage
   - Memory usage
   - HTTP requests
   - Response times

### Health Checks

O Render pode fazer health checks automáticos:

1. Vá em **"Settings"** > **"Health & Alerts"**
2. Configure:
   - **Health Check Path:** `/health`
   - **Timeout:** 30 segundos

## 🔄 Atualizar o Deploy

Para atualizar o código em produção:

### Opção 1: Push para GitHub (se Auto-Deploy ativado)
```bash
git add .
git commit -m "Atualização XYZ"
git push origin copilot/create-middleware-poc
```

O Render fará deploy automaticamente.

### Opção 2: Deploy Manual
1. No dashboard do Render, clique em **"Manual Deploy"**
2. Escolha a branch
3. Clique em **"Deploy"**

## ⚠️ Limitações do Free Tier

O plano gratuito do Render tem algumas limitações:

- ⏱️ **Cold Starts:** Após 15 minutos de inatividade, o serviço "dorme"
  - Primeira requisição após dormir pode levar 30-60 segundos
  - Salesforce pode ter timeout - considere retry logic
  
- 💾 **750 horas/mês:** Suficiente para POC, mas serviço dorme se não usado

- 🚫 **Sem Custom Domain no Free Tier:** Use a URL fornecida pelo Render

### Solução para Cold Starts (Opcional)

Se cold starts forem um problema, você pode:

1. **Fazer upgrade para Starter Plan** ($7/mês)
   - Sem cold starts
   - Serviço sempre ativo
   
2. **Usar cron job externo** para manter ativo:
   ```bash
   # Cron job que chama /health a cada 10 minutos
   */10 * * * * curl https://poc-api-salesforce-totvs.onrender.com/health
   ```

## 📝 Checklist Pós-Deploy

Após deploy bem-sucedido, verifique:

- [ ] URL do serviço obtida e testada
- [ ] Bearer Token gerado e salvo em local seguro
- [ ] Endpoint `/health` respondendo
- [ ] Endpoint `/pedido/:ordemVenda` respondendo com autenticação
- [ ] Logs aparecendo corretamente no dashboard
- [ ] Named Credential no Salesforce atualizada com a nova URL

## 🆘 Troubleshooting

### Deploy Falhou

**Erro: "Build failed"**
- Verifique os logs de build
- Confirme que `package.json` está correto
- Confirme que `npm install` funciona localmente

**Erro: "Start failed"**
- Verifique se `npm start` funciona localmente
- Confirme que a porta está configurada corretamente (use `process.env.PORT`)

### Serviço Não Responde

1. Verifique se o deploy foi concluído com sucesso
2. Veja os logs para identificar erros
3. Teste o endpoint `/health` primeiro
4. Confirme que as variáveis de ambiente estão configuradas

### Cold Start Muito Lento

- Primeira requisição após inatividade é lenta no Free Tier
- Considere upgrade para Starter Plan
- Ou use cron job para manter ativo

## 🔐 Segurança

### Boas Práticas:

1. **Nunca commite o .env** no repositório
   - O `.gitignore` já está configurado para isso
   
2. **Use tokens fortes**
   - Mínimo 32 caracteres
   - Caracteres aleatórios
   
3. **Rotacione tokens periodicamente**
   - Atualize no Render
   - Atualize no Salesforce
   
4. **Monitore os logs**
   - Procure por tentativas de autenticação falhas
   - Investigue padrões suspeitos

## 📞 Suporte

- **Documentação Render:** https://render.com/docs
- **Community Forum:** https://community.render.com
- **Status Page:** https://status.render.com

## 🎯 Próximos Passos

Após deploy bem-sucedido:

1. **Configure o Salesforce** - Siga o guia [SALESFORCE_CONFIG.md](./SALESFORCE_CONFIG.md)
2. **Teste a integração** - Execute callouts do Salesforce para a POC
3. **Monitore performance** - Acompanhe métricas e logs
4. **Avalie resultados** - Decida sobre próximos passos

---

**Deploy realizado com sucesso?** 🎉

Agora siga o guia [SALESFORCE_CONFIG.md](./SALESFORCE_CONFIG.md) para configurar a integração no Salesforce.
