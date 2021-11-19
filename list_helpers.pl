:- module(listHelpers, [
    op(710, xfy, [is_index_of, in, has, of]), 
    is_index_of/2
]).

0 is_index_of X in [X|_].
I is_index_of X in [_|R] :- I1 is_index_of X in R, I is I1 + 1.

[Item] has 1 of Item.
[Item|R] has Count of Item :- 
    R has LetterCount of Item,
    Count is LetterCount + 1.

concat([], L, L).
concat([X|L1], L2, [X|L3]) :- concat(L1, L2, L3).


