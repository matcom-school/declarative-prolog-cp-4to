:- module(playDataBase, [
    op(699, yf, [is_insect, is_player, is_card ]),
    op(688, xfx, [of_player]),
    op(700, fx, [cards]),
    cards/1,
    insect_play/3, 
    dont_mov/2, 
    save/3,
    remove/3,
    is_turn_of/1,
    next_player/1,
    other_player/2
]).

:- dynamic insect_play/3.
:- dynamic player_turn/1.
:- dynamic dont_mov/2.
:- dynamic cache/1.

save(Insect, X, Y) :- asserta(insect_play(Insect, X, Y )).

remove(Insect, X, Y) :- 
    insect_play(Insect, X, Y), !, 
    retract(insect_play(Insect, X, Y)).

X is_insect :- X = queen_bee.
X is_insect :- X = art.
X is_insect :- X = grasshopper.
X is_insect :- X = beetle.
X is_insect :- X = spider.
X is_insect :- X = ladybug.
X is_insect :- X = mosquito.
X is_insect :- X = pill_bug.

X is_player :- X = black.
X is_player :- X = white.

X is_card :- Player is_player, Insect is_insect, X = (Insect, Player).

cards List of_player X :- X is_player,
    List = [
        (queen_bee, X, 1), 
        (art, X, 1), (art, X, 2), (art, X, 3), 
        (grasshopper, X, 1), (grasshopper, X, 2), (grasshopper, X, 3),
        (beetle, X, 1), (beetle, X, 2),
        (spider, X, 1), (spider, X, 2)
    ].


is_turn_of(white) :- not(player_turn(_)), !, asserta(player_turn(white)). 
is_turn_of(Player) :- player_turn(Player).

other_player(white, black).
other_player(black, white).

next_player(Player) :- Player = white, !, retract(player_turn(white)), asserta(player_turn(black)). 
next_player(Player) :- Player = black, !, retract(player_turn(black)), asserta(player_turn(white)). 