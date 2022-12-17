%%% Sucesor y meta son predicados dinámicos.

:- dynamic
   s/2,
   meta/1.

%%% Búsqueda Primero en Profundidad

solucion(Nodo,[Nodo]) :-
    meta(Nodo).

solucion(Nodo, [Nodo|Sol]) :-
    s(Nodo,Nodo1),
    solucion(Nodo1,Sol).

%%% Búsqueda Primero en Profundidad evitando ciclos

solucion2(Nodo,Sol) :-
    primeroProfundidad([],Nodo,Sol).

primeroProfundidad(Camino, Nodo, [Nodo|Camino]) :-
    meta(Nodo).

primeroProfundidad(Camino, Nodo, Sol) :-
    s(Nodo,Nodo1),
    \+ member(Nodo1, Camino),
    primeroProfundidad([Nodo|Camino],Nodo1,Sol).

%%% Búsqueda Primero en Profundidad con máxima prof.

solucion3(Nodo,Sol,MaxProf) :-
    primeroProfundidad2(Nodo,Sol,MaxProf).

primeroProfundidad2(Nodo,[Nodo],_) :-
    meta(Nodo).

primeroProfundidad2(Nodo,[Nodo|Sol],MaxProf):-
    MaxProf > 0,
    s(Nodo,Nodo1),
    Max1 is MaxProf-1,
    primeroProfundidad2(Nodo1,Sol,Max1).

%%% Solución basada en generación iterativa de caminos

camino(Nodo,Nodo,[Nodo]).
camino(PrimerNodo,UltimoNodo,[UltimoNodo|Camino]) :-
    camino(PrimerNodo,MenosElUltimo,Camino),
    s(MenosElUltimo,UltimoNodo),
    \+ member(UltimoNodo,Camino).

solucion4(NodoInicial,Sol) :-
    camino(NodoInicial,NodoMeta,Sol),
    meta(NodoMeta).

%%% Reset para llamar un nuevo problema

reset :-
    retractall(s/2),
    retractall(meta/1).
