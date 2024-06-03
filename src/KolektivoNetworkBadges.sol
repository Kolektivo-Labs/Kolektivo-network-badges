// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract KolektivoNetworkBadges is ERC1155, Ownable {
    IERC20 private _kolektivoNetworkPoints;
    uint256 public maxBadgeLevel = 0;
    uint256[] public pointsPerTier;

    constructor(
        address initialOwner,
        IERC20 kolektivoNetworkPoints,
        uint256[] memory initialPointsPerTier
    ) ERC1155("") Ownable(initialOwner) {
        _setURI("https://kolektivo.network/badges/{id}.json");
        _kolektivoNetworkPoints = kolektivoNetworkPoints;
        _setInitialPointsPerTier(initialPointsPerTier);
    }

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function mint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public {
        require(id > 0 && id <= maxBadgeLevel, "Invalid badge level");
        require(
            _kolektivoNetworkPoints.balanceOf(account) >= pointsPerTier[id - 1],
            "Insufficient points for this badge level"
        );
        _mint(account, id, amount, data);
    }

    function setPointsRequired(
        uint256 level,
        uint256 points
    ) external onlyOwner {
        require(
            level <= maxBadgeLevel + 1,
            "The level must be the next one in the sequence or lower."
        );
        if (level > 1) {
            require(
                points > pointsPerTier[level - 2],
                "Points must be in ascending order"
            );
        }
        if (level <= maxBadgeLevel && level < pointsPerTier.length) {
            require(
                points < pointsPerTier[level],
                "Points must be in ascending order"
            );
        }

        if (level > maxBadgeLevel) {
            pointsPerTier.push(points);
            maxBadgeLevel = level;
        } else {
            pointsPerTier[level - 1] = points;
        }
    }

    function getPointsRequired(uint256 level) external view returns (uint256) {
        require(level > 0 && level <= maxBadgeLevel, "Invalid badge level");
        return pointsPerTier[level - 1];
    }

    function _setInitialPointsPerTier(
        uint256[] memory initialPointsPerTier
    ) internal {
        uint256 tail = 0;
        for (uint256 i = 0; i < initialPointsPerTier.length; i++) {
            require(
                tail < initialPointsPerTier[i],
                "Points must be in ascending order"
            );
            pointsPerTier.push(initialPointsPerTier[i]);
            tail = initialPointsPerTier[i];
        }
        maxBadgeLevel = initialPointsPerTier.length;
    }
}
