;; Simulation Management Contract

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u100))
(define-constant ERR_INVALID_SIMULATION (err u101))
(define-constant ERR_INSUFFICIENT_RESOURCES (err u102))

;; Data variables
(define-data-var simulation-count uint u0)

;; Data maps
(define-map simulations
  uint
  {
    creator: principal,
    parameters: (string-utf8 1024),
    resource-allocation: uint,
    status: (string-ascii 20),
    results: (optional (string-utf8 2048))
  }
)

;; Public functions
(define-public (create-simulation (parameters (string-utf8 1024)) (resource-allocation uint))
  (let
    (
      (simulation-id (+ (var-get simulation-count) u1))
    )
    (map-set simulations
      simulation-id
      {
        creator: tx-sender,
        parameters: parameters,
        resource-allocation: resource-allocation,
        status: "pending",
        results: none
      }
    )
    (var-set simulation-count simulation-id)
    (ok simulation-id)
  )
)

(define-public (start-simulation (simulation-id uint))
  (let
    (
      (simulation (unwrap! (map-get? simulations simulation-id) ERR_INVALID_SIMULATION))
    )
    (asserts! (is-eq tx-sender (get creator simulation)) ERR_NOT_AUTHORIZED)
    (asserts! (>= (stx-get-balance tx-sender) (get resource-allocation simulation)) ERR_INSUFFICIENT_RESOURCES)
    (try! (stx-transfer? (get resource-allocation simulation) tx-sender CONTRACT_OWNER))
    (ok (map-set simulations
      simulation-id
      (merge simulation { status: "running" })
    ))
  )
)

(define-public (update-simulation-results (simulation-id uint) (results (string-utf8 2048)))
  (let
    (
      (simulation (unwrap! (map-get? simulations simulation-id) ERR_INVALID_SIMULATION))
    )
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
    (ok (map-set simulations
      simulation-id
      (merge simulation {
        status: "completed",
        results: (some results)
      })
    ))
  )
)

;; Read-only functions
(define-read-only (get-simulation (simulation-id uint))
  (map-get? simulations simulation-id)
)

(define-read-only (get-simulation-count)
  (var-get simulation-count)
)

