%%% Sucesor, heurística y meta son predicados dinámicos.

:- dynamic
       s/3,
       h/2,
       meta/1.

% primeroMejor(Inicio, Sol): Sol es un camino de Inicio a la meta
% Asumimos 9999 > que todo f-valor

primeroMejor(Inicio, Sol) :-
  expandir([], l(Inicio,0/0),  9999, _, si, Sol).

% expandir(Camino, Arbol, Umbral, Arbol1, Resuelto, Sol):
%   Camino entre Inicio y Arbol,
%   Arbol1 es Arbol expandido bajo la Umbral,
%   Si meta es encontrada Sol es la solución y  Resuelto = si

%  Caso 1: nodo hoja meta, construir camino solución

expandir(Camino, l(Nodo, _), _, _, si, [Nodo|Camino]) :-
   meta(Nodo).

% Caso 2: nodo hoja, f-valor < Umbral
% Generar sucesores y expandir bajo la Umbral.

expandir(Camino, l(Nodo,F/G), Umbral, Arbol1, Resuelto, Sol)  :-
  F =< Umbral,
  ( bagof( Nodo2/C, (s(Nodo,Nodo2,C), \+ member(Nodo2,Camino) ), Succ), 
    !,                                    % N tiene sucesores
    listaSucs(G, Succ, As),               % Construir subárboles As
    mejorF(As, F1),                       % f-valor del mejor sucesor
    expandir(Camino, t(Nodo,F1/G,As), Umbral, Arbol1, Resuelto, Sol)
  ;
    Resuelto = nunca                      % N sin sucesores
  ).

%  Caso 3: no hoja, f-valor < Umbral
%  Expandir el subárbol más promisorio; dependiendo de 
%  resultados, continuar decidirá como proceder.

expandir(Camino, t(Nodo,F/G,[A|As]), Umbral, Arbol1, Resuelto, Sol)  :-
  F =< Umbral,
  mejorF(As, MejorF), min(Umbral, MejorF, Umbral1),          % Umbral1 = min(Umbral,MejorF)
  expandir([Nodo|Camino], A, Umbral1, A1, Resuelto1, Sol),
  continuar(Camino, t(Nodo,F/G,[A1|As]), Umbral, Arbol1, Resuelto1, Resuelto, Sol).

%  Caso 4: no hoja con subárboles vacío
%  Fallo

expandir( _, t(_,_,[]), _, _, nunca, _) :- !.

%  Caso 5:  f-valor > Umbral
%  Arbol debe crecer.

expandir( _, Arbol, Umbral, Arbol, no, _)  :-
  f(Arbol, F), F > Umbral.

% continuar( Camino, Arbol, Umbral, NuevoArbol, SubarbolResuelto, ArbolResuelto, Sol)

continuar( _, _, _, _, si, si, _).

continuar(Camino, t(Nodo,_/G,[A1|As]), Umbral, Arbol1, no, Resuelto, Sol)  :-
  insertar(A1, As, NAs),
  mejorF(NAs, F1),
  expandir(Camino, t(Nodo,F1/G,NAs), Umbral, Arbol1, Resuelto, Sol).

continuar(Camino, t(Nodo,_/G,[_|As]), Umbral, Arbol1, nunca, Resuelto, Sol)  :-
  mejorF(As, F1),
  expandir(Camino, t(Nodo,F1/G,As), Umbral, Arbol1, Resuelto, Sol).

% listaSucs(G0, [ Nodo1/Costo1, ...], [ l(MejorNodo,MejorF/G), ...]):
% ordena la lista de hojas por F-valor

listaSucs( _, [], []).

listaSucs(G0, [N/C|NCs], As)  :-
  G is G0 + C,
  h(N, H),                             % Heuristica h(N)
  F is G + H,
  listaSucs(G0, NCs, As1),
  insertar(l(N,F/G), As1, As).

% Insertar A en una lista de arboles As, preservando orden por
% f-valor.

insertar(A, As, [A|As])  :-
  f(A, F), mejorF(As, F1),
  F =< F1, !.

insertar(A, [A1|As], [A1|As1])  :-
  insertar(A, As, As1).

% Extraer f-value

f(l(_,F/_),F).        % f-valor de una hoja

f(t(_,F/_,_),F).      % f-valor de un árbol

mejorF([A|_],F)  :-   % mejor F de una lista de árboles
  f(A,F).

mejorF([],9999).       
  
min(X,Y,X)  :-
  X =< Y, !.

min(_,Y,Y).

%%% Reset para llamar un nuevo problema

reset :-
    retractall(s/3),
    retractall(h/2),
    retractall(meta/1).

% ------------------------------------------------------
% Eight puzzle


s([Vacio|Fichas], [Ficha|Fichas1], 1) :-
    cambio(Vacio, Ficha, Fichas, Fichas1).
% cambio/4 realiza cambios de piezas unicamente entre un espacio vacio y un espacio y uno no vacio.
cambio(Vacio, Ficha, [Ficha|Ts], [Vacio|Ts]) :-
    mandist(Vacio, Ficha, 1).
cambio(Vacio, Ficha, [T1|Ts], [T1|Ts1]) :-
    cambio(Vacio, Ficha, Ts, Ts1).

% Distancia Manhattan entre dos espacios, D.
mandist(X/Y, X1/Y1, D) :-
    dif(X, X1, Dx),
    dif(Y, Y1, Dy),
    D is Dx + Dy.

dif(A, B, D) :-
    D is abs(A - B).

% La heuristica h/2 es la suma de las distancias a cualquier espacio desde el espacio de origen mas 3 veces el puntaje de la secuencia.
h([Vacio|Fichas], H) :-
    meta([Vacio1|CuadrosMeta]),
    totdist(Fichas, CuadrosMeta, D),
    secpuntaje(Fichas, S),
    H is D + 3*S.

totdist([], [], 0).
totdist([Ficha|Fichas], [Cuadro|Cuadros], D) :-
    mandist(Ficha, Cuadro, D1),
    totdist(Fichas, Cuadros, D2),
    D is D1 + D2.

secpuntaje([Primera|OtrasFichas], S) :-
    secpuntaje([Primera|OtrasFichas], Primera, S).
secpuntaje([Ficha1,Ficha2|Fichas], Primera, S) :-
    puntaje(Ficha1, Ficha2, S1),
    secpuntaje([Ficha2|Fichas], Primera, S2),
    S is S1 + S2.
secpuntaje([Last], Primera, S) :-
    puntaje(Last, Primera, S).

puntaje(2/2, _, 1) :- !.
puntaje(1/3, 2/3, 0) :- !.
puntaje(2/3, 3/3, 0) :- !.
puntaje(3/3, 3/2, 0) :- !.
puntaje(3/2, 3/1, 0) :- !.
puntaje(3/1, 2/1, 0) :- !.
puntaje(2/1, 1/1, 0) :- !.
puntaje(1/1, 1/2, 0) :- !.
puntaje(1/2, 1/3, 0) :- !.
puntaje(_, _, 2).

meta([2/2, 1/3, 2/3, 3/3, 3/2, 3/1, 2/1, 1/1, 1/2]).

muestrasol([]).
muestrasol([P|L]) :-
    muestrasol(L), nl,
    write('+-----+'),
    muestrapos(P), nl,
    write('+-----+').

muestrapos([S0, S1, S2, S3, S4, S5, S6, S7, S8]) :-
    member(Y, [3,2,1]), nl,
    member(X, [1,2,3]),
    member(Ficha-X/Y, 
        [' '-S0, 1-S1, 2-S2, 3-S3, 4-S4, 5-S5, 6-S6, 7-S7, 8-S8]),
    write(' '), write(Ficha),
    fail
    ;
    true.

% Estados con distintas configuraciones iniciales del rompecabezas, se muestran sus numeros como referencia, y sus posiciones en x/y.
% Numeros: 0,   1,   2,   3,   4,   5,   6,   7,   8.
estado1([2/2, 1/3, 3/2, 2/3, 3/3, 3/1, 2/1, 1/1, 1/2]).
estado2([2/1, 1/2, 1/3, 3/3, 3/2, 3/1, 2/2, 1/1, 2/3]).
estado3([2/2, 2/3, 1/3, 3/1, 1/2, 2/1, 3/3, 1/1, 3/2]).
estado4([3/1, 2/2, 1/1, 2/3, 1/2, 3/3, 3/2, 2/1, 1/3]).
