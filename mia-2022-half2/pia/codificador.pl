% eye(X, N, L) :- 
%     eye(X, N, 1, L).
% eye(X, N, Counter, Ys) :-
%     Counter1 =< N,
%     Counter1 is 1 + Counter,
%     eye(X, N, Counter1, [X|Ys]).

eye(_, 0, []).
eye(X, N, [X|Xs]) :-
    N > 0,
    N1 is N - 1,
    eye(X, N1, Xs).

% coprime/2 
% ?- coprime([1,1,1,1,0,0,0,1,1], L).
% L = [cod(1, 4), cod(0, 3), cod(1, 2)] .

comprime([], []).
comprime([X|Xs], L) :-
    comp(Xs, X, 1, L).

comp([], X, N, [cod(X,N)]).
comp([X|Xs], X, N, Ys) :-
    N1 is N + 1,
    comp(Xs, X, N1, Ys).
comp([X|Xs], Y, N, [cod(Y,N)|Ys]) :-
    comp(Xs, X, 1, Ys).

% descomprime([], []).
% descomprime([X|Xs], L) :-
%     X=..[_, El, N],
%     % decomp(Xs, X=..[_,El,N], L).
%     decomp(Xs, El, N, L).

% decomp([X|Xs], El, N, Ys) :-
%     eye(El, N, Ys),
%     decomp(Xs, El, N, Ys).


% decomp(X, El, N) :-
%     X =..[_, El, N].

% descomprime([], []).
% descomprime([X|Xs], [eye(El, N, Y)|Ys]) :-
%     X =..[_, El, N],
%     descomprime(Xs, Ys).

% descomprime([], []).
% descomprime([X|Xs], L) :-
%     X=..[_,El,N],
%     descomprime(Xs, [eye(El,N,Y)|Ys]).