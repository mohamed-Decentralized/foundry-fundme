// Deploy mocks when we are on a local anvil chain
// Keep track of contract address across different chains
// Sepolia ETH/USD
// MainNet ETH/USD

// SPDX-License-Identifier: MIT
pragma solidity ^0.8;
import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockerV3Aggregator.sol";

contract HelperConfig is Script {
    // if we are on a local anvil we deploy mocks
    // otherwise grab the existing address from the live network
    struct NetworkConfig {
        address priceFeed; // ETH/USD priceFeed Address
    }
    NetworkConfig public activeNetworkConfig;
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaETHConfig();
        } else {
            activeNetworkConfig = getAnvilETHConfig();
        }
    }

    function getSepoliaETHConfig() public pure returns (NetworkConfig memory) {
        // price feed address
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

    function getAnvilETHConfig() public returns (NetworkConfig memory) {
        if(activeNetworkConfig.priceFeed != address(0)){
            return activeNetworkConfig;
        }
        // price feed address
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );
        vm.stopBroadcast();
        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });
        return anvilConfig;
    }
}
