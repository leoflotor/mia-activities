% pine/1 creates a pine on a desired number of levels specified by Levels
pine(Levels) :- pine(0, Levels), !.

% pine/2 iterates through the lines appending spaces each line to center the stars
pine(C, X) :- C < X, 
    C1 is C+1,
    Y1 is X - C1,
    spaces(Y1),
    stars(0, C),
    pine(C1, X).
pine(C, X) :- C >= X.

% spaces/1 writes N spaces on demand
spaces(0) :- write('').
spaces(N) :-
    N1 is N - 1,
    N1 >= 0,
    write(' '),
    spaces(N1).

% stars/2 writes stars on demand on one line only and writes a new line after it has finished
stars(X, Y) :- X =< Y,
    X1 is X + 1,
    write('*     '),
    stars(X1, Y).
stars(X, Y) :- X > Y, nl.



% USEFUL LINKS
% https://stackoverflow.com/questions/20009868/how-can-i-draw-star-triangle-using-recursive-in-prolog
% https://stackoverflow.com/questions/65277514/how-to-draw-right-triangle-using-recursion-in-prolog
