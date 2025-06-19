% 5*5 chessboard
% Models       : 1728
% Calls        : 1
% Time         : 52.853s (Solving: 52.83s 1st Model: 0.66s Unsat: 26.70s)
% CPU Time     : 52.828s

steps(1..25).
nums(1..5).

pick(S, X, Y) :- nums(X), nums(Y), steps(S), not free(S, X, Y).
free(S, X, Y) :- nums(X), nums(Y), steps(S), not pick(S, X, Y).

% Each step only pick one (x, y).
:- pick(S, X1, Y1), pick(S, X2, Y2), X1 != X2, Y1 != Y2.

% The same (x, y) cannot be visited more than once.
:- pick(S1, X, Y), pick(S2, X, Y), S1 != S2.

% Each step must pick one (x, y).
assigned(S) :- pick(S, X, Y).
:- steps(S), not assigned(S).

directions(X1, Y1, X2, Y2) :- nums(X1), nums(Y1), nums(X2), nums(Y2), X2 = X1 + 2, Y2 = Y1 + 1.
directions(X1, Y1, X2, Y2) :- nums(X1), nums(Y1), nums(X2), nums(Y2), X2 = X1 + 1, Y2 = Y1 + 2.
directions(X1, Y1, X2, Y2) :- nums(X1), nums(Y1), nums(X2), nums(Y2), X2 = X1 - 1, Y2 = Y1 + 2.
directions(X1, Y1, X2, Y2) :- nums(X1), nums(Y1), nums(X2), nums(Y2), X2 = X1 - 2, Y2 = Y1 + 1.
directions(X1, Y1, X2, Y2) :- nums(X1), nums(Y1), nums(X2), nums(Y2), X2 = X1 - 2, Y2 = Y1 - 1.
directions(X1, Y1, X2, Y2) :- nums(X1), nums(Y1), nums(X2), nums(Y2), X2 = X1 - 1, Y2 = Y1 - 2.
directions(X1, Y1, X2, Y2) :- nums(X1), nums(Y1), nums(X2), nums(Y2), X2 = X1 + 1, Y2 = Y1 - 2.
directions(X1, Y1, X2, Y2) :- nums(X1), nums(Y1), nums(X2), nums(Y2), X2 = X1 + 2, Y2 = Y1 - 1.

% Knight tour constraint: next step not in the 8 directions of the previous step.
:- pick(S1, X1, Y1), pick(S2, X2, Y2), S2 = S1 + 1, not directions(X1, Y1, X2, Y2).

% pick(1, 1, 1).

#show pick/3.