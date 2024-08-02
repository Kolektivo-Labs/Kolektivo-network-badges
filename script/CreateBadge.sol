// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {KolektivoNetworkFactory} from "../src/KolektivoNetworkFactory.sol";

contract CreateBadge is Script {
    KolektivoNetworkFactory public factory;

    function setUp() public {}

    function run() public {
        uint256 DECIMALS = 1e18;

        vm.broadcast();
        factory = KolektivoNetworkFactory(0x2Cc6fBbcBcD8996ce6cAaFa09fD1c9F410CB248b);
        console.log("Factory at: ", address(factory));
        uint256[] memory points = new uint256[](3);
        points[0] = 1 * DECIMALS;
        points[1] = 3 * DECIMALS;
        points[2] = 10 * DECIMALS;
        factory.createKolektivoNetworkCampaign(
            "PlasticRecoveryStamp",
            "PRS",
            points,
            "https://ipfs.io/ipfs/QmY6XWozzea9Pwy2N2NM4YFRYKdfi9BTTQGzyDR4indd6q/{id}.json",
            "https://ipfs.io/ipfs/QmY6XWozzea9Pwy2N2NM4YFRYKdfi9BTTQGzyDR4indd6q/"
        );
    }
}
