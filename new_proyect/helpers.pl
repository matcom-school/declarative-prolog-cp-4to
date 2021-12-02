:- module(playHelpers, [
    op(700, xfx, [play_played]),
    op(700, yf, [timess]),
    is_turn_of/1,
    finish_play/1
]).

:- use_module(find_by_table).
:- use_module(operators).

count_played([], _, 0).
count_played([Y|R], Player, N) :- is_from(Y, Player), !, count_played(R, Player, N1), N is N1 + 1.
count_played([Y|R], Player, N) :- not(is_from(Y, Player)), !, count_played(R, Player, N1), N is N1 .

X play_played N timess :- list_all_insects List, count_played(List, X, N).

is_turn_of(white) :- white play_played WN timess, black play_played BN timess, WN = BN, !.
is_turn_of(black) :- white play_played WN timess, black play_played BN timess, WN > BN, !.

finish_play(Result) :- Result = "Not finish".