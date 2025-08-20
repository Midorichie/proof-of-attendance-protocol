;; --------------------------------
;; Proof of Attendance Protocol (POAP)
;; Non-transferable (soulbound) NFTs
;; Organizer mints attendance NFTs to participants
;; --------------------------------

;; Import SIP-009 NFT Trait
(use-trait sip009-nft-trait .sip009-trait)

;; --------------------------------
;; Data definitions
;; --------------------------------

(define-data-var event-organizer principal tx-sender)
(define-data-var total-supply uint u0)

;; NFT: store ownership of tokens
(define-non-fungible-token poap uint)

;; Store metadata URIs for tokens
(define-map token-uris uint { uri: (string-utf8 256) })

;; Track claimed addresses (each principal can only mint one POAP)
(define-map claimed principal bool)

;; --------------------------------
;; Error codes
;; --------------------------------
(define-constant ERR-NOT-ORGANIZER (err u100))
(define-constant ERR-ALREADY-CLAIMED (err u101))
(define-constant ERR-NOT-OWNER (err u102))
(define-constant ERR-NONTRANSFERABLE (err u103))
(define-constant ERR-NOT-EXIST (err u104))

;; --------------------------------
;; Public functions
;; --------------------------------

;; Mint a POAP for an attendee (only organizer can mint)
(define-public (mint (recipient principal) (uri (string-utf8 256)))
  (if (is-eq tx-sender (var-get event-organizer))
      (if (is-some (map-get? claimed recipient))
          ERR-ALREADY-CLAIMED
          (let (
                 (id (+ u1 (var-get total-supply)))
               )
            (begin
              ;; mint NFT
              (nft-mint? poap id recipient)

              ;; record metadata
              (map-set token-uris id { uri: uri })

              ;; mark recipient as claimed
              (map-set claimed recipient true)

              ;; update supply
              (var-set total-supply id)

              (ok id)
            )
          )
      )
      ERR-NOT-ORGANIZER
  )
)

;; --------------------------------
;; SIP-009 required entrypoints
;; --------------------------------

;; Soulbound: disallow all transfers
(define-public (transfer (id uint) (sender principal) (recipient principal))
  ERR-NONTRANSFERABLE
)

(define-read-only (get-owner (id uint))
  (ok (nft-get-owner? poap id))
)

(define-read-only (get-last-token-id)
  (ok (var-get total-supply))
)

(define-read-only (get-token-uri (id uint))
  (ok
    (match (map-get? token-uris id)
      entry (some (get uri entry))
      none
    )
  )
)

;; --------------------------------
;; Convenience read-only methods
;; --------------------------------

(define-read-only (get-organizer)
  (var-get event-organizer)
)

(define-read-only (has-claim (who principal))
  (ok (is-some (map-get? claimed who)))
)
