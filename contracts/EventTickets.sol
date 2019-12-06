pragma solidity ^0.5.0;

contract EventTickets {

    address payable public owner;
    uint TICKET_PRICE = 100 wei;

    struct Event{
        string description;
        string website;
        uint totalTickets;
        uint sales;
        mapping (address => uint) buyers;
        bool isOpen;
    }
    Event myEvent;

    event LogBuyTickets(address purchaser, uint tickets);
    event LogGetRefund(address requester, uint tickets);
    event LogEndSale(address contractOwner, uint balance);

    modifier checkOwner() {
        require(msg.sender == owner, "you are not owner");
        _;
    }

    constructor(string memory description, string memory URL, uint tickets) public {
        owner = msg.sender;
        myEvent = Event(description, URL, tickets, 0, true);
    }

    function readEvent() public view returns(string memory description, string memory website, uint totalTickets, uint sales, bool isOpen)
    {
        description = myEvent.description;
        website = myEvent.website;
        totalTickets = myEvent.totalTickets;
        sales = myEvent.sales;
        isOpen = myEvent.isOpen;
        return (description, website, totalTickets, sales, isOpen);
    }

    function getBuyerTicketCount(address _address) public view returns(uint numberOfTickets) {
        return myEvent.buyers[_address];
    }
    function buyTickets(uint numberOfTickets) public payable {
        require(myEvent.isOpen == true, "it is not open");
        require(numberOfTickets <= myEvent.totalTickets, "tickets are not enough");
        require(msg.value >= (TICKET_PRICE * numberOfTickets), "value is not valid");
        myEvent.buyers[msg.sender] = numberOfTickets;
        myEvent.totalTickets -= numberOfTickets;
        myEvent.sales += numberOfTickets;
        msg.sender.transfer(msg.value - (TICKET_PRICE * numberOfTickets));
        emit LogBuyTickets(msg.sender, numberOfTickets);
    }

    function getRefund() public {
        require(myEvent.buyers[msg.sender] != 0, "you do not have tickets");
        uint tickets = myEvent.buyers[msg.sender];
        myEvent.buyers[msg.sender] = 0;
        myEvent.totalTickets += tickets;
        msg.sender.transfer(TICKET_PRICE * tickets);
        emit LogGetRefund(msg.sender, tickets);
    }

    function endSale() public checkOwner {
        myEvent.isOpen = false;
        address(owner).transfer(address(this).balance);
        emit LogEndSale(owner, address(this).balance);
    }
}

