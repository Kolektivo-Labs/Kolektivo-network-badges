// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;
import {KolektivoNetworkBadges} from "./KolektivoNetworkBadges.sol";
import {KolektivoNetworkStamps} from "./KolektivoNetworkStamps.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract KolektivoNetworkFactory is Ownable {
    constructor(address initialOwner) Ownable(initialOwner) {}

    address[] public badgesContracts;
    address[] public stampsContracts;

    function createKolektivoNetworkCampaign(
        string memory stampName,
        string memory stampSymbol,
        uint256[] calldata initialStampsPerTier,
        string calldata uri
    ) public onlyOwner returns (address stampsContract, address badgesContract ) {
        KolektivoNetworkStamps stamps = new KolektivoNetworkStamps(
            msg.sender,
            stampName,
            stampSymbol
        );
        KolektivoNetworkBadges badges = new KolektivoNetworkBadges(
            msg.sender,
            stamps,
            initialStampsPerTier,
            uri
        );
        stampsContracts.push(address(stamps));
        badgesContracts.push(address(badges));

        return (address(stamps),address(badges) );
    }

    function createKolektivoNetworkStamps() public {}

    function getBadgesContracts() public view returns (address[] memory) {
        return badgesContracts;
    }

    function getStampsContracts() public view returns (address[] memory) {
        return stampsContracts;
    }
}
