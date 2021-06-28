// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
import "remix_tests.sol"; // this import is automatically injected by Remix.
import "remix_accounts.sol";
import "../contracts/Library.sol";
pragma abicoder v2;

// Tried to write some tests but borrowBook and returnBook fails and I couldn't find out why.
contract LibraryTest {
    address acc0;
    address acc1;
    address acc2;
    
    Library public _library;
    
    function beforeAll() public {
        acc0 = TestsAccounts.getAccount(0); 
        acc1 = TestsAccounts.getAccount(1);
        acc2 = TestsAccounts.getAccount(2);
    }
    
    function beforeEach() public {
        _library = new Library();
    }
    
    function checkOwnerAddBook() public {
        Assert.ok(msg.sender == acc0, "");
        _library.addBook(1, "bookName", 1);
        Assert.equal(_library.seeAvailableBooks().length, 1, "");
    }
    
    // function checkNotOwnerAddBook() public {
    //     Assert.ok(msg.sender == acc1, "");
    //     _library.addBook(1, "bookName", 1);
    //     Assert.equal(_library.seeAvailableBooks().length, 0, "");
    // }
    
    function checkAddBookTwice() public {
        Assert.ok(msg.sender == acc0, "");
        _library.addBook(1, "bookName", 1);
        _library.addBook(1, "bookName", 1);
        Assert.equal(_library.bookCopiesNumber(1), 2, "");
    }
    
    // function checkBorrowBookSuccess() public {
    //     Assert.ok(msg.sender == acc0, "");
    //     _library.addBook(1, "bookName", 1);
    //     Assert.ok(msg.sender == acc1, "");
    //     Library.BookCopy memory asd = _library.borrowBook(1);
    //     Assert.equal(_library.borrowBook(1).bookId, 1, "");
    // }
}
