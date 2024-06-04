// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {KolektivoNetworkBadges} from "../src/KolektivoNetworkBadges.sol";
import {KolektivoNetworkStamps} from "../src/KolektivoNetworkStamps.sol";

contract Deploy is Script {
    function setUp() public {}

    function run() public {
        uint256 DECIMALS = 1e18;
        vm.broadcast();
        KolektivoNetworkStamps stamps = new KolektivoNetworkStamps(address(this));
        KolektivoNetworkBadges badges = new KolektivoNetworkBadges(address(this), stamps, [1 * DECIMALS, 5 * DECIMALS, 10 * DECIMALS]);

        console.log("Stamps deployed at: ", address(stamps));
        console.log("Badges deployed at: ", address(badges));
    }
}
