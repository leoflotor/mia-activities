%%% Sucesor y meta son predicados dinámicos.
:- dynamic
   s/2,
   meta/1.

meta(fin).

% Conexiones
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

% Definir como es que dos nodos estan conectados
s(Pos1, Pos2) :- conexion(Pos1, Pos2).
s(Pos1, Pos2) :- conexion(Pos2, Pos1).

% Solucion
sol :- 
    ruta([inicio], Sol), 
    reverse(Sol, SolR), 
    write(SolR).

%% Búsqueda Primero en Profundidad
ruta([fin|RestoDeRuta], [fin|RestoDeRuta]).
ruta([PosActual|RestoDeRuta], Sol) :-
    s(PosActual, PosSiguiente),
    \+ member(PosSiguiente, RestoDeRuta),
    ruta([PosSiguiente,PosActual|RestoDeRuta], Sol).