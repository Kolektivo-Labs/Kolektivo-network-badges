// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract KolektivoNetworkStamps is ERC20, Ownable {
    // error NonTransferrable();
    constructor(
        address initialOwner,
        string memory name,
        string memory symbol
    ) ERC20(name, symbol) Ownable(initialOwner) {}

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    // /**
    //  * @dev Being non transferrable, the Stamp token does not implement any of the
    //  * standard ERC20 functions for transfer and allowance.
    //  **/
    // function transfer(
    //     address recipient,
    //     uint256 amount
    // ) public virtual override returns (bool) {
    //     recipient;
    //     amount;
    //     revert("TRANSFER_NOT_SUPPORTED");
    // }

    // function transferFrom(
    //     address sender,
    //     address recipient,
    //     uint256 amount
    // ) public virtual override returns (bool) {
    //     sender;
    //     recipient;
    //     amount;
    //     revert("TRANSFER_NOT_SUPPORTED");
    // }

    // function allowance(
    //     address owner,
    //     address spender
    // ) public view virtual override returns (uint256) {
    //     owner;
    //     spender;
    //     revert("ALLOWANCE_NOT_SUPPORTED");
    // }

    // function approve(
    //     address spender,
    //     uint256 amount
    // ) public virtual override returns (bool) {
    //     spender;
    //     amount;
    //     revert("APPROVAL_NOT_SUPPORTED");
    // }
}
