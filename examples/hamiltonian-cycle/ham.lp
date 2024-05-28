% vertex(0).
% vertex(1).
% vertex(2).
% vertex(3).
% vertex(4).

% edge(0, 1).
% edge(1, 2).
% edge(2, 3).
% edge(3, 4).
% edge(4, 0).
% edge(4, 1).
% edge(4, 2).
% edge(4, 3).

vertex(1..6).

% (Directed) Edges
edge(1,(2;3;4)).  edge(2,(4;5;6)).  edge(3,(1;4;5)).
edge(4,(1;2)).    edge(5,(3;4;6)).  edge(6,(2;3;5)).


reachable(V) :- chosen(U, V), reachable(U).
reachable(V) :- chosen(1, V).

:- vertex(U), not reachable(U).

% { chosen(X,Y) : edge(X,Y) } 1 :- vertex(X).
% { chosen(X,Y) : edge(X,Y) } 1 :- vertex(Y).

chosen(U, V) :- vertex(U), edge(U, V), not free(U, V).
free(U, V) :- vertex(U), edge(U, V), not chosen(U, V).


:- chosen(U, V), chosen(X, Y), X = U, V != Y.
:- chosen(U, V), chosen(X, Y), X != U, V = Y.

#show chosen/2.