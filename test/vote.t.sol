// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/vote.sol";

contract VoteTest is Test {
    AnonymousVoting public voting;
    address public alice;
    address public bob;
    address public charlie;

    function setUp() public {
        voting = new AnonymousVoting();
        alice = makeAddr("alice");
        bob = makeAddr("bob");
        charlie = makeAddr("charlie");
    }

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

    function testVote() public {
        // Create proposal
        vm.startPrank(alice);
        uint256 proposalId = voting.createProposal("Test Proposal", 1 days);
        vm.stopPrank();

        // Bob votes
        vm.startPrank(bob);
        voting.vote(proposalId, suint256(1)); // Vote yes
        
        // Verify vote was recorded
        assertEq(voting.getMyVote(proposalId), 1);
    }

    function testCannotVoteTwice() public {
        vm.startPrank(alice);
        uint256 proposalId = voting.createProposal("Test Proposal", 1 days);
        vm.stopPrank();

        vm.startPrank(bob);
        voting.vote(proposalId, suint256(1));
        
        // Try to vote again
        vm.expectRevert("Already voted");
        voting.vote(proposalId, suint256(0));
    }

    function testCannotVoteAfterEnd() public {
        vm.startPrank(alice);
        uint256 proposalId = voting.createProposal("Test Proposal", 1 days);
        vm.stopPrank();

        // Move time forward past end time
        vm.warp(block.timestamp + 2 days);

        vm.startPrank(bob);
        vm.expectRevert("Voting ended");
        voting.vote(proposalId, suint256(1));
    }

    function testCreatorCanEndVoteEarly() public {
        vm.startPrank(alice);
        uint256 proposalId = voting.createProposal("Test Proposal", 1 days);
        vm.stopPrank();

        // Move time to middle of voting period
        vm.warp(block.timestamp + 12 hours);

        // Creator can end vote early
        vm.startPrank(alice);
        voting.endVoting(proposalId);

        // Verify voting is complete
        assertTrue(voting.isVotingComplete(proposalId));
    }

    function testNonCreatorCannotEndVoteEarly() public {
        vm.startPrank(alice);
        uint256 proposalId = voting.createProposal("Test Proposal", 1 days);
        vm.stopPrank();

        // Move time to middle of voting period
        vm.warp(block.timestamp + 12 hours);

        // Non-creator tries to end vote early
        vm.startPrank(bob);
        vm.expectRevert("Voting period active");
        voting.endVoting(proposalId);
    }

    function testGetResults() public {
        vm.startPrank(alice);
        uint256 proposalId = voting.createProposal("Test Proposal", 1 days);
        vm.stopPrank();

        // Multiple votes
        vm.startPrank(bob);
        voting.vote(proposalId, suint256(1)); // Yes
        vm.stopPrank();

        vm.startPrank(charlie);
        voting.vote(proposalId, suint256(0)); // No
        vm.stopPrank();

        // End voting
        vm.warp(block.timestamp + 2 days);
        voting.endVoting(proposalId);

        // Check results
        (uint256 votesFor, uint256 votesAgainst) = voting.getResults(proposalId);
        assertEq(votesFor, 1);
        assertEq(votesAgainst, 1);
    }
} 