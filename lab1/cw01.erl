-module(cw01).
-export([power/2]).

power(A, B) ->
    case B of
        0 -> 1;
        _ -> A * power(A, B-1)
    end.
