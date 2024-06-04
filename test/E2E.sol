// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {KolektivoNetworkBadges} from "../src/KolektivoNetworkBadges.sol";
import {KolektivoNetworkStamps} from "../src/KolektivoNetworkStamps.sol";
import {console2} from "forge-std/console2.sol";

contract KolektivoE2ETest is Test {
    KolektivoNetworkStamps private stamps;
    KolektivoNetworkBadges private badges;
    address private owner = address(this);
    address private user = address(0x123);

    function setUp() public {
        uint256 DECIMALS = 1e18;
        uint256[] memory points = new uint256[](3);
        points[0] = 1 * DECIMALS;
        points[1] = 5 * DECIMALS;
        points[2] = 10 * DECIMALS;

        stamps = new KolektivoNetworkStamps(
            owner,
            "Kolektivo Network Stamps",
            "KNS"
        );
        badges = new KolektivoNetworkBadges(
            owner,
            stamps,
            points,
            "https://kolektivo.network/badges/{id}.json",
            "https://kolektivo.network/badges"
        );
    }

    function testE2E() public {
        // Mint initial stamps to the user
        uint256 mintAmount = 20 * 1e18;
        stamps.mint(user, mintAmount);
        assertEq(stamps.balanceOf(user), mintAmount);

        // User mints level 1 badge
        vm.prank(user);
        badges.mint(user, 1, 1, "");
        assertEq(badges.balanceOf(user, 1), 1);
        assertEq(badges.getLastMintedLevel(user), 1);

        // User mints level 2 badge
        vm.prank(user);
        badges.mint(user, 2, 1, "");
        assertEq(badges.balanceOf(user, 2), 1);
        assertEq(badges.getLastMintedLevel(user), 2);

        // User mints level 3 badge
        vm.prank(user);
        badges.mint(user, 3, 1, "");
        assertEq(badges.balanceOf(user, 3), 1);
        assertEq(badges.getLastMintedLevel(user), 3);

        // Ensure user cannot mint level 4 as it doesn't exist yet
        vm.expectRevert("Invalid badge level");
        vm.prank(user);
        badges.mint(user, 4, 1, "");
    }

    function testMintWithoutEnoughPoints() public {
        // User tries to mint level 1 badge without enough stamps
        uint256 insufficientStamps = 0.5 * 1e18;
        stamps.mint(user, insufficientStamps);
        vm.expectRevert("Insufficient stamps for this badge level");
        vm.prank(user);
        badges.mint(user, 1, 1, "");
    }

    function testMintOutOfOrder() public {
        uint256 mintAmount = 10 * 1e18;
        stamps.mint(user, mintAmount);

        // Attempt to mint level 2 without minting level 1 should fail
        vm.expectRevert("Levels must be minted sequentially");
        vm.prank(user);
        badges.mint(user, 2, 1, "");
    }

    function testNonTransferrableStamps() public {
        uint256 mintAmount = 10 * 1e18;
        stamps.mint(user, mintAmount);

        vm.expectRevert("TRANSFER_NOT_SUPPORTED");
        vm.prank(user);
        stamps.transfer(address(0x456), mintAmount);

        vm.expectRevert("TRANSFER_NOT_SUPPORTED");
        vm.prank(user);
        stamps.transferFrom(user, address(0x456), mintAmount);

        vm.expectRevert("ALLOWANCE_NOT_SUPPORTED");
        stamps.allowance(user, address(0x456));

        vm.expectRevert("APPROVAL_NOT_SUPPORTED");
        vm.prank(user);
        stamps.approve(address(0x456), mintAmount);
    }

    function testURIs() public {
        uint256 DECIMALS = 1e18;
        uint256[] memory points = new uint256[](3);
        points[0] = 1 * DECIMALS;
        points[1] = 5 * DECIMALS;
        points[2] = 10 * DECIMALS;

        stamps = new KolektivoNetworkStamps(
            owner,
            "Kolektivo Network Stamps",
            "KNS"
        );
        badges = new KolektivoNetworkBadges(
            owner,
            stamps,
            points,
            "https://kolektivo.network/badges/{id}.json",
            "https://kolektivo.network/badges/"
        );

        // Mint initial stamps to the user
        uint256 mintAmount = 20 * 1e18;
        stamps.mint(user, mintAmount);

        // Mint level 1 badge and check URI
        vm.prank(user);
        badges.mint(user, 1, 1, "");
        string memory expectedURI1 = "https://kolektivo.network/badges/1.json";
        string memory actualURI1 = badges.uri(1);
        assertEq(actualURI1, expectedURI1);

        // Mint level 2 badge and check URI
        vm.prank(user);
        badges.mint(user, 2, 1, "");
        string memory expectedURI2 = "https://kolektivo.network/badges/2.json";
        string memory actualURI2 = badges.uri(2);
        assertEq(actualURI2, expectedURI2);

        // Mint level 3 badge and check URI
        vm.prank(user);
        badges.mint(user, 3, 1, "");
        string memory expectedURI3 = "https://kolektivo.network/badges/3.json";
        string memory actualURI3 = badges.uri(3);
        assertEq(actualURI3, expectedURI3);
    }
}
