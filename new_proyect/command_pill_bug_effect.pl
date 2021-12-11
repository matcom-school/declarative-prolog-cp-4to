:- module(pillBugEffect, [
    mov_by_pill_bug/5,
    pill_bug_fail_condition/9
]).

:- use_module(command_mov_insect).
:- use_module(find_by_table).
:- use_module(database).

pill_bug_fail_condition(Player, Insect, Other, Index, AX, AY, X, Y, Result) :- 
    pill_bug_adj_condition(Player, AX, AY, X, Y, Result);
    bussy_pill_bug_condition(X, Y, Result);
    dont_mov_condition(Insect, Other, Index, Result);
    connected_condition((Insect, Other, Index), (AX, AY), (X, Y), Result);
    last_insect_condition(Player, Other, Insect, Index, Result), !.

pill_bug_adj_condition(Player, AX, AY, X, Y, Result) :- 
    not(
        ( 
            adj_post(AX, AY, AdjX, AdjY), adj_post(AdjX, AdjY, X, Y),
            (
               ( 
                   insect_play((pill_bug, Player, 1), AdjX, AdjY), 
                   not(dont_mov_condition(pill_bug, Player, 1, _)) 
                );
               ( 
                    insect_play((mosquito, Player, 1), AdjX, AdjY),
                    not(dont_mov_condition(mosquito, Player, 1, _)),
                    adj_post(AdjX, AdjY, Adj2X, Adj2Y),
                    insect_play((ladybug, _, 1), Adj2X, Adj2Y)
                )
            )
        )
    ), !, Result = 'No hay bicho bola entre las posiciones señaladas'.

bussy_pill_bug_condition(X, Y, Result) :-
    insect_play(_, X, Y),!, Result = 'Posicion Ocupada'.

dont_mov_condition(Insect, Player, Index, Result) :- 
    (dont_mov(_, (Insect, Player, Index)); dont_mov((Insect, Player, Index), _)), !,
    Result = 'No puede mover insectos apilados'.

last_insect_condition(ByPLayer, Player, Insect, Index, Result) :- 
    other_player(ByPLayer, Player), !,
    last((Insect, Player, Index), _, _), !, Result = 'No puede mover la ultima jugada del oponente'.

mov_by_pill_bug(ByPLayer, (Insect, Player, Index), (AX, AY), (X, Y), Result) :- 
    pill_bug_fail_condition(ByPLayer, Insect, Player, Index, AX, AY, X, Y, Result), !.

mov_by_pill_bug(ByPLayer, (Insect, Player, Index), (AX, AY), (X, Y), Result) :-
    not(pill_bug_fail_condition(ByPLayer, Insect, Player, Index, AX, AY, X, Y, Result)), !,
    mov_insect_save((Insect, Player, Index), (AX, AY), (X, Y)), 
    assert(dont_mov((Insect, Player, Index), ByPLayer)),
    finish_play(Result).