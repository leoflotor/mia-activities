% Caso base
mist(0, []).
% Caso recursivo
mist(N, [N|Ns]) :-
    N1 is N-1,
    mist(N1, Ns).


% delt(_, [], []).
% delt(X, [X|Cola], Cola1) :-
%     del(X, Cola, Cola1).
% delt(X, [Y|Cola], [Y|Cola1]) :-
%     X \== Y,
%     delt(X, Cola, Cola1).