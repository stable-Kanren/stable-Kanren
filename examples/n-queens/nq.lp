% Problem instances.
% A graph with vertices and edges G = <V, E>.
% Only representing vertices here, the edges are capctured implicitly.
% (https://github.com/potassco/clingo/blob/master/examples/gringo/queens/queens2.lp)
% clingo -c n=8 nq.lp 0
num(1).
num(X+1) :- num(X), X < n.

% Algorithms.
queen(X,Y) :- not free(X,Y), num(X), num(Y).
free(X,Y) :- not queen(X,Y), num(X), num(Y).

% Bottom-up, lower bound, ensure each row&col has a queen.
row(X) :- queen(X,Y).
col(Y) :- queen(X,Y).

% Converted constraint rules.
% Naturally, we can write headless constraint rules in ASP.
:- num(X), not row(X).
:- num(Y), not col(Y).
% fail :- num(X), not row(X), not fail.
% fail :- num(Y), not col(Y), not fail.

:- queen(X,Y), queen(X,V), Y < V.
:- queen(X,Y), queen(U,Y), X < U.
% fail :- queen(X,Y), queen(X,V), Y < V, not fail.
% fail :- queen(X,Y), queen(U,Y), X < U, not fail.

:- queen(X,Y), queen(U,V), X-Y == U-V, f(X,Y) < f(U,V).
:- queen(X,Y), queen(U,V), X+Y == U+V, f(X,Y) < f(U,V).
% fail :- queen(X,Y), queen(U,V), X-Y == U-V, f(X,Y) < f(U,V), not fail.
% fail :- queen(X,Y), queen(U,V), X+Y == U+V, f(X,Y) < f(U,V), not fail.

#show queen/2.
