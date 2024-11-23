// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Interface for a basic external contract
interface IExternalContract {
    function externalCallback(uint _value) external;
}

// Library for basic math operations
library MathLib {
    function add(uint a, uint b) internal pure returns (uint) {
        return a + b;
    }
}

contract Ownable {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner.");
        _;
    }
}

contract MyContract is Ownable {
    using MathLib for uint;

    // Struct for holding user information
    struct User {
        uint id;
        address wallet;
        uint[] tokens;
    }

    // Mapping of address to User struct
    mapping(address => User) public users;

    // Events can take up to three parameters
    event UserRegistered(uint id, address wallet, uint[] tokens);

    // Error handling: custom errors
    error InsufficientBalance(uint available, uint required);

    // Interface variable
    IExternalContract externalContract;

    constructor(address _externalContractAddress) {
        externalContract = IExternalContract(_externalContractAddress);
    }

    // Function with modifiers, visibility, and return values
    function registerUser(uint _id, uint[] memory _tokens) public onlyOwner {
        User storage user = users[msg.sender];
        user.id = _id;
        user.wallet = msg.sender;
        user.tokens = _tokens;

        // Emit an event after registration
        emit UserRegistered(_id, msg.sender, _tokens);
    }

    // View function: checks user tokens without modifying state
    function getUserTokens(address _user) public view returns (uint[] memory) {
        return users[_user].tokens;
    }

    // Error handling: revert and require
    function transferTokens(address _to, uint _amount) public {
        User storage user = users[msg.sender];
        uint balance = user.tokens.length;

        // Revert if insufficient balance
        if (balance < _amount) {
            revert InsufficientBalance(balance, _amount);
        }

        // Basic logic using library
        uint newAmount = _amount.add(10);

        // Call external contract as callback
        externalContract.externalCallback(newAmount);

        // Transfer logic here...
    }

    // Fallback function for handling Ether payments
    receive() external payable {}

    // Withdraw function to send Ether to the owner
    function withdraw(uint _amount) public onlyOwner {
        require(address(this).balance >= _amount, "Insufficient contract balance.");
        payable(owner).transfer(_amount);
    }
}
