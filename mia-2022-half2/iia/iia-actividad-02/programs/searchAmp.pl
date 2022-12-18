%%% Sucesor y meta son predicados dinámicos.
:- dynamic
   s/2,
   meta/1.

meta(11).

% Conexiones
s(1,2).
s(1,3).
s(2,4).
s(2,5).
s(3,6).
s(3,7).
s(4,8).
s(4,9).
s(5,10).
s(5,11).
s(6,12).
s(6,13).
s(7,14).
s(7,15).

%%% Búsqueda primero en Amplitud

solucion5(Inicio,Sol) :-
    primeroEnAmplitud([[Inicio]],Sol).

%%% primeroEnAmplitud([Camino1,Camino2,...],Sol) Sol es una
%%% extensión hacía la meta de alguno de los caminos

primeroEnAmplitud([[Nodo|Camino]|_],[Nodo|Camino]) :-
    meta(Nodo).

primeroEnAmplitud([Camino|Caminos],Sol) :-
    extender(Camino,NuevosCaminos),
    append(Caminos,NuevosCaminos,Caminos1),
    primeroEnAmplitud(Caminos1,Sol).

extender([Nodo|Camino],NuevosCaminos) :-
    bagof([NuevoNodo,Nodo|Camino],
	  (s(Nodo,NuevoNodo),
	   \+ (member(NuevoNodo, [Nodo|Camino]))),
	  NuevosCaminos),
    !.

%%% Si extender falla, Camino no tiene sucesores (lista vacía)

extender(_,[]).