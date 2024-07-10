// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LibrarySystem {
    struct Book {
        uint id;
        string title;
        string author;
        uint price;
        uint quantity;
        string isbn;
        address uploader;
        address owner;
        address[] borrowers;
        uint available;
    }

    mapping(uint => Book) public books;
    uint public bookCount;
    address public contractOwner;

    constructor() {
        contractOwner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == contractOwner, "Only owner can perform this action");
        _;
    }

    event BookAdded(uint id, string title, string author, uint price, uint quantity, string isbn, address uploader);
    event BookBorrowed(uint id, address borrower);
    event BookBought(uint id, address buyer, address previousOwner);
    event BookReturned(uint id, address borrower);

    function addBook(string memory _title, string memory _author, uint _price, uint _quantity, string memory _isbn) public {
        bookCount++;
        books[bookCount] = Book(bookCount, _title, _author, _price, _quantity, _isbn, msg.sender, msg.sender, new address[](0), _quantity);
        emit BookAdded(bookCount, _title, _author, _price, _quantity, _isbn, msg.sender);
    }

    function borrowBook(uint _id) public {
        require(_id > 0 && _id <= bookCount, "Invalid book ID");
        require(books[_id].available > 0, "No copies available for borrowing");
        
        books[_id].borrowers.push(msg.sender);
        books[_id].available--;
        emit BookBorrowed(_id, msg.sender);
    }

    function buyBook(uint _id) public payable {
        require(_id > 0 && _id <= bookCount, "Invalid book ID");
        require(msg.value >= books[_id].price, "Insufficient funds to buy the book");
        require(books[_id].available > 0, "No copies available for sale");

        address previousOwner = books[_id].owner;
        books[_id].owner = msg.sender;
        books[_id].available--;
        
        payable(previousOwner).transfer(msg.value);
        emit BookBought(_id, msg.sender, previousOwner);
    }

    function returnBook(uint _id) public {
        require(_id > 0 && _id <= bookCount, "Invalid book ID");
        
        bool isBorrower = false;
        for (uint i = 0; i < books[_id].borrowers.length; i++) {
            if (books[_id].borrowers[i] == msg.sender) {
                isBorrower = true;
                // Remove borrower from the list
                books[_id].borrowers[i] = books[_id].borrowers[books[_id].borrowers.length - 1];
                books[_id].borrowers.pop();
                break;
            }
        }
        
        require(isBorrower, "Only a borrower can return the book");
        
        books[_id].available++;
        emit BookReturned(_id, msg.sender);
    }

    function getBooks() public view returns (Book[] memory) {
        Book[] memory result = new Book[](bookCount);
        for (uint i = 1; i <= bookCount; i++) {
            result[i - 1] = books[i];
        }
        return result;
    }
}
