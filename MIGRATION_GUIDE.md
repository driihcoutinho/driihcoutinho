# 📦 Guia de Migração para Novo Repositório

## ⚠️ IMPORTANTE

Este projeto foi movido para um repositório dedicado:

**Novo repositório:** https://github.com/driihcoutinho/POC-API-GATEWAY

## 🔄 Passos para Migração

### Opção 1: Criar Novo Repositório no GitHub (Recomendado)

1. **Criar o repositório no GitHub:**
   - Acesse: https://github.com/new
   - Repository name: `POC-API-GATEWAY`
   - Description: `POC API Gateway - Middleware para integração Salesforce ↔ Totvs`
   - Visibility: Public (ou Private, conforme preferir)
   - **NÃO** inicialize com README, .gitignore ou license
   - Clique em **Create repository**

2. **Fazer push do código para o novo repositório:**

```bash
# Clone este repositório se ainda não tiver
git clone https://github.com/driihcoutinho/driihcoutinho.git
cd driihcoutinho

# Criar uma nova pasta para o projeto POC
mkdir -p /tmp/POC-API-GATEWAY
cd /tmp/POC-API-GATEWAY

# Copiar apenas os arquivos do POC (não o histórico git)
cp -r /home/runner/work/driihcoutinho/driihcoutinho/.gitignore .
cp -r /home/runner/work/driihcoutinho/driihcoutinho/.env.example .
cp -r /home/runner/work/driihcoutinho/driihcoutinho/package.json .
cp -r /home/runner/work/driihcoutinho/driihcoutinho/package-lock.json .
cp -r /home/runner/work/driihcoutinho/driihcoutinho/src .
cp -r /home/runner/work/driihcoutinho/driihcoutinho/test.sh .
cp -r /home/runner/work/driihcoutinho/driihcoutinho/SETUP.md .
cp -r /home/runner/work/driihcoutinho/driihcoutinho/SALESFORCE_CONFIG.md .
cp -r /home/runner/work/driihcoutinho/driihcoutinho/RENDER_DEPLOY.md .
cp -r /home/runner/work/driihcoutinho/driihcoutinho/POC_EXPLICACAO.md .
cp -r /home/runner/work/driihcoutinho/driihcoutinho/SUMMARY.md .

# Criar README.md para o novo repositório
cat > README.md << 'EOF'
# POC API Gateway - Salesforce ↔ Totvs

Middleware de integração entre Salesforce e Totvs usando Node.js e Express.

## 🎯 Visão Geral

Esta POC demonstra a viabilidade técnica de integração entre Salesforce e Totvs através de um middleware API Gateway, sem necessidade de refatoração do código Apex existente.

## 📚 Documentação

- **[SETUP.md](./SETUP.md)** - Guia técnico de instalação e configuração
- **[SALESFORCE_CONFIG.md](./SALESFORCE_CONFIG.md)** - Configuração passo a passo no Salesforce
- **[RENDER_DEPLOY.md](./RENDER_DEPLOY.md)** - Guia de deploy no Render
- **[POC_EXPLICACAO.md](./POC_EXPLICACAO.md)** - Explicação detalhada da arquitetura
- **[SUMMARY.md](./SUMMARY.md)** - Resumo executivo do projeto

## 🚀 Quick Start

```bash
# Instalar dependências
npm install

# Configurar variáveis de ambiente
cp .env.example .env
# Edite .env e configure BEARER_TOKEN

# Iniciar servidor
npm start

# Testar
./test.sh
```

## 🏗️ Arquitetura

```
Salesforce → API Gateway (Node.js/Express) → Totvs (Simulado)
```

## 🔐 Segurança

- ✅ Autenticação ******
- ✅ Validação de inputs
- ✅ CORS configurável
- ✅ CodeQL: 0 vulnerabilidades

## 📊 Testes

```bash
export BEARER_TOKEN=test_token_poc_2026
./test.sh
```

Resultado: 7/7 testes passando (100%)

## 👤 Autora

**Adri Coutinho**
- LinkedIn: [adricoutinho](https://www.linkedin.com/in/adricoutinho/)
- Instagram: [@driihcoutinho](https://www.instagram.com/driihcoutinho/)
- GitHub: [@driihcoutinho](https://github.com/driihcoutinho)

## 📄 Licença

MIT License
EOF

# Inicializar git
git init
git add .
git commit -m "Initial commit: POC API Gateway - Salesforce ↔ Totvs integration"

# Adicionar remote e fazer push
git remote add origin https://github.com/driihcoutinho/POC-API-GATEWAY.git
git branch -M main
git push -u origin main
```

3. **Limpar o repositório de apresentação:**

Após confirmar que tudo foi movido com sucesso para o novo repositório, você pode remover os arquivos do POC do repositório de apresentação:

```bash
cd /home/runner/work/driihcoutinho/driihcoutinho
git checkout main  # ou a branch principal

# Remover arquivos do POC
git rm -r src/
git rm package.json package-lock.json
git rm .env.example test.sh
git rm SETUP.md SALESFORCE_CONFIG.md RENDER_DEPLOY.md POC_EXPLICACAO.md SUMMARY.md MIGRATION_GUIDE.md

# Atualizar README.md para remover referência ao POC
# (edite manualmente para remover a linha do POC)

git commit -m "Move POC to dedicated repository"
git push origin main
```

### Opção 2: Usar GitHub CLI (gh)

Se você tem o GitHub CLI instalado:

```bash
# Criar o repositório
gh repo create POC-API-GATEWAY --public --description "POC API Gateway - Middleware para integração Salesforce ↔ Totvs"

# Seguir os mesmos passos da Opção 1 para copiar e fazer push
```

## 📋 Checklist de Migração

- [ ] Criar repositório `POC-API-GATEWAY` no GitHub
- [ ] Copiar arquivos do POC para pasta temporária
- [ ] Criar README.md para o novo repositório
- [ ] Inicializar git e fazer commit
- [ ] Adicionar remote e fazer push
- [ ] Verificar que tudo está funcionando no novo repositório
- [ ] Atualizar Render para apontar para o novo repositório (se já deployado)
- [ ] Limpar arquivos do POC do repositório de apresentação
- [ ] Atualizar README.md do repositório de apresentação

## 🔄 Atualizar Deploy no Render (se aplicável)

Se você já fez deploy no Render, você precisará atualizar a configuração:

1. Acesse seu serviço no Render
2. Vá em **Settings**
3. Em **Build & Deploy** > **Repository**, clique em **Connect a repository**
4. Selecione o novo repositório `POC-API-GATEWAY`
5. Salve as alterações
6. Render fará um novo deploy automaticamente

## ✅ Verificação

Após a migração, teste:

```bash
# Clone o novo repositório
git clone https://github.com/driihcoutinho/POC-API-GATEWAY.git
cd POC-API-GATEWAY

# Instale e teste
npm install
cp .env.example .env
# Configure BEARER_TOKEN no .env
npm start

# Em outro terminal
export BEARER_TOKEN=test_token_poc_2026
./test.sh
```

## 📞 Suporte

Se encontrar problemas durante a migração, consulte a documentação ou abra uma issue no novo repositório.
