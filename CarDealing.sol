pragma solidity 0.4.24;
contract CarDealing
{
    address owner;
    uint index;
    
    enum Status{ForSale,Sold,Shipped}
    
    struct Items
    {
        string name;
        uint price;
        string model;
        uint value;
        Status status;
        uint remaining;
        address seller;
        address buyer;
    }
    mapping(uint=>Items) product;
    
    event forSale(uint index);
    event sold(uint value);
    event shipped(uint value);
    
    modifier ownerOnly()
    {
        require(msg.sender == owner);
        _;
    }
    
    modifier ForSale(uint value)
    {
        require(product[value].status == Status.ForSale);
        _;
    }
    
    modifier Sold(uint value)
    {
        require(product[value].status == Status.Sold);
        _;
    }
    
    modifier Shipped(uint value)
    {
        require(product[value].status == Status.Shipped);
        _;
    }
    
    modifier paidEnough(uint price)
    {
        require(msg.value>=price);
        _;
    }
    
    modifier Moneyvalue(uint value)
    {
        _;
        uint money = product[value].price;
        uint moneyReturn = msg.value - money;
        product[value].buyer.transfer(moneyReturn);
    }
    
    constructor()public payable
    {
        owner = msg.sender;
        index = 0;
    }
    
    function addItems(string _name, uint _price, string _model) ownerOnly public
    {
        index = index +1;
        emit forSale(index);
        product[index] = Items({
            name:_name,
            price:_price,
            model:_model,
            value:index,
            status:Status.ForSale,
            seller:msg.sender,
            buyer:0,
            remaining:0
        });
    }
    
    function fetchItems(uint value) public view returns(string _name, uint _price, string _model,uint _value,string _status, address _seller, address _buyer,uint _remaning)
    {
        uint state;
        _name=product[value].name;
        _price=product[value].price;
        _model=product[value].model;
        _value=product[value].value;
        state = uint(product[value].status);
        if(state==0)
        {
            _status="For Sale";
        }
        if(state==1)
        {
            _status="Sold";
        }
        if(state==2)
        {
            _status="Shipped";
        }
        _seller=product[value].seller;
        _buyer=product[value].buyer;
        _remaning=product[value].remaining;
    }
    
    function buyItem(uint value) ForSale(value) paidEnough(product[value].price) Moneyvalue(value) public payable
    {
        address buyer = msg.sender;
        product[value].buyer = buyer;
        product[value].status = Status.Sold;
        product[value].seller.transfer(value);
        uint money = product[value].price;
        uint moneyReturn = msg.value - money;
        product[value].remaining=moneyReturn;
        emit sold(value);
    }
    
    function shipping(uint value) Sold(value) public
    {
        product[value].status = Status.Shipped;
        emit shipped(value);
    }
}
