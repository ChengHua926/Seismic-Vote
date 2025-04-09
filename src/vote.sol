// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract AnonymousVoting {
    // Structured data for each proposal
    struct Proposal {
        uint256 id;
        string description;
        uint256 startTime;
        uint256 endTime;
        uint256 votesFor;
        uint256 votesAgainst;
        mapping(address => bool) hasVoted;
    }

    // Proposal counter to generate unique IDs
    uint256 private nextProposalId = 1;
    
    // Proposals storage
    mapping(uint256 => Proposal) public proposals;
    
    // Track who created each proposal
    mapping(uint256 => address) public proposalCreator;
    
    // Encrypted votes storage - maps proposal ID -> voter address -> encrypted vote
    mapping(uint256 => mapping(address => suint256)) private encryptedVotes;
    
    event ProposalCreated(uint256 indexed proposalId, string description, uint256 startTime, uint256 endTime);
    event VoteCast(uint256 indexed proposalId, address indexed voter);
    event VotingEnded(uint256 indexed proposalId, uint256 votesFor, uint256 votesAgainst);
    
    /**
     * @dev Creates a new voting proposal
     * @param _description Description of what is being voted on
     * @param _duration Duration of voting period in seconds
     * @return proposalId ID of the created proposal
     */
    function createProposal(string memory _description, uint256 _duration) public returns (uint256) {
        uint256 proposalId = nextProposalId++;
        
        Proposal storage newProposal = proposals[proposalId];
        newProposal.id = proposalId;
        newProposal.description = _description;
        newProposal.startTime = block.timestamp;
        newProposal.endTime = block.timestamp + _duration;
        newProposal.votesFor = 0;
        newProposal.votesAgainst = 0;
        
        // Store the creator's address
        proposalCreator[proposalId] = msg.sender;
        
        emit ProposalCreated(proposalId, _description, newProposal.startTime, newProposal.endTime);
        return proposalId;
    }
    
    /**
     * @dev Casts an encrypted vote for a proposal
     * @param _proposalId ID of the proposal
     * @param _vote Encrypted vote value (1 for yes, 0 for no)
     */
    function vote(uint256 _proposalId, suint256 _vote) public {
        Proposal storage proposal = proposals[_proposalId];
        
        // Check voting conditions
        require(block.timestamp >= proposal.startTime, "Voting not started");
        require(block.timestamp < proposal.endTime, "Voting ended");
        require(!proposal.hasVoted[msg.sender], "Already voted");
        
        // Store encrypted vote
        encryptedVotes[_proposalId][msg.sender] = _vote;
        proposal.hasVoted[msg.sender] = true;
        

        if (_vote == suint256(1)) {
            proposal.votesFor++;
        } else if (_vote == suint256(0)) {
            proposal.votesAgainst++;
        } else {
            revert("Invalid vote value");
        }
        
        emit VoteCast(_proposalId, msg.sender);
    }
    
    /**
     * @dev Ends voting for a proposal and finalizes results
     * @param _proposalId ID of the proposal
     */
    function endVoting(uint256 _proposalId) public {
        Proposal storage proposal = proposals[_proposalId];
        
        // Allow early ending if caller is the proposal creator
        if (msg.sender == proposalCreator[_proposalId]) {
            // Update endTime to current time to mark voting as complete
            proposal.endTime = block.timestamp;
        } else {
            // Others must wait for the end time
            require(block.timestamp >= proposal.endTime, "Voting period active");
        }
        
        emit VotingEnded(_proposalId, proposal.votesFor, proposal.votesAgainst);
    }
    
    /**
     * @dev Checks if a proposal's voting period has ended
     * @param _proposalId ID of the proposal
     * @return True if voting is complete
     */
    function isVotingComplete(uint256 _proposalId) public view returns (bool) {
        return block.timestamp >= proposals[_proposalId].endTime;
    }
    
    /**
     * @dev Gets voting results for a completed proposal
     * @param _proposalId ID of the proposal
     * @return votesFor Number of yes votes
     * @return votesAgainst Number of no votes
     */
    function getResults(uint256 _proposalId) public view returns (uint256 votesFor, uint256 votesAgainst) {
        Proposal storage proposal = proposals[_proposalId];
        require(isVotingComplete(_proposalId), "Voting not complete");
        return (proposal.votesFor, proposal.votesAgainst);
    }
    
    /**
     * @dev Gets the encrypted vote for a specific voter (can only be called by the voter)
     * @param _proposalId ID of the proposal
     * @return The caller's encrypted vote
     */
    function getMyVote(uint256 _proposalId) public view returns (uint256) {
        require(proposals[_proposalId].hasVoted[msg.sender], "You haven't voted");
    
        uint256 sender_vote = uint256(encryptedVotes[_proposalId][msg.sender]);
        return sender_vote;
    }
    
    /**
     * @dev Gets basic proposal information
     * @param _proposalId ID of the proposal
     * @return description Proposal description
     * @return startTime Start time of voting
     * @return endTime End time of voting
     * @return hasVoted Whether caller has voted
     */
    function getProposalInfo(uint256 _proposalId) public view returns (
        string memory description,
        uint256 startTime,
        uint256 endTime,
        bool hasVoted
    ) {
        Proposal storage proposal = proposals[_proposalId];
        return (
            proposal.description,
            proposal.startTime,
            proposal.endTime,
            proposal.hasVoted[msg.sender]
        );
    }
}