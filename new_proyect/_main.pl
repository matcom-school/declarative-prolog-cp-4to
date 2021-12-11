:- module(main, [
    mov_condition/1, 
    set_condition/1,
    insect_available_to_set/1,
    get_table/1,
    set_insect/4,
    mov_insect/4,
    turn_finish/0,
    insect_available_to_mov/1,
    simulate_steep/2,
    pill_bug_effect_insect/3,
    pill_bug_effect_condition/1
]).

:- use_module(command_set_insect).
:- use_module(command_mov_insect).
:- use_module(command_simulation).
:- use_module(command_pill_bug_effect).
:- use_module(database).
:- use_module(find_by_table).
:- use_module(helpers).
:- use_module(list_helpers).


test_play() :- 
    set_insect((pill_bug, 1), 0, 0, _), turn_finish(),
    set_insect((art, 1), 0, -1, _), turn_finish(), 
    set_insect((art, 1), 1, 0, _), turn_finish(), 
    set_insect((art, 2), -1, -1, _), turn_finish(),!.
    % set_insect((queen_bee, 1), 0, 0, _), turn_finish(),
    % set_insect((queen_bee, 1), 0, 1, _), turn_finish(),
    % set_insect((grasshopper, 1), 0, -1, _), turn_finish(),
    % mov_insect((queen_bee, 1), 1,0, _), turn_finish(),
    % mov_insect((grasshopper, 1), 0, 1, _), turn_finish(),
    % set_insect((spider, 1), 2, -1, _), turn_finish(), 
    % set_insect((art, 1), 0, 2, _), turn_finish(), !.

pill_bug_effect_condition(Option) :- 
    is_turn_of(Player),
    insect_play((pill_bug, Player, 1), _, _), !,
    Option = '3- PillBug Effect'.

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
    insect_available_to_set_by_player(Player, List).

insect_available_to_mov(List) :- 
    is_turn_of(Player),
    insect_available_to_mov_by_player(Player, List).

get_table(Table) :- 
    list_all_insects Table.

set_insect((Insect, Index), X, Y, Result) :- 
    is_turn_of(Player), 
    set_insect (Insect, Index) by Player of_index (X, Y) with Result.

turn_finish() :- is_turn_of(Player), next_player(Player).


mov_insect( (Insect, Index), X, Y, Result ) :- 
    is_turn_of(Player),
    ( 
        (not(insect_play((Insect, Player, Index), _, _)), !, Result = 'Error de Localizacion');
        (insect_play((Insect, Player, Index), ActualX, ActualY), !, mov((Insect, Player, Index), (ActualX, ActualY), (X, Y), Result))
    ).

pill_bug_effect_insect((AX, AY), (X, Y), Result) :- 
    is_turn_of(Player),
    ( 
        (
            not(insect_play(_, AX, AY)), !, 
            Result = 'Error de Localizacion');
        (
            insect_play((Insect, Other, Index), AX, AY), !, 
            mov_by_pill_bug(Player, (Insect, Other, Index), (AX, AY), (X, Y), Result)
        )
    ).

simulate_steep(Deep, Result) :- 
    simulate_one_steep(Deep, Result).


