# POAP (Proof of Attendance Protocol) – Clarity

Non-transferable NFT (“soulbound”) for event attendance on Stacks. Organizers mint a unique NFT to each attendee. The contract implements the local SIP-009 NFT trait.

## Files
- `contracts/sip009-trait.clar` – Local copy of the SIP-009 NFT trait.
- `contracts/poap.clar` – Soulbound NFT contract implementing the trait.
- `Clarinet.toml` – Project config.

## Prerequisites
- [Clarinet](https://docs.hiro.so/clarinet) installed.

## Quick Start
```bash
clarinet check
Usage (Console)
Organizer is the deployer by default.

Mint to attendee (optional URI):

clarity
Copy
Edit
;; with URI
(contract-call? .poap mint 'ST1... (some "https://example.com/metadata/123.json"))

;; without URI
(contract-call? .poap mint 'ST1... none)
Query ownership

clarity
Copy
Edit
(contract-call? .poap get-owner u1)
Last token id

clarity
Copy
Edit
(contract-call? .poap get-last-token-id)
Token URI

clarity
Copy
Edit
(contract-call? .poap get-token-uri u1)
Check if someone already claimed

clarity
Copy
Edit
(contract-call? .poap has-claim 'ST1...)
Rotate organizer (optional)

clarity
Copy
Edit
(contract-call? .poap set-organizer 'ST1NEWORGANIZER...)
Design & Security
Soulbound: transfer always returns ERR-NONTRANSFERABLE.

One-per-attendee: claimed map prevents multiple mints to the same principal for this event.

Organizer-only minting: enforced on mint and set-organizer.

SIP-009 Compliance: implements required entrypoints with local trait, no external dependency.

Per-token metadata: optional token-uris map set at mint time.

Next Steps
Add tests in tests/poap_test.ts.

Support multiple events via event IDs (collection per event).

Off-chain indexer / simple UI to view badges.
