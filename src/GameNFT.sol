pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract GameNFT is ERC1155, AccessControl {
    using SafeMath for uint256;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    uint256 private nextTokenId = 1;
    mapping(uint256 => string) private _unrevealedUri;
    mapping(uint256 => string) private _tokenUri;
    uint256 public revealTimestamp;

    constructor(string memory _uri, uint256 _revealTimestamp)
        ERC1155(_uri)
    {
        _setupRole(ADMIN_ROLE, _msgSender());
        revealTimestamp = _revealTimestamp;
    }

    function setRevealTimestamp(uint256 _revealTimestamp) external {
        require(hasRole(ADMIN_ROLE, _msgSender()), "Only admin can set reveal timestamp");
        revealTimestamp = _revealTimestamp;
    }

    function mint(address to, uint256 amount) external onlyRole(ADMIN_ROLE) returns (uint256) {
        uint256 tokenId = nextTokenId;
        nextTokenId = nextTokenId.add(1);
        _mint(to, tokenId, amount, "");
        return tokenId;
    }

    function setUnrevealedUri(uint256 tokenId, string memory _uri) external onlyRole(ADMIN_ROLE) {
        _unrevealedUri[tokenId] = _uri;
    }

    function setTokenUri(uint256 tokenId, string memory _uri) external onlyRole(ADMIN_ROLE) {
        _tokenUri[tokenId] = _uri;
    }

    function uri(uint256 tokenId) public view override returns (string memory) {
        if (block.timestamp < revealTimestamp) {
            return _unrevealedUri[tokenId];
        } else {
            return _tokenUri[tokenId];
        }
    }

    function grantAdminRole(address account) public onlyRole(ADMIN_ROLE) {
        grantRole(ADMIN_ROLE, account);
    }
}