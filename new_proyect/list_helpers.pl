:- module(listHelpers, [
    op(710, xfy, [is_index_of, in, has, of, compose_by]),
    compose_by/2,
    has/2, 
    is_index_of/2,
    contain/2,
    diff/3,
    concat/3,
    get_circular_value/2,
    is_connected_component/1,
    bfs/3,
    set_list/2
]).

:- use_module(find_by_table).

0 is_index_of X in [X|_].
I is_index_of X in [_|R] :- I1 is_index_of X in R, I is I1 + 1.

[Item] has 1 of Item.
[Item|R] has Count of Item :-
    Count1 is Count - 1,
    Count1 > 0, !,
    R has Count1 of Item, !.  

concat([], L, L).
concat([X|L1], L2, [X|L3]) :- concat(L1, L2, L3).

contain(_, []) :- fail, !.
contain(X, [X, _]).
contain(X, [_|R]) :- contain(X, R).

compose_by([], []).
compose_by([AList|R], List) :- compose_by(R, RList), concat(AList, RList, List).

remove(_, [], []).
remove(X, [X|List], List).
remove(X, [Y|List], [Y|ListResult]) :- X \= Y, !, remove(X, List, ListResult).

diff([], L, L).
diff([X|RList], List, ListResult) :- remove(X, List, RemoveList), diff(RList, RemoveList, ListResult).

get_circular_value(Index, Value) :- TrueIndex is Index mod 6, TrueIndex is_index_of Value in [0,1,2,3,4,5]. 

set_list([], []).
set_list([X|List], Set) :- member(X, List), !, set_list(List, Set). 
set_list([X|List], [X|Set]) :- not(member(X, List)), !, set_list(List, Set). 

is_connected_component([X|List]) :-
    aux_connected_component(List, [X]).

aux_connected_component(List, []) :- length(List, Len), Len = 0.
aux_connected_component(List, [n(SInsect, SPlayer, SIndex, X, Y)| Queue]) :-
    findall(n(Insect, Player, Index, AX, AY), (
        member(n(Insect, Player, Index, AX, AY), List), 
        adj_post(X, Y, AX, AY),
        not(member(n(Insect, Player, Index, AX, AY), Queue)) 
    ), ListPushedToQueue),
    append(Queue, ListPushedToQueue, NewQueue),
    diff([n(SInsect, SPlayer, SIndex, X, Y)], List, NewList),
    aux_connected_component(NewList, NewQueue).

bfs([S| List], (X, Y), Deep) :- 
    aux_bfs(List, [(S, [])], n(X,Y), Deep).

aux_bfs(_, [ (Objective, _) |_], Objective, _).
aux_bfs(_, [ (_, SubPath) |_], _, Deep) :- length(SubPath, Deep), !, fail.
aux_bfs(List, [ (n(X, Y), SubPath) | Queue ], Objective, Deep) :- 
    findall( (n(AX, AY), [n(X, Y)| SubPath]) , (
        member(n(AX, AY), List), adj_post(X, Y, AX, AY),
        not(member((n(AX, AY), _), Queue)) 
    ), ListPushedToQueue),
    append(Queue, ListPushedToQueue, NewQueue),
    diff([n(X, Y)], List, NewList),
    % writeln(NewQueue), writeln(Objective),
    aux_bfs(NewList, NewQueue, Objective, Deep), !.