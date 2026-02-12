#!/bin/bash

# Script para facilitar a migração do POC para novo repositório
# Execute este script para criar uma estrutura limpa do projeto POC

echo "🚀 ================================================"
echo "🚀 Migração POC API Gateway"
echo "🚀 ================================================"
echo ""

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script do diretório raiz do projeto"
    exit 1
fi

# Criar diretório temporário
TEMP_DIR="$HOME/POC-API-GATEWAY-temp"
echo "📁 Criando diretório temporário: $TEMP_DIR"
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"

# Copiar arquivos necessários
echo "📦 Copiando arquivos do POC..."

cp .gitignore "$TEMP_DIR/" 2>/dev/null || echo "⚠️  .gitignore não encontrado"
cp .env.example "$TEMP_DIR/"
cp package.json "$TEMP_DIR/"
cp package-lock.json "$TEMP_DIR/"
cp test.sh "$TEMP_DIR/"
chmod +x "$TEMP_DIR/test.sh"

# Copiar diretório src
cp -r src "$TEMP_DIR/"

# Copiar documentação
cp SETUP.md "$TEMP_DIR/"
cp SALESFORCE_CONFIG.md "$TEMP_DIR/"
cp RENDER_DEPLOY.md "$TEMP_DIR/"
cp POC_EXPLICACAO.md "$TEMP_DIR/"
cp SUMMARY.md "$TEMP_DIR/"

# Criar README.md específico para o novo repositório
cat > "$TEMP_DIR/README.md" << 'EOF'
# POC API Gateway - Salesforce ↔ Totvs

Middleware de integração entre Salesforce e Totvs usando Node.js e Express.

## 🎯 Visão Geral

Esta POC demonstra a viabilidade técnica de integração entre Salesforce e Totvs através de um middleware API Gateway, sem necessidade de refatoração do código Apex existente.

### Arquitetura

```
Salesforce → API Gateway (Node.js/Express) → Totvs (Simulado)
```

**Mudança necessária no Salesforce:** Apenas atualizar a URL da Named Credential.

## 📚 Documentação Completa

- **[SETUP.md](./SETUP.md)** - Guia técnico de instalação e configuração local
- **[SALESFORCE_CONFIG.md](./SALESFORCE_CONFIG.md)** - Configuração passo a passo no Salesforce
- **[RENDER_DEPLOY.md](./RENDER_DEPLOY.md)** - Guia completo de deploy no Render
- **[POC_EXPLICACAO.md](./POC_EXPLICACAO.md)** - Explicação detalhada da arquitetura (PT-BR)
- **[SUMMARY.md](./SUMMARY.md)** - Resumo executivo e próximos passos

## 🚀 Quick Start

```bash
# 1. Instalar dependências
npm install

# 2. Configurar variáveis de ambiente
cp .env.example .env
# Edite .env e configure BEARER_TOKEN com um token seguro

# 3. Iniciar servidor
npm start

# 4. Testar (em outro terminal)
export BEARER_TOKEN=seu_token_aqui
./test.sh
```

## 🎯 Endpoints

### Health Check
```bash
GET /health
```
Sem autenticação. Retorna status do servidor.

### Consultar Pedido
```bash
GET /pedido/:ordemVenda
Authorization: Bearer SEU_TOKEN
```
Retorna dados do pedido (simulado nesta POC).

## 🔐 Segurança

- ✅ Autenticação Bearer Token obrigatória
- ✅ Validação de inputs (alfanumérico, max 20 caracteres)
- ✅ CORS configurável via variável de ambiente
- ✅ CodeQL: 0 vulnerabilidades detectadas
- ✅ Code Review aprovado

## 🧪 Testes

```bash
export BEARER_TOKEN=test_token_poc_2026
./test.sh
```

**Resultado:** 7/7 testes passando (100%)

## 📊 Tecnologias

- Node.js 18+
- Express.js
- dotenv para variáveis de ambiente

## 🌐 Deploy

### Render (Recomendado)

Siga o guia completo em [RENDER_DEPLOY.md](./RENDER_DEPLOY.md).

**Resumo:**
1. Criar conta no Render
2. Conectar este repositório
3. Configurar variáveis de ambiente (BEARER_TOKEN)
4. Deploy automático

**Custo:** Grátis (Free Tier) ou $7/mês (Starter - sem cold starts)

## 📝 Configuração Salesforce

Siga o guia detalhado em [SALESFORCE_CONFIG.md](./SALESFORCE_CONFIG.md).

**Resumo:**
1. Atualizar Named Credential URL para a URL do Render
2. Configurar Remote Site Settings
3. Adicionar header de autenticação no código Apex

**Mudança no Apex:**
```apex
req.setHeader('Authorization', 'Bearer SEU_TOKEN');
```

## 🎓 O que Esta POC Demonstra

1. **Desacoplamento** - Salesforce independente do Totvs
2. **Flexibilidade** - Troca de middleware sem refatorar Apex
3. **Observabilidade** - Logs centralizados
4. **Segurança** - Autenticação e validação
5. **Escalabilidade** - Pronto para adicionar cache, retry logic, etc.

## 📈 Próximos Passos

- [ ] Implementar integração real com Totvs (substituir adapter simulado)
- [ ] Adicionar mais endpoints (criar pedido, atualizar, etc.)
- [ ] Implementar retry logic e circuit breaker
- [ ] Adicionar cache com Redis
- [ ] Migrar para OAuth2

## 👤 Autora

**Adri Coutinho**
- LinkedIn: [adricoutinho](https://www.linkedin.com/in/adricoutinho/)
- Instagram: [@driihcoutinho](https://www.instagram.com/driihcoutinho/)
- GitHub: [@driihcoutinho](https://github.com/driihcoutinho)

## 📄 Licença

MIT License

---

**Desenvolvido com ❤️ - Fevereiro 2026**
EOF

echo "✅ Arquivos copiados com sucesso!"
echo ""
echo "📍 Localização: $TEMP_DIR"
echo ""
echo "🔄 Próximos passos:"
echo ""
echo "1. Criar o repositório no GitHub:"
echo "   https://github.com/new"
echo "   Nome: POC-API-GATEWAY"
echo ""
echo "2. Executar os comandos:"
echo ""
echo "   cd $TEMP_DIR"
echo "   git init"
echo "   git add ."
echo "   git commit -m \"Initial commit: POC API Gateway\""
echo "   git branch -M main"
echo "   git remote add origin https://github.com/driihcoutinho/POC-API-GATEWAY.git"
echo "   git push -u origin main"
echo ""
echo "3. Verificar que tudo funcionou:"
echo "   https://github.com/driihcoutinho/POC-API-GATEWAY"
echo ""
echo "================================================"
echo "✨ Migração preparada com sucesso!"
echo "================================================"
