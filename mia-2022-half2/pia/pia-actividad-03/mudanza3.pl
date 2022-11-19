select(X, [X|Xs], Xs).
select(X, [Y|Ys], [Y|Zs]) :- 
    select(X, Ys, Zs).

initial_state(wgc, wgc(left, [wolf, goat, cabbage], [])).
final_state(wgc(right, [], [wolf, goat, cabbage])).

move(wgc(left, L, R), Cargo) :- member(Cargo, L).
move(wgc(right, L, R), Cargo) :- member(Cargo, R).
move(wgc(B, L, R), alone).

update(wgc(B, L, R), Cargo, wgc(B1, L1, R1)) :-
    update_boat(B, B1), 
    update_banks(Cargo, B, L, R, L1, R1).

update_boat(left, right).
update_boat(right, left).

update_banks(alone, B, L, R, L, R).
update_banks(Cargo, left, L, R, L1, R1) :-
    select(Cargo, L, L1), insert(Cargo, R, R1).
update_banks(Cargo, right, L, R, L1, R1) :-
    select(Cargo, R, R1), insert(Cargo, L, L1).

insert(X, [Y|Ys], [X,Y|Ys]) :- 
    precedes(X, Y).
insert(X, [Y|Ys], [Y|Zs]) :- 
    precedes(Y, X),
    insert(X, Ys, Zs).
insert(X, [], [X]).

precedes(wolf, X).
precedes(X, cabbage).

legal(wgc(left, L, R)) :- not(illegal(R)).
legal(wgc(right, L, R)) :- not(illegal(L)).

illegal(Bank) :- 
    member(wolf, Bank), 
    menber(goat, Bank).
illegal(Bank) :- 
    member(goat, Bank), 
    member(cabbage, Bank).
