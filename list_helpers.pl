:- module(listHelpers, [
    op(710, xfy, [is_index_of, in]), 
    is_index_of/2
]).

0 is_index_of X in [X|_].
I is_index_of X in [_|R] :- I1 is_index_of X in R, I is I1 + 1.