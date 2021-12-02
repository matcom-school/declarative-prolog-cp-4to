:- module(findByTable, [
    op(700, fx, [list_all_insects]),
    op(700, yfx, [of]),
    list_all_insects/1,
    of/2,
    adj_list/3,
    lineal_position/3
]).

:- use_module(database).
:- use_module(list_helpers).

list_all_insects List :- 
    findall((Insect, X, Y), insect_play(Insect, X, Y), List).

list_all_insects List of Player :- 
    findall((Insect, Index), insect_play((Insect, Player, Index), _, _), List).


adj_list(X, Y, List) :- 
    X_1 is X - 1, X1 is X + 1,
    Y_1 is Y - 1, Y1 is Y + 1,
    findall(Card, (
        insect_play( Card, X_1, Y_1); 
        insect_play( Card, X_1, Y);
        insect_play( Card, X, Y_1);
        insect_play( Card, X, Y1);
        insect_play( Card, X1, Y_1);
        insect_play( Card, X1, Y)), List).

path_compute((TopX, TopY), (TopX, TopY), _, []). 
path_compute((OriginX, OriginY), (TopX, TopY), (FactorX, FactorY), Path):-
    NewX is OriginX + FactorX, NewY is OriginY + FactorY,
    path_compute((NewX, NewY), (TopX,TopY), (FactorX, FactorY), SubPath),
    concat([NewX, NewY], SubPath, Path).

lineal_position((X1, Y1), (X2, Y2), Path) :- 
    X1 > X2, !, Y1 > Y2, !, 
    DiffX is X1 - X2, DiffY is Y1 - Y2, DiffX = DiffY, !,
    path_compute((X1, Y1), (X2, Y2), (-1, -1), Path). 

lineal_position((X1, Y1), (X2, Y2), Path) :- 
    X1 > X2, !, Y1 = Y2, !, 
    path_compute((X1, Y1), (X2, Y2), (-1, 0), Path). 

lineal_position((X1, Y1), (X2, Y2), Path) :- 
    X1 = X2, !, Y1 > Y2, !, 
    path_compute((X1, Y1), (X2, Y2), (0, -1), Path). 

lineal_position((X1, Y1), (X2, Y2), Path) :- 
    X1 < X2, !, Y1 > Y2, !, 
    DiffX is X2 - X1, DiffY is Y1 - Y2, DiffX = DiffY, !,
    path_compute((X1, Y1), (X2, Y2), (1, -1), Path). 

lineal_position((X1, Y1), (X2, Y2), Path) :- 
    X1 < X2, !, Y1 = Y2, !, 
    path_compute((X1, Y1), (X2, Y2), (1, 0), Path). 

lineal_position((X1, Y1), (X2, Y2), Path) :- 
    X1 = X2, !, Y1 < Y2, !, 
    path_compute((X1, Y1), (X2, Y2), (0, 1), Path). 

bfs(Objective, Start, Path, TopDeep) :- 
    bfs_d(Objective, [n(Start, [])], [], R, TopDeep),
    reverse(R, Path).

bfs_d(Objective, [n(Objective, _)|_], V, V, _).
bfs_d(_, [n(_, SubPath)|_], _, _, TopDeep) :- length(SubPath, SubLength), SubLength > TopDeep, !, fail, !.

bfs_d(Objective, [n((X, Y), SubPath)| NotVisited], Visited, Path, TopDeep) :- 
    length(SubPath, SubLength), 
    findall(n((NextX, NextY), [(NewX, NewY)|SubPath]), 
            (   adj_list(X, Y, AdjList), member((NextX, NextY), AdjList), 
                adj_list(NewX, NewY, NewAdjList), member((OtherX, OtherY), NewAdjList), 
                insect_play(_, OtherX, OtherY),
                \+ (member(n((NewX, NewY), SubPath2), NotVisited), length(SubPath2, SubLength)),
                \+ member((NewX, NewY), Visited)), 
            AdjListToStackPointer),
    append(NotVisited, AdjListToStackPointer, NewStack),
    bfs_d(Objective, NewStack, [(X,Y)|Visited], Path, TopDeep), !.