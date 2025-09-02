;; poap-minter.clar
;; POAP Minting Contract
;; Manages event organization and minting permissions

;; --------------------------------
;; Storage
;; --------------------------------
(define-data-var event-organizer principal tx-sender)
;; Track claims & blacklist
(define-map claimed principal bool)
(define-map blacklist principal bool)

;; --------------------------------
;; Error codes
;; --------------------------------
(define-constant ERR-NOT-ORGANIZER (err u100))
(define-constant ERR-ALREADY-CLAIMED (err u101))
(define-constant ERR-BLACKLISTED (err u102))

;; --------------------------------
;; Public functions
;; --------------------------------

;; Mint a POAP via poap-nft
(define-public (mint (recipient principal) (uri (string-utf8 256)))
  (begin
    (asserts! (is-eq tx-sender (var-get event-organizer)) ERR-NOT-ORGANIZER)
    (asserts! (is-none (map-get? claimed recipient)) ERR-ALREADY-CLAIMED)
    (asserts! (is-none (map-get? blacklist recipient)) ERR-BLACKLISTED)
    
    (let ((current-id (unwrap! (contract-call? .poap-nft get-last-token-id) ERR-NOT-ORGANIZER))
          (new-id (+ current-id u1)))
      (try! (contract-call? .poap-nft mint-internal recipient new-id uri))
      (map-set claimed recipient true)
      (ok new-id)
    )
  )
)

;; Blacklist malicious users
(define-public (blacklist-user (user principal))
  (begin
    (asserts! (is-eq tx-sender (var-get event-organizer)) ERR-NOT-ORGANIZER)
    (map-set blacklist user true)
    (ok true)
  )
)

;; Transfer event ownership
(define-public (transfer-organizer (new-organizer principal))
  (begin
    (asserts! (is-eq tx-sender (var-get event-organizer)) ERR-NOT-ORGANIZER)
    (var-set event-organizer new-organizer)
    (ok true)
  )
)

;; --------------------------------
;; Read-only helpers
;; --------------------------------

(define-read-only (get-organizer)
  (ok (var-get event-organizer))
)

(define-read-only (has-claimed (who principal))
  (ok (is-some (map-get? claimed who)))
)

(define-read-only (is-blacklisted (who principal))
  (ok (is-some (map-get? blacklist who)))
)
