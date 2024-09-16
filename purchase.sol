// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

contract NFT_purchase is ERC721Holder{
    struct Order{
        uint256 token_id;
        address nft_address;
        uint256 price;
        address seller;
    }

    mapping( uint256 => Order ) public orders;

    event listed(
        uint256 token_id,
        address nft_address,
        uint256 price,
        address seller
    );

    event purchased(
        uint256 token_id,
        uint256 price,
        address seller,
        address buyer
    );

    event Revoked(
        uint256 _tokenId,
        address _account
    );

    event Updated(uint256 tokenId, uint256 newPrice, address seller);
    
    function list(address _nftAddress, uint256 _tokenId, uint256 _price) external {
        IERC721 nft = IERC721(_nftAddress);
        require(nft.ownerOf(_tokenId) == msg.sender,"the owner of ntf must be message sender");
        require(orders[_tokenId].token_id == 0,"token already listed");
        require(_price > 0,"price must bigger than 0");

        nft.safeTransferFrom(msg.sender, address(this), _tokenId);

        orders[_tokenId] = Order({
            token_id: _tokenId,
            nft_address: _nftAddress,
            price: _price,
            seller: msg.sender
        });

        emit listed(_tokenId, _nftAddress, _price, msg.sender);
    }

    function purchase(uint256 _tokenId) external payable  {
        Order memory order = orders[_tokenId];
        require(orders[_tokenId].token_id == _tokenId,"token is wrong");
        require(msg.value > order.price,"Insufficient payment");

        delete orders[_tokenId];

        IERC721 nft = IERC721(order.nft_address);
        nft.safeTransferFrom(address(this), msg.sender, _tokenId);

        payable(order.seller).transfer(order.price);

        emit purchased(_tokenId, order.price, order.seller, msg.sender);
    }

    function revoke(uint256 _tokenId) external {

        Order memory order = orders[_tokenId];
        IERC721 nft = IERC721(order.nft_address);
        require(orders[_tokenId].token_id == _tokenId,"token is wrong");
        require(order.seller== msg.sender,"the owner of ntf must be message sender");

        delete orders[_tokenId];

        nft.safeTransferFrom(address(this), msg.sender, _tokenId);
        emit Revoked(_tokenId, msg.sender);
    }

    function update(uint256 _tokenId , uint256 new_price) external {
        Order storage order = orders[_tokenId];
        require(orders[_tokenId].token_id == _tokenId,"token is wrong");
        require(order.seller== msg.sender,"the owner of ntf must be message sender");
        
        require(new_price > 0,"price must bigger than 0");

        order.price = new_price;

        emit Updated(_tokenId, new_price, msg.sender);

    }
}