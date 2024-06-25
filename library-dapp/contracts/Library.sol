pragma solidity ^0.8.0;

contract Library {
    struct Book {
        string title;
        uint256 copies;
        uint256 price;
        address[] borrowers;
    }

    mapping(uint256 => Book) public books;
    uint256 public nextBookId;
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function addBook(string memory title, uint256 copies, uint256 price) public onlyOwner {
        books[nextBookId] = Book(title, copies, price, new address[](0));
        nextBookId++;
    }

    function borrowBook(uint256 bookId) public {
        Book storage book = books[bookId];
        require(book.copies > 0, "Book is not available");
        book.borrowers.push(msg.sender);
        book.copies--;
    }

    function returnBook(uint256 bookId) public {
        Book storage book = books[bookId];
        bool hasBorrowed = false;
        for (uint256 i = 0; i < book.borrowers.length; i++) {
            if (book.borrowers[i] == msg.sender) {
                hasBorrowed = true;
                delete book.borrowers[i];
                break;
            }
        }
        require(hasBorrowed, "You did not borrow this book");
        book.copies++;
    }

    function buyBook(uint256 bookId) public payable {
        Book storage book = books[bookId];
        require(msg.value >= book.price, "Not enough Ether to buy the book");
        require(book.copies > 0, "Book is not available for sale");
        book.copies--;
        payable(owner).transfer(msg.value);
    }

    function checkAvailability(uint256 bookId) public view returns (bool) {
        return books[bookId].copies > 0;
    }
}
