# Anonymous Voting Contract

A secure and anonymous voting system built on the Seismic devnet. The contract allows for proposal creation, anonymous voting, and early vote termination by proposal creators.

> **Contract Address**: [0xF050f37a7F8823e5BAe62962B0345D6Be736E35A](https://explorer-2.seismicdev.net/address/0xF050f37a7F8823e5BAe62962B0345D6Be736E35A)

## 🚀 Quick Start

This guide assumes you have already completed the [Seismic installation process](https://docs.seismic.systems/onboarding/publish-your-docs).

1. Get test ETH from [Seismic Faucet](https://faucet-2.seismicdev.net/)
2. Set up your private key:
```bash
export PRIVATE_KEY=your_private_key_here
```
3. Run the deployment script:
```bash
chmod +x script/deploy.sh
./script/deploy.sh
```

## 📝 Contract Overview

The `AnonymousVoting` contract implements a secure voting system with the following key features:
- Proposal creation with customizable duration
- Anonymous voting mechanism
- Vote counting for and against proposals
- Early termination capability for proposal creators
- Encrypted vote storage
- Time-based voting windows

## 🧪 Testing

The contract includes comprehensive tests covering all major functionality. Here are some key test examples:

```solidity
// Test for proposal creation
function testCreateProposal() public {
    vm.startPrank(alice);
    uint256 proposalId = voting.createProposal("Test Proposal", 1 days);
    
    (string memory description, uint256 startTime, uint256 endTime, bool hasVoted) = 
        voting.getProposalInfo(proposalId);
    
    assertEq(description, "Test Proposal");
    assertEq(endTime - startTime, 1 days);
    assertFalse(hasVoted);
    assertEq(voting.proposalCreator(proposalId), alice);
}

// Test for early vote termination
function testCreatorCanEndVoteEarly() public {
    vm.startPrank(alice);
    uint256 proposalId = voting.createProposal("Test Proposal", 1 days);
    vm.stopPrank();

    vm.warp(block.timestamp + 12 hours);
    vm.startPrank(alice);
    voting.endVoting(proposalId);
    assertTrue(voting.isVotingComplete(proposalId));
}
```

Run the tests with detailed output:
```bash
sforge test -vvv
```

You should see output similar to this:
```
[⠊] Compiling...
No files changed, compilation skipped

Ran 7 tests for test/vote.t.sol:VoteTest
[PASS] testCannotVoteAfterEnd() (gas: 139556)
[PASS] testCannotVoteTwice() (gas: 206833)
[PASS] testCreateProposal() (gas: 142676)
[PASS] testCreatorCanEndVoteEarly() (gas: 140388)
[PASS] testGetResults() (gas: 261616)
[PASS] testNonCreatorCannotEndVoteEarly() (gas: 139609)
[PASS] testVote() (gas: 206718)
Suite result: ok. 7 passed; 0 failed; 0 skipped
```

## 🔧 Deployment

### Prerequisites
1. Get test ETH from [Seismic Faucet](https://faucet-2.seismicdev.net/)
2. Set up your private key in the terminal:
```bash
export PRIVATE_KEY=your_private_key_here
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

## 💻 Interacting with the Contract

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

