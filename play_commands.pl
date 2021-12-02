:- use_module(list_helpers).
:- use_module(play_helpers).
:- use_module(play_database).

:- op(700, fx, [set_insect, init_play_with, cards, cards_out_play]).
:- op(699, yf, [is_insect, is_player, is_card ]).
:- op(710, xfy, [together, of_index, by, in]).
:- op(688, xfx, [of_player, to_play_by]).

X is_insect :- X = queen_bee.
X is_insect :- X = art.
X is_insect :- X = grasshopper.
X is_insect :- X = beetle.
X is_insect :- X = spider.

X is_player :- X = black.
X is_player :- X = white.

X is_card :- Player is_player, Insect is_insect, X = (Insect, Player).

cards List of_player X :- X is_player,
    QueenList = [(queen_bee, X, 1)],
    AntsList = [(art, X, 1), (art, X, 2), (art, X, 3)],
    GrasshopperList = [(grasshopper, X, 1), (grasshopper, X, 2), (grasshopper, X, 3)],
    BeetleList = [(beetle, X, 1), (beetle, X, 2)],
    SpiderList = [(spider, X, 1), (spider, X, 2)],
    compose_by([QueenList, AntsList, GrasshopperList, BeetleList, SpiderList], List).

cards_out_play List of_player Player :- 
    cards AllCards of_player Player,
    list insects CardInPlay,
    diff(CardInPlay, AllCards, List).



set_insect (Insect, Index) to_play_by Player in (X, Y):- 
    Insect is_insect, !, Player is_player, !, save((Insect, Player, Index), X, Y).

remove_insect (Insect, Index) to_play_by Player in (X, Y) :- 
    Insect is_insect, !, Player is_player, !, remove((Insect, Player, Index), X, Y).

init_play_with (Insect, Index)  :- 
    play_init(), !, 
    cards List of_player white,
    member((Insect, white, Index), List),
    set_insect (Insect, Index) to_play_by white in (0,0).

init_play_with (Insect, Index) of_index (X, Y) :-
    not(play_init()), !,
    cards List of_player black,
    member((Insect, black, Index), List),
    list insects CardInPlay, length(CardInPlay, 1), !,
    adj_list(X, Y, AdjCard), length(AdjCard, 1), !, 
    set_insect (Insect, Index) to_play_by black in (X,Y).

set_insect (Insect, Index) by Player of_index (X, Y)  :-
    is_turn_of(Player), !,
    the_queen_is_already_at_stake(Player), !,
    cards_out_play PlayerCards of_player Player, 
    contain((Insect, Player, Index), PlayerCards), !,
    set_condition(Player, X, Y), !, 
    set_insect (Insect, Index) to_play_by Player in (X, Y).

finish_play() :- 
    insect_play((queen_bee, Player, 1), X, Y), 
    adj_list(X, Y, List), map(get_player, List, PlayerList),
    OtherPlayer is_player, OtherPlayer \= Player,
    PlayerList has 6 of OtherPlayer.

basic_move (Insect, Index) by Player of_index (X, Y) :- 
    insect_play((queen_bee, Player, 1), _, _), !,
    not(insect_play(_, X, Y)), !,
    insect_play((Insect, Player, Index), ActualX, ActualY), !,
    adj_positions((ActualX, ActualY), (X, Y)), !,
    remove_insect (Insect, Index) to_play_by Player in (ActualX, ActualY), 
    set_insect (Insect, Index) by Player of_index (X,Y).
