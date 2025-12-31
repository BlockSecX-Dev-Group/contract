// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.4.0
pragma solidity ^0.8.27;

import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

event Mint(address to, uint256 nonce, uint256 id);
event RenounceMinter(address oldMinter);
event TransferMintership(address newMinter, address oldMinter);

contract NFToken is ERC721, EIP712 {
    bytes32 constant MINT_TYPEHASH =
        keccak256(
            "Mint(address to,string uri,uint256 nonce,uint256 deadline)"
        );
    mapping(address => uint256) public nonces;
    mapping(uint256 => string) public _tokenURIs;
    address public _minter;
    uint256 public totalSupply;

    constructor(
        address minter,
        string memory name,
        string memory symbol
    ) ERC721(name, symbol) EIP712("NFToken", "1") {
        _minter = minter;
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        _requireOwned(tokenId);
        return _tokenURIs[tokenId];
    }

    function _sigMint(address to, string calldata URI) internal {
        totalSupply++;
        _tokenURIs[totalSupply-1] = URI;
        _safeMint(to, totalSupply - 1);
   }

    function sigMint(
        address to,
        string calldata uri,
        uint256 nonce,
        uint256 deadline,
        bytes calldata sig
    ) external {
        require(msg.sender == _minter, "only minter");
        require(block.timestamp <= deadline, "expired");
        require(nonce == nonces[to], "bad nonce");

        bytes32 structHash = keccak256(
            abi.encode(
                MINT_TYPEHASH,
                to,
                keccak256(bytes(uri)),
                nonce,
                deadline
            )
        );
        bytes32 digest = _hashTypedDataV4(structHash);
        require(ECDSA.recover(digest, sig) == to, "bad sig");
        nonces[to]++;
        emit Mint(to, nonce, totalSupply);
        _sigMint(to, uri);
    }

    function renounceMinter() external {
        require(msg.sender == _minter, "only minter");
        emit RenounceMinter(_minter);
        _minter = address(0);
    }

    function transferMintership(address newMinter) external {
        require(msg.sender == _minter, "only minter");
        emit TransferMintership(newMinter, _minter);
        _minter = newMinter;
    }
}
