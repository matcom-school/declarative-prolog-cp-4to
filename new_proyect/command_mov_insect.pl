:- module(movInsect, [
    op(700, fx, [mov_insect]),
    op(700, yfx, [from, to, by, with]),
    mov/3
]).

% :- use_module(operators).
:- use_module(list_helpers).
:- use_module(find_by_table).
:- use_module(database).
:- use_module(helpers).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% General Mov
mov_insect_save( (Insect, Player, Index), (AX, AY), (NX, NY), Result) :- 
    save((Insect, Player, Index), NX, NY),
    remove((Insect, Player, Index), AX, AY), 
    finish_play(Result).

mov_fail_condition(_, _, Player, _, _, Result) :- 
    list_all_insects List of Player,
    not(member((queen_bee, Player, 1), List)),
    Result = 'La reina ni ha sido colocad'.

mov_fail_condition(Insect, Index, Player, _, _, Result) :- 
    not(insect_play((Insect, Player, Index), _, _)), !,
    Result = 'Error de Localizacion'.

mov_fail_condition(Insect, Index, Player, X, Y, Result) :- 
    insect_play((Insect, Player, Index), AX, AY), !,
    findall(n(FakerInsect, FakerPlayer, FakerIndex, FakerX, FakerY), 
            insect_play((FakerInsect, FakerPlayer, FakerIndex), FakerX, FakerY), 
            TempList),
    diff([n(Insect, Player, Index, AX, AY)], [n(Insect, Player, Index, X, Y)|TempList], FakerList),
    not(is_connected_component(FakerList)), !, Result = 'Mov Desconecta el Hive'. 


mov((Insect, Player, Index), (X, Y), Result) :- 
    mov_fail_condition(Insect, Index, Player, X, Y, Result). 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Queen Mov
mov((queen_bee, Player, 1), (X, Y), Result) :- 
    not(mov_fail_condition(queen_bee, 1, Player, X, Y, Result)), !,
    mov_queen(Player, X, Y, Result). 

queen_fail_condition(_, X, Y, Result) :- 
    insect_play(_, X, Y), !, Result = 'Posicion Ocupada'. 

queen_fail_condition(Player, X, Y, Result) :- 
    insect_play((queen_bee, Player, 1), ActualX, ActualY), 
    not(adj_post(ActualX, ActualY, X, Y)), !, Result = 'Posicion No Adyacente'.

mov_queen(Player, X, Y, Result) :- queen_fail_condition(Player, X, Y, Result).
mov_queen(Player, X, Y, Result) :- not(queen_fail_condition(Player, X, Y, Result)), 
    insect_play((queen_bee, Player, 1), ActualX, ActualY), 
    mov_insect_save((queen_bee, Player, 1), (ActualX, ActualY), (X, Y), Result).
   


% mov_insect (beetle, Index) by Player of_index (X, Y) with Result :- 
%     not(mov_fail_condition(beetle, Index, Player, X, Y, Result)), !, 
%     insect_play((beetle, Player, Index), ActualX, ActualY),
%     adj_post((ActualX, ActualY), X, Y), !,
%     mov_insect (beetle, Index) by Player from (ActualX, ActualY) to (X, Y) with Result.

% mov_insect (grasshopper, Index) by Player of_index (X, Y) with Result :-
%     not(mov_fail_condition(grasshopper, Index, Player, X, Y, Result)), !, 
%     insect_play((grasshopper, Player, Index), ActualX, ActualY),
%     lineal_position((ActualX, ActualY), (X, Y), Path), !,
%     findall(Card, (insect_play(Card, XP, YP), member((XP,YP), Path)), CardInLinea),
%     length(Path, Length1), length(CardInLinea, Length2), Length1 = Length2, !,
%     mov_insect (beetle, Index) by Player from (ActualX, ActualY) to (X, Y) with Result.

% mov_insect (spider, Index) by Player of_index (X, Y) with Result :- 
%     not(mov_fail_condition(spider, Index, Player, X, Y, Result)), !,
%     insect_play((spider, Player, Index), ActualX, ActualY),
%     bfs((X, Y), (ActualX, ActualY), _, 4), !,
%     mov_insect (spider, Index) by Player from (ActualX, ActualY) to (X, Y) with Result.

% mov_insect (art, Index) by Player of_index (X, Y) with Result :- 
%     not(mov_fail_condition(art, Index, Player, X, Y, Result)), !,
%     insect_play((art, Player, Index), ActualX, ActualY),
%     bfs((X, Y), (ActualX, ActualY), _, -1), !,
%     mov_insect (art, Index) by Player from (ActualX, ActualY) to (X, Y) with Result.