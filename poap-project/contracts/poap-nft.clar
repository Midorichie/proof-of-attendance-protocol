;; poap-nft.clar
;; Proof of Attendance Protocol (POAP) NFT Contract
;; Implements SIP-009 NFT standard

;; Import the SIP-009 trait from the local contract
(use-trait sip009-trait .sip009-trait.sip009-trait)

;; --------------------------------
;; NFT definition
;; --------------------------------
(define-non-fungible-token poap uint)

;; --------------------------------
;; Storage
;; --------------------------------
(define-map token-uris uint { uri: (string-utf8 256) })
(define-data-var last-token-id uint u0)

;; --------------------------------
;; Error constants
;; --------------------------------
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-NONTRANSFERABLE (err u101))

;; --------------------------------
;; Public functions
;; --------------------------------

;; Internal mint function (called by organizer/minter contract)
(define-public (mint-internal (recipient principal) (id uint) (uri (string-utf8 256)))
  (begin
    (try! (nft-mint? poap id recipient))
    (map-set token-uris id { uri: uri })
    (var-set last-token-id id)
    (ok id)
  )
)

;; Soulbound (no transfers allowed)
(define-public (transfer (id uint) (sender principal) (recipient principal))
  ERR-NONTRANSFERABLE
)

;; --------------------------------
;; SIP-009 required entrypoints
;; --------------------------------

(define-read-only (get-owner (id uint))
  (ok (nft-get-owner? poap id))
)

(define-read-only (get-last-token-id)
  (ok (var-get last-token-id))
)

(define-read-only (get-token-uri (id uint))
  (ok
    (match (map-get? token-uris id)
      entry (some (get uri entry))
      none
    )
  )
)
