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

    struct Review {
        address reviewer;
        string reviewText;
        uint rating;
    }

    mapping(uint => Book) public books;
    mapping(uint => Review[]) public bookReviews;
    mapping(address => uint[]) public wishlist;
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
    event ReviewAdded(uint bookId, address reviewer, string reviewText, uint rating);
    event BookWishlisted(uint id, address user);

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

    function addReview(uint _id, string memory _reviewText, uint _rating) public {
        require(_id > 0 && _id <= bookCount, "Invalid book ID");
        require(_rating > 0 && _rating <= 5, "Rating should be between 1 and 5");
        
        bookReviews[_id].push(Review(msg.sender, _reviewText, _rating));
        emit ReviewAdded(_id, msg.sender, _reviewText, _rating);
    }

    function getReviews(uint _id) public view returns (Review[] memory) {
        return bookReviews[_id];
    }

    function addToWishlist(uint _id) public {
        require(_id > 0 && _id <= bookCount, "Invalid book ID");
        wishlist[msg.sender].push(_id);
        emit BookWishlisted(_id, msg.sender);
    }

    function getWishlist() public view returns (uint[] memory) {
        return wishlist[msg.sender];
    }

    function getBooks() public view returns (Book[] memory) {
        Book[] memory result = new Book[](bookCount);
        for (uint i = 1; i <= bookCount; i++) {
            result[i - 1] = books[i];
        }
        return result;
    }
}
