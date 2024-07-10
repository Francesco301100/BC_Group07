// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LibrarySystem {
    struct Book {
        uint id;
        string title;
        string author;
        uint price;
        address borrower;
        bool isAvailable;
    }

    mapping(uint => Book) public books;
    uint public bookCount;
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    event BookAdded(uint id, string title, string author, uint price);
    event BookBorrowed(uint id, address borrower);
    event BookBought(uint id, address buyer);

    function addBook(string memory _title, string memory _author, uint _price) public onlyOwner {
        bookCount++;
        books[bookCount] = Book(bookCount, _title, _author, _price, address(0), true);
        emit BookAdded(bookCount, _title, _author, _price);
    }

    function borrowBook(uint _id) public {
        require(_id > 0 && _id <= bookCount, "Invalid book ID");
        require(books[_id].borrower == address(0), "Book already borrowed");
        require(books[_id].isAvailable, "Book not available");
        books[_id].borrower = msg.sender;
        books[_id].isAvailable = false;
        emit BookBorrowed(_id, msg.sender);
    }

    function buyBook(uint _id) public payable {
        require(_id > 0 && _id <= bookCount, "Invalid book ID");
        require(msg.value >= books[_id].price, "Insufficient funds to buy the book");
        require(books[_id].isAvailable, "Book not available");
        books[_id].borrower = msg.sender;
        books[_id].isAvailable = false;
        payable(owner).transfer(msg.value);
        emit BookBought(_id, msg.sender);
    }

    // Überprüfen Sie diese Funktion sorgfältig
    function getBooks() public view returns (Book[] memory) {
        Book[] memory result = new Book[](bookCount);
        for (uint i = 1; i <= bookCount; i++) {
            result[i - 1] = books[i];
        }
        return result;
    }
}
