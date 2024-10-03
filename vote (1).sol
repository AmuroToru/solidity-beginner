// SPDX-License-Identifier: MIT
pragma solidity >=0.0.0 <0.9.0;
///@title 委托投票
contract Bollot{

    //表示一个选民
    struct Voter{
        uint weight; //计票权重
        bool voted; //若为真，代表该人已投
        address delegate; //被委托人
        uint vote; //投票索引
    }

    struct Proposal {
        bytes32 name;
        uint voteCount;
    }

    address public  chairperson;

    uint startTime;
    uint endTime;

    mapping (address => Voter) public voters;
    Proposal[] public proposals; //投票议题
    constructor(bytes32[]  memory proposalNames,uint _startTime,uint _endTime) public {
        require(_startTime<_endTime,"Start time must be before end time");
        startTime=_startTime;
        endTime = _endTime;
        chairperson = msg.sender; //主席
        voters[chairperson].weight = 1;
        for (uint256 i = 0 ; i<proposalNames.length ; i++){
            proposals.push(Proposal({name:proposalNames[i],voteCount:0})); //初始化议题
        }
    }

    function  giveRightToVote(address voter)external {
        require(msg.sender == chairperson, "Only chairperson can give right to vote");
        require(!voters[voter].voted,"The voter has already voted");
        require(voters[voter].weight == 0,"the voter already has voting righrs");

        voters[voter].weight = 1; //设置权重
    }

    function delegate(address to) external {
        Voter storage sender= voters[msg.sender];
        require(sender.weight != 0 ,"you have no right to vote");
        require(!sender.voted ,"you already voted");
        require(to != msg.sender, "Self-delegation is  disallowed");

//while 确保如果被委托人也有了委托人，则进行传递
        while(voters[to].delegate != address(0)){
            to = voters[to].delegate;
            require(to!=msg.sender,"Found loop in delegation.");
        }

        Voter storage delegate_ = voters[to];
        require(delegate_.weight>=1,"Selected delegate does not have voting right.");
        sender.voted=true;
        sender.delegate=to;
        if(delegate_.voted){
            proposals[delegate_.vote].voteCount+=sender.weight ; 
        }
        else {
            delegate_.weight+=sender.weight;
        }
    }

    function vote(uint256 proposal) external {
        Voter storage sender = voters[msg.sender];
        require(block.timestamp>startTime,"Voting has not started yet");
        require(block.timestamp<endTime ,"Voting has ended" );
        require(sender.weight !=0,"No voting right"); //检查是否有权限投票
        require(!sender.voted,"You have already voted"); //检查是否已经投过票
        sender.voted=true;
        sender.vote=proposal;
        proposals[proposal].voteCount+=sender.weight ; //增加计票权重
    }   

    function winningProposal()public view returns(uint256 winningProposal_){
        uint256 winningVoteCount = 0;
        for(uint256 p=0 ; p<proposals.length;p++){
            if(proposals[p].voteCount>winningVoteCount){
                winningVoteCount = proposals[p].voteCount;
                winningProposal_=p;
            }
        }
    }

    function winnerName() external view returns(bytes32 winnerName_){
        winnerName_=proposals[winningProposal()].name;
    }

    function setVoterWeight(address voter, uint weight) private  {
    require(msg.sender==chairperson,"only chairperson own the right to modify the weight.");
    require(weight>=1,"Weight must be greater than or equal to one"); //检查权重
    voters[voter].weight = weight ; //设置权重
    }

}