% [human, dog, kitty, rat]
goal([newhome, newhome, newhome, newhome]).

change(newhome, oldhome).
change(oldhome, newhome).

move([X, X, Kitty, Rat], [Y, Y, Kitty, Rat]) :- change(X, Y).
move([X, Dog, X, Rat], [Y, Dog, Y, Rat]) :- change(X, Y).
move([X, Dog, Kitty, X], [Y, Dog, Kitty, Y]) :- change(X, Y).
move([X, Dog, Kitty, Rat], [Y, Dog, Kitty, Rat]) :- change(X, Y).

dontmove([X, Y, Y, _]) :- change(X, Y).
dontmove([X, _, Y, Y]) :- change(X, Y).

solution([E|L], [E|L]) :- goal(E).
solution([E|L], LS):-
    move(E, EP),
    not(dontmove(EP)),
    not(member(EP,L)),
    solution([EP, E | L], LS).

print_states([]) :- 
    write('End'), nl.
print_states([State|States]) :- 
    write(State), nl, 
    print_states(States).