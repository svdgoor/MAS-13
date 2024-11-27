breed [people person]

turtles-own [
  group                      ; Group A to F, representing ethnic groups
  prejudice                  ; Prejudice level towards other groups (0 to 100)
  economic-status            ; Economic status of each agent (0-100 scale)
  location                   ; Neighborhood or area where the agent lives
  age                        ; Age for youth socialization
  ptr                        ; Probability to reproduce
  cooperate-with-same?       ; Cooperation strategy with the same group
  cooperate-with-different?  ; Cooperation strategy with other groups
]

globals [
  meet                             ; Total interactions this turn
  meet-agg                         ; Total interactions through the run
  coopown                          ; Cooperation with same group this turn
  coopown-agg                      ; Total cooperation with same group through the run
  coopother                        ; Cooperation with other groups this turn
  coopother-agg                    ; Total cooperation with other groups through the run
  defother                         ; Defection with other groups this turn
  defother-agg                     ; Total defection with other groups through the run
  defown                           ; Defection within the same group this turn
  defown-agg                       ; Total defection within the same group through the run

  interventionStartTime            ; Time when interventions start

  ; Intensity variables for each intervention
  legalPolicyIntensity             ; Intensity of legal and policy reforms
  trainingIntensity                ; Intensity of diversity/anti-prejudice training
  communityEventIntensity          ; Intensity of community-based events
  economicIncentiveIntensity       ; Intensity of economic incentives
  sharedResourceIntensity          ; Intensity of shared resource management
  youthSocializationIntensity      ; Intensity of youth socialization

  avg-prejudice-group-A
  avg-prejudice-group-B
  avg-prejudice-group-C
  avg-prejudice-group-D
  avg-prejudice-group-E

  current-environment              ; Tracks current environment type
]


; ------------------------------
; Setup the simulation
to setup
  clear-all
  setup-environment
  setup-variables
  setup-people
  reset-ticks
end

to setup-environment
  if environmentType = 0 [ ; Fully Segregated with vertical stripes
    let region-size floor (max-pxcor / 5)

    ask patches [
      if pxcor < region-size [ set pcolor pink ]
      if pxcor >= region-size and pxcor < region-size * 2 [ set pcolor sky ]
      if pxcor >= region-size * 2 and pxcor < region-size * 3 [ set pcolor lime ]
      if pxcor >= region-size * 3 and pxcor < region-size * 4 [ set pcolor yellow ]
      if pxcor >= region-size * 4 [ set pcolor orange ]
    ]

    ; Place agents strictly in their regions
    ask people [
      if group = "A" [ move-to one-of patches with [pcolor = pink] ]
      if group = "B" [ move-to one-of patches with [pcolor = sky] ]
      if group = "C" [ move-to one-of patches with [pcolor = lime] ]
      if group = "D" [ move-to one-of patches with [pcolor = yellow] ]
      if group = "E" [ move-to one-of patches with [pcolor = orange] ]
    ]
  ]

  if environmentType = 1 [ ; Fully Mixed
    ask patches [ set pcolor gray ]
    ask people [ move-to one-of patches ]
  ]

  if environmentType = 2 [ ; Partial Segregation with natural clusters
    ; Start with all patches gray
    ask patches [ set pcolor gray ]

    ; Create cluster centers for each group
    let cluster-centers sort n-of 5 patches
    let colors (list pink sky lime yellow orange)
    let group-num 0

    ; For each cluster center
    foreach cluster-centers [ center ->
      ; Color a circular region around the center
      let this-color item group-num colors
      ask center [
        ask patches in-radius 6 [ ; Adjust radius as needed
          if random 100 < 90 [ ; 90% chance to be part of cluster
            set pcolor this-color
          ]
        ]
      ]
      set group-num group-num + 1
    ]

    ; Create interaction zones between clusters
    ask patches [
      if count neighbors with [pcolor != [pcolor] of myself] > 2 [
        if random 100 < 30 [ ; 30% chance to become interaction zone
          set pcolor gray
        ]
      ]
    ]

    ; Place agents with mixed strategy
    ask people [
      let target-color ifelse-value (group = "A") [pink]
        [ifelse-value (group = "B") [sky]
        [ifelse-value (group = "C") [lime]
        [ifelse-value (group = "D") [yellow]
        [orange]]]]

      ifelse random-float 100 < 70
        [ move-to one-of patches with [pcolor = target-color] ]
        [ move-to one-of patches with [pcolor = gray] ]
    ]
  ]
end

; ------------------------------
; Setup variables and agents
to setup-variables
  set meet 0
  set meet-agg 0
  set coopown 0
  set coopown-agg 0
  set coopother 0
  set coopother-agg 0
  set defother 0
  set defother-agg 0
end

to setup-people
  create-people 100 [
    setxy random-xcor random-ycor
    set group one-of ["A" "B" "C" "D" "E"]

    ; Different initial prejudice based on environment
    set prejudice random-float (
      ifelse-value (environmentType = 0)
        [ 75 ]  ; Higher initial prejudice in segregated
        [ ifelse-value (environmentType = 1)
            [ 25 ]  ; Lower initial prejudice in mixed
            [ 50 ]  ; Medium initial prejudice in partial
        ])

    ; Different economic status distributions
    set economic-status random-float (
      ifelse-value (environmentType = 0)
        [ 100 * (random-float 0.5 + 0.5) ]  ; Higher inequality in segregated
        [ ifelse-value (environmentType = 1)
            [ 100 ]  ; More equal in mixed
            [ 100 * (random-float 0.7 + 0.3) ]  ; Moderate inequality in partial
        ])

    set age random 100
    set ptr 0.5

    ; Different initial cooperation strategies
    set cooperate-with-same? (
      ifelse-value (environmentType = 0)
        [ true ]  ; Always cooperate with same group in segregated
        [ random 2 = 0 ]  ; Random in other environments
    )

    set cooperate-with-different? (
      ifelse-value (environmentType = 1)
        [ random 2 = 0 ]  ; More likely in mixed
        [ random 5 = 0 ]  ; Less likely in others
    )
  ]
  update-shape
end


; ------------------------------
; Update shapes dynamically
to update-shape
  ask people [
    if group = "A" [ set shape "circle" set color red ]       ; Group A → Pink region
    if group = "B" [ set shape "square" set color blue ]      ; Group B → Sky region
    if group = "C" [ set shape "triangle" set color green ]   ; Group C → Lime region
    if group = "D" [ set shape "star" set color black ]       ; Group D → Yellow region
    if group = "E" [ set shape "person" set color violet ]    ; Group E → Orange region
  ]
end

; ------------------------------
to go
  ;; Sync sliders to global variables
  set interventionStartTime slider_interventionStartTime
  set legalPolicyIntensity slider_legalPolicyIntensity
  set trainingIntensity slider_trainingIntensity
  set communityEventIntensity slider_communityEventIntensity
  set economicIncentiveIntensity slider_economicIncentiveIntensity
  set sharedResourceIntensity slider_sharedResourceIntensity
  set youthSocializationIntensity slider_youthSocializationIntensity

  ;; Determine if forced interventions are active
  let forced-intervention-active? (
    youthSocializationIntensity > 0 or
    sharedResourceIntensity > 0 or
    communityEventIntensity > 0
  )

  ;; Movement logic for environment 0
  if environmentType = 0 [
    if forced-intervention-active? [
      ;; Apply movement logic based on the active intervention
      ask people [
        move-based-on-intervention
      ]
    ]
    if not forced-intervention-active? [
      ;; Confine all agents to their assigned regions
      ask people [
        move-within-region
      ]
    ]
  ]

  ;; Movement for other environments
  if environmentType = 1 [
    ask people [ move-around ]
  ]
  if environmentType = 2 [
    ask people [
      let stay-segregated random-float 100 < 70
      if stay-segregated [ move-within-region ]
      if not stay-segregated [ move-around ]
    ]
  ]

  clear-stats
  ask people [
    interact
    update-prejudice
  ]

  implement-interventions
  update-stats
  tick
end

; ------------------------------

to move-based-on-intervention
  ;; Community Events: All agents move visibly across boundaries
  if communityEventIntensity > 0 [
    let step-size (communityEventIntensity / 10) + 2 ;; Higher intensity = larger steps
    let move-chance communityEventIntensity / 100  ;; Higher intensity = more frequent movement
    if random-float 1 < move-chance [
      rt random 360
      fd step-size
      stop
    ]
  ]

  ;; Shared Resources: All agents move visibly across boundaries
  if sharedResourceIntensity > 0 [
    let step-size (sharedResourceIntensity / 10) + 2 ;; Higher intensity = larger steps
    let move-chance sharedResourceIntensity / 100  ;; Higher intensity = more frequent movement
    if random-float 1 < move-chance [
      rt random 360
      fd step-size
      stop
    ]
  ]

  ;; Youth Socialization: Only agents under 18 move
  if youthSocializationIntensity > 0 and age < 18 [
    let step-size (youthSocializationIntensity / 10) + 2
    let move-chance youthSocializationIntensity / 100
    if random-float 1 < move-chance [
      rt random 360
      fd step-size
      stop
    ]
  ]

  ;; Agents not affected by active interventions stay within their region
  move-within-region
end

;; Modified move-within-region procedure to differentiate behavior
to move-within-region
  let current-region-color
    ifelse-value (group = "A") [pink]
    [ifelse-value (group = "B") [sky]
    [ifelse-value (group = "C") [lime]
    [ifelse-value (group = "D") [yellow]
    [orange]]]]

  ;; Different behavior based on environment type
  if environmentType = 0 [
    ;; Strictly enforce region boundaries
    if pcolor != current-region-color [
      move-to one-of patches with [pcolor = current-region-color]
    ]
    ;; Very limited movement within region
    rt random 30
    fd 0.5
  ]

  if environmentType = 2 [
    ;; Allow some boundary crossing
    ifelse pcolor = current-region-color [
      ;; When in home region, chance to stay or leave
      ifelse random-float 100 < 30 [  ;; 30% chance to try leaving
        let neighbor-regions patch-set patches with [
          distance myself < 3 and               ;; Look at nearby patches
          pcolor != [pcolor] of myself and      ;; Different color than current
          pcolor != black                       ;; Not a boundary
        ]
        if any? neighbor-regions [
          move-to one-of neighbor-regions
        ]
      ][
        ;; Stay in region but more movement freedom
        rt random 90
        fd 1
      ]
    ][
      ;; When outside home region, higher chance to return
      if random-float 100 < 60 [  ;; 60% chance to return home
        move-to one-of patches with [pcolor = [current-region-color] of myself]
      ]
    ]
  ]
end





;; Modified movement procedure
to move-around
  if environmentType = 1 [
    ; More random movement in mixed environment
    rt random 360
    fd 2  ; Increased movement distance
  ]
  if environmentType = 0 [
    ; Very limited movement in segregated environment
    rt random 45  ; Limited turning
    fd 0.5  ; Limited movement distance
  ]
  if environmentType = 2 [
    ; Moderate movement in partially segregated
    rt random 180
    fd 1
  ]
end



to interact
  let neighbor one-of turtles in-radius 1
  if neighbor != nobody [
    let interaction-group [group] of neighbor
    let interaction-outcome 0 ;; Default outcome is defection

    ;; Calculate base interaction probability based on environment type
    let base-interaction-probability 0

    ;; Env 0: Highly segregated - very low probability of inter-group interaction
    if environmentType = 0 [
      ifelse group = interaction-group [
        set base-interaction-probability 0.9  ;; High in-group interaction
      ][
        set base-interaction-probability 0.1  ;; Very low out-group interaction
      ]
    ]

    ;; Env 1: Fully mixed - equal probability for all interactions
    if environmentType = 1 [
      set base-interaction-probability 0.5
    ]

    ;; Env 2: Partially segregated - moderate probability differences
    if environmentType = 2 [
      ifelse group = interaction-group [
        set base-interaction-probability 0.7  ;; Moderate in-group preference
      ][
        ifelse [pcolor] of patch-here = gray [
          ;; In interaction zones, higher inter-group interaction
          set base-interaction-probability 0.6
        ][
          ;; Outside interaction zones, moderate inter-group interaction
          set base-interaction-probability 0.3
        ]
      ]
    ]

    ;; Check if interaction occurs based on probability
    if random-float 1 < base-interaction-probability [
      ;; Calculate intervention effects
      let intervention-multiplier 1
      if ticks >= interventionStartTime [
        set intervention-multiplier (1 +
          (legalPolicyIntensity / 100 * 0.3) +
          (trainingIntensity / 100 * 0.4) +
          (communityEventIntensity / 100 * 0.3) +
          (economicIncentiveIntensity / 100 * ifelse-value (economic-status < 50) [0.4] [0.1]) +
          (sharedResourceIntensity / 100 * 0.3) +
          (youthSocializationIntensity / 100 * ifelse-value (age < 18) [0.5] [0.1])
        )
      ]

      ;; Environment-specific cooperation effects
      let cooperation-effect
        ifelse-value (environmentType = 0) [
          ifelse-value (group = interaction-group) [2] [5]  ;; Bigger impact in segregated
        ][
          ifelse-value (environmentType = 1) [
            3  ;; Moderate impact in mixed
          ][
            ifelse-value ([pcolor] of patch-here = gray) [4] [3]  ;; Enhanced effect in interaction zones
          ]
        ]

      ;; Determine if cooperation occurs
      ifelse random-float 1 < (base-interaction-probability * intervention-multiplier) [
        set interaction-outcome 1

        ;; Apply prejudice reduction based on environment and location
        let prejudice-reduction cooperation-effect *
          ifelse-value (environmentType = 2 and [pcolor] of patch-here = gray)
          [1.5]  ;; Enhanced effect in interaction zones
          [1]

        set prejudice max list 0 (prejudice - prejudice-reduction)
      ][
        ;; Failed interaction increases prejudice
        let defection-effect
          ifelse-value (environmentType = 0) [2]
          [ifelse-value (environmentType = 1) [1] [1.5]]

        set prejudice min list 100 (prejudice + defection-effect)
      ]
    ]

    ;; Update interaction counters
    if interaction-outcome = 1 [
      ifelse group = interaction-group [
        set coopown coopown + 1
      ][
        set coopother coopother + 1
      ]
    ]
    if interaction-outcome = 0 [
      ifelse group = interaction-group [
        set defown defown + 1
      ][
        set defother defother + 1
      ]
    ]
  ]
end

to update-prejudice
  ask people [
    ;; Natural prejudice growth varies by environment
    if random-float 100 < 20 [
      let growth-rate (
        ifelse-value (environmentType = 0) [
          0.8  ;; Higher growth in segregated
        ][
          ifelse-value (environmentType = 1) [
            0.3  ;; Lower in mixed
          ][
            0.5  ;; Medium in partial
          ]
        ]
      )
      set prejudice prejudice + growth-rate
    ]

    if ticks >= interventionStartTime [
      let total-effect 0

      ;; Legal Policy
      if legalPolicyIntensity > 0 [
        let env-multiplier (
          ifelse-value (environmentType = 0) [
            2.0  ;; Most effective in segregated
          ][
            ifelse-value (environmentType = 1) [
              0.5  ;; Less needed in mixed
            ][
              1.0  ;; Medium in partial
            ]
          ]
        )
        set total-effect total-effect + (legalPolicyIntensity / 100 * 0.3 * env-multiplier)
      ]

      ;; Training
      if trainingIntensity > 0 [
        let env-multiplier (
          ifelse-value (environmentType = 0) [
            0.5  ;; Less effective in segregated
          ][
            ifelse-value (environmentType = 1) [
              2.0  ;; Most effective in mixed
            ][
              1.0  ;; Medium in partial
            ]
          ]
        )
        set total-effect total-effect + (trainingIntensity / 100 * 0.3 * env-multiplier)
      ]

      ;; Community Events
      if communityEventIntensity > 0 [
        let env-multiplier (
          ifelse-value (environmentType = 0) [
            0.3  ;; Least effective in segregated
          ][
            ifelse-value (environmentType = 1) [
              2.0  ;; Most effective in mixed
            ][
              1.0  ;; Medium in partial
            ]
          ]
        )
        let nearby-diversity length remove-duplicates [group] of turtles in-radius 3
        set total-effect total-effect + (communityEventIntensity / 100 * env-multiplier * (nearby-diversity / 5))
      ]

      ;; Economic Incentives
      if economicIncentiveIntensity > 0 [
        let env-multiplier (
          ifelse-value (environmentType = 0) [
            2.0  ;; Most effective in segregated
          ][
            ifelse-value (environmentType = 1) [
              0.5  ;; Less needed in mixed
            ][
              1.0  ;; Medium in partial
            ]
          ]
        )
        let economic-factor ifelse-value (economic-status < 50) [1.5] [0.5]
        set total-effect total-effect + (economicIncentiveIntensity / 100 * 0.3 * env-multiplier * economic-factor)
      ]

      ;; Shared Resources
      if sharedResourceIntensity > 0 [
        let env-multiplier (
          ifelse-value (environmentType = 0) [
            0.3  ;; Least effective in segregated
          ][
            ifelse-value (environmentType = 1) [
              2.0  ;; Most effective in mixed
            ][
              1.0  ;; Medium in partial
            ]
          ]
        )
        set total-effect total-effect + (sharedResourceIntensity / 100 * 0.3 * env-multiplier)
      ]

      ;; Youth Socialization
      if youthSocializationIntensity > 0 [
        let env-multiplier (
          ifelse-value (environmentType = 0) [
            0.7  ;; Less effective in segregated
          ][
            ifelse-value (environmentType = 1) [
              2.0  ;; Most effective in mixed
            ][
              1.2  ;; Medium-high in partial
            ]
          ]
        )
        let youth-factor ifelse-value (age < 18) [2.0] [0.1]
        set total-effect total-effect + (youthSocializationIntensity / 100 * 0.3 * env-multiplier * youth-factor)
      ]

      ;; Apply total effect
      set prejudice prejudice * (1 - total-effect)
      set prejudice max list 0 (min list 100 prejudice)
    ]
  ]
end

; ------------------------------
; Implement all interventions
to implement-interventions
  if ticks >= interventionStartTime [
    ;; Legal and policy reforms apply to all people with high prejudice
    ask people with [prejudice > 50] [
      set prejudice max list 0 (prejudice * (1 - (legalPolicyIntensity / 100)))
    ]

    ;; Training can apply to a specific group or globally
    ask people [
      set prejudice max list 0 (prejudice * (1 - (trainingIntensity / 100)))
    ]

    ;; Community events occur in specific areas (lime or yellow patches)
    ask patches with [pcolor = lime or pcolor = yellow] [
      ask people-here [
        let neighbor one-of other people-here
        if neighbor != nobody and group != [group] of neighbor [
          set prejudice max list 0 (prejudice * (1 - (communityEventIntensity / 100)))
        ]
      ]
    ]

    ;; Economic incentives target people with low economic status
    ask people with [economic-status < 50] [
      set prejudice max list 0 (prejudice * (1 - (economicIncentiveIntensity / 100)))
    ]

    ;; Shared resource management applies to all groups except A (adjust if needed)
    ask people [
      if group != "A" [
        set prejudice max list 0 (prejudice * (1 - (sharedResourceIntensity / 100)))
      ]
    ]

    ;; Youth socialization targets people under 18
    ask people with [age < 18] [
      set prejudice max list 0 (prejudice * (1 - (youthSocializationIntensity / 100)))
    ]
  ]
end


; ------------------------------
; Reset counters each tick
to clear-stats
  set meet 0
  set coopown 0
  set coopother 0
  set defother 0
  set defown 0
end


; ------------------------------
; Update statistics
; Update statistics
to update-stats
  set meet-agg meet-agg + meet
  set coopown-agg coopown-agg + coopown
  set coopother-agg coopother-agg + coopother
  set defother-agg defother-agg + defother
  set defown-agg defown-agg + defown

  if any? people with [group = "A"] [
    set avg-prejudice-group-A mean [prejudice] of people with [group = "A"]
  ]
  if not any? people with [group = "A"] [ set avg-prejudice-group-A 0 ]

  if any? people with [group = "B"] [
    set avg-prejudice-group-B mean [prejudice] of people with [group = "B"]
  ]
  if not any? people with [group = "B"] [ set avg-prejudice-group-B 0 ]

  if any? people with [group = "C"] [
    set avg-prejudice-group-C mean [prejudice] of people with [group = "C"]
  ]
  if not any? people with [group = "C"] [ set avg-prejudice-group-C 0 ]

  if any? people with [group = "D"] [
    set avg-prejudice-group-D mean [prejudice] of people with [group = "D"]
  ]
  if not any? people with [group = "D"] [ set avg-prejudice-group-D 0 ]

  if any? people with [group = "E"] [
    set avg-prejudice-group-E mean [prejudice] of people with [group = "E"]
  ]
  if not any? people with [group = "E"] [ set avg-prejudice-group-E 0 ]
end