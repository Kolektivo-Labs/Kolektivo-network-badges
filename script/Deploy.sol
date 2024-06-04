// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {KolektivoNetworkBadges} from "../src/KolektivoNetworkBadges.sol";
import {KolektivoNetworkStamps} from "../src/KolektivoNetworkStamps.sol";

contract Deploy is Script {
    KolektivoNetworkStamps public stamps;
    KolektivoNetworkBadges public badges;

    function setUp() public {}

    function run() public {
        uint256 DECIMALS = 1e18;
        vm.broadcast();
        uint256[] memory points = new uint256[](3);
        points[0] = 1 * DECIMALS;
        points[1] = 5 * DECIMALS;
        points[2] = 10 * DECIMALS;
        stamps = new KolektivoNetworkStamps(
            address(this),
            "Kolektivo Network Stamps",
            "KNS"
        );
        badges = new KolektivoNetworkBadges(
            address(this),
            stamps,
            points,
            "https://kolektivo.network/badges/{id}.json",
            "https://kolektivo.network/badges/"

        );

        console.log("Stamps deployed at: ", address(stamps));
        console.log("Badges deployed at: ", address(badges));
    }
}
