% https://en.wikipedia.org/wiki/Zebra_Puzzle
% Problem instances
colors(red;green;ivory;yellow;blue).
nationalities(english;spaniard;ukrainian;norwegian;japanese).
animals(dog;fox;horse;zebra;snails).
drinks(coffee;tea;milk;orange_juice;water).
cigarettes(old_gold;kools;chesterfields;lucky_strike;parliaments).
houses(1..5).


% 1 { color(House, Color) : colors(Color) } 1 :- houses(House).
% 1 { color(House, Color) : houses(House) } 1 :- colors(Color).
color(House, Color) :- colors(Color), houses(House), not n_color(House, Color).
n_color(House, Color) :- colors(Color), houses(House), not color(House, Color).
:- color(H, C1), color(H, C2), C1 != C2.
:- color(H1, C), color(H2, C), H1 != H2.
assigned_color(H) :- houses(H), colors(C), color(H, C).
:- houses(H), not assigned_color(H).


% 1 { nationality(House, Nationality) : nationalities(Nationality) } 1 :- houses(House).
% 1 { nationality(House, Nationality) : houses(House) } 1 :- nationalities(Nationality).
nationality(House, Nationality) :- nationalities(Nationality), houses(House), not n_nationality(House, Nationality).
n_nationality(House, Nationality) :- nationalities(Nationality), houses(House), not nationality(House, Nationality).
:- nationality(H, N1), nationality(H, N2), N1 != N2.
:- nationality(H1, N), nationality(H2, N), H1 != H2.
assigned_nat(H) :- houses(H), nationalities(N), nationality(H, N).
:- houses(H), not assigned_nat(H).


% 1 { animal(House, Animal) : animals(Animal) } 1 :- houses(House).
% 1 { animal(House, Animal) : houses(House) } 1 :- animals(Animal).
animal(House, Animal) :- animals(Animal), houses(House), not n_animal(House, Animal).
n_animal(House, Animal) :- animals(Animal), houses(House), not animal(House, Animal).
:- animal(H, A1), animal(H, A2), A1 != A2.
:- animal(H1, A), animal(H2, A), H1 != H2.
assigned_ani(H) :- houses(H), animals(A), animal(H, A).
:- houses(H), not assigned_ani(H).


% 1 { drink(House, Drink) : drinks(Drink) } 1 :- houses(House).
% 1 { drink(House, Drink) : houses(House) } 1 :- drinks(Drink).
drink(House, Drink) :- drinks(Drink), houses(House), not n_drink(House, Drink).
n_drink(House, Drink) :- drinks(Drink), houses(House), not drink(House, Drink).
:- drink(H, D1), drink(H, D2), D1 != D2.
:- drink(H1, D), drink(H2, D), H1 != H2.
assigned_drink(H) :- houses(H), drinks(D), drink(H, D).
:- houses(H), not assigned_drink(H).


% 1 { smoke(House, Cigarette) : cigarettes(Cigarette) } 1 :- houses(House).
% 1 { smoke(House, Cigarette) : houses(House) } 1 :- cigarettes(Cigarette).
smoke(House, Cigarette) :- cigarettes(Cigarette), houses(House), not n_smoke(House, Cigarette).
n_smoke(House, Cigarette) :- cigarettes(Cigarette), houses(House), not smoke(House, Cigarette).
:- smoke(H, S1), smoke(H, S2), S1 != S2.
:- smoke(H1, S), smoke(H2, S), H1 != H2.
assigned_smoke(H) :- houses(H), cigarettes(Cigarette), smoke(H, S).
:- houses(H), not assigned_smoke(H).

neighbor(1, 2).
neighbor(2, 3).
neighbor(3, 4).
neighbor(4, 5).

next_to(X, Y) :- neighbor(X, Y).
next_to(X, Y) :- neighbor(Y, X).


%   2. The Englishman lives in the red house.
:- color(H1, red), nationality(H2, english), H1 != H2.

%   3. The Spaniard owns the dog.
:- nationality(H1, spaniard), animal(H2,dog), H1 != H2.

%   4. Coffee is drunk in the green house.
:- color(H1, green), drink(H2, coffee), H1 != H2.

%   5. The Ukrainian drinks tea.
:- nationality(H1, ukrainian), drink(H2, tea), H1 != H2.

%   6. The green house is immediately to the right of the ivory house.
:- color(H1, green), color(H2, ivory), not neighbor(H1, H2). % H1 != H2 + 1.

%   7. The Old Gold smoker owns snails.
:- smoke(H1,old_gold), animal(H2, snails), H1 != H2.

%   8. Kools are smoked in the yellow house.
:- smoke(H1, kools), color(H2, yellow), H1 != H2.

%   9. Milk is drunk in the middle house.
:- not drink(3, milk).

%  10. The Norwegian lives in the first house.
:- not nationality(1,norwegian).

%  11. The man who smokes Chesterfields lives in the house next to the man with the fox.
:- smoke(H1, chesterfields), animal(H2, fox), not next_to(H1, H2).

%  12. Kools are smoked in the house next to the house where the horse 
%      is kept. (should be ".. a house ...", see Discussion section)
:- smoke(H1, kools), animal(H2, horse), not next_to(H1, H2).

%  13. The Lucky Strike smoker drinks orange juice.
:- smoke(H1, lucky_strike), drink(H2, orange_juice), H1 != H2.

%  14. The Japanese smokes Parliaments.
:- nationality(H1, japanese), smoke(H2, parliaments), H1 != H2.

%  15. The Norwegian lives next to the blue house.
:- nationality(H1, norwegian), color(H2, blue), not next_to(H1, H2).

has_zebra(Nationality) :- nationality(House, Nationality), animal(House, zebra). 
drinks_water(Nationality) :- nationality(House, Nationality), drink(House,water).

% Output:
house(House, Color, Nationality, Animal, Drink, Cigarette) :-
    houses(House),
    color(House, Color),
    nationality(House, Nationality),
    animal(House, Animal),
    drink(House, Drink),
    smoke(House, Cigarette).

% #show house/6.
#show has_zebra/1.
#show drinks_water/1.