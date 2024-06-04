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

    /**
     * @dev Creates a new Kolektivo Network Campaign with the specified parameters.
     * @param stampName Name of the stamp token.
     * @param stampSymbol Symbol of the stamp token.
     * @param initialStampsPerTier Initial supply of stamps per tier.
     * @param URI Metadata URI for the badges.
     * @param baseURI Metadata baseURI for the badges.
     * @return stampsContract Address of the created stamps contract.
     * @return badgesContract Address of the created badges contract.
     */
    function createKolektivoNetworkCampaign(
        string memory stampName,
        string memory stampSymbol,
        uint256[] calldata initialStampsPerTier,
        string calldata URI,
        string calldata baseURI
    )
        public
        onlyOwner
        returns (address stampsContract, address badgesContract)
    {
        KolektivoNetworkStamps stamps = new KolektivoNetworkStamps(
            msg.sender,
            stampName,
            stampSymbol
        );
        KolektivoNetworkBadges badges = new KolektivoNetworkBadges(
            msg.sender,
            stamps,
            initialStampsPerTier,
            URI,
            baseURI
        );
        stampsContracts.push(address(stamps));
        badgesContracts.push(address(badges));

        return (address(stamps), address(badges));
    }

    /**
     * @dev Returns the list of badges contracts created by this factory.
     * @return Array of addresses of badges contracts.
     */
    function getBadgesContracts() public view returns (address[] memory) {
        return badgesContracts;
    }

    /**
     * @dev Returns the list of stamps contracts created by this factory.
     * @return Array of addresses of stamps contracts.
     */
    function getStampsContracts() public view returns (address[] memory) {
        return stampsContracts;
    }
}
