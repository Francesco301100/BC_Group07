// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Library {
    struct Book {
        uint id;
        string name;
        string author;
        uint copies;
        uint price;
        uint borrowed;
    }

    address public owner;
    uint public bookCount = 0;
    mapping(uint => Book) public books;
    mapping(address => mapping(uint => bool)) public borrowedBooks;

    event BookAdded(uint id, string name, string author, uint copies, uint price);
    event BookBorrowed(uint id, address borrower);
    event BookBought(uint id, address buyer);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function addBook(string memory name, string memory author, uint copies, uint price) public onlyOwner {
        books[bookCount] = Book(bookCount, name, author, copies, price, 0);
        emit BookAdded(bookCount, name, author, copies, price);
        bookCount++;
    }

    function borrowBook(uint id) public {
        require(books[id].copies > books[id].borrowed, "No available copies to borrow");
        require(!borrowedBooks[msg.sender][id], "You have already borrowed this book");
        books[id].borrowed++;
        borrowedBooks[msg.sender][id] = true;
        emit BookBorrowed(id, msg.sender);
    }

    function buyBook(uint id) public payable {
        require(msg.value == books[id].price, "Incorrect value sent");
        require(books[id].copies > 0, "No available copies to buy");
        books[id].copies--;
        payable(owner).transfer(msg.value);
        emit BookBought(id, msg.sender);
    }
}
