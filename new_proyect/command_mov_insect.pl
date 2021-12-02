:- module(movInsect, []).

:- use_module(operators).
:- use_module(find_by_table).
:- use_module(database).

mov_fail_condition(Insect, Index, Player, X, Y, Result) :-
    list_all_insects List of Player, not(member((queen_bee, 1), List))
    Result is 'La reina ni ha sido colocad'.

mov_insect (Insect, Index) by Player from (AX, AY) to (NX, NY) wih Result :- 
    save((Insect, Player, Index), NX, NY),
    remove((Insect, Player, Index), AX, AY), 
    finish_play(Result).

mov_insect (queen_bee, Index) by Player of_index (X, Y) wish Result :- 
    not(mov_fail_condition(queen_bee, Index, Player, X, Y, Result)), !, 
    not(insect_play(_, X, Y)), !, 
    insect_play((queen_bee, Player, Index), ActualX, ActualY),
    adj_post((ActualX, ActualY), X, Y), !,
    mov_insect (queen_bee, Index) by Player from (ActualX, ActualY) to (X, Y) with Result.

mov_insect (beetle, Index) by Player of_index (X, Y) wish Result :- 
    not(mov_fail_condition(beetle, Index, Player, X, Y, Result)), !, 
    insect_play((beetle, Player, Index), ActualX, ActualY),
    adj_post((ActualX, ActualY), X, Y), !,
    mov_insect (beetle, Index) by Player from (ActualX, ActualY) to (X, Y) with Result.

mov_insect (grasshopper, Index) by Player of_index (X, Y) wish Result :-
    not(mov_fail_condition(grasshopper, Index, Player, X, Y, Result)), !, 
    insect_play((grasshopper, Player, Index), ActualX, ActualY),
    lineal_position((ActualX, ActualY), (X, Y), Path), !,
    findall(Card, (insect_play(Card, XP, YP), member((XP,YP), Path)), CardInLinea),
    length(Path, Length1), length(CardInLinea, Length2), Length1 = Length2, !,
    mov_insect (beetle, Index) by Player from (ActualX, ActualY) to (X, Y) with Result.

mov_insect (spider, Index) by Player, of_index, (X, Y) with Result :- 
    not(mov_fail_condition(spider, Index, Player, X, Y, Result)), !,
    insect_play((spider, Player, Index), ActualX, ActualY),
    bfs((X, Y), (ActualX, ActualY), Path, 4), !,
    mov_insect (spider, Index) by Player from (ActualX, ActualY) to (X, Y) with Result.

mov_insect (art, Index) by Player, of_index, (X, Y) with Result :- 
    not(mov_fail_condition(art, Index, Player, X, Y, Result)), !,
    insect_play((art, Player, Index), ActualX, ActualY),
    bfs((X, Y), (ActualX, ActualY), Path, -1), !,
    mov_insect (art, Index) by Player from (ActualX, ActualY) to (X, Y) with Result.