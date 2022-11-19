% goal/1 denotes the desired state/4 which I want to be in after successfully moving out from my old house with all my pets. Whereas, state/4 allows me to know which pets are in which house at a given time.
goal(state(newhome, newhome, newhome, newhome)).

% change/2 denotes the allowed change in position for all involved parties, i.e., move from the old house to the new one, and vice versa.
change(newhome, oldhome).
change(oldhome, newhome).

% move/2 modifies the current state me and my pets are in. Thus, if a move is made me and/or one of my pets will change positions between houses.
% Possible moves:
% a) Me and me alone move between houses.
move(state(X, Dog, Kitty, Rat), state(Y, Dog, Kitty, Rat)) :- change(X, Y).
% b) My dog and me.
move(state(X, X, Kitty, Rat), state(Y, Y, Kitty, Rat)) :- change(X, Y).
% c) My cat and me.
move(state(X, Dog, X, Rat), state(Y, Dog, Y, Rat)) :- change(X, Y).
% d) My little rat and me.
move(state(X, Dog, Kitty, X), state(Y, Dog, Kitty, Y)) :- change(X, Y).

% illegal/1 declares which moves shall not be made in order to avoid leaving alone those pets that cannot be so.
% a) My dog and my cat.
illegal(state(X, Y, Y, _)) :- change(X, Y).
% b) My cat and my little rat.
illegal(state(X, _, Y, Y)) :- change(X, Y).

% Solution
solution([Loc1|Locations], [Loc1|Locations]) :- goal(Loc1).
solution([Loc1|Locations], LS) :- move(Loc1, Loc2), 
    not(illegal(Loc2)), 
    not(member(Loc2, Locations)), 
    solution([Loc2,Loc1|Locations], LS).

print_states([]) :- 
    write('End'), nl,
    write('---').
print_states([State|States]) :- 
    write(State), nl, 
    print_states(States).

% print_states(States) :- 
%     print_states_aux(States, 0).
% print_states_aux([], _) :- 
%     write('End'), nl,
%     write('---').
% print_states_aux(States, Iter) :-
%     reverse(States, [St|Sts]),
%     Iter1 is Iter + 1,
%     write(Iter1), write(' >>> '), write(St), nl, 
%     print_states_aux(Sts, Iter1).