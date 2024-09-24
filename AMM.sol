// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


 import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

 contract SimpleSwap is ERC20{
     IERC20 public  token0;
     IERC20 public  token1;

     uint public reserve0;
     uint public reserve1;

     constructor(IERC20 _token1, ERC20 _token2)ERC20("SimpleSwap","SS") {
        token0 = _token1;
        token1 = _token2;
     }

    function min(uint x, uint y) internal pure returns (uint z) {
        z = x < y ? x : y;
    }

    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }


     event mint(address indexed sender, uint amount0, uint amount1);

     function Addliquidity(uint token0desires , uint token1desired) public returns(uint liquidity){
        token1.transferFrom(msg.sender,address(this), token1desired);
        token0.transferFrom(msg.sender,address(this), token0desires);


        uint _totalSupply = totalSupply();
        if(_totalSupply == 0){
            liquidity=sqrt(token1desired*token1desired);
        }
        else {
            liquidity=min(_totalSupply*(token0desires/reserve0),_totalSupply*(token1desired/reserve1));
        }

        reserve0=token0.balanceOf(address(this));
        reserve1=token1.balanceOf(address(this));

        require(liquidity > 0);

        _mint(msg.sender,liquidity);

        emit mint(msg.sender,token0desires,token1desired);
     }

     event RemoveLiquidity(address indexed sender,uint amount0,uint amount1);

     function remove_liquidity(uint liquidity) public returns   (uint amount0, uint amount1){
        uint balance0 = token1.balanceOf(address(this));
        uint balance1 = token1.balanceOf(address(this));

        uint _totalSupply = totalSupply();

        amount0 = liquidity*balance0/_totalSupply;
        amount1 = liquidity*balance1/_totalSupply;

        _burn(msg.sender,liquidity);

        token1.transfer(msg.sender,amount1);
        token1.transfer(msg.sender,amount0);

        emit RemoveLiquidity(msg.sender,amount0,amount1);
     }

     function AmountOut(uint amountIn,uint reserveIn,uint reserveOut) public view returns (uint amountOut){
        require(reserveOut > 0 && reserveIn > 0);
        require(amountIn > 0);
        amountOut = amountIn*reserveOut/(reserveIn+amountIn);
     }

     event  Swap(address sender, uint amountIn, address tokenIn ,  uint amountOut, address tokenOut);

     function swap(uint amountIn , IERC20 tokenIn , uint amoutOutMin) public returns (uint amountOut , IERC20 tokenOut) {
        require(amountIn > 0 );
        require(tokenIn == token0 || tokenIn == token1, 'INVALID_TOKEN');
        uint amount0 = token0.balanceOf(address(this));
        uint amount1 = token1.balanceOf(address(this));

        if(tokenIn == token0){
            amountOut = AmountOut(amountIn,amount0,amount1);
            require(amountOut > amoutOutMin);

            tokenIn.transferFrom(msg.sender,address(this),amountIn);
            tokenOut.transfer(msg.sender,amountOut);
        }else {
            amountOut = AmountOut(amountIn,amount1,amount0);
            require(amountOut > amoutOutMin);
            tokenIn.transferFrom(msg.sender,address(this),amountIn);
            tokenOut.transfer(msg.sender,amountOut);
        }
        reserve0 = token0.balanceOf(address(this));
        reserve1 = token1.balanceOf(address(this));
        
        emit Swap(msg.sender, amountIn, address(tokenIn), amountOut, address(tokenOut));
     }
 }