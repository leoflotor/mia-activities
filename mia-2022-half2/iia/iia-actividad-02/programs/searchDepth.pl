%%% Sucesor y meta son predicados dinamicos
:- dynamic
   conexion/2,
   meta/1.

%%% Declaracion de la meta
meta(fin).

% Conexiones entre nodos
conexion(inicio,1).
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
conexion(11,fin).

%%% Reglas para definir las condiciones de como dos nodos estan conectados
sucesor(Posicion1, Posicion2) :- conexion(Posicion1, Posicion2).
sucesor(Posicion1, Posicion2) :- conexion(Posicion2, Posicion1).

%%% Solicitar solucion
solucion(Inicio, Sol) :-
    ruta([Inicio], SolAux),
    reverse(SolAux, Sol).

%%% Algoritmo de busqueda en profundidad
ruta([fin|RestoDeRuta], [fin|RestoDeRuta]).
ruta([PosicionActual|RestoDeRuta], Sol) :-
    sucesor(PosicionActual, PosicionSiguiente),
    not(member(PosicionSiguiente, RestoDeRuta)),
    ruta([PosicionSiguiente,PosicionActual|RestoDeRuta], Sol).
