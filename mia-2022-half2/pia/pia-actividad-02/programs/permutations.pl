%%% perms/2 computes the all possible permutations of List in Perms.
%%% Ejemplo:
% ?- perms([1,2,3], L).
% L = [[1, 2, 3], [1, 3, 2], [2, 1, 3], 
%      [3, 1, 2], [2, 3, 1], [3, 2, 1]].
perms(List, Perms) :-
    findall(Perm, permutation(Perm, List), Perms).

% USEFUL LINKS
% https://stackoverflow.com/questions/12824685/prolog-compute-the-permutation
% https://stackoverflow.com/questions/4146117/gnu-prolog-powerset-modification/4146427#4146427