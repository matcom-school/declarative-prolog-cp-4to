:- module(main, [
    mov_condition/1, 
    set_condition/1,
    insect_available_to_set/1,
    get_table/1,
    set_insect/4,
    mov_insect/4,
    turn_finish/0
]).

:- use_module(command_set_insect).
:- use_module(command_mov_insect).
:- use_module(database).
:- use_module(find_by_table).
:- use_module(helpers).
:- use_module(list_helpers).


mov_condition(Option) :- 
    is_turn_of(Player), 
    insect_play((queen_bee, Player, 1),_,_), !, 
    findall((Insect, Player, Index), (
        insect_play((Insect, Player, Index), _, _),
        not(dont_mov((Insect, Player, Index), _))  
    ), List), 
    length(List, Len), Len \= 0,
    Option = '2- Mov Insect'.

set_condition(Option) :- 
    is_turn_of(Player),
    list_all_insects InsetList of Player,
    cards CardList of_player Player,
    length(InsetList, Length1), length(CardList, Length2),
    Length1 \= Length2,!, Option = '1- Set Insect'.

insect_available_to_set(List) :- 
    is_turn_of(Player),
    list_all_insects InsetList of Player,
    cards CardList of_player Player,
    diff(InsetList, CardList, List).

insect_available_to_mov(List) :- 
    is_turn_of(Player),
    list_all_insects InsetList of Player,
    findall((Insect, Player, Index), 
        (dont_mov((Insect, Player, Index), _)), 
        StoperList),
    diff(StoperList, InsetList, List).

get_table(Table) :- 
    list_all_insects Table.

set_insect((Insect, Index), X, Y, Result) :- 
    is_turn_of(Player), 
    set_insect (Insect, Index) by Player of_index (X, Y) with Result.

turn_finish() :- is_turn_of(Player), next_player(Player).

mov_insect( (Insect, Index), X, Y, Result ) :- 
    is_turn_of(Player),
    % mov_insect (Insect, Index) by Player of_index (X, Y) with Result.
    mov((Insect, Player, Index), (X, Y), Result).

% simulate_steep with Result :- 
%     simulate_steep(Result).