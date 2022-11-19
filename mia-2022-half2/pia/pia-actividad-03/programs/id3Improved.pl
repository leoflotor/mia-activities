:- dynamic
       ejemplo/3,
       nodo/3.

%%% id3.pl
%%% An implementation of the ID3 algorithm for inducing decision trees
%%% from data

% main call to id3

id3(ArchCSV) :- id3(ArchCSV,1).	% Umbral = 1, por default.

id3(ArchCSV,Umbral) :-
    reset,
    cargaEjs(ArchCSV,Atrs),
    findall(N,ejemplo(N,_,_),Inds), % Obtiene índices de los ejemplos
    induce(Inds,raiz,Atrs,Umbral),
    imprimeArbol, !.

% Caso 1. El número de ejemplos a clasificar es menor que el umbral.
% Se crea un nodo hoja con las distribución Distr, apuntando al padre
% del nodo.

induce(Ejs,Padre,_,Umbral) :-
    length(Ejs,NumEjs),
    NumEjs=<Umbral,
    distr(Ejs, Distr),
    assertz(nodo(hoja,Distr,Padre)), !. % Se agrega al final de los nodos.

% Caso 2. Todos los ejemplos a clasificar son de la misma clase.
% Se crea un nodo hoja con la distribución [Clase], apuntando al padre
% del nodo.

induce(Ejs,Padre,_,_) :-
    distr(Ejs, [Clase]),
    assertz(nodo(hoja,[Clase],Padre)).

% Caso 3. Se debe decidir que atributo es el mejor clasificador para
% los ejemplos dados.

induce(Ejs,Padre,Atrs,Umbral) :- 
    eligeAtr(Ejs,Atrs,Atr,Vals,Resto), !,
    particion(Vals,Atr,Ejs,Padre,Resto,Umbral).

% Caso 4. Los datos son inconsistentes, no se pueden particionar.

induce(Ejs,Padre,_,_) :- !,
    nodo(Padre,Test,_),
    write('Datos inconsistentes: no es posible construir partición de '),
    write(Ejs), write(' en el nodo '), writeln(Test). 

% eligeAtr(+Ejs,+Atrs,-Atr,-Vals,-Resto)
% A partir de un conjunto de ejemplos Ejs y atributos Atrs, computa
% el atributo Atr \in Atrs con mayor ganancia de información, sus Vals
% y el Resto de atributos en Atrs.

eligeAtr(Ejs,Atrs,Atr,Vals,RestoAtrs) :-
    length(Ejs,NumEjs),
    contenidoInformacion(Ejs,NumEjs,I), !,
    findall((Atr-Vals)/GainRatio, % Cambio de Gain por GainRatio
            (member(Atr,Atrs),
             vals(Ejs,Atr,[],Vals),
             separaEnSubConjs(Vals,Ejs,Atr,Parts),
             informacionResidual(Parts,NumEjs,IR),
             % Modificacion para calcular splitInformation
             splitInformation(Parts, NumEjs, SI),
             Gain is I - IR,
             % Modificacion para calcular GainRatio
             GainRatio is Gain / (SI + 1)),
            Todos),
    write(Todos),
    maximo(Todos,(Atr-Vals)/_),
    eliminar(Atr,Atrs,RestoAtrs), !.

% informacionResidual = Sum (Sv / S) E(Sv) donde v in A
% splitInformation = - Sum (Si / S) log2(Si / S) donde i = 1,...,c
% gainRatio = Gain / splitInformation

splitInformation([], _, 0) :- !.
splitInformation([Part|Parts], NumEjs, SI) :-
    length(Part, NumEjsPart),
    splitInformation(Parts, NumEjs, S),
    SI is S - (NumEjsPart / NumEjs) * log(NumEjsPart / NumEjs) / log(2).

separaEnSubConjs([],_,_,[]) :- !.
separaEnSubConjs([Val|Vals],Ejs,Atr,[Part|Parts]) :-
    subconj(Ejs,Atr=Val,Part), !,
    separaEnSubConjs(Vals,Ejs,Atr,Parts).

informacionResidual([],_,0) :- !.
informacionResidual([Part|Parts],NumEjs,IR) :-
    length(Part,NumEjsPart),
    contenidoInformacion(Part,NumEjsPart,I), !,
    informacionResidual(Parts,NumEjs,R),
    IR is R + I * NumEjsPart/NumEjs.

contenidoInformacion(Ejs,NumEjs,I) :-
    setof(Clase,Ej^AVs^(member(Ej,Ejs),ejemplo(Ej,Clase,AVs)),Clases), !,
    sumaTerms(Clases,Ejs,NumEjs,I).

sumaTerms([],_,_,0) :- !.
sumaTerms([Clase|Clases],Ejs,NumEjs,Info) :-
    findall(Ej,(member(Ej,Ejs),ejemplo(Ej,Clase,_)),EjsEnClase),
    length(EjsEnClase,NumEjsEnClase),
    sumaTerms(Clases,Ejs,NumEjs,I),
    Info is I - (NumEjsEnClase/NumEjs)*(log(NumEjsEnClase/NumEjs)/log(2)).

vals([],_,Vals,Vals) :- !.
vals([Ej|Ejs],Atr,Vs,Vals) :-
    ejemplo(Ej,_,AVs),
    member(Atr=V,AVs), !,
    (member(V,Vs), !, vals(Ejs,Atr,Vs,Vals);
     vals(Ejs,Atr,[V|Vs],Vals)
    ).

subconj([],_,[]) :- !.
subconj([Ej|Ejs],Atr,[Ej|RestoEjs]) :-
    ejemplo(Ej,_,AVs),
    member(Atr,AVs), !,
    subconj(Ejs,Atr,RestoEjs).
subconj([_|Ejs],Atr,RestoEjs) :-
    subconj(Ejs,Atr,RestoEjs).

% particion(+Vals,+Atr,+Ejs,+Padre,+Resto,+Umbral)
% Por acada Valor del atributo Atr en Vals, induce una partición
% en los ejemplos Ejs de acuerdo a Valor, para crear un nodo del
% árbol y llamar recursivamente a inducir.

particion([],_,_,_,_,_) :- !.
particion([Val|Vals],Atr,Ejs,Padre,RestoAtrs,Umbral) :-
    subconj(Ejs,Atr=Val,SubEjs), !,
    generaNodo(Nodo), 
    assertz(nodo(Nodo,Atr=Val,Padre)),
    induce(SubEjs,Nodo,RestoAtrs,Umbral), !,
    particion(Vals,Atr,Ejs,Padre,RestoAtrs,Umbral).

%%% distr(+Ejs,-DistrClaseEjs)
%%% Computa la Distribución de clases para el conjunto de ejemplos S.
%%% La notación X^Meta causa que X no sea instanciada al solucionar la Meta.

distr(Ejs,DistClaseEjs) :-
    % Extrae Valores de clase Cs de los ejemplos S
    setof(Clase,Ej^AVs^(member(Ej,Ejs),ejemplo(Ej,Clase,AVs)),Clases),
    % Cuenta la distribución de los valores para la Clase
    cuentaClases(Clases,Ejs,DistClaseEjs).

cuentaClases([],_,[]) :- !.
cuentaClases([Clase|Clases],Ejs,[Clase/NumEjsEnClase|RestoCuentas]) :-
    % Extrae los ejemplos con clase Clase en la lista Cuentas
    findall(Ej,(member(Ej,Ejs),ejemplo(Ej,Clase,_)),EjsEnClase),
    % Computa cuantos ejemplos hay en la Clase
    length(EjsEnClase,NumEjsEnClase), !,
    % Cuentas para el resto de los valores de la clase
    cuentaClases(Clases,Ejs,RestoCuentas).

/*--------------------- Imprime Arbol --------------------*/

imprimeArbol :-
    imprimeArbol(raiz,0).

imprimeArbol(Padre,_) :- 
    nodo(hoja,Clase,Padre), !,
    write(' => '),write(Clase).

imprimeArbol(Padre,Pos) :-
    findall(Hijo,nodo(Hijo,_,Padre),Hijos),
    Pos1 is Pos+2,
    imprimeLista(Hijos,Pos1).

imprimeLista([],_) :- !.

imprimeLista([N|T],Pos) :-
    nodo(N,Test,_),
    nl, tab(Pos), write(Test),
    imprimeArbol(N,Pos),
    imprimeLista(T,Pos).

/*------------------- Auxiliares --------------------------*/

generaNodo(M) :-
    retract(id(N)),
    M is N+1,
    assertz(id(M)), !.

generaNodo(1) :-
    assertz(id(1)).

eliminar(X,[X|T],T) :- !.

eliminar(X,[Y|T],[Y|Z]) :-
   eliminar(X,T,Z).

subconjunto([],_) :- !.

subconjunto([X|T],L) :-
    member(X,L), !,
    subconjunto(T,L).

maximo([X],X) :- !.
maximo([X/M|T],Y/N) :-
    maximo(T,Z/K),
    (M>K,Y/N=X/M ; Y/N=Z/K), !.

% elimina las ocurrencias de ejemplo y nodo en el espacio de trabajo

reset :-
    retractall(ejemplo(_,_,_)),
    retractall(nodo(_,_,_)),
    retractall(id(_)).

/*----------------------- Lectura y Procesamiento de CSV --------------------------*/

% cargaEjs(ArchCSV): carga ArchCSV como hechos estilo
% ejemplo(Ind,Clase,[Atr=Val]).

cargaEjs(ArchCSV,Atrs) :-
    csv2prolog(ArchCSV,Atrs,Ejs),
    maplist(assertz,Ejs).

% csv2prolog(ArchCSV,Ejs,Atrs): transforma las lista de salida de leerCSV/2 en una lista de
% ejemplos(Ind,Clase,[Atr=Val]) y otra lista de atributos.

csv2prolog(ArchCSV,Atrs,Ejs) :-
    leeCSV(ArchCSV,Atrs,EjsCSV),
    butlast(Atrs,AtrsSinClase),
    procEjs(1,AtrsSinClase,EjsCSV,Ejs).

procEjs(_,_,[],[]).

procEjs(Ind,AtrsSinClase,[Ej|Ejs],[ejemplo(Ind,Clase,EjAtrsVals)|Resto]) :-
    last(Ej,Clase),
    butlast(Ej,EjSinClase),
    maplist(procAtrVal,AtrsSinClase,EjSinClase,EjAtrsVals),
    IndAux is Ind + 1,
    procEjs(IndAux,AtrsSinClase,Ejs,Resto).

procAtrVal(Atr,Val,Atr=Val).

% leerCSV(ArchivoCSV,Ats,Ejs): lee el archivo CSV para obtener una lista
% de atributos Ats, y una de valores para cada ejemplo Ejs

leeCSV(ArchCSV,Atrs,Ejs) :-
    csv_read_file(ArchCSV,[AtrsAux|EjsAux], [strip(true)]),
    AtrsAux =.. [_|Atrs],
    maplist(procEj,EjsAux,Ejs).

% procEj(Ej,Args): regresa los argumento Args del ejempl Ej.

procEj(Ej,Args) :-
    Ej =.. [_|Args].

%%% last(L,E): E es el último elemento de la lista L.

last([],[]).
last(L,E) :-
    append(_,[E],L).

%%% butLast(L1,L2): L2 es L1 sin el último elemento.

butlast([],[]).
butlast(L1,L2) :-
    last(L1,Last),
    append(L2,[Last],L1).

