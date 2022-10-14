progenitor(pam, bob).
progenitor(tom, bob).
progenitor(tom, liz).
progenitor(bob, ann).
progenitor(bob, pat).
progenitor(pat, jim).

% mujer(ann).
% mujer(pat).

% hermana(X, Y) :-
%     progenitor(Z, X),
%     progenitor(Z, Y),
%     mujer(X).

f(A, g(B)) = f(g(B), A)