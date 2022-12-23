:- dynamic
   conexion/2,
   meta/1.

%%% Declaracion de la meta
meta(11).

% Conexiones entre nodos
conexion(1,2).
conexion(1,3).
conexion(2,4).
conexion(2,5).
conexion(3,6).
conexion(3,7).
conexion(4,8).
conexion(4,9).
conexion(5,10).
conexion(5,11).
conexion(6,12).
conexion(6,13).
conexion(7,14).
conexion(7,15).

%%% Búsqueda primero en Amplitud
solucion(Inicio, Sol) :-
    ruta([[Inicio]], SolAux),
    reverse(SolAux, Sol).

%%% La ruta en realidad es una lista de caminos que se van creando
%%% conforme se visitan los nodos en amplitud
ruta([[NodoActual|Camino]|_], [NodoActual|Camino]) :-
    meta(NodoActual).
ruta([Camino|Caminos], Sol) :-
    extender(Camino, NuevosCaminos),
    append(Caminos, NuevosCaminos, Caminos1),
    ruta(Caminos1, Sol).

extender([NodoActual|Camino], NuevosCaminos) :-
    bagof([NuevoNodo,NodoActual|Camino],
        (conexion(NodoActual, NuevoNodo),
        not((member(NuevoNodo, [NodoActual|Camino])))),
        NuevosCaminos),
        !.
%%% Caso si ya no hay sucesores en Camino
extender(_, []).
