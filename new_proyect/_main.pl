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

available_to_post(List) :- 
    get_table(Table), 
    findall((X, Y), member((_, X, Y), Table), PosInTable),
    findall((X1, Y1), (member((X2, Y2), PosInTable), adj_post(X2, Y2, X1, Y1), not(member((X1, Y1), PosInTable))), FreePost),
    append(PosInTable, FreePost, List).

get_table(Table) :- 
    list_all_insects Table.

set_insect((Insect, Index), X, Y, Result) :- 
    is_turn_of(Player), 
    set_insect (Insect, Index) by Player of_index (X, Y) with Result.

turn_finish() :- is_turn_of(Player), next_player(Player).

mov_insect( (Insect, Index), X, Y, Result ) :- 
    is_turn_of(Player),
    mov((Insect, Player, Index), (X, Y), Result).

simulate_play(_, Result) :-  finish_play(Result), Result \= 'Not finish', !.
simulate_play(Deep, Result) :-  
    simulate_steep(Deep, _),
    turn_finish(),
    simulate_play(Deep, Result), !.

simulate_steep(Deep, Result) :- 
    aux_simalate(Deep, 0, Density, MovList), 
    member(n(Action, Insect, Index, X, Y, Density), MovList), !,
    execute_action(Action, Insect, Index, X, Y, Result).

execute_action(1, Insect, Index, X, Y, Result) :- set_insect((Insect, Index), X, Y, Result).
execute_action(2, Insect, Index, X, Y, Result) :- mov_insect((Insect, Index), X, Y, Result).

aux_simalate(0, _, Density, _) :- 
    is_turn_of(Player), other_player(Player, Other), 
    compute_queen_warning(Player, ResultPlayer), compute_queen_warning(Other, ResultOther),
    Density is ResultPlayer/ResultOther.

aux_simalate(Deep, Steep, Result, MovList) :-
    Mod is Steep mod 2, Mod = 0, !,
    is_turn_of(Player),
    findall(n(Action, Insect, Index, X, Y, Density), ( 
        set_simulation(Insect, Player, Index, X, Y, Deep, Steep, Density), !, Action = 1
    ), MovList), 
    map(get_density, MovList, DensityList), min_list(DensityList, Result).

aux_simalate(Deep, Steep, Result, MovList) :-
    Mod is Steep mod 2, Mod = 1, !,
    is_turn_of(Player), other_player(Player, Other),
    findall(n(Action, Insect, Index, X, Y, Density), ( 
        set_simulation(Insect, Other, Index, X, Y, Deep, Steep, Density), !, Action = 1
    ), MovList), 
    map(get_density, MovList, DensityList), max_list(DensityList, Result).

set_simulation(Insect, Player, Index, X, Y, Deep, Steep, Density) :- 
    NewDeep is Deep - 1, NewDeep > -1, !,
    NewSteep is Steep + 1,
    insect_available_to_set(List), member((Insect, Player, Index), List),
    available_to_post(PostList), member((X, Y), PostList),
    not(set_fail_condition(Insect, Player, Index, X, Y, _)), !,
    save((Insect, Player, Index), X, Y), 
    aux_simalate(NewDeep, NewSteep, Density, _), 
    remove((Insect, Player, Index), X, Y).  

mov_simulation(Insect, Player, Index, X, Y, Deep, Steep, Density) :- 
    NewDeep is Deep - 1, NewDeep > -1, !,
    NewSteep is Steep + 1,
    insect_available_to_set(List), member((Insect, Player, Index), List),
    available_to_post(PostList), member((X, Y), PostList),
    insect_play((Insect, Player, Index), ActualX, ActualY),
    not(mov_fail_condition((Insect, Player, Index), (ActualX, ActualY), (X, Y), _)), !,
    mov_insect_save((Insect, Player, Index), (ActualX, ActualY), (X,Y)),
    aux_simalate(NewDeep, NewSteep, Density, _), 
    retract_mov_insect_save((Insect, Player, Index), (ActualX, ActualY), (X, Y)).  