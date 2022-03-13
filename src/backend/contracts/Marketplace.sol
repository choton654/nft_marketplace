// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Marketplace is ReentrancyGuard {
    //  state variables
    address payable public immutable feeAccount; // the account that receives fees
    uint256 public immutable feeParcent; // the fee percentage on sales
    uint256 public itemCount;

    struct Item {
        uint256 itemId;
        ERC721 nft;
        uint256 tokenId;
        uint256 price;
        address payable seller;
        bool sold;
    }

    mapping(uint256 => Item) public items;

    event Offered(
        uint256 itemId,
        address indexed nft,
        uint256 tokenId,
        uint256 price,
        address indexed seller
    );

    event Bought(
        uint256 itemId,
        address indexed nft,
        uint256 tokenId,
        uint256 price,
        address indexed seller,
        address indexed buyer
    );

    constructor(uint256 _feeParcent) {
        feeAccount = payable(msg.sender);
        feeParcent = _feeParcent;
    }

    function makeItem(
        ERC721 _nft,
        uint256 _tokenId,
        uint256 _price
    ) external nonReentrant {
        return (_price > 0, "Price must be greater than zero");

        itemCount++;

        _nft.transferFrom(msg.sender, address(this), _tokenId);

        items[itemCount] = Item(
            itemCount,
            _nft,
            _tokenId,
            _price,
            payable(msg.sender),
            false
        );

        emit Offered(itemCount, address(_nft), _tokenId, _price, msg.sender);
    }

    function purchaseItem(uint256 _itemId) external payable nonReentrant {
        uint256 _totalPrice = getTotalPrice(_itemId);
        Item storage item = items[_itemId];

        require(_itemId > 0 && _itemId <= itemCount, "item does not exist");
        require(
            msg.sender >= _totalPrice,
            "not enough ether to cover item price and market fee"
        );
        require(!item.sold, "item already sold");

        // pay seller and feeaccount
        item.seller.transfer(item.price);
        feeAccount.transfer(_totalPrice - item.price);

        // update item to sold
        item.sold = true;

        // transfer nft to buyer
        item.nft.transferFrom(address(this), msg.sender, item.tokenId);

        // emit bought event
        emit Bought(
            _itemId,
            address(item.nft),
            item.tokenId,
            item.price,
            item.seller,
            msg.sender
        );
    }

    function getTotalPrice(uint256 _itemId) public view returns (uint256) {
        return ((items[_itemId].price * (100 + feeParcent)) / 100);
    }
}
