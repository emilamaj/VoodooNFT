pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MintingContract is AccessControl {
    using SafeMath for uint256;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    NFT1155 public nftContract;
    IERC20 public maticToken;
    uint256 public nftPrice;
    mapping(address => bool) public hasMinted;
    address public fundsReceiver;

    constructor(
        address _nftContract,
        address _maticToken,
        uint256 _nftPrice,
        address _fundsReceiver
    ) {
        nftContract = NFT1155(_nftContract);
        maticToken = IERC20(_maticToken);
        nftPrice = _nftPrice;
        fundsReceiver = _fundsReceiver;
        _setupRole(ADMIN_ROLE, _msgSender());
    }

    function setNftPrice(uint256 _nftPrice) external onlyRole(ADMIN_ROLE) {
        nftPrice = _nftPrice;
    }

    function mintRandomNFT() external {
        require(!hasMinted[_msgSender()], "User has already minted an NFT");
        require(
            maticToken.balanceOf(_msgSender()) >= nftPrice,
            "Insufficient MATIC balance"
        );
        maticToken.transferFrom(_msgSender(), address(this), nftPrice);

        uint256 tokenId = nftContract.mint(_msgSender(), 1);
        hasMinted[_msgSender()] = true;
    }

    function withdrawFunds() external onlyRole(ADMIN_ROLE) {
        uint256 balance = maticToken.balanceOf(address(this));
        maticToken.transfer(fundsReceiver, balance);
    }

    function grantAdminRole(address account) public onlyRole(ADMIN_ROLE) {
        grantRole(ADMIN_ROLE, account);
    }
}
