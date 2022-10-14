
% Todo numero es menor que su sucesor
less(X, s(X)).

% Funcion que computa verdadero o falso 
% si hay algun numero que sea mayor que su sucesor.
foo :- less(s(Y), Y).