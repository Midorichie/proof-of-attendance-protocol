;; SIP-009 NFT Trait Definition (local copy)

(define-trait sip009-nft-trait
  (
    ;; Transfer NFT from `sender` to `recipient`
    (transfer (uint principal principal) (response bool uint))

    ;; Get the owner of a given token id
    (get-owner (uint) (response (optional principal) uint))

    ;; Get the last minted token id (monotonic increasing)
    (get-last-token-id () (response uint uint))

    ;; Optional token URI (e.g., metadata URL) for a token id
    (get-token-uri (uint) (response (optional (string-utf8 256)) uint))
  )
)
