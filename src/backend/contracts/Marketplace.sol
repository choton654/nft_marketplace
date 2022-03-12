// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Marketplace is ReentrancyGuard {
    //  state variables
    address payable public immutable feeAccount;
    uint256 public immutable feeParcent;
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
}
