% parent_of(offspring, parent)
parent_of(bob, pam).
parent_of(bob, tom).
parent_of(liz, tom).
parent_of(ann, bob).
parent_of(pat, bob).
parent_of(jim, pat).

% 
female(pam).
female(liz).
female(pat).
female(ann).

% 
male(tom).
male(bob).
male(jim).

% sister_of(Sibling, Sister)
sister_of(Sibling, Sister) :-
    dif(Sibling, Sister),
    female(Sister),
    parent_of(Parent, Sister),
    parent_of(Parent, Sibling).

% brother_of(Sibling, Brother)
brother_of(Sibling, Brother) :-
    dif(Sibling, Brother),
    male(Brother),
    parent_of(Parent, Brother),
    parent_of(Parent, Sibling).

% grandma_of(Grandchild, Grandma)
grandma_of(Grandchild, Grandma) :-
    female(Grandma),
    parent_of(Parent, Grandchild),
    parent_of(Grandma, Parent).

% grandpa_of(Grandchild, Grandpa)
grandpa_of(Grandchild, Grandpa) :-
    male(Grandpa),
    parent_of(Parent, Grandchild),
    parent_of(Grandpa, Parent).

% mother_of(Child, Mother)
mother_of(Child, Mother) :-
    female(Mother),
    parent_of(Mother, Child).

% father_of(Child, Father)
father_of(Child, Father) :-
    male(Father),
    parent_of(Father, Child).

% ancestor_of(Person, Ancestor)
% defined in terms of itself
ancestor_of(Person, Ancestor) :-
    parent_of(Person, Ancestor).

ancestor_of(Person, Ancestor) :-
    parent_of(Person, Parent),
    ancestor_of(Parent, Ancestor).

% ancestress_of(Person, Ancestress)
% defined in terms of itself
ancestress_of(Person, Ancestress) :-
    % female(Ancestress),
    % parent_of(Person, Ancestress).
    mother_of(Person, Ancestress).

ancestress_of(Person, Ancestress) :-
    female(Ancestress),
    parent_of(Person, Parent),
    ancestor_of(Parent, Ancestress).

