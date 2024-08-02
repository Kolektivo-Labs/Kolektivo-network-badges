// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {IKolektivoNetworkStamps} from './interfaces/IKolektivoNetworkStamps.sol';

contract KolektivoNetworkStamps is ERC20, Ownable, IKolektivoNetworkStamps {
    // error NonTransferrable();
    constructor(
        address initialOwner,
        string memory name,
        string memory symbol
    ) ERC20(name, symbol) Ownable(initialOwner) {}

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
  emit TokensMinted(to, amount);
    }
        /**
     * @notice Internal function to update token balances
     * @param from The address transferring the tokens
     * @param to The address receiving the tokens
     * @param value The list of token amounts
         */
    function _update(
        address from,
        address to,
        uint256 value
    ) internal override(ERC20) {
        // Ensure that the transfer is either minting, burning
        require(
            from == address(0) ||
                to == address(0), 
            "TRANSFER_NOT_SUPPORTED"
        );

        super._update(from, to,  value);
    }
}
