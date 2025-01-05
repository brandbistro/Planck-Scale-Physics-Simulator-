;; Planck Phenomena NFT Contract

(define-non-fungible-token planck-phenomena uint)

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u100))
(define-constant ERR_INVALID_PHENOMENON (err u101))

;; Data variables
(define-data-var last-phenomenon-id uint u0)

;; Data maps
(define-map phenomenon-data
  uint
  {
    discoverer: principal,
    name: (string-ascii 64),
    description: (string-utf8 1024),
    properties: (list 10 (tuple (key (string-ascii 64)) (value (string-utf8 256))))
  }
)

;; Public functions
(define-public (mint-phenomenon (name (string-ascii 64)) (description (string-utf8 1024)) (properties (list 10 (tuple (key (string-ascii 64)) (value (string-utf8 256))))))
  (let
    (
      (phenomenon-id (+ (var-get last-phenomenon-id) u1))
    )
    (try! (nft-mint? planck-phenomena phenomenon-id tx-sender))
    (map-set phenomenon-data
      phenomenon-id
      {
        discoverer: tx-sender,
        name: name,
        description: description,
        properties: properties
      }
    )
    (var-set last-phenomenon-id phenomenon-id)
    (ok phenomenon-id)
  )
)

(define-public (transfer-phenomenon (phenomenon-id uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender (unwrap! (nft-get-owner? planck-phenomena phenomenon-id) ERR_INVALID_PHENOMENON)) ERR_NOT_AUTHORIZED)
    (try! (nft-transfer? planck-phenomena phenomenon-id tx-sender recipient))
    (ok true)
  )
)

;; Read-only functions
(define-read-only (get-phenomenon-data (phenomenon-id uint))
  (map-get? phenomenon-data phenomenon-id)
)

(define-read-only (get-phenomenon-owner (phenomenon-id uint))
  (nft-get-owner? planck-phenomena phenomenon-id)
)

(define-read-only (get-last-phenomenon-id)
  (var-get last-phenomenon-id)
)

