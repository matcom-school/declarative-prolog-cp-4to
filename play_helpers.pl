:- module(playHelpers, [  
 op(700, fx, [insects]),
 op(700, fy, [list]), 
 op(700, xfx, [play_played]),
 op(700, yf, [timess]),
 list/1,
 timess/1, 
 place_tuple/2, 
 play_init/0,
 free_places/2,
 is_from/2,
 the_queen_is_already_at_stake/1,
 set_condition/3,
 adj_list/3,
 get_player/2,
 adj_positions/2
]).

:- use_module(list_helpers).
:- use_module(play_database).

list insects X :- findall(Y, insect_play(Y, _, _), X).

play_init() :- list insects X, length(X, 0).

adj_positions((X, Y), (X1, Y1)) :- 
    X is X1 - 1, Y is Y1 - 1;
    X is X1 - 1, Y is Y1;
    X is X1    , Y is Y1 - 1;
    X is X1    , Y is Y1 + 1;
    X is X1 + 1, Y is Y1 - 1;
    X is X1 + 1, Y is Y1.
    

set_condition(Player, X, Y) :-
    not(insect_play(_, X, Y)),
    adj_list(X, Y, List),
    map(get_player, List, PlayerList),
    length(PlayerList, Length),
    Length > 0, 
    PlayerList has Length of Player.

place_tuple(X, Y) :- 
    I1 is_index_of X in [0,1,2,3,4,5],
    I2 is_index_of Y in [3,4,5,0,1,2],
    I1 = I2.


free_places(I, List) :- setof(X, insect_linked_relation(I, _, X), List).




the_queen_is_already_at_stake(Player) :- 
    Player play_played N timess, N < 4, !.
the_queen_is_already_at_stake(Player) :- 
    Player play_played N timess, N > 3, !, 
    list insects List, contain((queen_bee, Player), List).

free_place_index(Insect1, Insect2, Player, Index) :- 
    not(insect_linked_relation((Insect1, Player), _, Index)), !,
    place_tuple(Index, OhterIndex),
    not(insect_linked_relation((Insect2, Player), _, OhterIndex)), !.

% right_check(Insect1, Player, Index, TopIndex) :- fail, !.
% left_check(Insect1, Player, Index, TopIndex) :- fail, !.
% does_not_touch_cards_of_other_player(Insect1, Player, Index, TopIndex) :- fail, !. 
    

% update_table_by_set(Insect1, Insect2, Player, Index) :- 
%     free_place_index(Insect1, Insect2, Player, Index), !,
%     place_tuple(Index, OhterIndex), 
%     does_not_touch_cards_of_other_player(Insect1, Insect2, Player, Index, OhterIndex), !,
%     save((Insect1, Player), (Insect2, Player), Index),
%     save((Insect2, Player), (Insect1, Player), OtherIndex).


    