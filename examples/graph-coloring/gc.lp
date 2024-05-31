% Problem instances.
% A graph with vertices and edges G = <V, E>.
% Small graph 3 nodes, big graph 6 nodes.
node(1..3).
% node(1..6).

edge(1, 2).
edge(1, 3).
edge(2, 3).
% edge(2, 4).
% edge(3, 4).
% edge(3, 5).
% edge(3, 6).
% edge(4, 5).
% edge(5, 6).

% Color options.
color(r).
color(g).
color(b).

% Neighbors.
neighbors(X, Y) :- edge(X, Y).
neighbors(X, Y) :- edge(Y, X).


% Algorithms.
% No choice rule support under stableKanren for now, so we convert it manually.
% clingo converts everything to normal program clauses (the foundation of stableKanren).
%
% 1{assign(N, C): color(C)}1 :- node(N).
assign(N, C) :- node(N), color(C), not free(N, C).
free(N, C) :- node(N), color(C), not assign(N, C).

% Upper bound (1) in the choice rule righ hand side.
:- assign(N, C1), assign(N, C2), C1 != C2.
% Lower bound (1) in the choice rule left hand side.
:- not assign(N, r), not assign(N, g), not assign(N, b), node(N).

% Two neighbors can not take the same color.
:- neighbors(N, M), assign(N, C), assign(M, C).

#show assign/2.
