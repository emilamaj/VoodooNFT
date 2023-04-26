// This is the deployment script for the project. It deploys the follwing smart contracts: "GameNFT.sol" and "GameMint.sol".

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../lib/forge-std/src/Script.sol";
import "../lib/forge-std/src/console.sol";
import "../src/GameNFT.sol";
import "../src/GameMint.sol";

contract DeployContract is Script {
    function run() external {
        uint256 deployerPrivateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80; // 1st address given by Anvil (local node)
        console.log("Deployer private key: ", deployerPrivateKey);

        vm.startBroadcast(deployerPrivateKey);

        string memory BASE_URI = vm.envString("BASE_URI");
        console.log("Base URI: ", BASE_URI);
        GameNFT nftContract = new GameNFT(BASE_URI);
        GameMint mintContract = new GameMint(address(nftContract));

        vm.stopBroadcast();
    }
}
