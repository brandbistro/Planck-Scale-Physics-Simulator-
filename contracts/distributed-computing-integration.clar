;; Distributed Computing Integration Contract

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u100))
(define-constant ERR_INVALID_COMPUTATION (err u101))

;; Data variables
(define-data-var computation-count uint u0)

;; Data maps
(define-map computations
  uint
  {
    requester: principal,
    simulation-id: uint,
    resource-requirements: uint,
    status: (string-ascii 20),
    result: (optional (string-utf8 1024))
  }
)

(define-map compute-nodes
  principal
  {
    capacity: uint,
    reputation: uint,
    active: bool
  }
)

;; Public functions
(define-public (register-compute-node (capacity uint))
  (ok (map-set compute-nodes
    tx-sender
    {
      capacity: capacity,
      reputation: u0,
      active: true
    }
  ))
)

(define-public (request-computation (simulation-id uint) (resource-requirements uint))
  (let
    (
      (computation-id (+ (var-get computation-count) u1))
    )
    (map-set computations
      computation-id
      {
        requester: tx-sender,
        simulation-id: simulation-id,
        resource-requirements: resource-requirements,
        status: "pending",
        result: none
      }
    )
    (var-set computation-count computation-id)
    (ok computation-id)
  )
)

(define-public (process-computation (computation-id uint))
  (let
    (
      (computation (unwrap! (map-get? computations computation-id) ERR_INVALID_COMPUTATION))
      (node (unwrap! (map-get? compute-nodes tx-sender) ERR_NOT_AUTHORIZED))
    )
    (asserts! (>= (get capacity node) (get resource-requirements computation)) ERR_NOT_AUTHORIZED)
    (ok (map-set computations
      computation-id
      (merge computation { status: "processing" })
    ))
  )
)

(define-public (submit-computation-result (computation-id uint) (result (string-utf8 1024)))
  (let
    (
      (computation (unwrap! (map-get? computations computation-id) ERR_INVALID_COMPUTATION))
    )
    (asserts! (is-eq (get status computation) "processing") ERR_NOT_AUTHORIZED)
    (ok (map-set computations
      computation-id
      (merge computation {
        status: "completed",
        result: (some result)
      })
    ))
  )
)

;; Read-only functions
(define-read-only (get-computation (computation-id uint))
  (map-get? computations computation-id)
)

(define-read-only (get-compute-node (node-address principal))
  (map-get? compute-nodes node-address)
)

(define-read-only (get-computation-count)
  (var-get computation-count)
)

