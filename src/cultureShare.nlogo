breed [people person]
breed [houses house]
people-own [culture]
houses-own [age]
patches-own [very-low very-high]

;; start setup

to setup
  clear-all
  set-default-shape houses "house"
  setup-patches
  setup-people
  setup-initial-culture
  color-people
  reset-ticks
  stop
end

to setup-patches
  ask patches [
    set pcolor black
    set very-high 0
    set very-low 0
  ]
end

to setup-people
  create-people people-number [
    set color white
    set culture 0
    set shape "person"
  ]
  ask turtles [
    setxy random-xcor random-ycor
  ]
end

;gives two random people opposite culture values
;to begin the simulation
to setup-initial-culture
  ask one-of people [
    set culture .1
  ]
  ask one-of people with [culture = 0]
  [
    set culture -.1
    ]
end

;assigns colors to people
to color-people
  ask people [
    if culture = 0 [
      set color [255 255 255]
      stop
    ]
    if culture > 0 [
      set color [255 0 0]
    ]
    if culture < 0 [
      set color [0 0 255]
    ]
  ]
end

;;end setup

;;start go

to go
  move-people
  influence-people
  degenerate-people
  color-people
  check-people
  validate-patch-for-house
  build-houses
  kill-houses
  tick
  age-houses
end

to check-people
  ask people [
    if culture > 1 [
      set culture 1
      stop
    ]
    if culture < -1 [
      set culture -1
      stop
    ]
  ]
end

;random movement
;(possibly change to a "flocking" movement)
to move-people
  ask people [
    right random 360
    forward 1
  ]
end

;changes culture of people around a person according to
;person's (myself's) culture and the proximity of the
;people being asked to houses
to influence-people
  ask people [
    ifelse culture > 0 [
      ifelse any? houses with [color = [255 150 160]] in-radius borders [
        ask people in-radius loudness [
          ifelse culture > 0 [
            set culture (culture + [culture] of myself * .4)
          ][
          set culture (culture + [culture] of myself * .2)
          ]
        ]
      ][
      ask people in-radius loudness [
        set culture (culture + [culture] of myself * .1)
        ]
      ]
    ][
    ifelse culture < 0 [
      ifelse any? houses with [color = [0 255 255]] in-radius borders [
        ask people in-radius loudness [
          ifelse culture < 0 [
            set culture (culture + [culture] of myself * .4)
        ][
          set culture (culture + [culture] of myself * .2)
          ]
        ]
     ][
      ask people in-radius loudness [
        set culture (culture + [culture] of myself * .1)
        ]
      ]
    ][
    ask people in-radius loudness [
      set culture (culture + [culture] of myself * .1)
    ]
  ]
]
  ]
end

;culture values fall
;isolated people will have their culture values fall
to degenerate-people
  ask people [
    if culture = 0 [
      stop
    ]
    if abs culture > 0 [
      set culture (culture - culture / 10)
    ]
  ]
end


;asks people if there is enough culture to build a house
;assigns values to houses
to validate-patch-for-house
  ask people [
    if sum ([culture] of people in-radius culture-to-house-radius) > 5 [
      ask patch-here [
        set very-high 1
        set very-low 0
        stop
      ]
    ]
    if sum ([culture] of people in-radius culture-to-house-radius) < -5 [
      ask patch-here [
        set very-low 1
        set very-high 0
        stop
      ]
    ]
  ]
end

;"sprouts" the house
;also "kills" the house
;houses of the wrong color according to people around have not been "seen" before
;the turtle "sees" the patch.
;; NOTE: a house that spawns cyan but is seemingly sprouted by a red person has not had the
;; condition of very-low met yet, the sum of culture around it is not low enough to set very-high 0.
to build-houses
  ask people [
    ask patch-here [
      if not any? houses in-radius borders [
        if-else very-high = 1 [
          sprout-houses 1 [set color [255 150 160]]
        ][
          if-else very-low = 1 [
            sprout-houses 1 [set color [0 255 255]]
          ][
            ask houses-here [die]
          ]
        ]
      ]
    ]
  ]
end

;to kill houses after number of ticks
to kill-houses
  ask houses [
    if ticks-to-kill = 0 [
      stop
    ]
    if age > ticks-to-kill [
      die
    ]
  ]
end

;to age houses per tick
to age-houses
  ask houses [
    set age (age + 1)
  ]
end


;;end go
@#$#@#$#@
GRAPHICS-WINDOW
210
10
933
427
30
16
11.7
1
10
1
1
1
0
1
1
1
-30
30
-16
16
0
0
1
ticks
30.0

BUTTON
10
10
74
43
setup
setup
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
60
182
93
people-number
people-number
0
250
100
5
1
NIL
HORIZONTAL

BUTTON
140
10
203
43
NIL
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

BUTTON
75
10
138
43
once
go
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
11
104
183
137
loudness
loudness
0
10
5
1
1
NIL
HORIZONTAL

SLIDER
10
152
182
185
borders
borders
0
10
5
1
1
NIL
HORIZONTAL

PLOT
959
23
1331
409
Cultures
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"positivsim" 1.0 0 -2674135 true "" "plot count people with [culture > 0]"
"negativism" 1.0 0 -13345367 true "" "plot count people with [culture < 0]"
"nihilism" 1.0 0 -7500403 true "" "plot count people with [culture = 0]"

SLIDER
10
196
183
229
culture-to-house-radius
culture-to-house-radius
0
10
2
1
1
NIL
HORIZONTAL

SLIDER
10
239
182
272
ticks-to-kill
ticks-to-kill
0
1000
1000
10
1
NIL
HORIZONTAL

TEXTBOX
16
287
166
315
If ticks-to-kill is set to 0, houses last indefinitely.
11
0.0
1

@#$#@#$#@
## WHAT IS IT?

This model simulates the spread of culture via communication through a small population of individuals. The simulation attempts to help the user better understand a few basic components of cultural evolution. It also aims to represent a form of scaffolding in which houses serve as artifacts that alter the transmission of culture. These houses are generated when a group of similar individuals congregate in an area and help to spread their shared culture.

## HOW IT WORKS

Each person has one 1 of 3 'culture' values: red (culture > 0), blue (culture < 0), or white/neutral (culture = 0). At setup, only 1 red person and 1 blue person exist while all others are neutral. People with cultural values greater than or less than 0 will attempt to transmit their cultural value to others within their 'loudness' radius, moving randomly along the patches. Neutral individuals do not spread their neutrality – as such the number of neutral individuals gradually decreases as the model runs. For example, if a neutral person comes within 5 patches of a blue person when loudness= 5 then the neutral person will be receptive to blue’s cultural transmission.

People with culture can also develop 'influence'. Influence is the strength of one's cultural transmission and helps determine the direction of cultural transmission. As people interact with other people of the same cultural value their influence levels strengthen. Individuals with lesser cultural influence will be more receptive to individuals with greater cultural influence. If two non-matching individuals come in communication range, the person with weaker influence will be swayed in the direction of the person with stronger influence.

When people of shared cultural values concentrate in an area, that area's cultural value will set the foundation for a like colored 'house' on a nearby patch. When the cultural value of that area reaches a limit, a house matching the color of the people in that area will spawn on that patch.

Houses serve as scaffolding objects which alter cultural transmission. For example, if a red person is near a red house communicating with another red person, the receiver’s influence is strengthened by .4 in the direction of red. If a red person is near a red house and communicating with a blue person, the receptive blue’s culture is weakened by .2 in the direction of red. If a blue person is near a red house and communicating with a red person, the receptive red’s culture is weakened by .1 in the direction of blue.

In effect, the houses strengthen cultural transmission between matching individuals when both match the house. Houses maintain average transmission between non-matching individuals when the receiver does not match the house.  And houses weaken transmission of non-matching individuals when the receiver matches the house.


## HOW TO USE IT

One can change the number of people with the 'people-number' slider. The loudness slider changes the patch radius with which the people communicate. The louder the slider, the greater the communication distance between two people. The 'borders' slider fixes the patch distance between houses. The smaller the boarder size, the closer houses can be built. For example, if the boarder is set to 5 then houses can be no closer than 5 patches apart. ‘Culture-to-house-radius’ determines the ability of individuals to create houses. When ‘culture-to-house-radius’ is 0, houses cannot be created. When this number is high houses form easily. ‘Ticks-to-kill’ determine the lifespan of the houses; lowering this slider reduces the lifespan of houses. However, if ‘ticks-to-kill’ is at 0 then houses will not die.

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
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
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

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

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.3
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="testorama" repetitions="4" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="100"/>
    <metric>count people with [culture &gt; 0]</metric>
    <metric>count people with [culture &lt; 0]</metric>
    <enumeratedValueSet variable="people-number">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="borders">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="loudness">
      <value value="5"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
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
0
@#$#@#$#@
