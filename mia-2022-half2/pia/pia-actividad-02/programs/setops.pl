%%% Set operations (using lists to represent sets).
%%% It is assumed that the usr took care to represent them as sets with unique elements.


%%% union1/3 computes the union operation between two lists and returns
%%% the same elements as union/3 predefined in prolog
% ?- union1([1,2,3,4], [2,3,4,5], L).
% L = [5, 1, 2, 3, 4] .
union1(X, Y, Z) :-
    union1aid(X, Y, Z1), !,
    sort(Z1, Z).
union1aid(X, [], X).
union1aid(X, [Y|Ys], [Y|Xs]) :-
    not(member(Y, X)),
    union1aid(X, Ys, Xs).
union1aid(X, [Y|Ys], Xs) :-
    member(Y, X),
    union1aid(X, Ys, Xs).


%%% union2/3 makes use of union/3 already predefined inside prolog
% ?- union2([1,2,3,4], [2,3,4,5], L).
% L = [1, 2, 3, 4, 5].
union2(X, Y, Z) :-
    union(X, Y, Z).


%%% intersection1/3
% ?- intersection1([1,2,3], [2,3,4], L).
% L = [2, 3].
intersection1(X, Y, Z) :-
    intersection1aid(X, Y, Z), !.
% base case
intersection1aid(_, [], []).
% case when Y is a member of Y
intersection1aid(X, [Y|Ys], [Y|Zs]) :-
    member(Y, X),
    intersection1aid(X, Ys, Zs).
% case when Y is not a member of X
intersection1aid(X, [_|Ys], Zs) :-
    intersection1aid(X, Ys, Zs).

%%% intersection2/3 makes use of intersection/3 alaready predefined inside prolog
% ?- intersection2([1,2,3], [2,3,4], L).
% L = [2, 3].
intersection2(X, Y, Z) :-
    intersection(X, Y, Z).


%%% subset/2
subset1([], _).
subset1([X|Xs], Y) :-
    member(X, Y), !,
    subset1(Xs, Y).

subset2(X, Y) :-
    subset(X, Y).


%%% difference/3
difference1(X, Y, Z) :- 
    difference1aid(X, Y, Z), !.
difference1aid([], _, []).
difference1aid([X|Xs], Y, Z) :-
    member(X, Y),
    difference1aid(Xs, Y, Z).
difference1aid([X|Xs], Y, [X|Zs]) :-
    difference1(Xs, Y, Zs).


% USEFUL LINKS
% https://stackoverflow.com/questions/46899153/making-a-union-of-two-lists-in-prolog
% https://stackoverflow.com/questions/9615002/intersection-and-union-of-2-lists
