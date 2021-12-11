:- module(playHelpers, [
    op(700, xfx, [play_played]),
    op(700, yf, [timess]),
    get_density/2,
    exclude_index/2,
    map/3
]).

:- use_module(find_by_table).
:- use_module(operators).

count_played([], _, 0).
count_played([Y|R], Player, N) :- is_from(Y, Player), !, count_played(R, Player, N1), N is N1 + 1.
count_played([Y|R], Player, N) :- not(is_from(Y, Player)), !, count_played(R, Player, N1), N is N1 .


get_density(n(_,_,_,_,_,D), Density) :- Density = D. 
exclude_index(((Insect, Player, _), X, Y ), (Insect, Player, X, Y)).

map(_,[],[]).
map(F,[X|Y],[V|R]):- T =..[F,X,V], call(T), map(F,Y,R).