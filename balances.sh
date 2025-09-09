#!/bin/bash

# Ethereum Balance Checker Script
# Uses Etherscan API to check balances for multiple addresses
# Requires ETHERSCAN_API_KEY environment variable

set -e  # Exit on any error

# Configuration
API_KEY="${ETHERSCAN_API_KEY}"
BASE_URL="https://api.etherscan.io/api"
OUTPUT_FILE="ethereum_balances_$(date +%Y%m%d_%H%M%S).csv"
TEMP_DIR="/tmp/eth_balance_check_$$"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Create temporary directory
mkdir -p "$TEMP_DIR"

# Function to log with timestamp
log() {
    echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Function to convert Wei to ETH
wei_to_eth() {
    local wei=$1
    # Use bc for precise decimal calculation
    if command -v bc >/dev/null 2>&1; then
        echo "scale=6; $wei / 1000000000000000000" | bc
    else
        # Fallback to awk if bc is not available
        echo "$wei" | awk '{printf "%.6f", $1/1000000000000000000}'
    fi
}

# Function to check single address balance and transaction count
check_balance() {
    local label=$1
    local address=$2
    local balance_url="${BASE_URL}?module=account&action=balance&address=${address}&tag=latest&apikey=${API_KEY}"
    local txcount_url="${BASE_URL}?module=account&action=txlist&address=${address}&startblock=0&endblock=99999999&page=1&offset=10000&sort=asc&apikey=${API_KEY}"
    
    log "${BLUE}Checking ${label}: ${address}${NC}"
    
    # Make balance API request with timeout
    local balance_response
    if ! balance_response=$(curl -s --max-time 30 "$balance_url"); then
        log "${RED}❌ ${label}: Network error (balance)${NC}"
        echo "$label,$address,ERROR,ERROR,Network error,https://etherscan.io/address/$address" >> "$TEMP_DIR/results.csv"
        return 1
    fi
    
    # Make transaction count API request with timeout
    local txcount_response
    if ! txcount_response=$(curl -s --max-time 30 "$txcount_url"); then
        log "${RED}❌ ${label}: Network error (tx count)${NC}"
        echo "$label,$address,ERROR,ERROR,Network error,https://etherscan.io/address/$address" >> "$TEMP_DIR/results.csv"
        return 1
    fi
    
    # Parse balance JSON response
    local balance_status
    local balance_result
    local balance_message
    
    # Extract balance values using grep and sed (works without jq)
    balance_status=$(echo "$balance_response" | grep -o '"status":"[^"]*"' | sed 's/"status":"//' | sed 's/"//')
    balance_result=$(echo "$balance_response" | grep -o '"result":"[^"]*"' | sed 's/"result":"//' | sed 's/"//')
    balance_message=$(echo "$balance_response" | grep -o '"message":"[^"]*"' | sed 's/"message":"//' | sed 's/"//')
    
    # Parse transaction count JSON response  
    local tx_count_decimal
    # Count the number of transactions in the result array
    if echo "$txcount_response" | grep -q '"status":"1"'; then
        # Count transactions by counting occurrences of transaction hashes
        tx_count_decimal=$(echo "$txcount_response" | grep -o '"hash":"[^"]*"' | wc -l | tr -d ' ')
        # If we got exactly 10000 results (our limit), there might be more
        if [ "$tx_count_decimal" = "10000" ]; then
            tx_count_decimal="10000+"
        fi
    else
        tx_count_decimal="0"
    fi
    
    if [ "$balance_status" = "1" ]; then
        # Success - convert Wei to ETH
        local eth_balance
        eth_balance=$(wei_to_eth "$balance_result")
        
        if (( $(echo "$eth_balance > 0" | bc -l 2>/dev/null || echo "0") )); then
            log "${GREEN}✅ ${label}: ${eth_balance} ETH (${tx_count_decimal} txs) 💰${NC}"
        else
            log "${YELLOW}✅ ${label}: ${eth_balance} ETH (${tx_count_decimal} txs)${NC}"
        fi
        
        echo "$label,$address,$eth_balance,$balance_result,$tx_count_decimal,https://etherscan.io/address/$address" >> "$TEMP_DIR/results.csv"
        return 0
    else
        log "${RED}❌ ${label}: ${balance_message:-Unknown error}${NC}"
        echo "$label,$address,ERROR,ERROR,ERROR,${balance_message:-Unknown error},https://etherscan.io/address/$address" >> "$TEMP_DIR/results.csv"
        return 1
    fi
}

# Main function
main() {
    log "${BLUE}🚀 Starting Ethereum Balance Check${NC}"
    log "API Key: ${ETHERSCAN_API_KEY:0:8}...${ETHERSCAN_API_KEY: -4}"
    log "Output file: $OUTPUT_FILE"
    echo ""
    
    # Create CSV header
    echo "Label,Address,Balance_ETH,Balance_Wei,Transaction_Count,Etherscan_URL" > "$TEMP_DIR/results.csv"
    
    # Define all addresses using parallel arrays (compatible with older shells)
    local labels=(
        "FlhWy" "sCKdW" "ZAiba" "AsHKD" "rzrhZ" "expPy" "zlBwY" "nElAL" "wqRjK" "HcYDT"
        "BqNRF" "OvURa" "PFfEj" "IOjJb" "uKfqV" "DAJYA" "SUVoY" "WJmWS" "QBAXK" "zLNIR"
        "kTQGi" "XJxSR" "kHjMo" "kxPDg" "gWISZ" "hIHlD" "QgItq" "bLJZU" "IdVSI" "Rpwne"
        "NYUBp" "eQrXq" "yRdVI" "IDnjA" "ajXoV" "xyHoE" "TCqKY" "dQfUy" "ctRhh" "JbMdu"
        "gjuIU" "fmDjk" "GjipQ" "wHLUW" "gYVeZ" "Sqlrp" "pcqRS" "fMapR" "ITrjn" "Ixxxa"
        "DdqMx" "mddEm" "GQlpD" "PFPfJ" "rgsmH" "kkUbC" "qHwwv" "mlgET" "Sflwm" "cKcDU"
    )
    
    local addresses=(
        "0xFc4a4858bafef54D1b1d7697bfb5c52F4c166976"
        "0xa29eeFb3f21Dc8FA8bce065Db4f4354AA683c024"
        "0x40C351B989113646bc4e9Dfe66AE66D24fE6Da7B"
        "0x30F895a2C66030795131FB66CBaD6a1f91461731"
        "0x57394449fE8Ee266Ead880D5588E43501cb84cC7"
        "0xCd422cCC9f6e8f30FfD6F68C0710D3a7F24a026A"
        "0x7C502F253124A88Bbb6a0Ad79D9BeD279d86E8f4"
        "0xe86749d6728d8b02c1eaF12383c686A8544de26A"
        "0xa4134741a64F882c751110D3E207C51d38f6c756"
        "0xD4A340CeBe238F148034Bbc14478af59b1323d67"
        "0xB00A433e1A5Fc40D825676e713E5E351416e6C26"
        "0xd9Df4e4659B1321259182191B683acc86c577b0f"
        "0x0a765FA154202E2105D7e37946caBB7C2475c76a"
        "0xE291a6A58259f660E8965C2f0938097030Bf1767"
        "0xe46e68f7856B26af1F9Ba941Bc9cd06F295eb06D"
        "0xa7eec0c4911ff75AEd179c81258a348c40a36e53"
        "0x3c6762469ea04c9586907F155A35f648572A0C3E"
        "0x322FE72E1Eb64F6d16E6FCd3d45a376efD4bC6b2"
        "0x51Bb31a441531d34210a4B35114D8EF3E57aB727"
        "0x314d5070DB6940C8dedf1da4c03501a3AcEE21E1"
        "0x75023D76D6cBf88ACeAA83447C466A9bBB0c5966"
        "0x1914F36c62b381856D1F9Dc524f1B167e0798e5E"
        "0xB9e9cfd931647192036197881A9082cD2D83589C"
        "0xE88ae1ae3947B6646e2c0b181da75CE3601287A4"
        "0x0D83F2770B5bDC0ccd9F09728B3eBF195cf890e2"
        "0xe2D5C35bf44881E37d7183DA2143Ee5A84Cd4c68"
        "0xd21E6Dd2Ef006FFAe9Be8d8b0cdf7a667B30806d"
        "0x93Ff376B931B92aF91241aAf257d708B62D62F4C"
        "0x5C068df7139aD2Dedb840ceC95C384F25b443275"
        "0x70D24a9989D17a537C36f2FB6d8198CC26c1c277"
        "0x0ae487200606DEfdbCEF1A50C003604a36C68E64"
        "0xc5588A6DEC3889AAD85b9673621a71fFcf7E6B56"
        "0x3c23bA2Db94E6aE11DBf9cD2DA5297A09d7EC673"
        "0x5B5cA7d3089D3B3C6393C0B79cDF371Ec93a3fd3"
        "0x4Cb4c0E7057829c378Eb7A9b174B004873b9D769"
        "0xd299f05D1504D0B98B1D6D3c282412FD4Df96109"
        "0x241689F750fCE4A974C953adBECe0673Dc4956E0"
        "0xBc5f75053Ae3a8F2B9CF9495845038554dDFb261"
        "0x5651dbb7838146fCF5135A65005946625A2685c8"
        "0x5c9D146b48f664f2bB4796f2Bb0279a6438C38b1"
        "0xd2Bf42514d35952Abf2082aAA0ddBBEf65a00BA3"
        "0xbB1EC85a7d0aa6Cd5ad7E7832F0b4c8659c44cc9"
        "0x013285c02ab81246F1D68699613447CE4B2B4ACC"
        "0x97A00E100BA7bA0a006B2A9A40f6A0d80869Ac9e"
        "0x4Bf0C0630A562eE973CE964a7d215D98ea115693"
        "0x805aa8adb8440aEA21fDc8f2348f8Db99ea86Efb"
        "0xae9935793835D5fCF8660e0D45bA35648e3CD463"
        "0xB051C0b7dCc22ab6289Adf7a2DcEaA7c35eB3027"
        "0xf7a82C48Edf9db4FBe6f10953d4D889A5bA6780D"
        "0x06de68F310a86B10746a4e35cD50a7B7C8663b8d"
        "0x51f3C0fCacF7d042605ABBE0ad61D6fabC4E1F54"
        "0x49BCc441AEA6Cd7bC5989685C917DC9fb58289Cf"
        "0x7fD999f778c1867eDa9A4026fE7D4BbB33A45272"
        "0xe8749d2347472AD1547E1c6436F267F0EdD725Cb"
        "0x2B471975ac4E4e29D110e43EBf9fBBc4aEBc8221"
        "0x02004fE6c250F008981d8Fc8F9C408cEfD679Ec3"
        "0xC4A51031A7d17bB6D02D52127D2774A942987D39"
        "0xa1b94fC12c0153D3fb5d60ED500AcEC430259751"
        "0xdedda1A02D79c3ba5fDf28C161382b1A7bA05223"
        "0xE55f51991C8D01Fb5a99B508CC39B8a04dcF9D04"
    )
    
    # Counters
    local total_addresses=${#addresses[@]}
    local successful_checks=0
    local failed_checks=0
    local addresses_with_balance=0
    local total_balance="0"
    local current=0
    
    log "Total addresses to check: $total_addresses"
    echo "=================================================================================="
    
    # Check each address using index-based loop
    for i in $(seq 0 $((total_addresses - 1))); do
        current=$((current + 1))
        local label="${labels[$i]}"
        local address="${addresses[$i]}"
        
        echo ""
        log "${BLUE}[$current/$total_addresses] Processing $label${NC}"
        
        if check_balance "$label" "$address"; then
            successful_checks=$((successful_checks + 1))
            
            # Check if balance > 0 (read from temp file)
            local last_balance
            last_balance=$(tail -n 1 "$TEMP_DIR/results.csv" | cut -d',' -f3)
            if [[ "$last_balance" != "ERROR" ]] && (( $(echo "$last_balance > 0" | bc -l 2>/dev/null || echo "0") )); then
                addresses_with_balance=$((addresses_with_balance + 1))
                total_balance=$(echo "$total_balance + $last_balance" | bc -l 2>/dev/null || echo "$total_balance")
            fi
        else
            failed_checks=$((failed_checks + 1))
        fi
        
        # Rate limiting - Etherscan allows 5 calls per second, we're making 2 calls per address
        sleep 0.5
    done
    
    # Generate final report
    echo ""
    echo "=================================================================================="
    log "${GREEN}🎉 Balance check completed!${NC}"
    echo "=================================================================================="
    log "📊 SUMMARY:"
    log "   Total addresses: $total_addresses"
    log "   Successful checks: ${GREEN}$successful_checks${NC}"
    log "   Failed checks: ${RED}$failed_checks${NC}"
    log "   Addresses with balance > 0: ${YELLOW}$addresses_with_balance${NC}"
    log "   Total ETH balance: ${GREEN}$total_balance ETH${NC}"
    echo ""
    
    # Move results to final output file
    mv "$TEMP_DIR/results.csv" "$OUTPUT_FILE"
    log "📁 Results saved to: ${YELLOW}$OUTPUT_FILE${NC}"
    
    # Show addresses with non-zero balance
    if [ "$addresses_with_balance" -gt 0 ]; then
        echo ""
        log "${GREEN}💰 ADDRESSES WITH NON-ZERO BALANCES:${NC}"
        echo "=================================================================================="
        while IFS=',' read -r label address balance_eth balance_wei tx_count etherscan_url; do
            if [[ "$balance_eth" != "ERROR" ]] && [[ "$balance_eth" != "Balance_ETH" ]] && (( $(echo "$balance_eth > 0" | bc -l 2>/dev/null || echo "0") )); then
                log "${GREEN}💎 $label: $balance_eth ETH (${tx_count} transactions)${NC}"
                log "   Address: $address"
                log "   Etherscan: $etherscan_url"
                echo ""
            fi
        done < "$OUTPUT_FILE"
    else
        log "${YELLOW}💸 No addresses found with non-zero balances.${NC}"
    fi
    
    # Show top 10 results in table format
    echo ""
    log "${BLUE}📋 RESULTS PREVIEW (showing first 10):${NC}"
    echo "=================================================================================="
    printf "%-8s %-44s %-15s %-8s %s\n" "Label" "Address" "Balance (ETH)" "Tx Count" "Status"
    echo "--------------------------------------------------------------------------------"
    
    local count=0
    while IFS=',' read -r label address balance_eth balance_wei tx_count etherscan_url; do
        if [[ "$label" != "Label" ]] && [ $count -lt 10 ]; then
            if [[ "$balance_eth" == "ERROR" ]]; then
                printf "%-8s %-44s %-15s %-8s %s\n" "$label" "$address" "ERROR" "ERROR" "❌ Failed"
            else
                local status_icon="✅"
                if (( $(echo "$balance_eth > 0" | bc -l 2>/dev/null || echo "0") )); then
                    status_icon="💰"
                fi
                printf "%-8s %-44s %-15s %-8s %s\n" "$label" "$address" "$balance_eth" "$tx_count" "$status_icon Success"
            fi
            count=$((count + 1))
        fi
    done < "$OUTPUT_FILE"
    
    if [ $total_addresses -gt 10 ]; then
        echo "... and $((total_addresses - 10)) more entries in $OUTPUT_FILE"
    fi
    
    echo ""
    log "${BLUE}💡 TIP: View the complete results with: ${YELLOW}cat $OUTPUT_FILE${NC}"
    log "${BLUE}💡 TIP: Open CSV in Excel/LibreOffice for better viewing${NC}"
    
    # Cleanup
    rm -rf "$TEMP_DIR"
}

# Help function
show_help() {
    echo "Ethereum Balance Checker"
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -v, --version  Show version information"
    echo ""
    echo "This script checks the ETH balance for 60 predefined Ethereum addresses"
    echo "using the Etherscan API and outputs the results to a CSV file."
    echo ""
    echo "Requirements:"
    echo "  - curl (for API requests)"
    echo "  - bc (for decimal calculations, optional)"
    echo ""
}

# Version function
show_version() {
    echo "Ethereum Balance Checker v1.0"
    if [ -n "${ETHERSCAN_API_KEY:-}" ]; then
        echo "API Key: ${ETHERSCAN_API_KEY:0:8}...${ETHERSCAN_API_KEY: -4}"
    else
        echo "API Key: Not set (ETHERSCAN_API_KEY environment variable required)"
    fi
    echo "Author: Claude AI Assistant"
}

# Check dependencies
check_dependencies() {
    if ! command -v curl >/dev/null 2>&1; then
        log "${RED}❌ Error: curl is required but not installed.${NC}"
        exit 1
    fi
    
    if [ -z "${ETHERSCAN_API_KEY:-}" ]; then
        log "${RED}❌ Error: ETHERSCAN_API_KEY environment variable is required.${NC}"
        log "${YELLOW}💡 TIP: Export your API key with: export ETHERSCAN_API_KEY='your_key_here'${NC}"
        exit 1
    fi
    
    if ! command -v bc >/dev/null 2>&1; then
        log "${YELLOW}⚠️  Warning: bc not found, using awk for calculations (less precise)${NC}"
    fi
}

# Handle command line arguments
case "${1:-}" in
    -h|--help)
        show_help
        exit 0
        ;;
    -v|--version)
        show_version
        exit 0
        ;;
    "")
        # No arguments, run main function
        ;;
    *)
        echo "Unknown option: $1"
        show_help
        exit 1
        ;;
esac

# Check dependencies and run main function
check_dependencies
main

# Exit with appropriate code
if [ -f "$OUTPUT_FILE" ]; then
    exit 0
else
    exit 1
fi
