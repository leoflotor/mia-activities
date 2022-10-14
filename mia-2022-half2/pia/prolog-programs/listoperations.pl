% conc(L1, L2, L3): La lista L3 es el resultado
% de agregar L1 a L2.
conc([], Ys, Ys).
conc([X|Xs], Ys, [X|Zs]) :-
    conc(Xs, Ys, Zs).

% del(X,L,R): R es la lista que resulta de eliminar
% la primera ocurrencia de X en L.
del(X, [X|Cola], Cola).
del(X, [Y|Cola], [Y|Cola1]) :-
    del(X, Cola, Cola1).

delall(_, [], []).
delall(X, [X|Cola], Cola1) :-
    delall(X, Cola, Cola1).

% -- false
% delall(X, [Y|Cola], Cola1) :-
%     dif(X, Y),
%     delall(X, Cola, [Cola1|Y]).

% -- Promising, reversed behaviour
% delall(X, [Y|Cola], [Cola1|Y]) :-
%     dif(X, Y),
%     delall(X, Cola, Cola1).

% -- false
% delall(X, [Y|Cola], Cola1) :-
%     dif(X, Y),
%     delall(X, Cola, [Cola1|Y]).

delall(X, [Y|Cola], [Y|Cola1]) :-
    dif(X, Y),
    delall(X, Cola, Cola1).