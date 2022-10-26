:- use_module(library(clpfd)).

%%% With finite domains
%%% natToPeano_fd/2 computes the conversion of a natural number to its Peano representation
natToPeano_fd(0, 0).
natToPeano_fd(N, s(X)) :-
    N #> 0,
    N1 #= N - 1,
    natToPeano_fd(N1, X).

% peanoToNat_fd/2 computes the conversion of a Peano number to its natural number equivalent
peanoToNat_fd(S, N) :-
    natToPeano_fd(N, S).

%%% Withouth finite domains
%%% natToPeano/2 computes the conversion of natural numbers to their Peano representation
%%% Example:
% ?- natToPeano(3, X).
% X = s(s(s(0))) .
natToPeano(0, 0).
natToPeano(N, s(X)) :-
    N >= 0,
    N1 is N - 1,
    natToPeano(N1, X).
%%% natToPeano/2 also deals with negative natural numbers
natToPeano(N, -s(X)) :-
    N < 0,
    N1 is - N - 1,
    natToPeano(N1, X).

%%% peanoToNat/2 computes the respective natural number of a Peano number
%%% Example:
% ?- peanoToNat(s(s(s(0))), X).
% X = 3.
peanoToNat(0, 0).
peanoToNat(s(X), N) :-
    peanoToNat(X, N1),
    N is N1 + 1.

%%% peanoToNat/2 also deals with negative Peano numbers
peanoToNat(-s(X), -N) :-
    peanoToNat(X, N1),
    N is N1 + 1.

%%% addPeano/3 adds S2 to S1, S3 = S1 + S2
% addPeano(S1, S2, S3) :-
%     peanoToNat(S1, N1),
%     peanoToNat(S2, _),
%     N1 < 0,
%     substractPeano(S1, S2, S3).

% addPeano(S1, S2, S3) :-
%     peanoToNat(S1, _),
%     peanoToNat(S2, N2),
%     N2 < 0,
%     substractPeano(S1, S2, S3).

% addPeano(S1, S2, S3) :-
%     peanoToNat(S1, N1),
%     peanoToNat(S2, N2),
%     N3 is N1 + N2,
%     N3 < 0,
%     natToPeano(N3, S3).

addPeano(S1, S2, S3) :-
    peanoToNat(S1, N1),
    peanoToNat(S2, N2),
    N3 is N1 + N2,
    natToPeano(N3, S3).

%%% substractPeano/3 substracts S2 to S1, S3 = S1 - S2
substractPeano(S1, S2, S3) :-
    peanoToNat(S1, N1),
    peanoToNat(S2, N2),
    N1 >= N2,
    N3 is N1 - N2,
    natToPeano(N3, S3).

substractPeano(S1, S2, -S3) :-
    peanoToNat(S1, N1),
    peanoToNat(S2, N2),
    N1 < N2,
    N3 is N2 - N1,
    natToPeano(N3, S3).



% USEFUL LINKS
% https://github.com/ffagerholm/peano
% https://stackoverflow.com/questions/8954435/convert-peano-number-sn-to-integer-in-prolog
