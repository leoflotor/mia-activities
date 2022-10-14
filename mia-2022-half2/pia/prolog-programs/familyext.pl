%%% Autor: Leonardo Flores Torres
%%% Curso: Programacion para la Inteligencia Artificial
%%% Profesor: Alejandro Guerra Hernández
%%% Version extendida del programa de la familia

%%% progenitor/2 denota el hecho sobre quién es progenitor de que persona. Este hecho no considera sexos de nacimiento, por lo que puede considerarse como neutro y usarse posteriormente en casos más específicos.
progenitor(pam, bob).
progenitor(tom, bob).
progenitor(tom, liz).
progenitor(bob, ann).
progenitor(bob, pat).
progenitor(pat, jim).

%%% mujer/1 denota el hecho de los individuos que nacieron con sexo femenino.
mujer(pam).
mujer(pat).
mujer(liz).
mujer(ann).

%%% hombre/1 denota el hecho de los individuos que nacieron con sexo masculino.
hombre(tom).
hombre(bob).
hombre(jim).

%%% hermanoneutro/2 computa quienes dos personas son hermanos, donde X es hermano de Y independientemente de su sexo biológico.
%%% Ejemplos:
%%% ?- hermanoneutro(ann, X).
%%% X = pat.
%%% ?- hermanoneutro(X, tom).
%%% false.
hermanoneutro(X, Y) :-
    dif(X, Y),
    progenitor(Z, X),
    progenitor(Z, Y).

%%% hermana/2 es un caso específico de hermanoneutro/2 donde X es femenino, y además es hermana de Y.
hermana(X, Y) :-
    mujer(X),
    hermanoneutro(X, Y).

%%% hermana/2 es un caso específico de hermanoneutro/2 donde X es masculino, y además es hermano de Y.
hermano(X, Y) :-
    hombre(X),
    hermanoneutro(X, Y).

%%% padre/2 es una regla donde se especifíca el sexo de nacimiento de X, y además es padre de Y.
padre(X, Y) :-
    hombre(X),
    progenitor(X, Y).

%%% madre/2 es una regla donde se especifíca el sexo de nacimiento de X, y además es madre de Y.
madre(X, Y) :-
    mujer(X),
    progenitor(X, Y).

%%% tioneutro/2 computa quien es tio de Y, donde X es el tio independiente de su sexo biológico.
%%% Ejemplos:
%%% ?- tioneutro(X, jim).
%%% X = ann ;
%%% false.
%%% ?- tioneutro(jim, X).
%%% false.
tioneutro(X, Y) :-
    hermanoneutro(X, Z),
    progenitor(Z, Y).

%%% tio/2 computa quien es tio de Y, donde X es el tio y debe tener sexo masculino de nacimiento.
tio(X, Y) :-
    hombre(X),
    tioneutro(X, Y).

%%% tia/2 computa quien es tio de Y, donde X es la tia y debe tener sexo femenino de nacimiento.
tia(X, Y) :-
    mujer(X),
    tioneutro(X, Y).

%%% sobrinoneutro/2 computa X sobrino de Y siempre y cuando Y sea tio de X, donde X es independiente de su sexo biológico y también lo es Y.
%%% Ejemplos:
%%% ?- sobrinoneutro(jim, X).
%%% X = ann ;
%%% false.
%%% ?- sobrinoneutro(X, ann).
%%% X = jim.
%%% ?- sobrinoneutro(X, liz).
%%% X = ann ;
%%% X = pat ;
%%% false.
sobrinoneutro(X, Y) :-
    tioneutro(Y, X).

%%% sobrino/2 computa de quien es sobrino X, donde X es el sobrino y debe tener sexo masculino de nacimiento, pero no importa el sexo de quien es tio.
sobrino(X, Y) :-
    hombre(X),
    sobrinoneutro(X, Y).

%%% sobrina/2 computa de quien es sobrina X, donde X es la sobrina y debe tener sexo femenino de nacimiento, pero no importa el sexo de quien es tio.
sobrina(X, Y) :-
    mujer(X),
    sobrinoneutro(X, Y).

%%% sobrinos/1 computa quienes son los sobrinos dentro de la familia independiente del sexo de nacimiento, sin importar de quien sean sobrinos.
%%% Ejemplo:
%%% ?- sobrinos(X).
%%% X = ann ;
%%% X = pat ;
%%% X = jim ;
%%% false.
sobrinos(X) :-
    sobrinoneutro(X, _).