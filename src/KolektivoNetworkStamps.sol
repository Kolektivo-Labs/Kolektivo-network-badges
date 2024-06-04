// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract KolektivoNetworkStamps is ERC20, Ownable {
    error NonTransferrable();
    constructor(
        address initialOwner
    ) ERC20("KolektivoNetworkStamps", "KNS") Ownable(initialOwner) {}

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    /**
     * @dev See {ERC20-_beforeTokenTransfer} - transfer of token is disabled
     *
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal pure override {
        if (from != address(0)) revert NonTransferrable();
    }
}
