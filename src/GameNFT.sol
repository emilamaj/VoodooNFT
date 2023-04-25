// This ERC1155 NFT smart contract allows the deployment of multiple types of NFTs. 
// It grants admin role to some account. 
// The users will interact with the GameMint.sol smart contract for the minting mechanics.

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../lib/openzeppelin-contracts/contracts/token/ERC1155/ERC1155.sol";
import "../lib/openzeppelin-contracts/contracts/access/AccessControl.sol";
import "../lib/openzeppelin-contracts/contracts/utils/Strings.sol";

contract GameNFT is ERC1155, AccessControl {
    // Base URI
    string constant BASE_URI = "https://localhost:3000/metadata/";
    string constant JSON_URI = "https://localhost:3000/metadata/{id}.json";
    // bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00; // Inherited from AccessControl.sol
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    
    // Constructor, not much is done here.
    constructor() ERC1155(JSON_URI) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    // Add a new MINTER_ROLE to an account.
    function addMinter(address account) public virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(MINTER_ROLE, account);
    }

    // Remove a MINTER_ROLE from an account.
    function removeMinter(address account) public virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        revokeRole(MINTER_ROLE, account);
    }
    
    // Override supportsInterface since it is implemented both in ERC1155 and AccessControl. 
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155, AccessControl) returns (bool) {
        return ERC1155.supportsInterface(interfaceId) || AccessControl.supportsInterface(interfaceId);
    }
    
    // Override "uri" function to return the base URI (for compatibility with OpenSea).
    function uri(uint256 _tokenid) override public pure returns (string memory) {
        return string(
            abi.encodePacked( // Use of abi.encodePacked to concatenate strings
                BASE_URI,
                Strings.toString(_tokenid),".json"
            )
        );
    }

    // Override setApprovedForAll to work with Wyvern proxy accounts (optional).

    // Contract-level metadata (also called storefront metadata)
    function contractURI() public pure returns (string memory) {
        return string(abi.encodePacked(BASE_URI, "contract.json"));
    }

    // Mint a new NFT. Only authorized accounts can mint (GameMint/Admins). The users are supposed to interact with GameMint.sol for minting.
    function mint(address account, uint256 id, uint256 amount, bytes memory data) public virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        _mint(account, id, amount, data);
    }
}
