## Documentation for Kolektivo Network Contracts

This document describes the functionality and deployment steps for the **Kolektivo Network** contracts that make up the **Badges** and **Stamps** system, using [Foundry](https://getfoundry.sh/) as the development environment. The contracts are based on [OpenZeppelin Contracts ^5.0.0](https://docs.openzeppelin.com/contracts/5.x/) and leverage advanced features such as access control, ERC20, ERC1155, and extensions.

---

## Prerequisites

1. **Foundry**: Ensure Foundry is installed. You can find the installation instructions at [getfoundry.sh](https://getfoundry.sh/).

2. **OpenZeppelin Contracts**: The contracts use the OpenZeppelin library version ^5.0.0, so make sure your dependencies are up-to-date.

---

## General Overview

The system consists of the following main contracts:

1. **KolektivoNetworkStamps (ERC20)**  
   - Represents the "stamps" that users accumulate within the Kolektivo network.
   - This token is **NOT** freely transferable. It can only be minted or burned—other transfers are disabled via the `_update` method.

2. **KolektivoNetworkBadges (ERC1155)**  
   - Represents the **badges** that grant recognition within the Kolektivo network.
   - Each badge level requires a certain number of **stamps** to mint.
   - Badges must be minted sequentially: users cannot skip levels or mint the same level more than once.
   - Uses the `ERC1155URIStorage` extension to allow individual URIs for each token ID.

3. **KolektivoNetworkFactory**  
   - A factory contract that facilitates the creation of new KolektivoNetworkStamps and KolektivoNetworkBadges deployments.
   - Exposes the `createKolektivoNetworkCampaign` function, which creates both the Stamps (ERC20) and Badges (ERC1155) contracts in a single call.
   - Allows querying of deployed contract addresses.

### General Flow

1. **Users accumulate Stamps** (ERC20) through minting (admin/owner-controlled).  
2. **Users mint Badges** in ascending order, provided they meet the "Stamps" requirements.

---

## Contract Details

### KolektivoNetworkStamps (ERC20)

- **File**: `KolektivoNetworkStamps.sol`
- **Inheritance**: 
  - `ERC20` for standard fungible token functionality.
  - `Ownable` to restrict certain operations to the owner.
- **Restricted Transfers**:  
  The contract overrides the internal `_update` function of `ERC20` to allow only minting and burning. Any attempt to transfer tokens between accounts (other than mint or burn) will revert.

**Key Points**:
- Only the owner can mint tokens (via the `mint` function).
- Regular transfers are not allowed (only mint/burn).
- The `TokensMinted(address to, uint256 amount)` event is emitted on every successful mint.

```solidity
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {IKolektivoNetworkStamps} from './interfaces/IKolektivoNetworkStamps.sol';

contract KolektivoNetworkStamps is ERC20, Ownable, IKolektivoNetworkStamps {
    constructor(
        address initialOwner,
        string memory name,
        string memory symbol
    ) ERC20(name, symbol) Ownable(initialOwner) {}

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
        emit TokensMinted(to, amount);
    }

    /**
     * @notice Overrides the internal function to update balances.
     *         Only allows minting (from == address(0)) or burning (to == address(0)).
     */
    function _update(
        address from,
        address to,
        uint256 value
    ) internal override(ERC20) {
        require(
            from == address(0) || to == address(0),
            "TRANSFER_NOT_SUPPORTED"
        );
        super._update(from, to, value);
    }
}
```

### KolektivoNetworkBadges (ERC1155)

- **File**: `KolektivoNetworkBadges.sol`
- **Inheritance**:
  - `ERC1155URIStorage` for individual URIs per token ID.
  - `Ownable` for admin-controlled functions.
- **Sequential Levels**:
  - Badges must be minted in order (1, 2, 3, ...).
  - Each level requires an increasing number of **Stamps**.
  - The requirements for each level are stored in `stampsPerTier`.
- **Restricted Transfers**:
  - Similar to Stamps, the `_update` method ensures only minting and burning are allowed, prohibiting free transfers of badges.

**Events**:
- `BadgeMinted(address indexed account, uint256 indexed level)`: Emitted when a badge is minted.
- `StampsUpdated(uint256 indexed level, uint256 stamps)`: Emitted when the number of stamps required for a level is updated.

```solidity
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

    // Maps accounts to the last level minted
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
            // Dynamically assign the URI for the new level
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
}
```

### KolektivoNetworkFactory

- **File**: `KolektivoNetworkFactory.sol`
- **Functionality**:
  - Facilitates the creation of new **KolektivoNetworkStamps** and **KolektivoNetworkBadges** deployments via the `createKolektivoNetworkCampaign` function.
  - Stores the addresses of deployed contracts in public arrays for easy retrieval.
  - Requires ownership (`Ownable`) to create new contracts.

#### Functions

1. **createKolektivoNetworkCampaign**
   - Deploys a new set of **Stamps** and **Badges** contracts with specified parameters.
   - Adds the deployed contract addresses to `stampsContracts` and `badgesContracts` arrays.
   - Returns the addresses of the deployed contracts.

2. **getBadgesContracts**
   - Returns the array of deployed badge contract addresses.

3. **getStampsContracts**
   - Returns the array of deployed stamp contract addresses.

```solidity
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
     * @dev Creates a new Kolektivo Network campaign with the specified parameters.
     * @param stampName Name of the stamp token.
     * @param stampSymbol Symbol of the stamp token.
     * @param initialStampsPerTier Array of stamps required per badge level.
     * @param URI Metadata URI for the badges.
     * @param baseURI Base URI for badge metadata.
     * @return stampsContract Address of the created stamp contract.
     * @return badgesContract Address of the created badge contract.
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
     * @dev Returns the list of deployed badge contracts.
     */
    function getBadgesContracts() public view returns (address[] memory) {
        return badgesContracts;
    }

    /**
     * @dev Returns the list of deployed stamp contracts.
     */
    function getStampsContracts() public view returns (address[] memory) {
        return stampsContracts;
    }
}
```

---

## Deployment and Usage

### 1. Prepare the Deployment Scripts

This section includes two deployment scripts: 

1. **Deploy the Factory**: Deploys the `KolektivoNetworkFactory`.
2. **Create Badges**: Uses the factory to create a badge campaign.

#### 1.1. Deploy the Factory (`DeployFactory.sol`)

This script deploys the `KolektivoNetworkFactory` with the deployer (`msg.sender`) as the owner.

```solidity
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {KolektivoNetworkFactory} from "../src/KolektivoNetworkFactory.sol";

contract DeployFactory is Script {
    KolektivoNetworkFactory public factory;

    function setUp() public {}

    function run() public {
        // Broadcast the transaction
        vm.broadcast();
        factory = new KolektivoNetworkFactory(msg.sender);
        console.log("Factory deployed at: ", address(factory));
    }
}
```

##### Steps:
1. **Broadcast** the transaction to deploy the factory.
2. **Log the deployed address** of the factory for future reference.

---

#### 1.2. Create Badges via the Factory (`CreateBadge.sol`)

This script creates a badge campaign by interacting with an already deployed factory contract.

```solidity
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {KolektivoNetworkFactory} from "../src/KolektivoNetworkFactory.sol";

contract CreateBadge is Script {
    KolektivoNetworkFactory public factory;

    function setUp() public {}

    function run() public {
        uint256 DECIMALS = 1e18;

        // Broadcast the transaction
        vm.broadcast();

        // Initialize the factory with the known address
        factory = KolektivoNetworkFactory(<FactoryAddress>);
        console.log("Factory at: ", address(factory));

        // Define the points required for each badge level
        uint256;
        points[0] = 1 * DECIMALS;
        points[1] = 3 * DECIMALS;
        points[2] = 10 * DECIMALS;

        // Create a new badge campaign via the factory
        factory.createKolektivoNetworkCampaign(
            "<Campaign Name>",
            "<Stamps Symbol>",
            points,
            "https://ipfs.io/ipfs/<IPFS_ID>/{id}.json",
            "https://ipfs.io/ipfs/<IPFS_ID>/"
        );
    }
}
```

##### Steps:
1. Set up the `factory` instance with its deployed address (replace the placeholder `<FactoryAddress>` with the actual factory address from the first script).
2. Define an array of points (`stampsPerTier`) required for each badge level.
3. Call `createKolektivoNetworkCampaign` with the desired parameters:
   - **Stamp Name**: `"PlasticRecoveryStamp"`
   - **Stamp Symbol**: `"PRS"`
   - **Points Required**: `[1e18, 3e18, 10e18]`
   - **URI**: Base metadata URI for badges.
   - **Base URI**: Used for metadata URI composition.

---

### 2. Compile the Scripts

Run the following command to compile all contracts and scripts:

```bash
forge build
```

---

### 3. Deploy the Factory

To deploy the factory, use the `DeployFactory.sol` script. Run the following command:

```bash
forge script script/DeployFactory.sol \
  --rpc-url <YOUR_RPC_URL> \
  --private-key <YOUR_PRIVATE_KEY> \
  --broadcast
```

The script will log the deployed factory address. Save this address for use in the next script.

---

### 4. Create a Badge Campaign

To create a badge campaign, use the `CreateBadge.sol` script. Replace the placeholder factory address (`0x2Cc6fBbcBcD8996ce6cAaFa09fD1c9F410CB248b`) with the actual factory address obtained from the previous step.

Run the script with the following command:

```bash
forge script script/CreateBadge.sol \
  --rpc-url <YOUR_RPC_URL> \
  --private-key <YOUR_PRIVATE_KEY> \
  --broadcast
```

The new badge campaign will be created, and the transaction logs will show the result.

---

## Interaction with the Contracts

### KolektivoNetworkStamps

- **Minting**: Only the owner can mint tokens via the `mint` function:  
  ```solidity
  stamps.mint(0xAbCd..., 1000 * 1e18);
  ```
- **Transfers**: Transfers are not allowed unless the `from` or `to` address is `address(0)` (for minting or burning).

### KolektivoNetworkBadges

- **Minting**: To mint a badge of level `id`, the user must:
  - Hold the required number of stamps.
  - Have minted the previous level.  
  Example:
  ```solidity
  badges.mint(0xAbCd..., 1); // Mint level 1
  badges.mint(0xAbCd..., 2); // Mint level 2
  ...
  ```
- **Sequential Levels**:
  - The last minted badge level by `account` must be `id - 1`.
  - The stamps required for each level are defined in `stampsPerTier[id - 1]`.

- **Updating Stamps Required**:
  - Only the owner can call `setStampsRequired(level, stamps)` to change the required stamps for an existing level or add a new level (`level = maxBadgeLevel + 1`).

### KolektivoNetworkFactory

- **createKolektivoNetworkCampaign**:
  - Deploys a new pair of contracts (Stamps and Badges) with specified initial parameters.
  - Stores the addresses of the new contracts in arrays, retrievable via `getStampsContracts()` and `getBadgesContracts()`.

---

## Conclusion

This updated documentation provides a comprehensive guide on using the **KolektivoNetworkStamps**, **KolektivoNetworkBadges**, and **KolektivoNetworkFactory** contracts, along with deployment steps using Foundry.

### Key Features:

- **Stamps (ERC20)**:
  - Non-transferable (mint/burn only).
  - Owner-controlled issuance.

- **Badges (ERC1155)**:
  - Sequential levels with increasing stamp requirements.
  - Non-transferable (mint/burn only).
  - Supports unique URIs per level.

- **Factory**:
  - Simplifies the creation of new campaigns.
  - Maintains a registry of deployed contracts.

For further details, refer to the [Foundry documentation](https://book.getfoundry.sh/) and [OpenZeppelin](https://docs.openzeppelin.com/contracts/5.x/). 