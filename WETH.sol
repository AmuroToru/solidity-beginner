// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0 ;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract WETH is ERC20{
    //事件提取和存入
    event deposite(address sender, uint value );
    event withdraw(address sender, uint value );

    constructor() ERC20("WETH", "WETH") {

    }

    fallback() external payable {
        Deposite();
     }

     receive() external payable {
        Deposite();
     }

     function Deposite() public payable {
        require(msg.value > 0, 'value must greater than 0'); 
        _mint(msg.sender , msg.value);
        emit deposite(msg.sender, msg.value);
         }

     function Withdraw(uint amount) public  {
        require(balanceOf(msg.sender)>=amount, 'amount must smaller than 0');
        payable(msg.sender).transfer(amount);
        emit withdraw(msg.sender, amount);
      }


}

