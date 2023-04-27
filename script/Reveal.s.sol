// This is the deployment script for the project. It deploys the follwing smart contracts: "GameNFT.sol" and "GameMint.sol".

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../lib/forge-std/src/Script.sol";
import "../lib/forge-std/src/console.sol";
import "../src/GameMint.sol";

contract RevealSecret is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        console.log("Deployer private key: ", deployerPrivateKey);

        // Read the address of the Mint contract from a local file
        string memory path = "./mintAddress.txt"; // The path is relative to the root of the project folder.
        string memory strAddress = vm.readLine(path);
        address addr = vm.parseAddress(strAddress);
        console.log("Mint contract address: ", addr);
        GameMint mintContract = GameMint(addr);
        
        uint256 adminSecret = vm.envUint("ADMIN_SECRET_UINT256");
        console.log("Admin secret to be revealed: ", adminSecret);

        /////////////////////////////
        // //NOTE 1: Sometimes, the deployment fails for unknown reasons, and to redeploy, the nonce of the transcation needs to be bumped by 1.
        // vm.setNonce(address(this), vm.getNonce(address(this)) + 1);
        /////////////////////////////
        vm.startBroadcast(deployerPrivateKey);
        mintContract.adminReveal(adminSecret);
        vm.stopBroadcast();

        
        //NOTE Sometimes, the deployment fails for unknown reasons, and to redeploy, the nonce of the transcation needs to be bumped by 1.
        console.log("If the transaction fails for 'gas underpriced' reasons, uncomment the line after 'NOTE 1'.");
    }
}
