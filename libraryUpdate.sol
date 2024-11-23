// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Library {
    struct BookDetails {
        string title;
        string author;
        bool availabilityStatus;
    }

    mapping(uint => BookDetails) public bookList;
    mapping(address => uint) public borrowedBooks; // Maps user to their borrowed book ID
    uint public bookCounter;

    event BookAdded(uint bookId, string title, string author);
    event BorrowBook(uint bookId);
    event ReturnBook(uint bookId);

    modifier isBookAvailableBorrow(uint bookId) {
        require(bookList[bookId].availabilityStatus, "Book is not available.");
        _;
    }

    modifier hasBorrowedBook() {
        require(borrowedBooks[msg.sender] != 0, "You have not borrowed any book.");
        _;
    }

    function addBook(string memory title, string memory author) public {
        bookCounter++;
        bookList[bookCounter] = BookDetails(title, author, true);
        emit BookAdded(bookCounter, title, author);
    } 

    function borrowBook(uint bId) public isBookAvailableBorrow(bId) {
        bookList[bId].availabilityStatus = false;
        borrowedBooks[msg.sender] = bId;
        emit BorrowBook(bId);
    }

    function returnBook(uint bId) public hasBorrowedBook() {
        require(borrowedBooks[msg.sender] == bId, "You did not borrow this book.");
        bookList[bId].availabilityStatus = true;
        delete borrowedBooks[msg.sender];
        emit ReturnBook(bId);
    }
}
