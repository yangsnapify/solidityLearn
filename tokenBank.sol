// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Interface for an external verification system
interface IVerificationContract {
    function verifyTransaction(address _user, uint _amount) external returns (bool);
}

// Library for mathematical operations
library SafeMath {
    function subtract(uint a, uint b) internal pure returns (uint) {
        require(a >= b, "Subtraction overflow");
        return a - b;
    }

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
        require(msg.sender == owner, "Caller is not the owner.");
        _;
    }
}

contract TokenBank is Ownable {
    using SafeMath for uint;

    // Struct for tracking user balances
    struct Account {
        uint balance;
        address wallet;
    }

    // Mapping user address to account data
    mapping(address => Account) public accounts;

    // External verification contract
    IVerificationContract public verificationContract;

    // Events
    event Deposit(address indexed user, uint amount);
    event Withdrawal(address indexed user, uint amount);
    event Transfer(address indexed from, address indexed to, uint amount);

    // Custom error for insufficient balance
    error NotEnoughBalance(uint balance, uint attempted);

    // Constructor to set external contract address
    constructor(address _verificationContractAddress) {
        verificationContract = IVerificationContract(_verificationContractAddress);
    }

    // Deposit tokens into the bank
    function depositTokens(uint _amount) external {
        require(_amount > 0, "Amount must be greater than zero.");

        // Update account balance
        accounts[msg.sender].balance = accounts[msg.sender].balance.add(_amount);

        // Emit the deposit event
        emit Deposit(msg.sender, _amount);
    }

    // Withdraw tokens from the bank
    function withdrawTokens(uint _amount) external {
        Account storage account = accounts[msg.sender];
        
        // Ensure the user has enough balance
        if (account.balance < _amount) {
            revert NotEnoughBalance(account.balance, _amount);
        }

        // Update balance safely
        account.balance = account.balance.subtract(_amount);

        // Emit the withdrawal event
        emit Withdrawal(msg.sender, _amount);
    }

    // Transfer tokens to another user
    function transferTokens(address _to, uint _amount) external {
        Account storage senderAccount = accounts[msg.sender];
        Account storage recipientAccount = accounts[_to];

        // Ensure the sender has sufficient balance
        if (senderAccount.balance < _amount) {
            revert NotEnoughBalance(senderAccount.balance, _amount);
        }

        // Perform external verification
        bool verified = verificationContract.verifyTransaction(msg.sender, _amount);
        require(verified, "Transaction verification failed.");

        // Perform the transfer
        senderAccount.balance = senderAccount.balance.subtract(_amount);
        recipientAccount.balance = recipientAccount.balance.add(_amount);

        // Emit the transfer event
        emit Transfer(msg.sender, _to, _amount);
    }

    // Fallback to handle Ether transactions sent directly to this contract
    receive() external payable {}

    // Withdraw Ether to the owner's wallet
    function withdrawEther(uint _amount) external onlyOwner {
        require(address(this).balance >= _amount, "Not enough Ether in the contract.");
        payable(owner).transfer(_amount);
    }
}
