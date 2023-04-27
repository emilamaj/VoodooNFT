// This test file performs general unitary tests for the contract "GameMint.sol".
// The goal is to test each function independently at least once. More thorough testing is performed in the other test files.

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../lib/forge-std/src/Test.sol";
import "../src/GameNFT.sol";
import "../src/GameMint.sol";

contract UnitNFT is Test {
    string constant BASE_URI = "http://localhost:3000/metadata/";
    GameNFT public nftContract;
    GameMint public mintContract;

    uint256 private id_count = 4;
    uint256 private secretNumber = 0xBAD; // Must not be revealed on-chain before the revealBlock
    bytes32 public committedSecretHash; // Calculated in setUpSale()
    uint256 public revealBlock; // Calculated in setUpSale()
    uint256 public setPrice = 0.1 ether; // 0.1 * 10**18 wei

    // In each Foundry test, the setUp() function is called before each test. Tests are independent of each other.
    function setUp() public {
        // Deploy the NFT contract
        nftContract = new GameNFT(BASE_URI);
        mintContract = new GameMint(address(nftContract), id_count);

        // Set the mint contract as a minter for the NFT contract (MINTER_ROLE)
        nftContract.addMinterRole(address(mintContract));
    }

    // Setup the sale of the NFTs. Not a test in itself (will be used in other tests).
    function setUpSale() public {
        // Hash the secret number
        bytes32 _hashedSecret = mintContract._calculateHash(secretNumber);
        committedSecretHash = _hashedSecret;
        revealBlock = block.number + 10;
        mintContract.adminSetup(revealBlock, setPrice, committedSecretHash);
    }

    // Fund a user with X ethers, commit Y ethers to the sale.
    function setUpUserCommit(address testUser, uint256 userBalance, uint256 userCommitment) public {
        vm.startPrank(testUser); // Spoof random account for multiple CALLs
        vm.deal(testUser, userBalance); // Give X ethers to the spoofed account
        mintContract.userCommit{value: userCommitment}(); // Call function with Y ethers
        vm.stopPrank(); // Stop spoofing the account
    }

    // Setup the reveal of the admin secret. Warning: block.number will be set to revealBlock.
    function setUpReveal() public {
        vm.roll(revealBlock); // Cheatcode to set the block number
        mintContract.adminReveal(secretNumber);
    }

    // Test adminSetup() function
    function test_AdminSetup() public {
        setUpSale();

        // Check that the parameters were correctly set
        assertEq(mintContract.isSetup(), true);
        assertEq(mintContract.revealBlock(), revealBlock);
        assertEq(mintContract.nftPrice(), setPrice);
        assertEq(mintContract.hashOfCommitment(), committedSecretHash);
    }

    // Test the commit mechanism that allows the users to commit a purchase of a random NFT.
    function test_UserCommit() public {
        setUpSale();
        address testUser = address(0x1234);

        // Commit with 0 ether
        vm.expectRevert(); // Next EVM CALL is expected to revert
        setUpUserCommit(testUser, 0, 0);

        // Commit with 0.2 ether (too much)
        vm.expectRevert(); // Next EVM CALL is expected to revert
        setUpUserCommit(testUser, 2*setPrice, 2*setPrice);

        // Commit with 0.1 ether (correct amount)
        setUpUserCommit(testUser, setPrice, setPrice);

        // hasCommitted() mapping should be true for the testUser
        assertEq(mintContract.hasCommitted(testUser), true);

        // Check that the user's balance was correctly updated
        assertEq(testUser.balance, 0);

        // Commit for another user
        address testUser2 = address(0x5678);
        setUpUserCommit(testUser2, setPrice, setPrice);
        assertEq(mintContract.hasCommitted(testUser2), true);
    }

    // Test the reveal mechanism
    function test_Reveal() public {
        setUpSale();
        // When not set, the secret on the contract should be 0
        assertEq(mintContract.adminSecret(), 0);

        // Reveal the secret number before the revealBlock
        vm.expectRevert(); // Next EVM CALL is expected to revert
        mintContract.adminReveal(secretNumber);

        // Reveal the secret number after the revealBlock
        setUpReveal();

        // Check that the secret number was correctly set
        assertEq(mintContract.adminSecret(), secretNumber);
    }

    // Test the minting mechanism
    function test_Mint() public {
        setUpSale();
        address testUser = address(0x1234);
        setUpUserCommit(testUser, setPrice, setPrice); // Buy 1 NFT
        setUpReveal();

        // Mint the NFT
        vm.prank(testUser); // Spoof the testUser account
        uint256 nftId = mintContract.userMint();

        // Check that the NFT was correctly minted
        assertEq(nftContract.balanceOf(testUser, nftId), 1);
    }

    // Test funds withdrawal
    function test_Withdraw() public {
        setUpSale();
        address testUser = address(0x1234);
        setUpUserCommit(testUser, setPrice, setPrice); // Buy 1 NFT
        setUpReveal();

        // Now that the Admin has revealed the secret, we can withdraw funds.

        // Withdraw the funds
        address payable bankAddress = payable(address(0x5678));
        mintContract.withdrawFunds(bankAddress, setPrice);

        // Check that the funds were correctly withdrawn
        assertEq(bankAddress.balance, setPrice);
    }

    // Test Admin role granting 
    function test_AddRemoveAdmin() public {
        //// Test with the deployment account (authorized admin)
        address testRecipient = address(0x1234);

        // // Remove recipient before addition (should fail)
        // vm.expectRevert();
        // mintContract.removeAdminRole(testRecipient); // Silently fails
        assertEq(mintContract.hasRole(mintContract.DEFAULT_ADMIN_ROLE(), testRecipient), false);

        // Add recipient
        mintContract.addAdminRole(testRecipient);
        assertEq(mintContract.hasRole(mintContract.DEFAULT_ADMIN_ROLE(), testRecipient), true);

        // Remove recipient
        mintContract.removeAdminRole(testRecipient);
        assertEq(mintContract.hasRole(mintContract.DEFAULT_ADMIN_ROLE(), testRecipient), false);


        //// Test with a non-admin account
        address testUser = address(0xcafebabe);
        vm.startPrank(testUser);
        assertEq(mintContract.hasRole(mintContract.DEFAULT_ADMIN_ROLE(), testUser), false); // Make sure the user is not an admin
        vm.expectRevert();
        mintContract.addAdminRole(testRecipient);
        vm.expectRevert();
        mintContract.removeAdminRole(testRecipient);
        vm.stopPrank();
    }
}
