// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract KolektivoNetworkBadges is ERC1155, Ownable {
    IERC20 private _kolektivoNetworkPoints;
    
    constructor(address initialOwner,IERC20 kolektivoNetworkPoints ) ERC1155("") Ownable(initialOwner) {
        _setURI("https://kolektivo.network/badges/{id}.json");
        _kolektivoNetworkPoints = kolektivoNetworkPoints;
    }

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function mint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public onlyOwner {
        _mint(account, id, amount, data);
    }

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public onlyOwner {
        _mintBatch(to, ids, amounts, data);
    }
}
