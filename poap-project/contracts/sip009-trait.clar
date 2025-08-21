;; contracts/sip009-trait.clar
(define-trait sip009-trait
  (
    (transfer (uint principal principal) (response bool uint))
    (get-owner (uint) (response (optional principal) uint))
    (get-last-token-id () (response uint uint))
    (get-token-uri (uint) (response (optional (string-utf8 256)) uint))
  )
)
