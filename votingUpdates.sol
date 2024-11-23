// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DVote {
    struct SUsersInfo {
        bool createStatus;
        bool createdProposal;  // Indicates if the user has created a proposal
        uint256 votedProposalId;
    }
    
    enum VoteStatus {
        OPEN, FINALIZED
    }

    struct SProposalInfo {
        address createdBy;
        string title;
        string description;
        uint256 votingTimeStamp;
        uint256 proposalId;
        uint256 totalVotes;
        VoteStatus status;
    }

    uint256 public proposalId = 0;
    mapping(address => SUsersInfo) public users;
    mapping(uint256 => SProposalInfo) public proposalList;

    event UserRegistration(address indexed name);

    modifier hasNotCreateUserBefore() {
        require(!users[msg.sender].createStatus, "You can only create one user");
        _;
    }

    modifier hasRegistered(address usrAddr) {
        require(users[usrAddr].createdProposal, "User has not created a proposal");
        _;
    }
    
    modifier hasNotVote() {
        require(users[msg.sender].votedProposalId == 0, "You can only vote once");
        _;
    }

    modifier hasRegisteredUser() {
        require(users[msg.sender].createStatus, "User must be registered");
        _;
    }

    function createUser() public hasNotCreateUserBefore {
        users[msg.sender] = SUsersInfo(true, false, 0);
        emit UserRegistration(msg.sender);
    }

    function createProposal(string memory title, string memory description) public hasRegisteredUser {
        proposalId++;
        proposalList[proposalId] = SProposalInfo(msg.sender, title, description, block.timestamp, proposalId, 0, VoteStatus.OPEN);
        users[msg.sender].createdProposal = true; // Mark the user as having created a proposal
    }

    function voteProposal(uint256 _proposalId) public hasNotVote() {
        require(_proposalId > 0 && _proposalId <= proposalId, "Proposal does not exist");
        proposalList[_proposalId].totalVotes++;
        users[msg.sender].votedProposalId = _proposalId; // Mark the user as having voted
    }

    function getContractCount(uint256 _proposalId) public view returns (uint256) {
        require(_proposalId > 0 && _proposalId <= proposalId, "Proposal does not exist");
        return proposalList[_proposalId].totalVotes;
    }

    function getProposalDetails(uint256 _proposalId) public view returns (SProposalInfo memory) {
        require(_proposalId > 0 && _proposalId <= proposalId, "Proposal does not exist");
        return proposalList[_proposalId];
    }

    function getProposalStatus(uint256 _proposalId) public view returns (VoteStatus) {
        require(_proposalId > 0 && _proposalId <= proposalId, "Proposal does not exist");
        return proposalList[_proposalId].status;
    }
}
