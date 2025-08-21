# POAP (Proof of Attendance Protocol) – Clarity on Stacks

Soulbound SIP-009 NFTs for event attendance. Organizers mint badges to attendees, can pause minting, revoke badges, and rotate organizer with a two-step process.

## Features
- Soulbound NFTs (transfers disabled).
- Organizer-only mint with one-claim-per-principal guard.
- Pause/unpause minting.
- Revoke a badge (logical burn): `get-owner` returns `none` for revoked IDs.
- Two-step organizer rotation: `propose-organizer` -> `accept-organizer`.
- SIP-009 compliant read-only functions and token URI storage.

## Files
- `contracts/sip009-trait.clar` – Local SIP-009 trait definition.
- `contracts/poap.clar` – POAP contract.
- `Clarinet.toml` – Project config.

## Setup
```bash
# from project root
clarinet check
