# Ethereum Balance Checker

![Console Output](console%20output.png)

A bash script to check ETH balances and transaction counts for multiple Ethereum addresses using the Etherscan API.
It is pre-configured with the NPM supply chain exploit hard coded Ethereum addresses, see [exploit gist](https://gist.github.com/tintinweb/e518182a6ec521131a9e7386fe130e81#file-npm-vulnerability-deobfusicated-js-L183-L242)

## Features

- ✅ **Batch Balance Checking**: Check ETH balances for up to 60 addresses at once
- 📊 **Transaction Count**: Get the total number of transactions for each address
- 💾 **CSV Export**: Results saved to timestamped CSV file for analysis
- 🎨 **Colored Output**: Beautiful terminal output with status indicators
- 🔄 **Rate Limiting**: Built-in API rate limiting to respect Etherscan limits
- 🔒 **Environment Variables**: Secure API key handling through environment variables
- 📈 **Summary Reports**: Detailed statistics and non-zero balance highlights
- 🌐 **Etherscan Links**: Direct links to view addresses on Etherscan

## Prerequisites

- **curl**: For making API requests
- **bc**: For precise decimal calculations (optional, falls back to awk)
- **Etherscan API Key**: Get yours free at [etherscan.io/apis](https://etherscan.io/apis)

## Installation

1. Clone or download the script:
```bash
git clone <repository-url>
cd Eth-balances
```

2. Make the script executable:
```bash
chmod +x balances.sh
```

3. Set your Etherscan API key:
```bash
export ETHERSCAN_API_KEY='your_etherscan_api_key_here'
```

## Usage

### Basic Usage

```bash
# Set your API key (required)
export ETHERSCAN_API_KEY='your_etherscan_api_key_here'

# Run the balance checker
./balances.sh
```

### Command Line Options

```bash
# Show help
./balances.sh --help

# Show version information
./balances.sh --version
```

### Test Transaction Count

Use the included test script to verify transaction counting works:

```bash
export ETHERSCAN_API_KEY='your_key_here'
./test_tx.sh
```

## Output

### Terminal Output
The script provides real-time colored output showing:
- 🚀 Starting status with API key preview
- 🔍 Individual address checking progress
- ✅ Success with balance and transaction count
- ❌ Errors with descriptive messages
- 📊 Final summary with statistics
- 💰 Highlighted addresses with non-zero balances

### CSV Export
Results are automatically saved to a timestamped CSV file:
```
ethereum_balances_20250909_123456.csv
```

CSV format:
```
Label,Address,Balance_ETH,Balance_Wei,Transaction_Count,Etherscan_URL
FlhWy,0xFc4a4858bafef54D1b1d7697bfb5c52F4c166976,0.000011,11000000000000,8,https://etherscan.io/address/0xFc4a4858bafef54D1b1d7697bfb5c52F4c166976
```

## Configuration

### Pre-configured Addresses
The script includes 60 pre-configured Ethereum addresses with labels. You can modify the addresses in the script by editing these arrays:

```bash
# Labels for addresses
local labels=(
    "FlhWy" "sCKdW" "ZAiba" # ... add more
)

# Corresponding Ethereum addresses  
local addresses=(
    "0xFc4a4858bafef54D1b1d7697bfb5c52F4c166976"
    "0xa29eeFb3f21Dc8FA8bce065Db4f4354AA683c024"
    # ... add more
)
```

### Rate Limiting
The script includes built-in rate limiting to respect Etherscan's API limits:
- Default: 0.5 seconds between requests
- Etherscan free tier: 5 calls per second
- Adjust sleep time in the script if needed

## API Endpoints Used

1. **Balance Check**: `module=account&action=balance`
2. **Transaction Count**: `module=account&action=txlist`

## Example Output

```
[2025-09-09 08:58:08] 🚀 Starting Ethereum Balance Check
[2025-09-09 08:58:08] API Key: GK2H9B37...A3HE
[2025-09-09 08:58:08] Output file: ethereum_balances_20250909_085808.csv

[2025-09-09 08:58:08] Total addresses to check: 60
==================================================================================

[2025-09-09 08:58:08] [1/60] Processing FlhWy
[2025-09-09 08:58:08] Checking FlhWy: 0xFc4a4858bafef54D1b1d7697bfb5c52F4c166976
[2025-09-09 08:58:10] ✅ FlhWy: .000011 ETH (8 txs) 💰

==================================================================================
🎉 Balance check completed!
==================================================================================
📊 SUMMARY:
   Total addresses: 60
   Successful checks: 58
   Failed checks: 2
   Addresses with balance > 0: 1
   Total ETH balance: 0.000011 ETH

💰 ADDRESSES WITH NON-ZERO BALANCES:
==================================================================================
💎 FlhWy: 0.000011 ETH (8 transactions)
   Address: 0xFc4a4858bafef54D1b1d7697bfb5c52F4c166976
   Etherscan: https://etherscan.io/address/0xFc4a4858bafef54D1b1d7697bfb5c52F4c166976
```

## Error Handling

The script handles various error conditions:
- ❌ Missing or invalid API key
- ❌ Network connectivity issues
- ❌ API rate limiting
- ❌ Invalid API responses
- ❌ Missing dependencies

## Troubleshooting

### Common Issues

1. **"Missing/Invalid API Key"**
   ```bash
   export ETHERSCAN_API_KEY='your_valid_key_here'
   ```

2. **"curl: command not found"**
   ```bash
   # macOS
   brew install curl
   
   # Ubuntu/Debian
   sudo apt-get install curl
   ```

3. **"bc: command not found"** (optional)
   ```bash
   # macOS
   brew install bc
   
   # Ubuntu/Debian  
   sudo apt-get install bc
   ```

4. **Rate limiting errors**
   - Wait a few minutes and try again
   - Consider getting a paid Etherscan API plan

## Security Notes

- ✅ API key is handled via environment variables
- ✅ No hardcoded credentials in the script
- ✅ API key is masked in output logs
- ⚠️ Don't commit your API key to version control

## Contributing

Feel free to submit issues and enhancement requests!

## License

This project is open source and available under the MIT License.

## Version

Current version: v1.0

## Author

Created with assistance from Claude AI Assistant.
