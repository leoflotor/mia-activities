%%% Sucesor y meta son predicados dinámicos.

:- dynamic
   s/2,
   meta/1.

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

%%% Reset para llamar un nuevo problema

reset :-
    retractall(s/2),
    retractall(meta/1).
