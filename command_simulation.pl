:- module(simulations, [
    simulate_one_steep/2,
    insect_available_to_set_by_player/2,
    insect_available_to_mov_by_player/2
]).

:- use_module(command_set_insect).
:- use_module(command_mov_insect).
:- use_module(command_pill_bug_effect).
:- use_module(database).
:- use_module(find_by_table).
:- use_module(helpers).
:- use_module(list_helpers).

simulate_one_steep(Deep, Result) :- 
    % findall(_,(cache(Table, Player, List, D), retract(cache(Table, Player, List, D))),_)
    aux_simalate(Deep, 0, Density, MovList), 
    (   
        (   
            length(MovList, Len), Len > 0 , !, 
            member(n(Action, Insect, Index, X, Y, Density), MovList), !, 
            execute_action(Action, Insect, Index, X, Y, Result)%, writeln(MovList), writeln((Action, Insect, Index, X, Y, Result)) 
        );
        (length(MovList, 0), !, Result = 'No se encontro action', writeln(Result))
    ),
    findall(_,( (Player = white; Player = black), dont_mov(X, Player), retract(dont_mov(X, Player))),_).

execute_action(Action, Insect, Index, X, Y, Result) :- Action = 1, !, set_insect((Insect, Index), X, Y, Result).
execute_action(Action, Insect, Index, X, Y, Result) :- Action = 2, !, mov_insect((Insect, Index), X, Y, Result).
execute_action(Action, AX, AY, X, Y, Result) :- 
    Action = 3, !, 
    is_turn_of(Player),
    insect_play((Insect, Other, Index), AX, AY), !, 
    (retract(last((Insect, Other, Index), AX, AY)), !; not(fail)),
    mov_by_pill_bug(Player, (Insect, Other, Index), (AX, AY), (X, Y), Result), !.

insect_available_to_set_by_player(Player, List) :- 
    list_all_insects InsetList of Player,
    cards CardList of_player Player,
    diff(InsetList, CardList, List).

insect_available_to_mov_by_player(Player, List) :- 
    list_all_insects InsetList of Player,
    findall((Insect, Player, Index), 
        (dont_mov((Insect, Player, Index), _)), 
        StoperList),
    diff(StoperList, InsetList, List).

available_to_post(List) :- list_all_insects Table, length(Table, 0), !, List = [(0,0)].
available_to_post(List) :- 
    list_all_insects Table, length(Table, Len), Len > 0, !,
    findall((X, Y), member((_, X, Y), Table), PosInTable),
    findall((X1, Y1), (member((X2, Y2), PosInTable), adj_post(X2, Y2, X1, Y1), not(member((X1, Y1), PosInTable))), FreePost),
    append(PosInTable, FreePost, List).

aux_simalate(0, _, Density, _) :- 
    is_turn_of(Player), other_player(Player, Other), 
    compute_queen_warning(Player, ResultPlayer), compute_queen_warning(Other, ResultOther),
    Density is ResultPlayer/ResultOther.

aux_simalate(Deep, Steep, Result, MovList) :-
    Mod is Steep mod 2, Mod = 0, !, Deep > 0, !,
    is_turn_of(Player),
    list_all_insects Table, map(exclude_index, Table, NewTable), sort(NewTable, CachingTable),
    ( 
        ( cache(CachingTable, Player, MovList, Result), ! );
        (
            not(cache(CachingTable, Player, _, _)), !, 
            set_simulation(Player, Deep, Steep, SetListOptions), !,
            mov_simulation(Player, Deep, Steep, MovListOptions), !,
            pill_bug_effect_simulation(Player, Deep, Steep, EffectListOptions), !,
            append(MovListOptions, EffectListOptions, TempList), !,
            append(TempList, SetListOptions, MovList), %!, writeln(MovList),
            (
                (map(get_density, MovList, DensityList), min_list(DensityList, Result));
                (length(MovList, 0), !, Result = -1) 
            ), 
            assert(cache(CachingTable, Player, MovList, Result))
        )
    ).

aux_simalate(Deep, Steep, Result, MovList) :-
    not((Mod is Steep mod 2, Mod = 0)), !, Deep > 0, !,
    is_turn_of(Player), other_player(Player, Other),
    findall(_,(dont_mov(X, Other), retract(dont_mov(X, Other))),_), 
    list_all_insects Table, map(exclude_index, Table, NewTable), sort(NewTable, CachingTable),
    ( 
        ( cache(CachingTable, Other, MovList, Result), ! );
        (
            not(cache(CachingTable, Other, _, _)), !, 
            set_simulation(Player, Deep, Steep, SetListOptions), !,
            mov_simulation(Player, Deep, Steep, MovListOptions), !,
            pill_bug_effect_simulation(Player, Deep, Steep, EffectListOptions), !,
            append(MovListOptions, EffectListOptions, TempList), !,
            append(TempList, SetListOptions, MovList), %!, writeln(MovList),
            (
                (map(get_density, MovList, DensityList), max_list(DensityList, Result));
                (length(MovList, 0), !, Result = 1000) 
            ), 
            assert(cache(CachingTable, Player, MovList, Result))
        )
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


pill_bug_effect_simulation(Player, Deep, Steep, ListOptions) :-
    NewDeep is Deep - 1,
    NewSteep is Steep + 1,
    findall(n(3, ActualX, ActualY, X, Y, Density), 
        (
            (PillBug = pill_bug; PillBug = mosquito),
            insect_play((PillBug, Player, 1), AdjX, AdjY), 
            adj_post(AdjX, AdjY, ActualX, ActualY), insect_play((Insect, Other, Index), ActualX, ActualY),
            adj_post(AdjX, AdjY, X, Y), not(insect_play(_, X, Y)), 
            not(pill_bug_fail_condition(Player, Insect, Other, Index, ActualX, ActualY, X, Y, _)),
            assert(dont_mov((Insect, Player, Index), Player)),
            mov_insect_save((Insect, Other, Index), (ActualX, ActualY), (X,Y)),
            aux_simalate(NewDeep, NewSteep, Density, _),
            retract_mov_insect_save((Insect, Other, Index), (ActualX, ActualY), (X, Y)) 
        ),
        ListOptions
    ).