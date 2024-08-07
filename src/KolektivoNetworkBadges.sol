// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import {IKolektivoNetworkBadges} from './interfaces/IKolektivoNetworkBadges.sol';

contract KolektivoNetworkBadges is ERC1155URIStorage, Ownable, IKolektivoNetworkBadges {
    IERC20 private _kolektivoNetworkStamps;
    uint256 public maxBadgeLevel = 0;
    uint256[] public stampsPerTier;

    // Mapping to track the highest level minted by each user
    mapping(address => uint256) public _lastMintedLevel;

    constructor(
        address initialOwner,
        IERC20 kolektivoNetworkStamps,
        uint256[] memory initialStampsPerTier,
        string memory URI,
        string memory baseURI
    ) ERC1155(URI) Ownable(initialOwner) {
        _kolektivoNetworkStamps = kolektivoNetworkStamps;
        _setInitialStampsPerTier(initialStampsPerTier);
        _setBaseURI(baseURI);
    }

    function mint(address account, uint256 id) public {
        require(id > 0 && id <= maxBadgeLevel, "Invalid badge level");
        require(
            _kolektivoNetworkStamps.balanceOf(account) >= stampsPerTier[id - 1],
            "Insufficient stamps for this badge level"
        );
        require(
            _lastMintedLevel[account] + 1 == id,
            "Levels must be minted sequentially"
        );
        _mint(account, id, 1, "");
        _lastMintedLevel[account] = id;
emit BadgeMinted(account, id);
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
            _setURI(
                level,
                string(abi.encodePacked(_toPaddedHexString(level), ".json"))
            );
            maxBadgeLevel = level;

        } else {
            stampsPerTier[level - 1] = stamps;
        }

emit StampsUpdated(level, stamps);
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
            _setURI(
                i + 1,
                string(abi.encodePacked(_toPaddedHexString(i + 1), ".json"))
            );
            tail = initialStampsPerTier[i];
        }
        maxBadgeLevel = initialStampsPerTier.length;
    }
    function _toPaddedHexString(
        uint256 value
    ) internal pure returns (string memory) {
        bytes memory buffer = new bytes(64);
        for (uint256 i = 64; i > 0; --i) {
            buffer[i - 1] = bytes1(uint8(48 + uint256(value & 0xf)));
            value >>= 4;
        }
        return string(buffer);
    }
        /**
     * @notice Internal function to update token balances
     * @param from The address transferring the tokens
     * @param to The address receiving the tokens
     * @param ids The list of token IDs
     * @param values The list of token amounts
     */
    function _update(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values
    ) internal override(ERC1155) {
        // Ensure that the transfer is either minting, burning
        require(
            from == address(0) ||
                to == address(0), 
            "TRANSFER_NOT_SUPPORTED"
        );

        super._update(from, to, ids, values);
    }

    }
