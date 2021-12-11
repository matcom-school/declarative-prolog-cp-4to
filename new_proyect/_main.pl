:- module(main, [
    mov_condition/1, 
    set_condition/1,
    insect_available_to_set/1,
    get_table/1,
    set_insect/4,
    mov_insect/4,
    turn_finish/0,
    insect_available_to_mov/1
]).

:- use_module(command_set_insect).
:- use_module(command_mov_insect).
:- use_module(database).
:- use_module(find_by_table).
:- use_module(helpers).
:- use_module(list_helpers).


test_play() :- 
    set_insect((queen_bee, 1), 0, 0, _), turn_finish(),
    set_insect((queen_bee, 1), 0, 1, _), turn_finish(),
    set_insect((grasshopper, 1), 0, -1, _), turn_finish(),
    mov_insect((queen_bee, 1), 1,0, _), turn_finish(),
    mov_insect((grasshopper, 1), 0, 1, _), turn_finish(),
    set_insect((spider, 1), 2, -1, _), turn_finish(), 
    set_insect((art, 1), 0, 2, _), turn_finish(), !.

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

insect_available_to_set_by_player(Player, List) :- 
    list_all_insects InsetList of Player,
    cards CardList of_player Player,
    diff(InsetList, CardList, List).

insect_available_to_mov(List) :- 
    is_turn_of(Player),
    insect_available_to_mov_by_player(Player, List).

insect_available_to_mov_by_player(Player, List) :- 
    list_all_insects InsetList of Player,
    findall((Insect, Player, Index), 
        (dont_mov((Insect, Player, Index), _)), 
        StoperList),
    diff(StoperList, InsetList, List).

available_to_post(List) :- get_table(Table), length(Table, 0), !, List = [(0,0)].
available_to_post(List) :- 
    get_table(Table), length(Table, Len), Len > 0, !,
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
    ( 
        (not(insect_play((Insect, Player, Index), _, _)), !, Result = 'Error de Localizacion');
        (insect_play((Insect, Player, Index), ActualX, ActualY), !, mov((Insect, Player, Index), (ActualX, ActualY), (X, Y), Result))
    ).

simulate_play(_, Result) :-  finish_play(Result), Result \= 'Not finish', !.
simulate_play(Deep, Result) :-  
    simulate_steep(Deep, _),
    turn_finish(),
    simulate_play(Deep, Result), !.

simulate_steep(Deep, Result) :- 
    findall(_,(cache(X), retract(cache(X))),_).
    aux_simalate(Deep, 0, Density, MovList), 
    (   
        (   
            length(MovList, Len), Len > 0 , !, 
            member(n(Action, Insect, Index, X, Y, Density), MovList), !, 
            execute_action(Action, Insect, Index, X, Y, Result)
        );
        (length(MovList, 0), !, Result = 'No se encontro action')
    ).

execute_action(Action, Insect, Index, X, Y, Result) :- Action = 1, !, set_insect((Insect, Index), X, Y, Result).
execute_action(Action, Insect, Index, X, Y, Result) :- Action = 2, !, mov_insect((Insect, Index), X, Y, Result).

aux_simalate(0, _, Density, _) :- 
    is_turn_of(Player), other_player(Player, Other), 
    compute_queen_warning(Player, ResultPlayer), compute_queen_warning(Other, ResultOther),
    Density is ResultPlayer/ResultOther.

aux_simalate(Deep, Steep, Result, MovList) :-
    Mod is Steep mod 2, Mod = 0, !, Deep > 0, !,
    is_turn_of(Player),
    set_simulation(Player, Deep, Steep, SetListOptions), !,
    mov_simulation(Player, Deep, Steep, MovListOptions), !,
    append(MovListOptions, SetListOptions, MovList), writeln(MovList),
    (
        (map(get_density, MovList, DensityList), min_list(DensityList, Result));
        (length(MovList, 0), !, Result = -1) 
    ).

aux_simalate(Deep, Steep, Result, MovList) :-
    not((Mod is Steep mod 2, Mod = 0)), !, Deep > 0, !,
    is_turn_of(Player), other_player(Player, Other),
    set_simulation(Other, Deep, Steep, SetListOptions), !,
    mov_simulation(Other, Deep, Steep, MovListOptions), !,
    append(MovListOptions, SetListOptions, MovList), writeln(MovList),
    (
        (map(get_density, MovList, DensityList), max_list(DensityList, Result));
        (length(MovList, 0), !, Result = 1000) 
    ).


set_simulation(Player, Deep, Steep, ListOptions) :-
    NewDeep is Deep - 1,
    NewSteep is Steep + 1,
    findall(n(1, Insect, Index, X, Y, Density), 
        (
            insect_available_to_set_by_player(Player, List), member((Insect, Player, Index), List),
            available_to_post(PostList), member((X, Y), PostList),
            not(set_fail_condition(Insect, Index, Player, X, Y, _)),
            save((Insect, Player, Index), X, Y), 
            aux_simalate(NewDeep, NewSteep, Density, _),
            remove((Insect, Player, Index), X, Y)
        ),
        ListOptions
    ).

mov_simulation(Player, Deep, Steep, ListOptions) :-
    NewDeep is Deep - 1,
    NewSteep is Steep + 1,
    findall(n(2, Insect, Index, X, Y, Density), 
        (
            insect_available_to_mov_by_player(Player, List), member((Insect, Player, Index), List),
            available_to_post(PostList), member((X, Y), PostList),
            insect_play((Insect, Player, Index), ActualX, ActualY),
            not(mov_fail_condition((Insect, Index, Player), (ActualX, ActualY), (X, Y), _)),
            mov_insect_save((Insect, Player, Index), (ActualX, ActualY), (X,Y)),
            aux_simalate(NewDeep, NewSteep, Density, _),
            retract_mov_insect_save((Insect, Player, Index), (ActualX, ActualY), (X, Y)) 
        ),
        ListOptions
    ).