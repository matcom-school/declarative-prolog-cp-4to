:- module(listHelpers, [
    op(710, xfy, [is_index_of, in, has, of, compose_by]),
    compose_by/2,
    has/2, 
    is_index_of/2,
    contain/2,
    diff/3,
    concat/3,
    get_circular_value/2
]).

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