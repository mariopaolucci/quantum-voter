breed [arrows arrow]
breed [voters voter]
voters-own [
  spin
  u_re
  u_im
  v_re
  v_im
  u_arrow
  v_arrow
]



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;    ORIGINAL CODE   ;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;spin=(int*)calloc(L,sizeof(int)); //opinione agenti a seguito della misura
;  prec=(int*)calloc(L,sizeof(int));
;  succ=(int*)calloc(L,sizeof(int));
;  poss=(int*)calloc(T_MAX+1,sizeof(int));
;  negs=(int*)calloc(T_MAX+1,sizeof(int));
;  bounds=(int*)calloc(T_MAX+1,sizeof(int));
;  sz=(int*)calloc(S,sizeof(int));
;  u_re=(double*)calloc(L,sizeof(double));//parte reale del coefficiente |u> dello stato
;  u_im=(double*)calloc(L,sizeof(double));//parte immag del coefficiente |u> dello stato
;  d_re=(double*)calloc(L,sizeof(double));//parte reale del coefficiente |d> dello stato
;  d_im=(double*)calloc(L,sizeof(double));//parte immag del coefficiente |d> dello stato
;

to setup-arrows
  ask voters [
    hatch-arrows 1 [
      create-link-from myself [set color green]
      hide-turtle
      ask myself [set u_arrow self]
    ]
    hatch-arrows 1 [
      create-link-from myself [set color blue]
      hide-turtle
      ask myself [set v_arrow self]
    ]
  ]
end



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;   ARROW RULES   ;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to do-coloring
  ask voters [
    ask u_arrow [move-to myself set heading [atan u_im u_re] of myself forward 1]
    ask v_arrow [move-to myself set heading [atan v_im v_re] of myself forward 1]
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; SETUP ;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



to setup-loop
  clear-all
  create-voters N
  ; fragile code follows - but they shouldn't have any "other" inlinks
  ask voters [create-link-to one-of other voters with [not any? in-link-neighbors]
    let the_angle  random-float 360
    set u_im  sin the_angle
    set u_re  cos the_angle
    set the_angle  random-float 360
    set v_im  sin the_angle
    set v_re  cos the_angle
  ]
  ;; we want to add one to each coordinate, then create links with those coordinates
  setup-arrows
  reset-ticks
end






to setup-small-world ;; Small World
  clear-all
  crt N
  ask turtles [ set shape "circle" ]
  layout-circle (sort turtles) max-pxcor - 1
  let c 0
  while [c < count turtles]
  [  ask turtle c [create-link-with turtle ((c + 1) mod count turtles)]
      set c c + 1
  ]
  reset-ticks
end

to setup-preferential ;; Scale Free
  clear-all
  create-initial-nodes
  repeat N - m0 [make-node-with preferential-group]
;  ask turtles [ set belief one-of [-3 3]
;      do-coloring]
  reset-ticks
end

to create-initial-nodes
  repeat m0
  [ make-node-with one-of other turtles ]; with [not link-neighbor? self] ] ;;do we need this part?
end

;; Idea: first create a function that takes two turtles as inputs and when executed, links the two
;; Next, repeat N times the following: create new node, link to m separate lottery winners
to make-node [arg]
  crt arg
end

;; used for creating a new node.
;; if TARGET is a single agent, link with that agent
;; if TARGET is a set of agents, link with all agents.
to make-node-with [target]
  make-node 1
  ask max-one-of turtles [who] ;; the last turtle added
  [ if target != nobody
      [ if is-agent? target
        [ create-link-with target [ set color gray ]
          move-to target ]
        if is-agentset? target
        [ create-links-with target[ set color gray ]
          move-to one-of target ]
        ;; position the new node near its partner
        fd 20 ] ]
end

to-report preferential-group
  ;; connect the turtle to m number of partners
  ;; start by creating one target
  let targets (turtle-set find-partner)
  repeat (m - 1)
  [ let next-node find-partner

    ;; add a target that is not already a target
    while [member? next-node targets]
      [set next-node find-partner ]

    set targets (turtle-set targets next-node) ]
  report targets
end


;; This code is borrowed from Lottery Example (in the Code Examples
;; section of the Models Library).
;; The idea behind the code is a bit tricky to understand.
;; Basically we take the sum of the degrees (number of connections)
;; of the turtles, and that's how many "tickets" we have in our lottery.
;; Then we pick a random "ticket" (a random number).  Then we step
;; through the turtles to figure out which node holds the winning ticket.
to-report find-partner
  let total random-float sum [count link-neighbors] of turtles
  let partner nobody
  ask turtles
  [ let nc count link-neighbors
    ;; if there's no winner yet...
    if partner = nobody
    [ ifelse nc > total
        [ set partner self ]
        [ set total total - nc ] ] ]
  report partner
end

@#$#@#$#@
GRAPHICS-WINDOW
300
10
737
448
-1
-1
13.0
1
10
1
1
1
0
0
0
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
10
35
102
68
Loop
setup-loop
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
10
405
182
438
dimension
dimension
0
5
0.0
1
1
NIL
HORIZONTAL

SLIDER
10
440
182
473
cube-length
cube-length
0
100
0.0
1
1
NIL
HORIZONTAL

SLIDER
10
475
182
508
N
N
0
5000
1338.0
1
1
NIL
HORIZONTAL

BUTTON
10
75
97
108
Mean Field
setup-fully-connected
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
100
75
190
108
Random
setup-random
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
10
110
97
143
Scale Free
setup-preferential
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
10
510
182
543
m
m
1
5
0.0
1
1
NIL
HORIZONTAL

SLIDER
10
545
182
578
m0
m0
2
5
0.0
1
1
NIL
HORIZONTAL

BUTTON
75
175
142
208
Layout
layout
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
100
110
190
143
Small World
setup-small-world
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
10
215
148
260
voting-rule
voting-rule
"extremal" "marginal"
1

BUTTON
10
175
73
208
Go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
750
10
1175
210
Opinions of the population
ticks
percent of popoulation
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"negative confident" 1.0 0 -13345367 true "" "plotxy ticks (count turtles with [belief = -3])/(count turtles + .0000000000000001)"
"positive confident" 1.0 0 -2674135 true "" "plotxy ticks (count turtles with [belief = 3])/(count turtles + .0000000000000001)"
"negative unsure" 1.0 0 -10899396 true "" "plotxy ticks (count turtles with [belief = -1])/(count turtles + .0000000000000001)"
"positive unsure" 1.0 0 -1184463 true "" "plotxy ticks (count turtles with [belief = 1])/(count turtles + .0000000000000001)"

SWITCH
10
265
142
298
simultaneous?
simultaneous?
0
1
-1000

TEXTBOX
10
20
160
38
Setup
12
0.0
1

TEXTBOX
10
160
160
178
Running the model\n
12
0.0
1

TEXTBOX
10
390
160
408
Variables
12
0.0
1

SLIDER
10
305
182
338
p
p
0
1
0.0
.01
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

This simulation models the Confident Voter model discussed in Volovik and Redner (2012). The Confident Voter model studies how individuals change opinion through interaction. Agents interact with their neighbors and adjust their opinion accordingly. Two adjustment procedures are studied: the Extremal Voter Model and the Marginal Voter Model. 

## HOW IT WORKS

Agents can have one of four opinions: negative confident, negative unsure, positive unsure, or positive confident. These four opinions can be seen as steps. Each agent is initially assigned to be either negative confident or positive confident. As the simulation runs and agents interact with other agents of different opinions, their own opinion changes based on a probability distribution. This probability distribution depends on which version of the model is being simulated, extremal or marginal. For all versions, if an agent interacts with another agent of the exact same opinion, both opinions remain unchanged.

Let us first look at the marginal version. Under this version, when two agents of the same side, e.g. both positive, but different levels of confidence interact, then either opinions remain unchanged or the unsure agent will become confident. When two agents of opposing sides interact, one will change its opinions towards the other by a step. For example, if a positive confident and a negative unsure agent interact, then either the positive confident agent becomes positive unsure, or the negative unsure agent becomes positive unsure. Which event happens depends on the variable p.

The extremal version behaves largely the same except for one key difference. When an agent changes opinion to the other side under the extremal version, it becomes confident in its new opinion. Thus in the prior example, if a positive confident agent and a negative unsure agent interact and the negative unsure agent changes opinion, then it will change to positive confident instead of positive unsure as in the marginal version. There is still the possibility in this example that the positive confident agent would switch to positive unsure. Again this depends on p, and the exact distribution can be seen in the code.

## HOW TO USE IT

To start, select one of five setup versions. These versions differ in how the agents are connected to one another. The options are Lattice, Mean Field, Random, Scale Free, and Small World.

-Lattice: Creates cube-length^dimension agents and arranges and links them to represent a lattice.
-Mean Field: Creates N agents and connects every agent to every other agent.
-Random: Creates N agents. Each agent then randomly selects one other agent and makes a link with that agent. Though each agent may only select one target, it is possible for one agent to be the target of many other agents.
-Scale Free: Arranges N agents into preferential groups determined by the m0 and m variables.
-Small World: Creates N agents and arranges them in a circle. Each agent is linked with its adjacent agents.

When using the Lattice, Random, or Scale Free setup, the Layout button may be pushed to assist in visualization. Push Layout again to stop the agent rearrangement.

Next, decide which version of the model you wish to run by selecting the appropriate one under the voting-rule chooser. Also select whether you want the mode to run simultaneously, all agents interacting each tick, or not, one randomly selected agent interacting each tick. Finally, select which value of p you would like to simulate. The default option, p=.5, makes it so that both new opinion outcomes are equally likely. We suggest you keep p=.5 to start.

When you are satisfied with the setup, press Go. Agents will change color to reflect their opinion. The opinion shares in the population are tracked in the plot on the right side of the interface. Press Go again to stop the simulation.

The sliders under the variable heading adjust the number of agents created during the setup. The dimension and cube-length sliders affect the number of agents in the Lattice setup and their relation. Similarly, the m0 and m sliders are specifically used in the Scale Free setup. See the code section for the exact implications of modifying these variables.

## THINGS TO NOTICE

Notice how the opinion shares change over time and how this differs between the marginal and extremal versions of the model. 

## THINGS TO TRY

Try adjusting the p variable to examine how changing the probability distribution over outcomes affects the share of opinions in the simulation

## EXTENDING THE MODEL

This model initially assigns positive confident and negative confident opinions with equal probability. One possible extension is to examine the effects of asymmetric initial opinions. This can be further studied by modifying the p variable with asymmetric starting distributions. It may also be interesting to see what happens when positive unsure and negative unsure opinions are initially assigned as well.

## RELATED MODELS

Axelrod
Heterogeneous Voter
Social Consensus
Ising
Potts
Voter Turnout

## CREDITS AND REFERENCES
Volovik, Daniel, and Sidney Redner. 2012. "Dynamics of Confident Voting." _Journal of Statistical Mechanics_ P04003
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
0
Rectangle -7500403 true true 151 225 180 285
Rectangle -7500403 true true 47 225 75 285
Rectangle -7500403 true true 15 75 210 225
Circle -7500403 true true 135 75 150
Circle -16777216 true false 165 76 116

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
1
@#$#@#$#@
