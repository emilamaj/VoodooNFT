// This ERC1155 NFT smart contract allows the deployment of multiple types of NFTs. 
// It grants admin role to some account. 
// The users will interact with the GameMint.sol smart contract for the minting mechanics.

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../lib/openzeppelin-contracts/contracts/token/ERC1155/ERC1155.sol";
import "../lib/openzeppelin-contracts/contracts/access/AccessControl.sol";
import "../lib/openzeppelin-contracts/contracts/utils/Strings.sol";

contract GameNFT is ERC1155, AccessControl {
    event Mint(address indexed account, uint256 indexed id, uint256 amount, bytes data);

    // Base URI https://localhost:3000/metadata/
    string public base_uri = "";
    // bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00; // Inherited from AccessControl.sol
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    uint256 public constant ID_COUNT = 4; // Number of different NFTs available for minting.
    
    // Constructor, not much is done here.
    constructor(string memory _base_uri) ERC1155("") {
        // ERC1155 constructor requires a base URI, but we overried the uri() function to return "base_uri + {id}.json"
        base_uri = _base_uri;
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
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
    
    // Add a new MINTER_ROLE to an account.
    function addMinterRole(address account) public virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(MINTER_ROLE, account);
    }

    // Remove a MINTER_ROLE from an account.
    function removeMinterRole(address account) public virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        revokeRole(MINTER_ROLE, account);
    }
    
    // Override supportsInterface since it is implemented both in ERC1155 and AccessControl. 
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155, AccessControl) returns (bool) {
        return ERC1155.supportsInterface(interfaceId) || AccessControl.supportsInterface(interfaceId);
    }
    
    // Override "uri" function to return the base URI (for compatibility with OpenSea).
    function uri(uint256 _tokenid) override public view returns (string memory) {
        return string(
            abi.encodePacked( // Use of abi.encodePacked to concatenate strings
                base_uri,
                Strings.toString(_tokenid),".json"
            )
        );
    }

    // Contract-level metadata (also called storefront metadata)
    function contractURI() public view returns (string memory) {
        return string(abi.encodePacked(base_uri, "contract.json"));
    }

    // Mint a new NFT. Only authorized accounts can mint (GameMint/Admins). The users are supposed to interact with GameMint.sol for minting.
    function mint(address account, uint256 id, uint256 amount, bytes memory data) public virtual onlyRole(MINTER_ROLE) {
        _mint(account, id, amount, data);

        // Emit event
        emit Mint(account, id, amount, data);
    }
}
