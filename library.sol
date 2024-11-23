// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract Library {
    struct BookDetails {
        string title;
        string author;
        bool availabilityStatus;
    }

    uint public bookIncrementId = 0;
    mapping(uint => BookDetails) public bookList;
       mapping(address => uint) public borrowedBooks; // Maps user to their borrowed book ID

    event BookAdded(string indexed title, string indexed author, uint indexed bookId);
    event BorrowBook(uint indexed bookId, string indexed author, string indexed title);
   event ReturnBook(uint bookId);
   
    modifier isBookAvailableBorrow(uint bookId) {
        require(bookList[bookId].availabilityStatus);
        _;
    }

     modifier hasBorrowedBook() {
        require(borrowedBooks[msg.sender] != 0, "You have not borrowed any book.");
        _;
    }

    function addBook(string memory title, string memory author) public {
        bookIncrementId++;
        bookList[bookIncrementId] = BookDetails(title, author, true);
        emit BookAdded(title, author, bookIncrementId);
    } 

    function borrowBook(uint bId) public isBookAvailableBorrow(bId) {
        bookList[bId].availabilityStatus = false;
        BookDetails memory _bookDetails = bookList[bId]; 
        emit BorrowBook(bId, _bookDetails.author, _bookDetails.title);
    }

    function returnBook(uint bId) public hasBorrowedBook() {
        require(borrowedBooks[msg.sender] == bId, "You did not borrow this book.");
        bookList[bId].availabilityStatus = true;
        delete borrowedBooks[msg.sender];
        emit ReturnBook(bId);
    }
}