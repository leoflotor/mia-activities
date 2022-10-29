%%% Autor: Leonardo Flores Torres
%%% Curso: Programacion para la Inteligencia Artificial
%%% Profesor: Alejandro Guerra Hernández
%%% Implementación del algoritmo de unificación

% Caso inicial: comienza el proceso de unificación comparando la cabeza de las metas, sus subtérminos y su aridad.
unify(T1, T2) :-
    compound(T1), 
    compound(T2),
    T1=..[F|Args1],
    T2=..[F|Args2],
    length(Args1, Len), 
    length(Args2, Len),
    maplist(unify, Args1, Args2).

% Caso: T1 es una variable y T2 un termino compuesto, se hace chequeo de ocurrencias para verificar que T1 no sea un subtermino en T2.
unify(T1, T2) :-
    var(T1),
    compound(T2),
    unify_with_occurs_check(T1, T2).

% Caso: T1 es un atomo y T2 es una variable
unify(T1, T2) :-
    atomic(T1),
    var(T2),
    T2 = T1.

% Caso: T1 es una variable y T2 es un atomo
unify(T1, T2) :-
    var(T1),
    atomic(T2),
    T1 = T2.

% Caso: T1 es una variable y T2 tambien pero son diferentes
unify(T1, T2) :-
    var(T1),
    var(T2),
    T1 = T2.

% Caso: T1 y T2 son el mismo y ademas son variables
unify(T, T) :- var(T).

