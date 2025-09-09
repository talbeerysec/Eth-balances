# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with the Ethereum Balance Checker project.

## Project Overview

This is a bash-based Ethereum balance checker that uses the Etherscan API to:
- Check ETH balances for multiple addresses
- Count transactions for each address  
- Export results to CSV format
- Provide colored terminal output with summaries

## Key Files

- `balances.sh` - Main balance checker script
- `test_tx.sh` - Test script for transaction count functionality
- `README.md` - User documentation
- `.gitignore` - Git ignore patterns for security and cleanliness

## Development Environment

### Requirements
- **bash** - Unix shell (macOS/Linux)
- **curl** - For API requests to Etherscan
- **bc** - For precise decimal calculations (optional, falls back to awk)
- **Etherscan API Key** - Required environment variable

### Common Commands

```bash
# Set API key (required)
export ETHERSCAN_API_KEY='your_etherscan_api_key_here'

# Run main balance checker
./balances.sh

# Test transaction count functionality
./test_tx.sh

# Show help
./balances.sh --help

# Show version
./balances.sh --version
```

## Code Architecture

### Main Components
- **Configuration**: API key via environment variables
- **Rate Limiting**: 0.5s delays to respect Etherscan limits (5 calls/second)
- **Dual API Calls**: Balance + transaction count for each address
- **Error Handling**: Network errors, API failures, missing dependencies
- **Output Formats**: Colored terminal output + timestamped CSV export

### Security Features
- ✅ Environment variables for API keys (no hardcoded secrets)
- ✅ API key masking in logs (`GK2H9B37...A3HE`)
- ✅ Validation of required environment variables
- ✅ .gitignore prevents committing sensitive data

### API Integration
- **Etherscan API**: Official Ethereum blockchain API
- **Balance Endpoint**: `module=account&action=balance`
- **Transaction Count**: `module=account&action=txlist` with hash counting
- **Rate Limiting**: Built-in delays to prevent API throttling

## Development Best Practices

### Code Style
- **Bash best practices**: `set -e`, proper quoting, error handling
- **Security first**: No hardcoded credentials, environment variables only
- **Readable output**: Colored logs with emoji indicators
- **Comprehensive logging**: Timestamps, progress indicators, error messages

### Testing Approach
- **test_tx.sh**: Isolated testing of transaction count functionality
- **Manual verification**: Compare results with Etherscan website
- **Error simulation**: Test with invalid API keys, network issues
- **Address validation**: Use known addresses with transaction history

### Output Management
- **CSV export**: Timestamped files prevent overwrites
- **Progress tracking**: Real-time status updates during execution  
- **Summary reports**: Statistics and highlighted non-zero balances
- **Direct links**: Etherscan URLs for easy verification

## API Key Management

### Environment Variable Setup
```bash
# Temporary (current session)
export ETHERSCAN_API_KEY='your_key_here'

# Permanent (add to ~/.bashrc or ~/.zshrc)
echo 'export ETHERSCAN_API_KEY="your_key_here"' >> ~/.bashrc
source ~/.bashrc
```

### Security Guidelines
- ❌ Never hardcode API keys in scripts
- ❌ Never commit API keys to version control
- ✅ Always use environment variables
- ✅ Mask API keys in output logs
- ✅ Validate API key presence before execution

## Debugging and Troubleshooting

### Common Issues
1. **Missing API key**: Script validates and provides clear error messages
2. **Network failures**: Individual request timeouts with retry logic
3. **API rate limiting**: Built-in delays prevent most rate limit issues
4. **Invalid addresses**: Etherscan API returns appropriate error messages

### Debug Output
- **Verbose logging**: Timestamps and detailed progress information
- **API response inspection**: test_tx.sh shows raw API responses
- **CSV verification**: Results saved for later analysis
- **Error categorization**: Network vs API vs validation errors

## Deployment Considerations

### Production Usage
- Use paid Etherscan API plans for higher rate limits
- Consider batch processing for large address lists
- Monitor API usage and costs
- Implement result caching for repeated queries

### Maintenance
- Update address lists in the arrays within balances.sh
- Monitor Etherscan API changes and deprecations
- Test with new addresses periodically
- Keep dependencies (curl, bc) updated

## Important Instructions

- **ALWAYS** ensure ETHERSCAN_API_KEY is set via environment variables
- **NEVER** hardcode API keys or secrets in the code
- **TEST** with the test_tx.sh script before making changes
- **VALIDATE** results against Etherscan website for accuracy
- **RESPECT** API rate limits to avoid being blocked