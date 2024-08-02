
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IKolektivoNetworkStamps {
    event TokensMinted(address indexed to, uint256 amount);

    function mint(address to, uint256 amount) external;
}
