:- module(findByTable, [
    op(700, fx, [list_all_insects]),
    op(700, yfx, [of]),
    list_all_insects/1,
    of/2,
    adj_list/3,
    adj_post/4,
    lineal_position/3, 
    finish_play/1,
    bfs/4,
    hive_bfs/4,
    get_all_insects/1,
    compute_queen_warning/2
]).

:- use_module(database).
:- use_module(list_helpers).

get_all_insects(List) :- 
    findall((Insect, X, Y), insect_play(Insect, X, Y), List).

list_all_insects List :- 
    findall((Insect, X, Y), insect_play(Insect, X, Y), List).

list_all_insects List of Player :- 
    findall((Insect, Player, Index), insect_play((Insect, Player, Index), _, _), List).

adj_post(X, Y, X0, Y0) :- 
    X_1 is X - 1, X1 is X + 1,
    Y_1 is Y - 1, Y1 is Y + 1,
    ( ( X = X0, Y_1 = Y0); 
      ( X_1 = X0, Y = Y0); 
      ( X_1 = X0, Y1 = Y0); 
      ( X = X0, Y1 = Y0); 
      ( X1 = X0, Y = Y0); 
      ( X1 = X0, Y_1 = Y0)).

adj_list(X, Y, List) :- 
    X_1 is X - 1, X1 is X + 1,
    Y_1 is Y - 1, Y1 is Y + 1,
    findall(Card, (
        insect_play( Card, X, Y_1); 
        insect_play( Card, X_1, Y);
        insect_play( Card, X_1, Y1);
        insect_play( Card, X,  Y1);
        insect_play( Card, X1,   Y);
        insect_play( Card, X1, Y_1)), List).

path_compute((TopX, TopY), (TopX, TopY), _, []). 
path_compute((_, OriginY), (_, TopY), (0, -1), _) :- OriginY < TopY, !, fail. 
path_compute((OriginX, _), (TopX, _), (-1, 0), _) :- OriginX < TopX, !, fail.
path_compute((OriginX, OriginY), (TopX, TopY), (-1, 1), _) :- OriginX < TopX, !, OriginY > TopY, !, fail. 
path_compute((_, OriginY), (_, TopY), (0, 1), _) :- OriginY > TopY , !, fail. 
path_compute((OriginX, _), (TopX, _), (1, 0), _) :- OriginX > TopX, !, fail.
path_compute((OriginX, OriginY), (TopX, TopY), (1, -1), _) :- OriginX > TopX, !, OriginY < TopY, !, fail. 
path_compute((OriginX, OriginY), (TopX, TopY), (FactorX, FactorY), Path):-
    NewX is OriginX + FactorX, NewY is OriginY + FactorY,
    path_compute((NewX, NewY), (TopX,TopY), (FactorX, FactorY), SubPath),
    concat([(NewX, NewY)], SubPath, Path).

lineal_position((X1, Y1), (X2, Y2), Path) :- 
    X1 > X2, !, Y1 < Y2, !, 
    DiffX is X1 - X2, DiffY is Y2 - Y1, DiffX = DiffY, !,
    path_compute((X1, Y1), (X2, Y2), (-1, 1), Path). 

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
bfs_d(_, [n(_, SubPath)|_], _, _, TopDeep) :- length(SubPath, SubLength), SubLength = TopDeep, !, fail.

bfs_d(Objective, [n((X, Y), SubPath)| NotVisited], Visited, Path, TopDeep) :- 
    length(SubPath, SubLength), 
    findall(n((NextX, NextY), [(NewX, NewY)|SubPath]), 
            (   adj_post(X, Y, NextX, NextY), not(insect_play(_, NextX, NextY)), !,
                adj_post(NewX, NewY, OtherX, OtherY), X \= OtherX, Y \= OtherY,  !, insect_play(_, OtherX, OtherY),
                \+ (member(n((NewX, NewY), SubPath2), NotVisited), length(SubPath2, SubLength)),
                \+ member((NewX, NewY), Visited)), 
            AdjListToStackPointer),
    append(NotVisited, AdjListToStackPointer, NewStack),
    bfs_d(Objective, NewStack, [(X,Y)|Visited], Path, TopDeep), !.



hive_bfs(Objective, Start, Path, TopDeep) :- 
    bfs_h(Objective, [n(Start, [])], [], R, TopDeep),
    reverse(R, Path).

bfs_h((OX, OY), [n((SX, SY), _)|_], V, V, _) :- adj_post(SX, SY, OX, OY).
bfs_h(_, [n(_, SubPath)|_], _, _, TopDeep) :- length(SubPath, SubLength), SubLength = TopDeep, !, fail.

bfs_h(Objective, [n((X, Y), SubPath)| NotVisited], Visited, Path, TopDeep) :- 
    length(SubPath, SubLength), 
    findall(n((NextX, NextY), [(NewX, NewY)|SubPath]), 
            (   adj_post(X, Y, NextX, NextY), insect_play(_, NextX, NextY)), !,
                \+ (member(n((NewX, NewY), SubPath2), NotVisited), length(SubPath2, SubLength)),
                \+ member((NewX, NewY), Visited), 
            AdjListToStackPointer),
    append(NotVisited, AdjListToStackPointer, NewStack),
    bfs_d(Objective, NewStack, [(X,Y)|Visited], Path, TopDeep), !.


finish_play(Result) :- not(finish_condition(_)), !, Result = 'Not finish'.
finish_play(Result) :- finish_condition(black), !, Result = 'finish: win white'.
finish_play(Result) :- finish_condition(white), !, Result = 'finish: win black'.

% finish_condition(_) :- not(insect_play((queen_bee, _, 1), _, _)), !.
finish_condition(Player) :- 
    insect_play((queen_bee, Player, 1), X, Y), !,
    other_player(Player, Other),
    findall((AdjInsectX, AdjInsectY), 
        ( insect_play((_, Other, _), AdjInsectX, AdjInsectY), 
          adj_post(X, Y, AdjInsectX, AdjInsectY) ), 
        InsectPostList),
    findall((AdjX, AdjY),  adj_post(X, Y, AdjX, AdjY), AdjList),
    append(AdjList, _, InsectPostList), !.

compute_queen_warning(Player, Result) :- not(insect_play((queen_bee, Player, 1), _, _)), Result = 0.1.
compute_queen_warning(Player, Result) :- 
    insect_play((queen_bee, Player, 1),X,Y), !,
    (
        (   finish_condition(Player), !, Result = 100 );
        (   other_player(Player, Other),
            findall((AdjX, AdjY), 
                (   insect_play((_, Other, _), AdjX, AdjY), 
                    adj_post(X, Y, AdjX, AdjY)
                ), FistDeepList),
            findall((Adj2X, Adj2Y), 
                (   insect_play((_, Other, _), Adj2X, Adj2Y), 
                    adj_post(X, Y, TempX, TempY), 
                    adj_post(TempX, TempY, Adj2X, Adj2Y),
                    X\=Adj2X, Y \= Adj2Y, 
                    not(member((Adj2X, Adj2Y), FistDeepList))
                ), SecondDeepList),
            length(FistDeepList, Len1), length(SecondDeepList, Len2),
            Result is Len1 + Len2 + 1
        )
    ).
