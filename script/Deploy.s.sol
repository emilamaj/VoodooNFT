// This is the deployment script for the project. It deploys the follwing smart contracts: "GameNFT.sol" and "GameMint.sol".

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../lib/forge-std/src/Script.sol";
import "../lib/forge-std/src/console.sol";
import "../src/GameNFT.sol";
import "../src/GameMint.sol";
import "../lib/openzeppelin-contracts/contracts/utils/Strings.sol";

contract DeployContract is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        console.log("Deployer private key: ", deployerPrivateKey);

        string memory BASE_URI = vm.envString("BASE_URI");
        console.log("Base URI: ", BASE_URI);

        uint256 id_count = vm.envUint("NFT_ID_COUNT");
        console.log("NFT ID count: ", id_count);

        vm.startBroadcast(deployerPrivateKey);

        // Deploy the NFT contract
        GameNFT nftContract = new GameNFT(BASE_URI);

        // Deploy the Mint contract
        GameMint mintContract = new GameMint(address(nftContract), id_count);

        // Grant MINTER_ROLE to the Mint contract
        nftContract.addMinterRole(address(mintContract));

        vm.stopBroadcast();

        // Write both addresses to a local file
        string memory path = "./nftAddress.txt"; // The path is relative to the root of the project folder.
        string memory data = Strings.toHexString(
            uint256(uint160(address(nftContract))),
            20
        );
        vm.writeFile(path, data);

        string memory path2 = "./mintAddress.txt"; // The path is relative to the root of the project folder.
        string memory data2 = Strings.toHexString(
            uint256(uint160(address(mintContract))),
            20
        );
        vm.writeFile(path2, data2);

        /*Create a .json file with the following content:
        {
            "deployed": true,
            "nftContractAddress": "0x7750069da7917855f54c01016343e8dae39654b2",
            "mintContractAddress": "0xf3f93b31430744e99518bb6b2a6a9ac72f9ce874",
            "rpcUrl": "https://polygon-mumbai.g.alchemy.com/v2/2cLxegjcwQTpjyJ71oNmF0ePehN8zDSc"
        }
        The file will be located in ./game-ui/public/params.json */
        string memory path3 = "./game-ui/public/params.json"; // The path is relative to the root of the project folder.
        string memory data3 = '{\n\t"deployed": true,\n\t"nftContractAddress": "';
        data3 = string(abi.encodePacked(data3, Strings.toHexString(uint256(uint160(address(nftContract))), 20)));
        data3 = string(abi.encodePacked(data3, '",\n\t"mintContractAddress": "'));
        data3 = string(abi.encodePacked(data3, Strings.toHexString(uint256(uint160(address(mintContract))), 20)));
        data3 = string(abi.encodePacked(data3, '",\n\t"rpcUrl": "'));
        data3 = string(abi.encodePacked(data3, vm.envString("MUMBAI_RPC_URL")));
        data3 = string(abi.encodePacked(data3, '"\n}'));
        vm.writeFile(path3, data3);
        
    }
}
