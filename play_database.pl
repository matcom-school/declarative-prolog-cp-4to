:- module(playDataBase, [
    insect_play/1, 
    insect_linked_relation/3, 
    save/1, 
    save/3
]).

:- dynamic insect_play/1.
:- dynamic insect_linked_relation/3.

save(X) :- asserta(insect_play(X)).
save(X,Y,Z) :- asserta(insect_linked_relation(X,Y,Z)).