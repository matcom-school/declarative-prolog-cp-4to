:- use_module(list_helpers).
:- use_module(play_helpers).
:- use_module(play_database).

:- op(700, fx, [set_insect, init_play_with, cards]).
:- op(699, yf, [to_play, is_insect, is_player, is_card]).
:- op(710, xfy, [together, of_index]).
:- op(688, xfx, [of_player]).

X is_insect :- X = queen_bee.
X is_insect :- X = art.
X is_insect :- X = grasshopper.
X is_insect :- X = beetle.
X is_insect :- X = spider.

X is_player :- X = black.
X is_player :- X = white.

X is_card :- Player is_player, Insect is_insect, X = (Insect, Player).

cards List of_player X :- X is_player,
    QueenList has 1 of (queen_bee, X),
    AntsList has 3 of (art, X),
    GrasshopperList has 3 of (grasshopper, X),
    BeetleList has 2 of (beetle, X),
    SpiderList has 2 of (spider, X),
    List is [QueenList, AntsList, GrasshopperList, BeetleList, SpiderList].


set_insect X to_play :- X is_insect, !, save(X).

init_play_with X  :- play_init(), !, set_insect X to_play.
 
set_insect X together Y of_index Z :- 
    set_insect X to_play,
    place_tuple(Z, Z1),
    save(X, Y, Z),
    save(Y, X, Z1).

