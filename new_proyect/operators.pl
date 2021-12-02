:- module(playOperatos, [
    op(700, yfx, [by, of_index, with]),
    get_player/2,
    is_from/2
]).

get_player((_,Player,_), Player).
is_from(Y, X) :- Y = (_, X).