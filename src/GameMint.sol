// This smart contract handles the minting of the NFTs of GameNFT.sol (ERC1155). It grants admin role to some account. The users will interact with the GameMint.sol smart contract for minting.
// A given user can only mint 1 NFT, randomly out of the 4 available types. There is no supply limit.
// The minting price is set by the admin. It is paid in MATIC. It can be withdrawn by the admin.
// Fairness is guaranteed by a simple commit-reveal mechanism:
// - The admin commits a random number by first publishing a hash of the random number.
// - The user commits a mint order. Their address constitutes a random number (commitment). They pay the price in advance.
// - The the target block is reached, the admin reveals their random number. 
// - Finally the users can then mint the NFT that was fairly attributed to them.

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./GameNFT.sol";
import "../lib/openzeppelin-contracts/contracts/access/AccessControl.sol";

contract GameMint is AccessControl {
    event Setup(uint256 revealBlock, uint256 nftPrice, bytes32 hashOfCommitment);
    event UserCommit(address indexed user);
    event Reveal(uint256 adminSecret);
    event UserMint(address indexed user, uint256 indexed nftId);

    // bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00; // Inherited from AccessControl.sol
    GameNFT public nftContract;
    uint256 public id_count; // Number of different NFTs available for minting.

    bool public isSetup = false; // Is the contract correctly setup (price, hash, block height, etc...) ?
    uint256 public revealBlock; // Block number starting from which the Admin can reveal their commitment, and allow users to mint their NFTs. Could use uint32 to save gas on storage. Could merge with isSetup.
    uint256 public nftPrice = 0; // Price of the NFT in MATIC, set by the admin
    bytes32 public hashOfCommitment; // Commitment of the admin
    uint256 public adminSecret = 0; // Secret of the admin, revealed starting from the revealBlock

    mapping(address => bool) public hasCommitted; // Keep track of which users have committed a mint order.
    mapping(address => bool) public hasMinted; // Keeps track of which users have minted an NFT.

    // Simple constructor.
    constructor(address _nftContract, uint256 _id_count) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        nftContract = GameNFT(_nftContract);
        id_count = _id_count;
    }

    // Grant admin role to another account. WARNING: Make sure to communicate the adminSecret through an off-chain canal.
    function addAdminRole(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(DEFAULT_ADMIN_ROLE, account);
    }

    // Revoke admin role from an account. WARNING: Make sure to communicate the adminSecret through an off-chain canal.
    function removeAdminRole(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(account != _msgSender(), "Cannot revoke oneself from an admin role"); // This makes sure that there is always at least 1 admin.
        revokeRole(DEFAULT_ADMIN_ROLE, account);
    }

    // Helper function to reliably find the hash of a random number off-chain.
    function _calculateHash(uint256 _randomNumber) public pure returns (bytes32) {
        assert(_randomNumber > 0); // Make sure the random number is not 0. (Would be easily guessable. The whole range should be used.)
        return keccak256(abi.encodePacked(_randomNumber));
    }

    // Allows the Admin to setup the sale. This function can only be called once for trustless reasons.
    function adminSetup(uint256 _revealBlock, uint256 _nftPrice, bytes32 _hashOfCommitment) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(!isSetup, "Contract is already setup");
        require(_revealBlock > block.number, "Reveal block must be in the future");
        // require(_nftPrice > 0, "NFT price must be positive"); // NFT can be free.
        
        revealBlock = _revealBlock;
        nftPrice = _nftPrice;
        hashOfCommitment = _hashOfCommitment;
        isSetup = true; // Now the contract is setup. Users can commit to minting an NFT until the reveal block.
        
        // Emit the corresponding event.
        emit Setup(_revealBlock, _nftPrice, _hashOfCommitment);
    }

    // Users can commit to minting an NFT by calling this function.
    function userCommit() external payable {
        require(isSetup, "Contract is not setup");
        require(block.number < revealBlock, "Reveal block has already passed");
        require(!hasCommitted[_msgSender()], "User has already committed");

        // Check that the user has paid exactly the price.
        require(msg.value == nftPrice, "Incorrect amount of MATIC sent");

        // Mark the user as having committed.
        hasCommitted[_msgSender()] = true;

        // Emit the corresponding event.
        emit UserCommit(_msgSender());
    }

    // The admin can reveal their commitment by calling this function.
    function adminReveal(uint256 _adminSecret) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(isSetup, "Contract is not setup");
        require(block.number >= revealBlock, "Reveal block has not passed yet");
        require(adminSecret == 0, "Admin has already revealed their secret");

        // Check that the admin has revealed the correct secret.
        require(_calculateHash(_adminSecret) == hashOfCommitment, "Incorrect secret");

        // Mark the admin as having revealed their secret.
        adminSecret = _adminSecret;

        // Emit Reveal event.
        emit Reveal(_adminSecret);
    }

    // Users can mint their NFT by calling this function.
    function userMint() external returns(uint256){
        require(isSetup, "Contract is not setup");
        require(block.number >= revealBlock, "Reveal block has not passed yet");
        require(hasCommitted[_msgSender()], "User has not committed");
        require(adminSecret > 0, "Admin has not revealed their secret");
        require(!hasMinted[_msgSender()], "User has already minted");

        // Calculate the NFT type to mint.
        uint256 nftTypeId = uint256(keccak256(abi.encodePacked(_msgSender(), adminSecret))) % id_count;

        // Mint 1 NFT of the given type, with no optional data.
        nftContract.mint(_msgSender(), nftTypeId, 1, "");

        // Mark the user as having minted.
        hasMinted[_msgSender()] = true;

        // Emit an event.
        emit UserMint(_msgSender(), nftTypeId);

        return nftTypeId;
    }

    // Withdraw collected MATIC, only once the admin has revealed their secret.
    function withdrawFunds(address payable recipient, uint256 amount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(adminSecret > 0, "Admin has not revealed their secret");
        recipient.transfer(amount);
    }
}
