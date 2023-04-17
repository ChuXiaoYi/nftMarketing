// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "hardhat/console.sol";

contract Marketplace is ReentrancyGuard {
    address payable public immutable feeAccount;
    uint public immutable feePercent;
    uint public itemCount;

    struct Item {
        uint id;
        IERC721 nft;
        uint tokenId;
        address payable seller;
        uint price;
        bool sold;
    }

    mapping(uint => Item) public items;

    event Offered(
        uint id,
        IERC721 nft,
        uint tokenId,
        address payable seller,
        uint price
    );

    event Bought(
        uint id,
        IERC721 nft,
        uint tokenId,
        address payable seller,
        address payable buyer,
        uint price
    );

    constructor(uint _feePercent) {
        feeAccount = payable(msg.sender);
        feePercent = _feePercent;
    }

    function offer(IERC721 nft, uint tokenId, uint price) public {
        require(price > 0, "Price must be greater than 0");
        require(nft.ownerOf(tokenId) == msg.sender, "You must own the token");

        itemCount++;
        nft.transferFrom(msg.sender, address(this), tokenId);
        items[itemCount] = Item(
            itemCount,
            nft,
            tokenId,
            payable(msg.sender),
            price,
            false
        );

        emit Offered(itemCount, nft, tokenId, payable(msg.sender), price);
    }

    function purchase(uint _itemId) external payable nonReentrant {
        uint _totalPrice = getTotalPrice(_itemId);
        Item storage item = items[_itemId];
        require(item.id > 0 && item.id <= itemCount, "Item does not exist");
        require(item.sold == false, "Item is already sold");
        require(msg.value >= _totalPrice, "not enough ether to cover item price and market fee");

        item.seller.transfer(item.price);
        feeAccount.transfer(msg.value - item.price);

        item.sold = true;
        item.nft.transferFrom(address(this), msg.sender, item.tokenId);

        emit Bought(
            _itemId,
            item.nft,
            item.tokenId,
            item.seller,
            payable(msg.sender),
            item.price
        );


    }

    function getTotalPrice(uint _itemId) view public returns(uint) {
        Item memory item = items[_itemId];
        uint totalPrice = item.price;
        uint fee = totalPrice * feePercent / 100;
        return totalPrice + fee;
    }
}