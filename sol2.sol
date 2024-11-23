// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Interface for interacting with the external contract (optional)
interface IVoting {
    function getVoteCount(uint proposalId) external view returns (uint);
}

contract Voting is IVoting {
    struct Proposal {
        string name;
        uint voteCount;
        bool exists;
    }

    mapping(uint => Proposal) public proposals;
    mapping(address => mapping(uint => bool)) public votes; // tracks if an address has voted for a proposal
    uint public proposalCount;


    event ProposalCreated(uint proposalId, string name);
    event Voted(address indexed voter, uint proposalId);

    modifier hasNotVoted(uint proposalId) {
        require(!votes[msg.sender][proposalId], "You have already voted for this proposal.");
        _;
    }

    function getVoteCount(uint proposalId) public view returns (uint) {
        require(proposals[proposalId].exists, "Proposal Does Not Exists!");
        return proposals[proposalId].voteCount;
    }

    function createProposal(string calldata name) external {
        proposals[proposalCount] = Proposal(name, 0, true);
        emit ProposalCreated(proposalCount, name);
        proposalCount++;
    }

    function vote(uint proposalId) external hasNotVoted(proposalId) {
        require(proposals[proposalId].exists, "Proposal does not exist.");
        
        proposals[proposalId].voteCount++;
        votes[msg.sender][proposalId] = true;

        emit Voted(msg.sender, proposalId);
    }

    function getProposal(uint proposalId) external view returns (string memory name, uint voteCount) {
        require(proposals[proposalId].exists, "Proposal does not exist.");
        Proposal memory proposal = proposals[proposalId];
        return (proposal.name, proposal.voteCount);
    }
}
