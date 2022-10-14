vivencerca(juan, maria).
vivencerca(gloria, estefan).
vivencerca(maria, gloria).

vecinos(X, Y) :- dif(X, Y), vivencerca(X, Y).
vecinos(X, Y) :- vivencerca(Y, X), dif(X, Y).