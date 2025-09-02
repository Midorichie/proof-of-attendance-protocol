;; --------------------------------
;; Proof of Attendance Protocol (POAP)
;; --------------------------------
;; Non-transferable (soulbound) SIP-009 NFTs for event attendance
;; Pause/unpause, revoke, two-step organizer rotation,
;; and delegated minting via a trusted minter contract.
;; --------------------------------

(impl-trait .sip009-trait.sip009-nft-trait)

;; --------------------------------
;; State variables
;; --------------------------------
(define-data-var event-organizer principal tx-sender)
(define-data-var pending-organizer (optional principal) none)
(define-data-var total-supply uint u0)
(define-data-var paused bool false)
(define-data-var trusted-minter (optional principal) none)

;; NFT: token-id -> owner
(define-non-fungible-token poap uint)

;; token-id -> metadata URI
(define-map token-uris uint { uri: (string-utf8 256) })

;; one-per-attendee: principal -> true
(define-map claimed principal bool)

;; revocation registry: token-id -> true if revoked
(define-map revoked uint bool)

;; --------------------------------
;; Error codes
;; --------------------------------
(define-constant ERR-NOT-ORGANIZER (err u100))
(define-constant ERR-ALREADY-CLAIMED (err u101))
(define-constant ERR-NONTRANSFERABLE (err u102))
(define-constant ERR-NO-SUCH-TOKEN (err u103))
(define-constant ERR-PAUSED (err u104))
(define-constant ERR-NO-PENDING (err u105))
(define-constant ERR-NOT-PENDING-ACCEPTOR (err u106))
(define-constant ERR-NO-MINTER (err u107))
(define-constant ERR-NOT-MINTER (err u108))

;; --------------------------------
;; Admin: organizer rotation (two-step)
;; --------------------------------

(define-public (propose-organizer (new-org principal))
  (if (is-eq tx-sender (var-get event-organizer))
      (begin (var-set pending-organizer (some new-org)) (ok true))
      ERR-NOT-ORGANIZER
  )
)

(define-public (accept-organizer)
  (match (var-get pending-organizer)
    proposed
      (if (is-eq tx-sender proposed)
          (begin
            (var-set event-organizer proposed)
            (var-set pending-organizer none)
            (ok true)
          )
          ERR-NOT-PENDING-ACCEPTOR
      )
    ERR-NO-PENDING
  )
)

;; Pause/unpause minting
(define-public (pause)
  (if (is-eq tx-sender (var-get event-organizer))
      (begin (var-set paused true) (ok true))
      ERR-NOT-ORGANIZER
  )
)

(define-public (unpause)
  (if (is-eq tx-sender (var-get event-organizer))
      (begin (var-set paused false) (ok true))
      ERR-NOT-ORGANIZER
  )
)

;; Trusted minter management
(define-public (set-trusted-minter (minter principal))
  (if (is-eq tx-sender (var-get event-organizer))
      (begin (var-set trusted-minter (some minter)) (ok true))
      ERR-NOT-ORGANIZER
  )
)

(define-public (clear-trusted-minter)
  (if (is-eq tx-sender (var-get event-organizer))
      (begin (var-set trusted-minter none) (ok true))
      ERR-NOT-ORGANIZER
  )
)

;; --------------------------------
;; Minting
;; --------------------------------

;; Organizer mints directly (one per principal)
(define-public (mint (recipient principal) (uri (string-utf8 256)))
  (if (is-eq tx-sender (var-get event-organizer))
      (if (var-get paused) ERR-PAUSED
          (if (is-some (map-get? claimed recipient)) ERR-ALREADY-CLAIMED
              (let ((id (+ u1 (var-get total-supply))))
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
      ERR-NOT-ORGANIZER
  )
)

;; Delegated mint called by a trusted minter contract
(define-public (mint-via (recipient principal) (uri (string-utf8 256)))
  (match (var-get trusted-minter)
    tm
      (if (is-eq contract-caller tm)
          (if (var-get paused) ERR-PAUSED
              (if (is-some (map-get? claimed recipient)) ERR-ALREADY-CLAIMED
                  (let ((id (+ u1 (var-get total-supply))))
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
          ERR-NOT-MINTER
      )
    ERR-NO-MINTER
  )
)

;; --------------------------------
;; Revocation
;; --------------------------------

(define-public (revoke (id uint))
  (if (is-eq tx-sender (var-get event-organizer))
      (let ((owner-opt (nft-get-owner? poap id)))
        (if (is-none owner-opt) ERR-NO-SUCH-TOKEN
            (let ((owner (unwrap! owner-opt ERR-NO-SUCH-TOKEN)))
              (begin
                (map-set revoked id true)
                (map-delete claimed owner)
                (ok true)
              )
            )
        )
      )
      ERR-NOT-ORGANIZER
  )
)

;; --------------------------------
;; SIP-009 required entrypoints
;; --------------------------------

(define-public (transfer (id uint) (sender principal) (recipient principal))
  ERR-NONTRANSFERABLE
)

(define-read-only (get-owner (id uint))
  (let ((current (nft-get-owner? poap id)))
    (ok (if (or (is-none current) (is-some (map-get? revoked id))) none current))
  )
)

(define-read-only (get-last-token-id)
  (ok (var-get total-supply))
)

(define-read-only (get-token-uri (id uint))
  (ok (match (map-get? token-uris id) entry (some (get uri entry)) none))
)

;; --------------------------------
;; Convenience read-only methods
;; --------------------------------

(define-read-only (get-organizer) (var-get event-organizer))
(define-read-only (get-pending-organizer) (var-get pending-organizer))
(define-read-only (is-paused) (var-get paused))
(define-read-only (has-claim (who principal)) (ok (is-some (map-get? claimed who))))
(define-read-only (is-revoked (id uint)) (ok (is-some (map-get? revoked id))))
(define-read-only (token-exists? (id uint)) (ok (is-some (nft-get-owner? poap id))))
(define-read-only (get-trusted-minter) (var-get trusted-minter))
