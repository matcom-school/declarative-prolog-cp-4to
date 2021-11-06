:- use_module(list_helpers).
:- use_module(play_helpers).
:- use_module(play_database).

:- op(700, fx, [set_insect, init_play_with]).
:- op(699, yf, [to_play]).
:- op(710, xfy, [together, of_index]).

set_insect X to_play :- save(X).

init_play_with X  :- play_init(), !, set_insect X to_play.
 
set_insect X together Y of_index Z :- 
    set_insect X to_play,
    place_tuple(Z, Z1),
    save(X, Y, Z),
    save(Y, X, Z1).

