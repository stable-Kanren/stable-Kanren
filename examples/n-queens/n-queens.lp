% Example taken from s(ASP)/s(CASP) paper
% (https://www.cs.nmsu.edu/ALP/wp-content/uploads/2017/04/marple_etal2017.pdf)
% (https://github.com/JanWielemaker/sCASP/blob/swipl/examples/queens.pl)
% solve the N queens problem for a given N, returning a list of queens as Q.
%
% Program slightly modified, so it can run using Prolog, as the "not" operator
% here is stratified negation. No stable model semantics is needed.
% The changes are removed the prefix "_" of predicate names, removed useless
% q(X, Y) :- not _negq(X, Y).
% _negq(X, Y) :- not q(X, Y).
% And changed the s(ASP)/s(CASP) "not" to Prolog "not()".
nqueens(N, Q) :-
    nqueens(N, N, [], Q).

% Pick queens one at a time and test against all previous queens.
nqueens(X, N, Qi, Qo) :-
    X > 0,
    pickqueen(X, Y, N),
    not(attack(X, Y, Qi)),
    X1 is X - 1,
    nqueens(X1, N, [q(X, Y) | Qi], Qo).
nqueens(0, _, Q, Q).


% Pick a queen for row X.
pickqueen(X, Y, Y) :-
    Y > 0. 
    % q(X, Y).
pickqueen(X, Y, N) :-
    N > 1,
    N1 is N - 1,
    pickqueen(X, Y, N1).

% Check if a queen can attack any previously selected queen.
attack(X, _, [q(X, _) | _]). % Same row
attack(_, Y, [q(_, Y) | _]). % Same col
attack(X, Y, [q(X2, Y2) | _]) :- % Same diagonal
    Xd is X2 - X,
    abs(Xd, Xd2),
    Yd is Y2 - Y,
    abs(Yd, Yd2),
    Xd2 = Yd2.
attack(X, Y, [_ | T]) :-
    attack(X, Y, T).

% q(X, Y) :- not _negq(X, Y).
% _negq(X, Y) :- not q(X, Y).

abs(X, X) :- X >= 0.
abs(X, Y) :- X < 0, Y is X * -1.
