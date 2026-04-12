(source-directories '("." "../../"))
(load "sk.scm")

; colors(red;green;ivory;yellow;blue).
(defineo (colors c)
  (conde
    [(== c 'red)]
    [(== c 'green)]
    [(== c 'ivory)]
    [(== c 'yellow)]
    [(== c 'blue)]
))

; nationalities(english;spaniard;ukrainian;norwegian;japanese).
(defineo (nationalities n)
  (conde
    [(== n 'english)]
    [(== n 'spaniard)]
    [(== n 'ukrainian)]
    [(== n 'norwegian)]
    [(== n 'japanese)]
))

; animals(dog;fox;horse;zebra;snails).
(defineo (animals a)
  (conde
    [(== a 'dog)]
    [(== a 'fox)]
    [(== a 'horse)]
    [(== a 'zebra)]
    [(== a 'snails)]
))

; drinks(coffee;tea;milk;orange_juice;water).
(defineo (drinks d)
  (conde
    [(== d 'coffee)]
    [(== d 'tea)]
    [(== d 'milk)]
    [(== d 'orange_juice)]
    [(== d 'water)]
))

; cigarettes(old_gold;kools;chesterfields;lucky_strike;parliaments).
(defineo (cigarettes c)
  (conde
    [(== c 'old_gold)]
    [(== c 'kools)]
    [(== c 'chesterfields)]
    [(== c 'lucky_strike)]
    [(== c 'parliaments)]
))

; houses(1..5).
(defineo (houses h)
  (conde
    [(== h 1)]
    [(== h 2)]
    [(== h 3)]
    [(== h 4)]
    [(== h 5)]
))

; The domain of neighbor is 4: {(1, 2), (2, 3), (3, 4), (4, 5)}.
; However, the grounded domain is 5 * 5: {(1, 1), ... , (5, 5)}.
; Therefore, `neighbor` and `next_to` need to encoded as verifiers using functions,
; not relations to cover a larger domain. (Similar to the nqueens problem)
;
; ; neighbor(1, 2).
; ; neighbor(2, 3).
; ; neighbor(3, 4).
; ; neighbor(4, 5).
; (defineo (neighbor x y)
;   (conde
;     [(== x 1) (== y 2)]
;     [(== x 2) (== y 3)]
;     [(== x 3) (== y 4)]
;     [(== x 4) (== y 5)]
;   ))

; ; next_to(X, Y) :- neighbor(X, Y).
; ; next_to(X, Y) :- neighbor(Y, X).
; (defineo (next_to x y)
;   (conde
;     [(houses x) (houses y) (neighbor x y)]
;     [(houses x) (houses y) (neighbor y x)]
;   ))

; Each house must has a color, nationality, animal, drink, and cigarette.
; % 1 { color(House, Color) : colors(Color) } 1 :- houses(House).
; % 1 { color(House, Color) : houses(House) } 1 :- colors(Color).

; color(House, Color) :- colors(Color), houses(House), not n_color(House, Color).
; n_color(House, Color) :- colors(Color), houses(House), not color(House, Color).
(defineo (color h c)
  (colors c) (houses h) (noto (n_color h c)))
(defineo (n_color h c)
  (colors c) (houses h) (noto (color h c)))

; :- color(H, C1), color(H, C2), C1 != C2.
; :- color(H1, C), color(H2, C), H1 != H2.
(constrainto [(color h1 c1) (color h2 c2)] [(eq? h1 h2) (not (eq? c1 c2))])
(constrainto [(color h1 c1) (color h2 c2)] [(not (eq? h1 h2)) (eq? c1 c2)])

; assigned_color(H) :- houses(H), colors(C), color(H, C).
(defineo (assigned_color h)
  (fresh (c)
    (houses h) (colors c) (color h c)))
; :- houses(H), not assigned_color(H).
(constrainto [(houses h1) (noto (assigned_color h2))] [(eq? h1 h2)])

; % 1 { nationality(House, Nationality) : nationalities(Nationality) } 1 :- houses(House).
; % 1 { nationality(House, Nationality) : houses(House) } 1 :- nationalities(Nationality).

; nationality(House, Nationality) :- nationalities(Nationality), houses(House), not n_nationality(House, Nationality).
; n_nationality(House, Nationality) :- nationalities(Nationality), houses(House), not nationality(House, Nationality).
(defineo (nationality h c)
  (nationalities c) (houses h) (noto (n_nationality h c)))
(defineo (n_nationality h c)
  (nationalities c) (houses h) (noto (nationality h c)))

; :- nationality(H, N1), nationality(H, N2), N1 != N2.
; :- nationality(H1, N), nationality(H2, N), H1 != H2.
(constrainto [(nationality h1 c1) (nationality h2 c2)] [(eq? h1 h2) (not (eq? c1 c2))])
(constrainto [(nationality h1 c1) (nationality h2 c2)] [(not (eq? h1 h2)) (eq? c1 c2)])

; assigned_nat(H) :- houses(H), nationalities(N), nationality(H, N).
(defineo (assigned_nat h)
  (fresh (c)
    (houses h) (nationalities c) (nationality h c)))
; :- houses(H), not assigned_nat(H).
(constrainto [(houses h1) (noto (assigned_nat h2))] [(eq? h1 h2)])

; % 1 { animal(House, Animal) : animals(Animal) } 1 :- houses(House).
; % 1 { animal(House, Animal) : houses(House) } 1 :- animals(Animal).

; animal(House, Animal) :- animals(Animal), houses(House), not n_animal(House, Animal).
; n_animal(House, Animal) :- animals(Animal), houses(House), not animal(House, Animal).
(defineo (animal h c)
  (animals c) (houses h) (noto (n_animal h c)))
(defineo (n_animal h c)
  (animals c) (houses h) (noto (animal h c)))

; :- animal(H, A1), animal(H, A2), A1 != A2.
; :- animal(H1, A), animal(H2, A), H1 != H2.
(constrainto [(animal h1 c1) (animal h2 c2)] [(eq? h1 h2) (not (eq? c1 c2))])
(constrainto [(animal h1 c1) (animal h2 c2)] [(not (eq? h1 h2)) (eq? c1 c2)])

; assigned_ani(H) :- houses(H), animals(A), animal(H, A).
(defineo (assigned_ani h)
  (fresh (c)
    (houses h) (animals c) (animal h c)))
; :- houses(H), not assigned_ani(H).
(constrainto [(houses h1) (noto (assigned_ani h2))] [(eq? h1 h2)])

; % 1 { drink(House, Drink) : drinks(Drink) } 1 :- houses(House).
; % 1 { drink(House, Drink) : houses(House) } 1 :- drinks(Drink).

; drink(House, Drink) :- drinks(Drink), houses(House), not n_drink(House, Drink).
; n_drink(House, Drink) :- drinks(Drink), houses(House), not drink(House, Drink).
(defineo (drink h c)
  (drinks c) (houses h) (noto (n_drink h c)))
(defineo (n_drink h c)
  (drinks c) (houses h) (noto (drink h c)))

; :- drink(H, D1), drink(H, D2), D1 != D2.
; :- drink(H1, D), drink(H2, D), H1 != H2.
(constrainto [(drink h1 c1) (drink h2 c2)] [(eq? h1 h2) (not (eq? c1 c2))])
(constrainto [(drink h1 c1) (drink h2 c2)] [(not (eq? h1 h2)) (eq? c1 c2)])

; assigned_drink(H) :- houses(H), drinks(D), drink(H, D).
(defineo (assigned_drink h)
  (fresh (c)
    (houses h) (drinks c) (drink h c)))
; :- houses(H), not assigned_drink(H).
(constrainto [(houses h1) (noto (assigned_drink h2))] [(eq? h1 h2)])

; % 1 { smoke(House, Cigarette) : cigarettes(Cigarette) } 1 :- houses(House).
; % 1 { smoke(House, Cigarette) : houses(House) } 1 :- cigarettes(Cigarette).

; smoke(House, Cigarette) :- cigarettes(Cigarette), houses(House), not n_smoke(House, Cigarette).
; n_smoke(House, Cigarette) :- cigarettes(Cigarette), houses(House), not smoke(House, Cigarette).
(defineo (smoke h c)
  (cigarettes c) (houses h) (noto (n_smoke h c)))
(defineo (n_smoke h c)
  (cigarettes c) (houses h) (noto (smoke h c)))

; :- smoke(H, S1), smoke(H, S2), S1 != S2.
; :- smoke(H1, S), smoke(H2, S), H1 != H2.
(constrainto [(smoke h1 c1) (smoke h2 c2)] [(eq? h1 h2) (not (eq? c1 c2))])
(constrainto [(smoke h1 c1) (smoke h2 c2)] [(not (eq? h1 h2)) (eq? c1 c2)])

; assigned_smoke(H) :- houses(H), cigarettes(Cigarette), smoke(H, S).
(defineo (assigned_smoke h)
  (fresh (c)
    (houses h) (cigarettes c) (smoke h c)))
; :- houses(H), not assigned_smoke(H).
(constrainto [(houses h1) (noto (assigned_smoke h2))] [(eq? h1 h2)])

; %   2. The Englishman lives in the red house.
; :- color(H1, red), nationality(H2, english), H1 != H2.
(constrainto [(color h1 'red) (nationality h2 'english)] [(not (eq? h1 h2))])

; %   3. The Spanish owns the dog.
; :- nationality(H1, spaniard), animal(H2,dog), H1 != H2.
(constrainto [(nationality h1 'spaniard) (animal h2 'dog)] [(not (eq? h1 h2))])

; %   4. Coffee is drunk in the green house.
; :- color(H1, green), drink(H2, coffee), H1 != H2.
(constrainto [(color h1 'green) (drink h2 'coffee)] [(not (eq? h1 h2))])

; %   5. The Ukrainian drinks tea.
; :- nationality(H1, ukrainian), drink(H2, tea), H1 != H2.
(constrainto [(nationality h1 'ukrainian) (drink h2 'tea)] [(not (eq? h1 h2))])

; %   6. The green house is immediately to the right of the ivory house.
; :- color(H1, green), color(H2, ivory), not neighbor(H2, H1). % H1 != H2 + 1.
(constrainto [(color h1 'green) (color h2 'ivory)] [(not (= h1 (+ h2 1)))])

; %   7. The Old Gold smoker owns snails.
; :- smoke(H1,old_gold), animal(H2, snails), H1 != H2.
(constrainto [(smoke h1 'old_gold) (animal h2 'snails)] [(not (eq? h1 h2))])

; %   8. Kools are smoked in the yellow house.
; :- smoke(H1, kools), color(H2, yellow), H1 != H2.
(constrainto [(smoke h1 'kools) (color h2 'yellow)] [(not (eq? h1 h2))])

; %   9. Milk is drunk in the middle house.
; :- not drink(3, milk).
(constrainto [(noto (drink 3 'milk))] [])

; %  10. The Norwegian lives in the first house.
; :- not nationality(1,norwegian).
(constrainto [(noto (nationality 1 'norwegian))] [])

; %  11. The man who smokes Chesterfields lives in the house next to the man with the fox.
; :- smoke(H1, chesterfields), animal(H2, fox), not next_to(H1,H2).
(constrainto [(smoke h1 'chesterfields) (animal h2 'fox)] [(not (= 1 (abs (- h1 h2))))])

; %  12. Kools are smoked in the house next to the house where the horse 
; %      is kept. (should be ".. a house ...", see Discussion section)
; :- smoke(H1, kools), animal(H2, horse), not next_to(H1,H2).
(constrainto [(smoke h1 'kools) (animal h2 'horse)] [(not (= 1 (abs (- h1 h2))))])

; %  13. The Lucky Strike smoker drinks orange juice.
; :- smoke(H1, lucky_strike), drink(H2, orange_juice), H1 != H2.
(constrainto [(smoke h1 'lucky_strike) (drink h2 'orange_juice)] [(not (eq? h1 h2))])

; %  14. The Japanese smokes Parliaments.
; :- nationality(H1, japanese), smoke(H2, parliaments), H1 != H2.
(constrainto [(nationality h1 'japanese) (smoke h2 'parliaments)] [(not (eq? h1 h2))])

; %  15. The Norwegian lives next to the blue house.
; :- nationality(H1, norwegian), color(H2, blue), not next_to(H1, H2).
(constrainto [(nationality h1 'norwegian) (color h2 'blue)] [(not (= 1 (abs (- h1 h2))))])

; has_zebra(Nationality) :- nationality(House, Nationality), animal(House, zebra).
(defineo (has_zebra n)
  (fresh (h)
    (nationality h n)
    (animal h 'zebra)))
; drinks_water(Nationality) :- nationality(House, Nationality), drink(House,water).
(defineo (drinks_water n)
  (fresh (h)
    (nationality h n)
    (drink h 'water)))

; house(House, Color, Nationality, Animal, Drink, Cigarette) :-
;     houses(House),
;     color(House, Color),
;     nationality(House, Nationality),
;     animal(House, Animal),
;     drink(House, Drink),
;     smoke(House, Cigarette).
(defineo (house h c n a d ci)
  (houses h) (color h c) (nationality h n) (animal h a) (drink h d) (smoke h ci))

; (house 1 'yellow 'norwegian 'fox 'water 'kools)
; (house 2 'blue 'ukrainian 'horse 'tea 'chesterfields)
; (house 3 'red 'english 'snails 'milk 'old_gold)
; (house 4 'ivory' 'spaniard 'dog 'orange_juice 'lucky_strike)
; (house 5 'green 'japanese 'zebra 'coffee 'parliaments)
