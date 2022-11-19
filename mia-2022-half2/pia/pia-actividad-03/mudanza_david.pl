% Me estoy cambiando de casa y debo llevar a mi casa nueva a mi perro, mi
% gato y mi hamster que, sobra decirlo, no se llevan muy bien entre ellos. Mi
% mini auto solo me permite llevar a una mascota conmigo. De manera que,
% por ejemplo, puedo llevarme al gato, dejando solos al hamster y al perro,
% pero no puedo dejar juntos a éste último y al gato, ni al gato y al perro.
% Escribir un programa en Prolog para encontrar los movimientos válidos para
% pasar todas mis mascota de una casa a otra. Implemente una solución al
% problema mediante una búsqueda en el espacio de soluciones del problema.
% Definimos como variables las posiciones en donde se desea llegar,
% estableciendo que la casa donde van a partir está en el lado derecho.
% Orden: Yo, Gato, Perro, hamster
goal(e(old_house, old_house, old_house, old_house)).
% Esribimos todas las posibles direcciones que puede haber.
direccion(old_house, new_house).
direccion(new_house, old_house).
%Configuramos los movimientos permitidos 
% Nos movemos de una casa hacia la otra, de la old house a new house
% Movimiento a realizar llendo de old house a new house solo.
m(e(Mov, Gato, Perro, Hamster), e(Mov1, Gato, Perro, Hamster)):- direccion(Mov, Mov1).
% Movimiento donde puedo mover el cambio de casa con el perro
m(e(Mov, Gato, Mov, Hamster), e(Mov1, Gato, Mov1, Hamster)):- direccion(Mov, Mov1).
% Regla donde puedo hacer movimiento con el gato.
m(e(Mov, Mov, Perro, Hamster), e(Mov1, Mov1, Perro, Hamster)):- direccion(Mov, Mov1).
% Regla donde me puedo mover el Hamster
m(e(Mov, Gato, Perro, Mov), e(Mov1, Gato, Perro, Mov1)):- direccion(Mov,Mov1).
% Prohibido una vez realizado el movimiento no puedo estar 
% del perro y el gato juntos
p(e(Mov, Mov1, Mov1, _)):- direccion(Mov, Mov1).
% Prohibido que el una vez realizado no puede estar el hamster
% juntos
p(e(Mov, Mov1, _, Mov1)):- direccion(Mov, Mov1).
% Establecemos la solución en una lista donde aparezcan los movimientos
% requeridos para poder pasar todas mis masotas.
% Determinamos que no existan estados repetidos.
member(X, [X|_]).
member(X, [_|L]):- member(X, L).
% Establecemos solución.
solucion([E | L], [E | L]) :- goal(E).
% Generamos una regla en donde se encuentre un caso donde no sea solución.
solucion([E | L], LS):- m(E, EP), not(p(EP)), not(member(EP, L)), solucion([EP, E | L], LS).