# Anonymous Voting Contract

A secure and anonymous voting system built on the Seismic devnet. The contract allows for proposal creation, anonymous voting, and early vote termination by proposal creators.

## Contract Overview

The `AnonymousVoting` contract implements a secure voting system with the following key features:
- Proposal creation with customizable duration
- Anonymous voting mechanism
- Vote counting for and against proposals
- Early termination capability for proposal creators
- Encrypted vote storage
- Time-based voting windows

## Testing

The contract includes comprehensive tests covering all major functionality:

```solidity
// Example test for proposal creation
function testCreateProposal() public {
    vm.startPrank(alice);
    uint256 proposalId = voting.createProposal("Test Proposal", 1 days);
    // ... verification code
}

// Example test for voting
function testVote() public {
    // ... voting test code
}
```

Run the tests with detailed output:
```bash
forge test -vvv
```

## Deployment

### Prerequisites
1. Install Foundry
2. Get test ETH from [Seismic Faucet](https://faucet-2.seismicdev.net/)
3. Set up your environment variables in `.env`:
```
SEISMIC_RPC_URL=https://node-2.seismicdev.net/rpc
SEISMIC_CHAIN_ID=5124
PRIVATE_KEY=your_private_key_here
```

### Deployment Steps
1. Make the deployment script executable:
```bash
chmod +x script/deploy.sh
```

2. Run the deployment script:
```bash
./script/deploy.sh
```

The contract is deployed at: [0xF050f37a7F8823e5BAe62962B0345D6Be736E35A](https://explorer-2.seismicdev.net/address/0xF050f37a7F8823e5BAe62962B0345D6Be736E35A)

## Interacting with the Contract

After deployment, you can interact with the contract using cast:

```bash
# Create a proposal
cast send <CONTRACT_ADDRESS> "createProposal(string,uint256)" "Test Proposal" 86400 \
    --rpc-url https://node-2.seismicdev.net/rpc \
    --private-key $PRIVATE_KEY

# Get proposal info
cast call <CONTRACT_ADDRESS> "getProposalInfo(uint256)" 1 \
    --rpc-url https://node-2.seismicdev.net/rpc
```

Replace `<CONTRACT_ADDRESS>` with the deployed contract address.

