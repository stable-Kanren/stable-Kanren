% Problem instances.
% A graph with vertices and edges G = <V, E>.
% Small graph 3 nodes, big graph 6 nodes.
node(1).
node(2).
node(3).
% node(4).
% node(5).
% node(6).

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
% Pick a color one at a time and test against all previous colorings.
colorize(N, In, Out) :-
    N = 0, In = Out.
colorize(N, In, Out) :-
    N > 0, color(C), not(violate(C, N, In)),
    N1 is N - 1, colorize(N1, [(N, C) | In], Out).

% Check if the two neighbors get the same color for all previous colorings.
violate(C, N, Ans) :-
    [H|T] = Ans,
    violate(C, N, T).
violate(C, N, Ans) :-
    [(N1, C1) | T] = Ans,
    neighbors(N, N1),
    C = C1.

% ?- colorize(3, [], Out).
