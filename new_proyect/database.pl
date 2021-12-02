:- module(playDataBase, [
    op(699, yf, [is_insect, is_player, is_card ]),
    op(688, xfx, [of_player]),
    op(700, fx, [cards]),
    cards/1,
    insect_play/3,  
    save/3,
    remove/3
]).

:- dynamic insect_play/3.

save(Insect, X, Y) :- asserta(insect_play(Insect, X, Y )).

remove(Insect, X, Y) :- 
    not(insect_play(Insect, X, Y)), !, 
    retract(insect_play(Insect, X, Y)).

X is_insect :- X = queen_bee.
X is_insect :- X = art.
X is_insect :- X = grasshopper.
X is_insect :- X = beetle.
X is_insect :- X = spider.

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