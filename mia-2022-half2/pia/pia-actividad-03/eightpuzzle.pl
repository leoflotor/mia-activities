s([Vacio|Fichas], [Ficha|Fichas1], 1) :-
    swap(Vacio, Ficha, Fichas, Fichas1).

swap(Vacio, Ficha, [Ficha|Ts], [Vacio|Ts]) :-
    mandist(Vacio, Ficha, 1).
swap(Vacio, Ficha, [T1|Ts], [T1|Ts1]) :-
    swap(Vacio, Ficha, Ts, Ts1).

mandist(X/Y, X1/Y1, D) :-
    dif(X, X1, Dx),
    dif(Y, Y1, Dy),
    D is Dx + Dy.

dif(A, B, D) :-
    % D is A - B,
    % D >= 0, !
    % ;
    % D is B - A.
    D is abs(A - B).

h([Vacio|Fichas], H) :-
    goal([Vacio1|GoalSquares]),
    totdist(Fichas, GoalSquares, D),
    seq(Fichas, S),
    H is D + 3*S.

totdist([], [], 0).
totdist([Ficha|Fichas], [Square|Squares], D) :-
    mandist(Ficha, Square, D1),
    totdist(Fichas, Squares, D2),
    D is D1 + D2.

seq([First|OtherFichas], S) :-
    seq([First|OtherFichas], First, S).
seq([Ficha1,Ficha2|Fichas], First, S) :-
    score(Ficha1, Ficha2, S1),
    seq([Ficha2|Fichas], First, S2),
    S is S1 + S2.
seq([Last], First, S) :-
    score(Last, First, S).

score(2/2, _, 1) :- !.
score(1/3, 2/3, 0) :- !.
score(2/3, 3/3, 0) :- !.
score(3/3, 3/2, 0) :- !.
score(3/2, 3/1, 0) :- !.
score(3/1, 2/1, 0) :- !.
score(2/1, 1/1, 0) :- !.
score(1/1, 1/2, 0) :- !.
score(1/2, 1/3, 0) :- !.
score(_, _, 2).

goal([2/2, 1/3, 2/3, 3/3, 3/2, 3/1, 2/1, 1/1, 1/2]).

showsol([]).
showsol([P|L]) :-
    showsol(L), nl,
    write('---'),
    showpos(P).

showpos([S0, S1, S2, S3, S4, S5, S6, S7, S8]) :-
    member(Y, [3,2,1]), nl,
    member(X, [1,2,3]),
    member(Ficha-X/Y, 
        [''-S0, 1-S1, 2-S2, 3-S3, 4-S4, 5-S5, 6-S6, 7-S7, 8-S8]),
    write(Ficha),
    fail
    ;
    true.

start1([2/2, 1/3, 3/2, 2/3, 3/3, 3/1, 2/1, 1/1, 1/2]).