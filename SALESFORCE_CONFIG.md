# Configuração no Salesforce

Este guia detalha o que precisa ser configurado no Salesforce para integrar com a POC API Gateway.

## 📋 Pré-requisitos

- Acesso administrativo ao Salesforce
- Código Apex existente para integração com Totvs
- Named Credential já configurada (ou permissão para criar uma nova)

## 🔧 Passos de Configuração

### 1. Atualizar ou Criar Named Credential

A **única alteração necessária** é apontar a Named Credential para a URL da POC no Render.

#### Acessar Named Credentials:
1. No Salesforce, vá em **Setup** (Configuração)
2. No Quick Find, busque por **Named Credentials**
3. Clique em **Named Credentials** na seção Security

#### Opção A: Atualizar Named Credential Existente

Se você já tem uma Named Credential configurada (ex: `TotvsEndpoint`):

1. Clique em **Edit** ao lado da Named Credential existente
2. Atualize o campo **URL** para:
   ```
   https://poc-api-tru.onrender.com
   ```
3. Mantenha todas as outras configurações como estão
4. Clique em **Save**

#### Opção B: Criar Nova Named Credential

Se você precisa criar uma nova Named Credential para a POC:

1. Clique em **New Named Credential**
2. Preencha os campos:

   **Named Credential Details:**
   - **Label:** `Totvs POC Endpoint`
   - **Name:** `TotvsEndpoint` (ou o nome que seu código Apex já usa)
   - **URL:** `https://poc-api-tru.onrender.com`

   **Identity Type:**
   - Selecione: **Named Principal**

   **Authentication Protocol:**
   - Selecione: **No Authentication** (a autenticação Bearer será configurada no código)

   **Callout Options:**
   - ✅ **Generate Authorization Header** (desmarque esta opção)
   - ✅ **Allow Merge Fields in HTTP Header**
   - ✅ **Allow Merge Fields in HTTP Body**

3. Clique em **Save**

### 2. Configurar Autenticação Bearer Token no Apex

Como a Named Credential não gerencia o Bearer Token automaticamente, você precisa adicioná-lo no código Apex.

#### No seu código Apex de callout:

```apex
// Exemplo de código Apex existente
HttpRequest req = new HttpRequest();
req.setEndpoint('callout:TotvsEndpoint/pedido/2981977');
req.setMethod('GET');

// ADICIONE ESTA LINHA - Bearer Token
req.setHeader('Authorization', 'Bearer seu_token_secreto_aqui');

// Continue com o resto do código...
HttpResponse res = new Http().send(req);
```

**IMPORTANTE:** Substitua `seu_token_secreto_aqui` pelo token configurado na variável de ambiente `BEARER_TOKEN` da POC.

### 3. Configurar Remote Site Settings

Para permitir que o Salesforce faça callouts para a URL do Render:

1. No Setup, busque por **Remote Site Settings**
2. Clique em **New Remote Site**
3. Preencha:
   - **Remote Site Name:** `TotvsAPI_POC`
   - **Remote Site URL:** `https://poc-api-tru.onrender.com`
   - ✅ **Active**
   - Descrição: `POC API Gateway para integração Totvs`
4. Clique em **Save**

### 4. Verificar Código Apex Existente

O código Apex **NÃO precisa ser alterado** além da adição do header de autenticação.

#### Estrutura esperada do código:

```apex
public class TotvsIntegrationService {
    
    public static Map<String, Object> consultarPedido(String ordemVenda) {
        HttpRequest req = new HttpRequest();
        
        // Named Credential aponta para a POC
        req.setEndpoint('callout:TotvsEndpoint/pedido/' + ordemVenda);
        req.setMethod('GET');
        
        // Bearer Token para autenticação
        req.setHeader('Authorization', 'Bearer seu_token_secreto_aqui');
        req.setHeader('Content-Type', 'application/json');
        
        HttpResponse res = new Http().send(req);
        
        if (res.getStatusCode() == 200) {
            // Parse da resposta JSON
            Map<String, Object> resultado = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            return resultado;
        } else {
            throw new CalloutException('Erro ao consultar pedido: ' + res.getBody());
        }
    }
}
```

### 5. Mapear Campos de Resposta

A resposta da POC retorna os seguintes campos:

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

Certifique-se de que seu código Apex mapeia esses campos corretamente para os objetos Salesforce (Account/Order).

### 6. Testar a Integração

#### Teste Manual no Developer Console:

1. Abra o **Developer Console**
2. Vá em **Debug** > **Open Execute Anonymous Window**
3. Execute o seguinte código:

```apex
Map<String, Object> pedido = TotvsIntegrationService.consultarPedido('2981977');
System.debug('Pedido retornado: ' + pedido);
System.debug('Status: ' + pedido.get('Status'));
System.debug('Valor Total: ' + pedido.get('ValorTotal'));
```

4. Verifique os logs para confirmar que os dados foram retornados corretamente

#### Verificar Logs:

1. No Developer Console, vá em **Logs**
2. Procure por mensagens de debug com os dados do pedido
3. Confirme que não há erros de callout

### 7. Configurações de Segurança (Opcional)

#### Gerenciar Token de Forma Segura

Para produção, é recomendado armazenar o Bearer Token de forma segura:

**Opção 1: Custom Metadata Type**
1. Crie um Custom Metadata Type chamado `API_Configuration__mdt`
2. Adicione um campo `Bearer_Token__c` (tipo Text)
3. Crie um registro com o token
4. No Apex, recupere: `API_Configuration__mdt.getInstance('Totvs').Bearer_Token__c`

**Opção 2: Custom Settings**
1. Crie um Custom Setting hierárquico chamado `API_Config__c`
2. Adicione um campo `Bearer_Token__c`
3. Configure o valor no Setup
4. No Apex, recupere: `API_Config__c.getInstance().Bearer_Token__c`

## 🧪 Testando a POC

### Teste 1: Health Check (sem autenticação)

```bash
curl https://poc-api-tru.onrender.com/health
```

Resposta esperada:
```json
{
  "status": "online",
  "timestamp": "2026-02-12T12:00:00.000Z",
  "servico": "POC API Gateway - Salesforce ↔ Totvs",
  "versao": "1.0.0"
}
```

### Teste 2: Consultar Pedido (com autenticação)

```bash
curl -H "Authorization: Bearer seu_token_secreto_aqui" \
     https://poc-api-tru.onrender.com/pedido/2981977
```

Resposta esperada:
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

## ⚠️ Importante

1. **Nenhuma mudança estrutural no Apex** - Apenas atualizar a URL da Named Credential
2. **Bearer Token** - Deve ser o mesmo configurado na variável de ambiente da POC
3. **Backward Compatible** - O formato de resposta é idêntico ao que o Salesforce espera
4. **Logs** - Todos os callouts são logados na POC para debugging

## 📞 Troubleshooting

### Erro: "Unauthorized endpoint"
- Verifique se o Remote Site Setting está configurado e ativo

### Erro: 401 Token não fornecido
- Confirme que o header `Authorization: Bearer token` está sendo enviado

### Erro: 403 Token inválido
- Verifique se o token no Apex corresponde ao token configurado na POC

### Erro: Callout timeout
- A POC no Render pode levar alguns segundos para "acordar" no primeiro acesso (cold start)
- Tente novamente após 10-15 segundos

## 🎯 Próximos Passos

Após validar a POC:
1. Avaliar performance e tempo de resposta
2. Decidir sobre migração completa
3. Implementar integração real com Totvs (substituindo o adapter simulado)
4. Adicionar monitoramento e alertas
5. Implementar rate limiting e cache se necessário
