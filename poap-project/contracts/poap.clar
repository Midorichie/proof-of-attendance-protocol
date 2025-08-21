;; --------------------------------
;; Proof of Attendance Protocol (POAP)
;; --------------------------------
;; Attendees receive non-transferable NFTs (soulbound)
;; Only the event organizer can mint new POAPs
;; Implements SIP-009 NFT standard
;; --------------------------------

(use-trait sip009 <sip009-trait>)

;; --------------------------------
;; State variables
;; --------------------------------
(define-data-var event-organizer principal tx-sender)
(define-data-var total-supply uint u0)

;; Mapping from token-id -> owner
(define-nft poap uint)

;; Mapping from token-id -> metadata URI
(define-map token-uris uint { uri: (string-utf8 256) })

;; Track which principals already claimed
(define-map claimed principal bool)

;; --------------------------------
;; Error constants
;; --------------------------------
(define-constant ERR-NOT-ORGANIZER (err u100))
(define-constant ERR-ALREADY-CLAIMED (err u101))
(define-constant ERR-NOT-EXIST (err u102))
(define-constant ERR-NONTRANSFERABLE (err u103))

;; --------------------------------
;; Public functions
;; --------------------------------

;; Mint a POAP (only organizer, one per attendee)
(define-public (mint (recipient principal) (uri (string-utf8 256)))
  (begin
    (if (not (is-eq tx-sender (var-get event-organizer)))
        ERR-NOT-ORGANIZER
        (if (is-some (map-get? claimed recipient))
            ERR-ALREADY-CLAIMED
            (let (
                  (id (+ u1 (var-get total-supply)))
                 )
              (begin
                (try! (nft-mint? poap id recipient))
                (map-set token-uris id { uri: uri })
                (map-set claimed recipient true)
                (var-set total-supply id)
                (ok id)
              )
            )
        )
    )
  )
)

;; --------------------------------
;; SIP-009 required entrypoints
;; --------------------------------

;; Disallow transfers (soulbound)
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
