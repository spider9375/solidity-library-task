// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
pragma abicoder v2;

import "./Ownable.sol";

contract Library is Ownable {
    event BorrowedBook(uint bookId, address borrower);
    event ReturnedBook(uint bookId, address borrower);
    event NewBook(uint bookId, string name, uint totalCopies);
    event AddedBookCopies(uint bookId, uint copies, uint totalCopies);
    
    constructor() {
        // Had issues with mappings and zero index so I decided to start counting from 1;
        books.push(Book("BookAtIndex0"));
    }
    
    // Given to users
    // Can have `string content;` property but I removed it for clarity;
    struct BookCopy {
        uint bookId;
        address libraryAddress;
    }
    
    // Can also have `string content;` property.
    struct Book {
        string name;
    }
    
    struct BookViewModel {
        uint id;
        string name;
    }
    
    Book[] private books;
    uint private availableBooksCount = 0;
    
    mapping(uint => uint) private bookCopiesNumber;
    mapping (uint => address[]) private bookOwnerHistory;
    mapping(address => mapping(uint => bool)) private ownerBooks;

    
    modifier isAvailable(uint _id) {
        require(bookCopiesNumber[_id] > 0, "There are no copies of this book at the moment");
        _;
    }
    
    modifier isFromLibrary(BookCopy calldata bookCopy) {
        require(books.length >= bookCopy.bookId && bookCopy.libraryAddress == owner, "This book is not from this library");
        _;
    }
    
    modifier callerBorrowedBook(uint id) {
        require(ownerBooks[msg.sender][id], "This user hasn't borrowed this book");
        _;
    }
    
    modifier isFirstCopyOfBookForUser(uint id) {
        require(!ownerBooks[msg.sender][id], "Cannot borrow more than one copy of a book at a time");
        _;
    }
    
    modifier bookExists(uint id) {
        require(books.length > id, "Book does not exist");
        _;
    }
    
    modifier idIsSubsequent(uint id) {
        require(books.length + 1 >= id, "Cant skip ids");
        _;
    }
    
    modifier notOwner() {
        require(msg.sender != owner, "Owner cannot borrow books");
        _;
    }

    // _bookId starts at 1 and can add new book with subsequent id; (1,2,3...);
    // Had problems with zero index for mapping bookCopiesNumber it just didn't work; 
    function addBook(uint _bookId, string memory _name, uint _copies)
        public
        onlyOwner
        idIsSubsequent(_bookId)
    {
        if (books.length == _bookId) {
            books.push(Book(_name));
            uint id = books.length - 1;
            require(id == _bookId, "Wrong id");
            bookCopiesNumber[id] = _copies;
            availableBooksCount++;
            
            emit NewBook(id, books[id].name, bookCopiesNumber[id]);
        } else {
            if (bookCopiesNumber[_bookId] == 0) {
                availableBooksCount++;
            }
            
            bookCopiesNumber[_bookId] += _copies;
            
            emit AddedBookCopies(_bookId, _copies, bookCopiesNumber[_bookId]);
        }
    }
    
    function seeAvailableBooks()
        public
        view
        returns(BookViewModel[] memory)
    {
        BookViewModel[] memory result = new BookViewModel[](availableBooksCount);
        
        uint counter = 0;
        for (uint i = 0; i < books.length; i++) {
            if (bookCopiesNumber[i] > 0) {
                result[counter] = BookViewModel(i, books[i].name);
                counter++;
            }
        }
        
        return result;
    }
    
    function borrowBook(uint _id)
        public 
        isFirstCopyOfBookForUser(_id)
        isAvailable(_id)
        bookExists(_id)
        notOwner
        returns(BookCopy memory)
    {
        ownerBooks[msg.sender][_id] = true;
        bookOwnerHistory[_id].push(msg.sender);
        BookCopy memory bookCopy = BookCopy(_id, owner);
        bookCopiesNumber[_id]--;
        
        if (bookCopiesNumber[_id] == 0) {
            availableBooksCount--;
        }
        
        emit BorrowedBook(bookCopy.bookId, msg.sender);
        
        return bookCopy;
    }
    
    function returnBook(BookCopy calldata bookCopy)
        public
        isFromLibrary(bookCopy)
        callerBorrowedBook(bookCopy.bookId)
        notOwner
    {
        ownerBooks[msg.sender][bookCopy.bookId] = false;
        bookCopiesNumber[bookCopy.bookId]++;
        
        if (bookCopiesNumber[bookCopy.bookId] == 1) {
            availableBooksCount++;
        }
        
        emit ReturnedBook(bookCopy.bookId, msg.sender);
    }
    
    function getBookBorrowers(uint _bookId)
        public
        view
        bookExists(_bookId)
        returns(address[] memory)
    {
        return bookOwnerHistory[_bookId];
    }
}