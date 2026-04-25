-module(myLists).

-export([contains/2, duplicate_elements/1, sum_floats/1, sum_floats2/1]).

contains([], _) -> false;
contains([V|_], V) -> true;
contains([_|T], V) -> contains(T, V).

duplicate_elements([]) -> [];
duplicate_elements([H|T]) -> [H, H|duplicate_elements(T)].

sum_floats([]) -> 0;
sum_floats([H|T]) when is_float(H) ->
    H + sum_floats(T);
sum_floats([_|T]) ->
    sum_floats(T).

sum_floats2(L) ->
    sum_floats2(L, 0.0).
sum_floats2([], A) -> A;
sum_floats2([H|T], A) when is_float(H) ->
    sum_floats2(T, A+H);
sum_floats2([_|T], A) ->
    sum_floats2(T, A).
