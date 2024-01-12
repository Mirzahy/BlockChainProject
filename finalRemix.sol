// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

contract BookStore{
    struct Book{
        uint id;
        string author;
        string name;
        uint year_of_publishing;
        string genre;
        uint price;
    }
    struct User{
        address a;
        string name;
        string city;
        string adresa;
        string country;
        uint zipcode;
    }

    uint private nextId=1;

    address immutable private owner;

    constructor(address _owner) {
        owner = _owner;
    }

    mapping(uint => Book) public list_of_books;
    mapping(address => Book[]) bought_books;
    mapping(uint =>User ) list_of_users;

    event BookMade(uint _id);

    modifier OnlyOwner(){
        require(msg.sender==owner,"Not owner");
        _;
    }

    modifier autoincrement(){
        _;
        nextId+=1;
    }

    modifier checkId(uint _id){
        require(_id <= nextId && _id>=0,"Invalid id");
        _;
        
    }

    function createBook(string memory _author, string memory _name,uint _year,string memory _genre, uint _price) external OnlyOwner() autoincrement(){
        list_of_books[nextId]=Book(nextId,_author,_name,_year,_genre,_price);
        emit BookMade(nextId);
    }

    uint userId=1;

    function IsItOwner() external view returns(address){
        return owner;
    }

    function buyBook(uint _id,string memory name, string memory  city,string memory adresa,string memory country,
        uint zipcode) external checkId(_id) payable {
        //1 ether = 10 **18 wei msg value je u weima odnosno feningziiii
    
        require(list_of_books[_id].price==msg.value,"You need to send exact eth amount");
        //emit PurchaseItemEvent(_id, msg.sender);
        
        //sending money to user
        (bool sent,) = owner.call{value: msg.value}("");
        require(sent, "Failed to send Ether");
       
        bought_books[msg.sender].push(list_of_books[_id]);
        list_of_users[userId]=User(msg.sender,name,city,adresa,country,zipcode);

        userId++;
        delete list_of_books[_id];
    }

    function getBoughtBooks() external view returns(Book[] memory){
        return bought_books[msg.sender];
    }

    function getNotZeros() private view returns(uint){
        uint zero=0;
        for(uint i=1; i<nextId; i++){
            if(list_of_books[i].id!=0){
                zero++;
            }
        }
        return zero;
    }

    function getAvailableBooks() public view returns (Book[] memory){
        uint number=getNotZeros();
        uint j=0;
        Book[] memory _books = new Book[](number);
        for(uint i=1; i<nextId; i++){
            if(list_of_books[i].id!=0){
                _books[j]=list_of_books[i];
                j++;
            }
        }
        return _books;
    }

    function getBookId(uint id) public view returns(Book memory){
        return list_of_books[id];
    }

    function getUsers()  external OnlyOwner() view returns (User[] memory){
        User[] memory _users = new User[](userId-1);
        for(uint i=1; i<userId; i++){
            _users[i-1]=list_of_users[i];
        }
        return _users;
    }
}