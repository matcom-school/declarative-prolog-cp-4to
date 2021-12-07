:- module(setInsect, [
    op(700, fx, [set_insect]),
    op(700, yfx, [by, of_index, with]),
    with/2
]).

:- use_module(find_by_table).
:- use_module(database).
% :- use_module(operators).
:- use_module(helpers).
:- use_module(list_helpers).

set_fail_condition(_, _, _, X, Y, Result) :- 
    list_all_insects ListAllCard, length(ListAllCard, Length), Length = 0, !,
    X \= 0, Y \= 0, !, Result = 'La posicion inicial debe ser la 0:0'.

set_fail_condition(_, _, _, X, Y, Result) :- 
    insect_play(_, X, Y), !, Result = 'Posicion Ocupada'.

set_fail_condition(Insect, Index, Player, _, _, Result) :- 
    list_all_insects List of Player,
    member((Insect, Player ,Index), List), !,
    Result = 'Insecto no Disponible'.

set_fail_condition( _, _, _, X, Y, Result) :- 
    list_all_insects ListAllCard, length(ListAllCard, Length1), Length1 > 1, !, 
    adj_list(X, Y, ListAdjCard), length(ListAdjCard, Length2), 
    Length2 = 0, !, Result = 'Posicion Desconectada'.

set_fail_condition(_, _, Player, _, _, Result) :- 
    list_all_insects List of Player, length(List, Length), Length > 3, !,
    not(member(queen_bee, 1), List), 
    Result = 'Falta por colocar la reina'. 

set_fail_condition(_, _, Player, X, Y, Result) :- 
    list_all_insects ListAllCard, length(ListAllCard, Length1), Length1 > 2, !, 
    adj_list(X, Y, ListAdjCard), length(ListAdjCard, Length2), 
    Length2 > 0, !,
    map(get_player, ListAdjCard, PlayerList),
    not(PlayerList has Length2 of Player),
    Result = 'Toca un insecto del contrario'.

set_insect (Insect, Index) by Player of_index (X, Y) with Result :- 
    set_fail_condition(Insect, Index, Player, X, Y, Result).

set_insect (Insect, Index) by Player of_index (X, Y) with Result :- 
    not(set_fail_condition(Insect, Index, Player, X, Y, Result)), !,
    save((Insect, Player, Index), X, Y), finish_play(Result).


