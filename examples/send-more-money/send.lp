letter(s;e;n;d;m;o;r;y).
values(0..9).

% exact 1 occurrence of each letter
% 1 { assign(L,Val) : values(Val) } 1 :- letter(L).
assign(L, V) :- letter(L), values(V), not n_assign(L, V).
n_assign(L, V) :- letter(L), values(V), not assign(L, V).
:- assign(L, V1), assign(L, V2), V1 != V2.

assigned(L) :- letter(L), values(V), assign(L, V).
:- letter(L), not assigned(L).

% no digit can be given to two different symbols
:- letter(L), letter(L1), assign(L, V1), assign(L1, V1), L != L1.

:- assign(s, S), assign(e, E), assign(n, N), assign(d, D), assign(m, M), assign(o, O), assign(r, R), assign(y, Y), S*1000+E*100+N*10+D + M*1000+O*100+R*10+E != M*10000+O*1000+N*100+E*10+Y.

summ :- assign(s, S), assign(e, E), assign(n, N), assign(d, D), assign(m, M), assign(o, O), assign(r, R), assign(y, Y), S*1000+E*100+N*10+D + M*1000+O*100+R*10+E = M*10000+O*1000+N*100+E*10+Y.
:- not summ.

% no leading zeros
:- assign(m, M), M = 0.
:- assign(s, S), S = 0.

#show assign/2.
