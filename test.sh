#!/bin/bash

# Script de Testes da POC API Gateway
# Este script executa uma série de testes para validar a API

echo "🧪 ============================================"
echo "🧪 POC API Gateway - Suite de Testes"
echo "🧪 ============================================"
echo ""

# Configurações
BASE_URL="${1:-http://localhost:3000}"
TOKEN="${BEARER_TOKEN:-test_token_poc_2026}"

echo "🔧 Configurações:"
echo "   Base URL: $BASE_URL"
echo "   Token: ${TOKEN:0:10}..."
echo ""

# Contador de testes
TOTAL=0
PASSED=0
FAILED=0

# Função auxiliar para testar
test_endpoint() {
    local test_name=$1
    local method=$2
    local endpoint=$3
    local expected_status=$4
    local headers=$5
    
    TOTAL=$((TOTAL + 1))
    echo "📝 Test $TOTAL: $test_name"
    
    if [ -z "$headers" ]; then
        response=$(curl -s -w "\n%{http_code}" -X "$method" "$BASE_URL$endpoint")
    else
        response=$(curl -s -w "\n%{http_code}" -X "$method" -H "$headers" "$BASE_URL$endpoint")
    fi
    
    # Separa body e status code
    status_code=$(echo "$response" | tail -n 1)
    body=$(echo "$response" | sed '$d')
    
    if [ "$status_code" -eq "$expected_status" ]; then
        echo "   ✅ Status Code: $status_code (esperado: $expected_status)"
        PASSED=$((PASSED + 1))
        if [ ! -z "$body" ]; then
            echo "   📄 Response: $(echo $body | jq -c '.' 2>/dev/null || echo $body)"
        fi
    else
        echo "   ❌ Status Code: $status_code (esperado: $expected_status)"
        echo "   📄 Response: $body"
        FAILED=$((FAILED + 1))
    fi
    echo ""
}

# ============================================
# Testes
# ============================================

echo "🚀 Iniciando testes..."
echo ""

# Test 1: Health Check
test_endpoint \
    "Health Check (sem autenticação)" \
    "GET" \
    "/health" \
    200

# Test 2: Pedido com token válido
test_endpoint \
    "Consultar Pedido 2981977 (token válido)" \
    "GET" \
    "/pedido/2981977" \
    200 \
    "Authorization: Bearer $TOKEN"

# Test 3: Pedido com outro número
test_endpoint \
    "Consultar Pedido 1234567 (token válido)" \
    "GET" \
    "/pedido/1234567" \
    200 \
    "Authorization: Bearer $TOKEN"

# Test 4: Pedido sem token
test_endpoint \
    "Consultar Pedido sem token (erro esperado)" \
    "GET" \
    "/pedido/2981977" \
    401

# Test 5: Pedido com token inválido
test_endpoint \
    "Consultar Pedido com token inválido (erro esperado)" \
    "GET" \
    "/pedido/2981977" \
    403 \
    "Authorization: Bearer token_invalido_xyz"

# Test 6: Rota não existente
test_endpoint \
    "Rota não existente (404 esperado)" \
    "GET" \
    "/rota-invalida" \
    404

# Test 7: Pedido vazio
test_endpoint \
    "Consultar Pedido vazio (400 esperado)" \
    "GET" \
    "/pedido/" \
    404

# ============================================
# Resultados
# ============================================

echo "============================================"
echo "📊 Resultados dos Testes"
echo "============================================"
echo ""
echo "   Total de testes: $TOTAL"
echo "   ✅ Passou: $PASSED"
echo "   ❌ Falhou: $FAILED"
echo ""

if [ $FAILED -eq 0 ]; then
    echo "🎉 Todos os testes passaram com sucesso!"
    exit 0
else
    echo "⚠️  Alguns testes falharam. Revise os logs acima."
    exit 1
fi
