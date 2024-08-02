  // SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;


interface IKolektivoNetworkBadges{
  
    event BadgeMinted(address indexed account, uint256 indexed id);
    event StampsUpdated(uint256 indexed level, uint256 stamps);
    function mint(address account, uint256 id) external;
    function setStampsRequired(uint256 level, uint256 stamps) external;
    function getStampsRequired(uint256 level) external view returns (uint256);
    function getLastMintedLevel(address account) external view returns (uint256);
}
