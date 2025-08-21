# Proof of Attendance Protocol (POAP) - Clarity

This project implements a **soulbound Proof of Attendance Protocol** on the Stacks blockchain.

## Features
- **Soulbound NFTs** (cannot be transferred).
- **One per attendee** (enforced via `claimed` mapping).
- **Blacklist system** (prevent malicious actors from minting).
- **Organizer-only minting**.
- **Organizer transfer** (ownership of event can be reassigned).
- **Modular option**:
  - `poap-nft.clar` → Core NFT (SIP-009 compliant).
  - `poap-minter.clar` → Business logic.

## Contracts
- `sip009-trait.clar` → SIP-009 trait definition.
- `poap-minter.clar` → Minting logic.
- `poap-nft.clar` → NFT logic.

## Setup
```bash
clarinet check
clarinet test
