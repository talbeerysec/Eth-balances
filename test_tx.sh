#!/bin/bash

# Test transaction count for specific address
ADDRESS="0xFc4a4858bafef54D1b1d7697bfb5c52F4c166976"
BASE_URL="https://api.etherscan.io/api"

# Check if API key is set
if [ -z "${ETHERSCAN_API_KEY:-}" ]; then
    echo "❌ ETHERSCAN_API_KEY environment variable is required"
    echo "💡 Set it with: export ETHERSCAN_API_KEY='your_key_here'"
    exit 1
fi

echo "🔍 Testing transaction count for address: $ADDRESS"
echo "📡 API Key: ${ETHERSCAN_API_KEY:0:8}...${ETHERSCAN_API_KEY: -4}"

# Test transaction count API
txcount_url="${BASE_URL}?module=account&action=txlist&address=${ADDRESS}&startblock=0&endblock=99999999&page=1&offset=10000&sort=asc&apikey=${ETHERSCAN_API_KEY}"

echo "🌐 Making API call..."
txcount_response=$(curl -s --max-time 30 "$txcount_url")

echo "📝 Raw response (first 500 chars):"
echo "$txcount_response" | head -c 500
echo ""
echo ""

echo "🔍 Checking response status..."
if echo "$txcount_response" | grep -q '"status":"1"'; then
    echo "✅ API call successful"
    
    echo "🔢 Counting transactions..."
    tx_count=$(echo "$txcount_response" | grep -o '"hash":"[^"]*"' | wc -l | tr -d ' ')
    echo "📊 Transaction count: $tx_count"
    
    if [ "$tx_count" = "10000" ]; then
        echo "⚠️ Reached limit of 10,000 transactions (there may be more)"
    fi
    
    echo ""
    echo "🔍 Sample transaction hashes found:"
    echo "$txcount_response" | grep -o '"hash":"[^"]*"' | head -5
    
else
    echo "❌ API call failed"
    echo "📝 Error message:"
    echo "$txcount_response" | grep -o '"message":"[^"]*"' | sed 's/"message":"//' | sed 's/"//'
fi