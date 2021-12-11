:- module(movInsect, [
    op(700, fx, [mov_insect]),
    op(700, yfx, [from, to, by, with]),
    mov/4,
    mov_fail_condition/4,
    retract_mov_insect_save/3,
    mov_insect_save/3,
    connected_condition/4
]).

% :- discontiguous movInsect:mov/3.

:- use_module(list_helpers).
:- use_module(find_by_table).
:- use_module(database).
:- use_module(helpers).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% General Mov
mov_insect_save( (Insect, Player, Index), (AX, AY), (NX, NY)) :- 
    save((Insect, Player, Index), NX, NY),
    remove((Insect, Player, Index), AX, AY),
    unblocking(Insect, Player, Index, AX, AY),
    blocking(Insect, Player, Index, NX, NY).

retract_mov_insect_save((Insect, Player, Index), (AX, AY), (NX, NY)) :- 
    save((Insect, Player, Index), AX, AY),
    remove((Insect, Player, Index), NX, NY),
    unblocking(Insect, Player, Index, NX, NY),
    blocking(Insect, Player, Index, AX, AY).

unblocking(Insect, _, _, _, _) :- Insect \= beetle, !.
unblocking(Insect, Player, Index, _, _) :- Insect = beetle, not(dont_mov(_, (beetle, Player, Index))), !.
unblocking(Insect, Player, Index, _, _) :- 
    Insect = beetle, 
    dont_mov((BInsect, BPlayer,BIndex), (beetle, Player, Index)), !,
    retract(dont_mov((BInsect, BPlayer,BIndex), (beetle, Player, Index))).

blocking(Insect, _, _, _, _) :- Insect \= beetle, !.
blocking(Insect, _, _, X, Y) :- Insect \= beetle, not(insect_play(_, X, Y)), !.
blocking(Insect, Player, Index, X, Y) :- 
    Insect = beetle, 
    insect_play((BInsect, BPlayer, BIndex), X, Y), !,
    assert(dont_mov((BInsect, BPlayer, BIndex), (beetle, Player, Index))).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fail Condition Mov
mov_fail_condition((Insect, Index, Player), (AX, AY), (X, Y), Result) :- 
    queen_condition((Insect, Index, Player), (AX, AY), (X, Y), Result);
    bloking_condition((Insect, Index, Player), (AX, AY), (X, Y), Result);
    bussy_condition((Insect, Index, Player), (AX, AY), (X, Y), Result);
    connected_condition((Insect, Index, Player), (AX, AY), (X, Y), Result);
    grasshopper_lineal_condition((Insect, Index, Player), (AX, AY), (X, Y), Result);
    grasshopper_void_space_condition((Insect, Index, Player), (AX, AY), (X, Y), Result);
    spider_condition((Insect, Index, Player), (AX, AY), (X, Y), Result);
    ladybug_condition((Insect, Index, Player), (AX, AY), (X, Y), Result);
    mosquito_stoper_condition((Insect, Index, Player), (AX, AY), (X, Y), Result);
    mosquito_condition((Insect, Index, Player), (AX, AY), (X, Y), Result), !.

queen_condition((_, _, Player), _, _, Result) :-  
    list_all_insects List of Player,
    not(member((queen_bee, Player, 1), List)),
    Result = 'La reina ni ha sido colocad'.

bloking_condition((Insect, Index, Player), _, _, Result) :- 
    dont_mov((Insect, Player, Index), _), !,
    Result = 'La Pieza esta Bloqueada'.

connected_condition((Insect, Index, Player), (ActualX, ActualY), (X, Y), Result) :- 
    findall(n(FakerInsect, FakerPlayer, FakerIndex, FakerX, FakerY), 
            insect_play((FakerInsect, FakerPlayer, FakerIndex), FakerX, FakerY), 
            TempList),
    diff([n(Insect, Player, Index, ActualX, ActualY)], [n(Insect, Player, Index, X, Y)|TempList], FakerList),
    not(is_connected_component(FakerList)), !, Result = 'Mov Desconecta el Hive'. 

bussy_condition((Insect, _, _), _, (X, Y), Result) :- 
    Insect \= beetle, !,
    insect_play(_, X, Y), !, Result = 'Posicion Ocupada'. 

adj_condition((Insect, _, _), (ActualX, ActualY), (X, Y), Result) :- 
    (Insect = queen_bee; Insect = beetle; Insect = pill_bug), !, 
    not(adj_post(ActualX, ActualY, X, Y)), !, Result = 'Posicion No Adyacente'.

grasshopper_lineal_condition((grasshopper, _, _), (ActualX, ActualY), (X, Y), Result) :- 
    not(lineal_position((ActualX, ActualY), (X, Y), _)), !, Result = 'El Camino no es Lineal'.

grasshopper_void_space_condition((grasshopper, _, _), (ActualX, ActualY), (X, Y), Result) :- 
    lineal_position((ActualX, ActualY), (X, Y), Path), 
    findall(Card, (insect_play(Card, XP, YP), member((XP,YP), Path)), CardInLinea),
    length(Path, Length1), length(CardInLinea, Length2), Length1 \= Length2, !, Result = 'El Camino Tiene Huecos Vacios'.

spider_condition((spider, _, _), (ActualX, ActualY), (X, Y), Result) :- 
    findall(n(OtherX, OtherY),
    (
        insect_play(_, FakerX, FakerY), 
        adj_post(FakerX, FakerY, OtherX, OtherY), 
        not(insect_play(_,OtherX, OtherY))
    ),
    TempList), set_list(TempList, Set), !,
    not(bfs([n(ActualX, ActualY)| Set], (X, Y), 4)), !,
    Result = 'La posicion no se encontro disponible tres pasos mas alante'.  

art_condition((art, _, _), (ActualX, ActualY), (X, Y), Result) :- 
    findall(n(OtherX, OtherY),
    (
        insect_play(_, FakerX, FakerY), 
        adj_post(FakerX, FakerY, OtherX, OtherY), 
        not(insect_play(_,OtherX, OtherY))
    ),
    TempList), set_list(TempList, Set), !,
    not(bfs([n(ActualX, ActualY)| Set], (X, Y), -1)), !,
    Result = 'No se encontro camino posible'.  

ladybug_condition((ladybug, _, _), (ActualX, ActualY), (X, Y), Result) :- 
    findall(n(FakerX, FakerY), insect_play(_, FakerX, FakerY), FakerList),
    findall(n(AdjX, AdjY), 
        (
            adj_post(X, Y, AdjX, AdjY),
            bfs([n(ActualX, ActualY)| FakerList], (AdjX, AdjY), 3)
        ),
        AdjList
    ),
    length(AdjList, 0), !,
    Result = 'No se encontro camino sobre el Hive'.

mosquito_stoper_condition((mosquito, _, _), (ActualX, ActualY), _, Result) :- 
    findall(Insect, (adj_post(ActualX, ActualY, AdjX, AdjY), insect_play((Insect, _, _), AdjX, AdjY)), InsectList),
    not((member(InsectInList, InsectList), InsectInList \= mosquito)), !,
    Result = 'El mosquito solo tiene al lado a otro mosquito'. 

mosquito_condition((mosquito, _, Player), (ActualX, ActualY), (X, Y), Result) :- 
    findall(Insect, (adj_post(ActualX, ActualY, AdjX, AdjY), insect_play((Insect, _, _), AdjX, AdjY)), InsectList),
    not((
        member(InsectInList, InsectList), 
        InsectInList \= mosquito, 
        not(mov_fail_condition((InsectInList, _, Player), (ActualX, ActualY), (X, Y), _))
    )), !, Result = 'Ninguno de los adyacentes puede realizar ese movimiento'. 


mov((Insect, Player, Index), (ActualX, ActualY), (X, Y), Result) :- 
    mov_fail_condition((Insect, Index, Player), (ActualX, ActualY), (X, Y), Result), !. 

mov((Insect, Player, Index), (ActualX, ActualY),(X, Y), Result) :-
    not(mov_fail_condition((Insect, Index, Player), (ActualX, ActualY), (X, Y), Result)), !,
    mov_insect_save((Insect, Player, Index), (ActualX, ActualY), (X, Y)), 
    finish_play(Result).

