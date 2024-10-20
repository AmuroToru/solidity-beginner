/*这是一个基于solidity语言的拍卖合约Auction，售卖者可以起拍价，拍卖时长，每次竞价冷却时间和延长时长。
竞价者可以调用bid函数进行竞价。若出现更高竞价，则竞价者可以调用witdraw函数取回竞价金额；
拍卖结束后售卖者可以通过endFunction函数获得拍卖金额*/
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Auction {
    address payable public seller;//拍卖者的地址
    uint public auctionEndTime;//拍卖结束时间
    uint public highestBid;//最高出价
    uint public coolingTime;//出价冷却时间
    uint public bidTime;//再次出价时间
    bool public ended;//拍卖是否结束
    uint public delayTime;//每次有人竞标后选择延长时间
    address public highestBidder;//最高出价者
    mapping(address=>uint) public bids;//记录每个地址的出价


    event HighestBidInCreased(address bidder,uint amount);
    event AuctionEnded(address winner , uint amount);

    constructor(uint _biddingTime,address payable _seller,uint startPrice,uint CoolTime,uint DelayTime){
        require(CoolTime<DelayTime,"the cooling time smaller than delaytime");
        seller=_seller;
        auctionEndTime=block.timestamp+_biddingTime;
        highestBid=startPrice;
        ended=false;
        coolingTime=CoolTime;
        bidTime=block.timestamp;
        delayTime=DelayTime;
    }

    //出价函数
    function bid()public payable {
        require(block.timestamp<auctionEndTime,"auction has ended");
        require(msg.value>highestBid,"there is already higher bid");
        require(block.timestamp>bidTime,"in the cooling time");
        if(highestBidder!=address(0)){
            bids[highestBidder]=highestBid;
        }

        highestBidder=msg.sender;
        highestBid=msg.value;

        emit HighestBidInCreased(msg.sender, msg.value);
        bidTime=block.timestamp+coolingTime;
        auctionEndTime+=delayTime;

    }
    
    //未竞价成功者取回出价
    function withdraw() public{
        uint amount=bids[msg.sender];
        require(amount>0,"No bid to withdraw");
        bids[msg.sender]=0;
        payable (msg.sender).transfer(amount);
    }
    //拍卖结束，将最高出价发送给出售人
    function endAuction()public{
        require(block.timestamp>=auctionEndTime,"auction does not ended yet");
        require(!ended,"auction has already ended");
        require(msg.sender==seller,"only seller can end the auction");

        ended=true;
        emit AuctionEnded(highestBidder, highestBid);

        seller.transfer(highestBid);
    }
}
