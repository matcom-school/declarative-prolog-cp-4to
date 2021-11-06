:- module(playHelpers, [  
 op(700, fx, [insects]),
 op(700, fy, [list]), 
 place_tuple/2, 
 play_init/0,
 free_places/2
]).

:- use_module(list_helpers).
:- use_module(play_database).

list insects X :- findall(Y, insect_play(Y), X).

play_init() :- list insects X, length(X, 0).

place_tuple(X, Y) :- 
    I1 is_index_of X in [0,1,2,3,4,5],
    I2 is_index_of Y in [3,4,5,0,1,2],
    I1 = I2.

free_places(I, List) :- setof(X, insect_linked_relation(Y, _, X), P).