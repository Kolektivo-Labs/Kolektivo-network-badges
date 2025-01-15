### Kolektivo Network Badges Smart Contract Documentation

This documentation provides detailed instructions on how to use and deploy the `KolektivoNetworkBadges` smart contract using Foundry.

#### Prerequisites

- Foundry installed
- OpenZeppelin Contracts

### Overview

The `KolektivoNetworkBadges` contract is an ERC1155 token that represents badges in the Kolektivo network. Each badge level requires a certain number of Kolektivo Network Stamps (ERC20 token) to mint. Users must mint badge levels sequentially and cannot mint the same level more than once.

### Contract Details

- **KolektivoNetworkBadges**: ERC1155 token contract for badges.
- **KolektivoNetworkStamps**: ERC20 token contract representing Kolektivo Network Stamps.

### Usage

#### Deployment

To deploy the `KolektivoNetworkBadges` and `KolektivoNetworkStamps` contracts, follow these steps:

1. **Install Foundry:**

   If you haven't already installed Foundry, follow the installation instructions [here](https://getfoundry.sh/).

2. **Prepare the Deployment Script:**

   Create a `Deploy.sol` script in the `script` folder:

   ```solidity
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
            uint256[] memory points = new uint256[](3);
            points[0] = 1 * DECIMALS;
            points[1] = 5 * DECIMALS;
            points[2] = 10 * DECIMALS;
            KolektivoNetworkStamps stamps = new KolektivoNetworkStamps(
                address(this)
            );
            KolektivoNetworkBadges badges = new KolektivoNetworkBadges(
                address(this),
                stamps,
                points
            );

           console.log("Stamps deployed at: ", address(stamps));
           console.log("Badges deployed at: ", address(badges));
       }
   }
   ```


3. **Compile the Contracts:**

   Compile the contracts using Foundry:

   ```bash
   forge build
   ```

4. **Run the Deployment Script:**

   Use Foundry to run the deployment script:

   ```bash
   forge script script/Deploy.sol --rpc-url <YOUR_RPC_URL> --private-key <YOUR_PRIVATE_KEY> --broadcast
   ```



#### Factory Contract:

   - The `KolektivoNetworkFactory` contract is responsible for deploying `KolektivoNetworkBadges` and `KolektivoNetworkStamps` contracts.
   - It stores the addresses of the deployed contracts for later retrieval.
   - The `createKolektivoNetworkBadges` function deploys a new `KolektivoNetworkBadges` contract and stores its address along with the address of the associated ERC20 contract.
   - The `createKolektivoNetworkStamps` function deploys a new `KolektivoNetworkStamps` contract and stores its address.
   - The `getBadgesContracts` and `getStampsContracts` functions return the addresses of the deployed `KolektivoNetworkBadges` and `KolektivoNetworkStamps` contracts respectively.

1. **Setup Function:**

   - Initializes any required setup. Currently, it is empty.

2. **Run Function:**
   - Deploys the `KolektivoNetworkStamps` contract.
   - Deploys the `KolektivoNetworkBadges` contract with the address of the `KolektivoNetworkStamps` contract and the initial points required for each badge level.
   - Logs the deployed contract addresses.


### Contract Functions

#### `KolektivoNetworkBadges`

- **Constructor:**

  ```solidity
  constructor(
      address initialOwner,
      IERC20 kolektivoNetworkPoints,
      uint256[] memory initialPointsPerTier
  ) ERC1155("") Ownable(initialOwner) {
      _setURI("https://kolektivo.network/badges/{id}.json");
      _kolektivoNetworkPoints = kolektivoNetworkPoints;
      _setInitialPointsPerTier(initialPointsPerTier);
  }
  ```

  Deploy the contract with the initial owner, the address of the Kolektivo Network Points contract, and an array of initial points required for each tier.

- **setURI(string memory newuri):**

  Sets the base URI for all token types.

  ```solidity
  function setURI(string memory newuri) public onlyOwner {
      _setURI(newuri);
  }
  ```

- **mint(address account, uint256 id):**

  Mints a new badge token for the specified account, mind the id is the level you want to mint (starts on 1, SO IMPORTANT).

  ```solidity
  function mint(
      address account,
      uint256 id
  ) public {
      require(id > 0 && id <= maxBadgeLevel, "Invalid badge level");
      require(
          _kolektivoNetworkPoints.balanceOf(account) >= pointsPerTier[id - 1],
          "Insufficient points for this badge level"
      );
      require(
          _lastMintedLevel[account] + 1 == id,
          "Levels must be minted sequentially"
      );

      _mint(account, id, 1, "");
      _lastMintedLevel[account] = id;
  }
  ```

- **setPointsRequired(uint256 level, uint256 points):**

  Sets the points required for a specific level.

  ```solidity
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
  ```

- **getPointsRequired(uint256 level):**

  Returns the points required for a specific level.

  ```solidity
  function getPointsRequired(uint256 level) external view returns (uint256) {
      require(level > 0 && level <= maxBadgeLevel, "Invalid badge level");
      return pointsPerTier[level - 1];
  }
  ```

- **getLastMintedLevel(address account):**

  Returns the last badge level minted by the specified account.

  ```solidity
  function getLastMintedLevel(address account) external view returns (uint256) {
      return _lastMintedLevel[account];
  }
  ```

### Deployment Script Details

The deployment script (`Deploy.sol`) initializes and deploys the `KolektivoNetworkStamps` and `KolektivoNetworkBadges` contracts.

```solidity
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
        uint256[] memory points = new uint256[](3);
        points[0] = 1 * DECIMALS;
        points[1] = 5 * DECIMALS;
        points[2] = 10 * DECIMALS;
        KolektivoNetworkStamps stamps = new KolektivoNetworkStamps(
            address(this)
        );
        KolektivoNetworkBadges badges = new KolektivoNetworkBadges(
            address(this),
            stamps,
            points
        );

        console.log("Stamps deployed at: ", address(stamps));
        console.log("Badges deployed at: ", address(badges));
    }
}
```

1. **Setup Function:**

   - Initializes any required setup. Currently, it is empty.

2. **Run Function:**
   - Deploys the `KolektivoNetworkStamps` contract.
   - Deploys the `KolektivoNetworkBadges` contract with the address of the `KolektivoNetworkStamps` contract and the initial points required for each badge level.
   - Logs the deployed contract addresses.

### Conclusion

This documentation provides a detailed guide on how to use and deploy the `KolektivoNetworkBadges` smart contract using Foundry. Follow the steps outlined to successfully deploy and interact with the contract. If you encounter any issues or have further questions, please refer to the official OpenZeppelin and Foundry documentation or reach out to the Kolektivo network support team.
