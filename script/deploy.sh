#!/bin/bash

set -e

# Configuration
RPC_URL="https://node-2.seismicdev.net/rpc"
EXPLORER_URL="https://explorer-2.seismicdev.net"
CONTRACT_PATH="src/vote.sol:AnonymousVoting"
DEPLOY_FILE="out/deploy.txt"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_step() {
    echo -e "${BLUE}Step $1: $2${NC}"
}

print_success() {
    echo -e "${GREEN}$1${NC}"
}

# Get private key from env
privkey=$PRIVATE_KEY

print_step "1" "Deploying AnonymousVoting contract"
deploy_output=$(sforge create \
    --rpc-url "$RPC_URL" \
    --private-key "$privkey" \
    --broadcast \
    "$CONTRACT_PATH")
print_success "Success."

print_step "2" "Summarizing deployment"
contract_address=$(echo "$deploy_output" | grep "Deployed to:" | awk '{print $3}')
tx_hash=$(echo "$deploy_output" | grep "Transaction hash:" | awk '{print $3}')
echo "$contract_address" >"$DEPLOY_FILE"
echo -e "Contract Address: ${GREEN}$contract_address${NC}"
echo -e "Contract Link: ${GREEN}$EXPLORER_URL/address/$contract_address${NC}"

echo -e "\n"
print_success "Success. AnonymousVoting contract deployed on Seismic!"