// This test file performs general unitary tests for the contract "GameNFT.sol".
// The goal is to test each function independently at least once. More thorough testing is performed in the other test files.

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../lib/forge-std/src/Test.sol";
import "../src/GameNFT.sol";

contract UnitNFT is Test {
    GameNFT public nftContract;
    string constant BASE_URI = "https://localhost:3000/metadata/";
    // In each Foundry test, the setUp() function is called before each test. Tests are independent of each other.
    function setUp() public {
        // Deploy the NFT contract
        nftContract = new GameNFT(BASE_URI);
    }

    // Contract should return storefront metadata .json file
    function test_ContractURI() public { // In Foundry, tests are earmarked with the "test_" keyword prefix.
        // Test the contractURI function
        assertEq(nftContract.contractURI(), "https://localhost:3000/metadata/contract.json");
    }

    // Should return the correct URI for a given token ID
    function test_TokenURI() public {
        // Test the uri function
        assertEq(nftContract.uri(1), "https://localhost:3000/metadata/1.json");
    }

    // Check the supportsInterface function.
    function test_SupportsInterface() public {
        // Test the supportsInterface function
        assertEq(nftContract.supportsInterface(0x01ffc9a7), true); // ERC165
        assertEq(nftContract.supportsInterface(0xd9b67a26), true); // ERC1155
        assertEq(nftContract.supportsInterface(0xdeadbeef), false); // Invalid interface
    }

    // Adds a new MINTER_ROLE to an account, as an admin account. Then removes it.
    function test_AddRemoveMinter() public {
        //// Test with sufficient permissions
        address testRecipient = address(0x123); // Dummy address

        // // Remove role that hasn't been added yet (should fail)
        // vm.expectRevert();
        // nftContract.removeMinterRole(testRecipient); // Silently fails
        assertEq(nftContract.hasRole(nftContract.MINTER_ROLE(), testRecipient), false);
        
        // Add the new MINTER_ROLE
        nftContract.addMinterRole(testRecipient);
        assertEq(nftContract.hasRole(nftContract.MINTER_ROLE(), testRecipient), true);

        // Remove the new MINTER_ROLE
        nftContract.removeMinterRole(testRecipient);
        assertEq(nftContract.hasRole(nftContract.MINTER_ROLE(), testRecipient), false);


        //// Test without permissions
        address spoofedSender = address(0xcafebabe); // Dummy address

        // Spoof as another account for the next CALL encountered by the EVM.
        vm.startPrank(spoofedSender);
        assertEq(nftContract.hasRole(nftContract.DEFAULT_ADMIN_ROLE(), spoofedSender), false);// Make sure that the spoofed account doesn't have the admin role
        vm.expectRevert();
        nftContract.addMinterRole(testRecipient);
        vm.expectRevert();
        nftContract.removeMinterRole(testRecipient);
        vm.stopPrank();
    }

    // Adds a new DEFAULT_ADMIN_ROLE to an account, as an admin account. Then removes it.
    function test_AddRemoveAdmin() public {
        //// Test with sufficient permissions
        address testRecipient = address(0x123); // Dummy address

        // // Remove role that hasn't been added yet (should fail)
        // vm.expectRevert();
        // nftContract.removeAdminRole(testRecipient); // Silently fails
        assertEq(nftContract.hasRole(nftContract.DEFAULT_ADMIN_ROLE(), testRecipient), false);
        
        // Add the new DEFAULT_ADMIN_ROLE
        nftContract.addAdminRole(testRecipient);
        assertEq(nftContract.hasRole(nftContract.DEFAULT_ADMIN_ROLE(), testRecipient), true);

        // Remove the new DEFAULT_ADMIN_ROLE
        nftContract.removeAdminRole(testRecipient);
        assertEq(nftContract.hasRole(nftContract.DEFAULT_ADMIN_ROLE(), testRecipient), false);


        //// Test without permissions
        address spoofedSender = address(0xcafebabe); // Dummy address

        // Spoof as another account for the next CALL encountered by the EVM.
        vm.startPrank(spoofedSender);
        assertEq(nftContract.hasRole(nftContract.DEFAULT_ADMIN_ROLE(), spoofedSender), false);// Make sure that the spoofed account doesn't have the admin role
        vm.expectRevert();
        nftContract.addAdminRole(testRecipient);
        vm.expectRevert();
        nftContract.removeAdminRole(testRecipient);
        vm.stopPrank();
    }
}
