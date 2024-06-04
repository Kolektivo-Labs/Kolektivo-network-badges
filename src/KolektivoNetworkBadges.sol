    // SPDX-License-Identifier: MIT
    // Compatible with OpenZeppelin Contracts ^5.0.0
    pragma solidity ^0.8.20;

    import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
    import "@openzeppelin/contracts/access/Ownable.sol";
    import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

    contract KolektivoNetworkBadges is ERC1155, Ownable {
        IERC20 private _kolektivoNetworkStamps;
        uint256 public maxBadgeLevel = 0;
        uint256[] public stampsPerTier;

        // Mapping to track the highest level minted by each user
        mapping(address => uint256) private _lastMintedLevel;

        constructor(
            address initialOwner,
            IERC20 kolektivoNetworkStamps,
            uint256[] memory initialStampsPerTier,
            string memory uri
        )
            ERC1155(uri)
            Ownable(initialOwner)
        {
            _kolektivoNetworkStamps = kolektivoNetworkStamps;
            _setInitialStampsPerTier(initialStampsPerTier);
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
                _kolektivoNetworkStamps.balanceOf(account) >= stampsPerTier[id - 1],
                "Insufficient stamps for this badge level"
            );
            require(
                _lastMintedLevel[account] + 1 == id,
                "Levels must be minted sequentially"
            );
            _mint(account, id, amount, data);
            _lastMintedLevel[account] = id;
        }

        function setStampsRequired(
            uint256 level,
            uint256 stamps
        ) external onlyOwner {
            require(
                level <= maxBadgeLevel + 1,
                "The level must be the next one in the sequence or lower."
            );
            if (level > 1) {
                require(
                    stamps > stampsPerTier[level - 2],
                    "Stamps must be in ascending order"
                );
            }
            if (level <= maxBadgeLevel && level < stampsPerTier.length) {
                require(
                    stamps < stampsPerTier[level],
                    "Stamps must be in ascending order"
                );
            }

            if (level > maxBadgeLevel) {
                stampsPerTier.push(stamps);
                maxBadgeLevel = level;
            } else {
                stampsPerTier[level - 1] = stamps;
            }
        }

        function getStampsRequired(uint256 level) external view returns (uint256) {
            require(level > 0 && level <= maxBadgeLevel, "Invalid badge level");
            return stampsPerTier[level - 1];
        }

        function getLastMintedLevel(
            address account
        ) external view returns (uint256) {
            return _lastMintedLevel[account];
        }

        function _setInitialStampsPerTier(
            uint256[] memory initialStampsPerTier
        ) internal {
            uint256 tail = 0;
            for (uint256 i = 0; i < initialStampsPerTier.length; i++) {
                require(
                    tail < initialStampsPerTier[i],
                    "Stamps must be in ascending order"
                );
                stampsPerTier.push(initialStampsPerTier[i]);
                tail = initialStampsPerTier[i];
            }
            maxBadgeLevel = initialStampsPerTier.length;
        }
    }
