% Caso base:
% Para cualquier valor que se quiera eliminar de una lista, si la lista 
% está vacía entonces la lista de retorno también estará vacía.
delall(_, [], []).

% Caso 1:
% Cuando la cabeza de la lista es igual al elemento que se quiere eliminar.
% Se quita el elemento de la lista, y se pasa al siguiente.
delall(X, [X|Tail1], Tail2) :-
    delall(X, Tail1, Tail2).

% Caso 2:
% Cuando la cabeza de la lista no es igual al elemento que se quiere 
% eliminar. Se quita la cabeza aunque no sea igual, pero se pasa a una lista
% que guarda los valores diferentes al elemento que se quiere remover.
% delall(X, [Y|Tail1], Tail2) :-
%     delall(X, Tail1, [Y|Tail2]).
delall(X, [Y|Tail1], [Y|Tail2]) :-
    delall(X, Tail1, Tail2).

% Vamos a filtar (filter in) los elementos pares de una lista.
% Tiene el mismo patrón que para la funcion delall/3.
even(X) :- 0 is X mod 2.
odd(X) :- 1 is X mod 2.

evens([], []).
evens([X|Tail1], [X|Tail2]) :-
    even(X),
    evens(Tail1, Tail2).
evens([X|Tail1], Tail2) :-
    odd(X),
    evens(Tail1, Tail2).

evens2([], []).
evens2([X|Tail1], [X|Tail2]) :-
    even(X),
    evens2(Tail1, Tail2).
evens2([_|Tail1], Tail2) :-
    evens(Tail1, Tail2).


% RELACIONES Y PROPIEDADES ENTRE LOS OBJETOS DEL UNIVERSO DE DISCURSO!