// This is the deployment script for the project. It deploys the follwing smart contracts: "GameNFT.sol" and "GameMint.sol".

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../lib/forge-std/src/Script.sol";
import "../lib/forge-std/src/console.sol";
import "../src/GameNFT.sol";
import "../src/GameMint.sol";

contract DeployContract is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        console.log("Deployer private key: ", deployerPrivateKey);

        string memory BASE_URI = vm.envString("BASE_URI");
        console.log("Base URI: ", BASE_URI);

        vm.startBroadcast(deployerPrivateKey);

        GameNFT nftContract = new GameNFT(BASE_URI);
        GameMint mintContract = new GameMint(address(nftContract));

        vm.stopBroadcast();
    }
}
