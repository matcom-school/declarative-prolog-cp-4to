:- module(setInsect, [
    op(700, fx, [set_insect]),
    op(700, yfx, [by, of_index, with]),
    with/2,
    set_fail_condition/6
]).

:- use_module(find_by_table).
:- use_module(database).
:- use_module(helpers).
:- use_module(list_helpers).


set_fail_condition(Insect, Index, Player, X, Y, Result) :- 
    init_condition(Insect, Index, Player, X, Y, Result);
    bussy_condition(Insect, Index, Player, X, Y, Result);
    availability_condition(Insect, Index, Player, X, Y, Result);
    connected_condition(Insect, Index, Player, X, Y, Result);
    queen_condition(Insect, Index, Player, X, Y, Result);
    other_player_condition(Index, Index, Player, X, Y, Result), !.

init_condition(_, _, _, X, Y, Result) :- 
    list_all_insects ListAllCard, length(ListAllCard, Length), Length = 0, !,
    (X \= 0; Y \= 0), !, Result = 'La posicion inicial debe ser la 0:0'.

bussy_condition(_, _, _, X, Y, Result) :- 
    insect_play(_, X, Y), !, Result = 'Posicion Ocupada'.

availability_condition(Insect, Index, Player, _, _, Result) :- 
    list_all_insects List of Player,
    member((Insect, Player ,Index), List), !,
    Result = 'Insecto no Disponible'.

connected_condition( _, _, _, X, Y, Result) :- 
    get_all_insects(ListAllCard), length(ListAllCard, Length1), Length1 > 0, !, 
    adj_list(X, Y, ListAdjCard), length(ListAdjCard, Length2), Length2 = 0, !, 
    Result = 'Posicion Desconectada'.

queen_condition(_, _, Player, _, _, Result) :- 
    list_all_insects List of Player, length(List, Length), Length > 3, !,
    not(member((queen_bee, Player, 1), List)), 
    Result = 'Falta por colocar la reina'. 

other_player_condition(_, _, Player, X, Y, Result) :- 
    get_all_insects(ListAllCard), length(ListAllCard, Length1), Length1 > 1, !, 
    adj_list(X, Y, ListAdjCard), length(ListAdjCard, Length2), Length2 \= 0, !, 
    map(get_player, ListAdjCard, PlayerList),
    other_player(Player, OtherPLayer), member(OtherPLayer, PlayerList), !,
    Result = 'Toca un insecto del contrario'.

set_insect (Insect, Index) by Player of_index (X, Y) with Result :- 
    set_fail_condition(Insect, Index, Player, X, Y, Result).

set_insect (Insect, Index) by Player of_index (X, Y) with Result :- 
    not(set_fail_condition(Insect, Index, Player, X, Y, Result)), !,
    save((Insect, Player, Index), X, Y), finish_play(Result).


