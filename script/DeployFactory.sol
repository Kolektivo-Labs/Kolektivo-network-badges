// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {KolektivoNetworkFactory} from "../src/KolektivoNetworkFactory.sol";

contract DeployFactory is Script {
    KolektivoNetworkFactory public factory;

    function setUp() public {}

    function run() public {
        vm.broadcast();
        factory = new KolektivoNetworkFactory(address(this));
        console.log("Factory deployed at: ", address(factory));
    }
}
