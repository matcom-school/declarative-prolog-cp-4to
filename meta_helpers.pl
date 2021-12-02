connected(1,7,2).
connected(1,8,1).
connected(1,3,1).
connected(7,4,1).
connected(7,20,3).
connected(7,17,1).
connected(8,6,1).
connected(3,9,1).
connected(3,12,1).
connected(9,19,1).
connected(4,42,1).
connected(20,28,4).
connected(17,10,1).

connected2(X,Y,D) :- connected(X,Y,D).
connected2(X,Y,D) :- connected(Y,X,D).

next_node(Current, Next, Path) :-
    connected2(Current, Next, _),
    not(member(Next, Path)).


bfs(Objective, Start, Path) :- 
    bfs_d(Objective, [n(Start, [])], [], R),
    reverse(R, Path).

bfs_d(Objective, [n(Objective, _)|_], V, V).
bfs_d(Objective, [n(StackPointer, SubPath)| NotVisited], Visited, Path) :- 
    length(SubPath, SubLength), 
    findall(n(AdjToStackPointer, [Edge|SubPath]), 
            (   connected2(StackPointer, AdjToStackPointer, Edge),
                \+ (member(n(AdjToStackPointer, SubPath2), NotVisited), length(SubPath2, SubLength)),
                \+ member(AdjToStackPointer, Visited)), 
            AdjListToStackPointer),
    append(NotVisited, AdjListToStackPointer, NewStack),
    bfs_d(Objective, NewStack, [StackPointer|Visited], Path).

