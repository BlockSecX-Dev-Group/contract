# BlockSecArena Smart Contracts

## 📖 Introduction

This repository contains the smart contracts for **BlockSecArena**, a decentralized Web3 security education platform.

The core contract is an **ERC-721** standard NFT, designed to issue achievement badges and credentials to users. It implements **EIP-712** typed structured data hashing and signing to enable secure, gas-efficient, and authorized minting. This allows the backend to act as a centralized authority to verify user achievements (off-chain) and authorize on-chain minting without paying gas fees directly.

## ✨ Key Features

* **ERC-721 Standard**: Fully compatible with standard NFT marketplaces (OpenSea, Element) and wallets.
* **EIP-712 Security**: Utilizes off-chain signatures to authorize minting transactions. Only requests signed by the designated `Admin/Signer` wallet can successfully mint tokens.
* **Batch Minting**: Supports `batchSigMint` to mint multiple tokens in a single transaction, optimizing gas usage.
* **Nonce Management**: Built-in nonce tracking to prevent signature replay attacks.
* **Deadline Protection**: Signatures include a timestamp deadline to ensure validity windows.

## 🛠 Technical Stack

* **Language**: Solidity ^0.8.0
* **Framework**: Hardhat
* **Libraries**: OpenZeppelin (ERC721, ECDSA, EIP712)
* **Network**: BNB Chain (BSC) / Ethereum

## 🧩 EIP-712 Implementation Details

The contract uses EIP-712 to verify that a minting request was authorized by the platform backend.

### Domain Separator
* **Name**: `NFToken`
* **Version**: `1`
* **ChainId**: `56` (BSC Mainnet) or as configured.
* **VerifyingContract**: The deployed address of this contract.

### Data Structure (The "Mint" Type)
The backend must sign a message containing the following structure:

```solidity
struct Mint {
    address to;       // User's wallet address
    string uri;       // IPFS metadata URI
    uint256 nonce;    // User's current nonce (prevent replay)
    uint256 deadline; // Expiration timestamp
}
