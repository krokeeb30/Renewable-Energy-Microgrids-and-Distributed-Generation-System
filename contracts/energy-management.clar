;; Energy Management Contract
;; Manages energy production, consumption, and participant registration

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-PARTICIPANT-EXISTS (err u101))
(define-constant ERR-PARTICIPANT-NOT-FOUND (err u102))
(define-constant ERR-INVALID-INPUT (err u103))
(define-constant ERR-INSUFFICIENT-CAPACITY (err u104))
(define-constant ERR-GRID-DISCONNECTED (err u105))

;; Data Variables
(define-data-var total-production uint u0)
(define-data-var total-consumption uint u0)
(define-data-var grid-balance int 0)
(define-data-var emergency-mode bool false)

;; Data Maps
(define-map participants principal {
  participant-type: (string-ascii 20),
  capacity: uint,
  current-production: uint,
  current-consumption: uint,
  grid-connected: bool,
  registration-block: uint,
  status: (string-ascii 20)
})

(define-map energy-storage principal {
  storage-capacity: uint,
  current-stored: uint,
  charge-rate: uint,
  discharge-rate: uint,
  efficiency: uint
})

(define-map production-history {participant: principal, block: uint} {
  production: uint,
  timestamp: uint
})

(define-map consumption-history {participant: principal, block: uint} {
  consumption: uint,
  timestamp: uint
})

;; Public Functions

;; Register a new energy participant
(define-public (register-participant (participant-type (string-ascii 20)) (capacity uint) (grid-connected bool))
  (let ((participant tx-sender))
    (asserts! (> capacity u0) ERR-INVALID-INPUT)
    (asserts! (is-none (map-get? participants participant)) ERR-PARTICIPANT-EXISTS)
    (map-set participants participant {
      participant-type: participant-type,
      capacity: capacity,
      current-production: u0,
      current-consumption: u0,
      grid-connected: grid-connected,
      registration-block: block-height,
      status: "active"
    })
    (ok true)
  )
)

;; Update energy production for a participant
(define-public (update-production (production uint))
  (let (
    (participant tx-sender)
    (participant-data (unwrap! (map-get? participants participant) ERR-PARTICIPANT-NOT-FOUND))
  )
    (asserts! (<= production (get capacity participant-data)) ERR-INSUFFICIENT-CAPACITY)
    (asserts! (get grid-connected participant-data) ERR-GRID-DISCONNECTED)

    ;; Update participant production
    (map-set participants participant (merge participant-data {current-production: production}))

    ;; Record production history
    (map-set production-history {participant: participant, block: block-height} {
      production: production,
      timestamp: (unwrap-panic (get-block-info? time block-height))
    })

    ;; Update total production
    (var-set total-production (+ (var-get total-production) production))
    (update-grid-balance)
    (ok true)
  )
)

;; Update energy consumption for a participant
(define-public (update-consumption (consumption uint))
  (let (
    (participant tx-sender)
    (participant-data (unwrap! (map-get? participants participant) ERR-PARTICIPANT-NOT-FOUND))
  )
    (asserts! (> consumption u0) ERR-INVALID-INPUT)

    ;; Update participant consumption
    (map-set participants participant (merge participant-data {current-consumption: consumption}))

    ;; Record consumption history
    (map-set consumption-history {participant: participant, block: block-height} {
      consumption: consumption,
      timestamp: (unwrap-panic (get-block-info? time block-height))
    })

    ;; Update total consumption
    (var-set total-consumption (+ (var-get total-consumption) consumption))
    (update-grid-balance)
    (ok true)
  )
)

;; Register energy storage system
(define-public (register-storage (storage-capacity uint) (charge-rate uint) (discharge-rate uint) (efficiency uint))
  (let ((participant tx-sender))
    (asserts! (> storage-capacity u0) ERR-INVALID-INPUT)
    (asserts! (<= efficiency u100) ERR-INVALID-INPUT)
    (asserts! (is-some (map-get? participants participant)) ERR-PARTICIPANT-NOT-FOUND)

    (map-set energy-storage participant {
      storage-capacity: storage-capacity,
      current-stored: u0,
      charge-rate: charge-rate,
      discharge-rate: discharge-rate,
      efficiency: efficiency
    })
    (ok true)
  )
)

;; Charge energy storage
(define-public (charge-storage (amount uint))
  (let (
    (participant tx-sender)
    (storage-data (unwrap! (map-get? energy-storage participant) ERR-PARTICIPANT-NOT-FOUND))
    (new-stored (+ (get current-stored storage-data) amount))
  )
    (asserts! (<= new-stored (get storage-capacity storage-data)) ERR-INSUFFICIENT-CAPACITY)
    (asserts! (<= amount (get charge-rate storage-data)) ERR-INVALID-INPUT)

    (map-set energy-storage participant (merge storage-data {current-stored: new-stored}))
    (ok true)
  )
)

;; Discharge energy storage
(define-public (discharge-storage (amount uint))
  (let (
    (participant tx-sender)
    (storage-data (unwrap! (map-get? energy-storage participant) ERR-PARTICIPANT-NOT-FOUND))
    (current-stored (get current-stored storage-data))
  )
    (asserts! (<= amount current-stored) ERR-INSUFFICIENT-CAPACITY)
    (asserts! (<= amount (get discharge-rate storage-data)) ERR-INVALID-INPUT)

    (map-set energy-storage participant (merge storage-data {
      current-stored: (- current-stored amount)
    }))
    (ok true)
  )
)

;; Emergency grid control (admin only)
(define-public (set-emergency-mode (enabled bool))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set emergency-mode enabled)
    (ok true)
  )
)

;; Private Functions

;; Update grid balance calculation
(define-private (update-grid-balance)
  (let (
    (production (var-get total-production))
    (consumption (var-get total-consumption))
    (balance (- (to-int production) (to-int consumption)))
  )
    (var-set grid-balance balance)
    balance
  )
)

;; Read-only Functions

;; Get participant information
(define-read-only (get-participant (participant principal))
  (map-get? participants participant)
)

;; Get storage information
(define-read-only (get-storage-info (participant principal))
  (map-get? energy-storage participant)
)

;; Get current grid balance
(define-read-only (get-grid-balance)
  (var-get grid-balance)
)

;; Get total production
(define-read-only (get-total-production)
  (var-get total-production)
)

;; Get total consumption
(define-read-only (get-total-consumption)
  (var-get total-consumption)
)

;; Check if emergency mode is active
(define-read-only (is-emergency-mode)
  (var-get emergency-mode)
)

;; Get production history
(define-read-only (get-production-history (participant principal) (block uint))
  (map-get? production-history {participant: participant, block: block})
)

;; Get consumption history
(define-read-only (get-consumption-history (participant principal) (block uint))
  (map-get? consumption-history {participant: participant, block: block})
)
