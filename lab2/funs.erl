-module(funs).
-export([fun1/1, fun2/1, fun2_/1, fun3/1]).

data() ->
    P1 = {"miernik1", {1.23, 4.3}, {12, 8, 2026}, {12, 45, 8}, [{"pm1", 5.0}, {"pm2", 12.0}]},
    P2 = {"miernik2", {3.21, 5.6}, {12, 8, 2026}, {11, 15, 3}, [{"pm1", 6.0}, {"pm3", 4.0}, {"pm4", 2.0}]},
    P3 = {"miernik1", {1.23, 4.3}, {12, 8, 2026}, {13, 10, 0}, [{"pm1", 4.0}, {"pm2", 15.0}]},
    P4 = {"miernik3", {52.1, 21.0}, {12, 8, 2026}, {09, 30, 15}, [{"pm10", 25.0}, {"so2", 2.0}]},
    P5 = {"miernik2", {3.21, 5.6}, {13, 8, 2026}, {08, 00, 0}, [{"pm1", 8.0}, {"pm3", 5.0}]},
    P6 = {"miernik4", {18.4, 19.2}, {13, 8, 2026}, {10, 20, 45}, [{"no2", 14.0}, {"o3", 30.0}]},
    P7 = {"miernik1", {1.23, 4.3}, {13, 8, 2026}, {15, 55, 12}, [{"pm1", 3.0}, {"pm2", 10.0}]},
    P8 = {"miernik5", {44.5, 11.2}, {14, 8, 2026}, {07, 15, 0}, [{"pm10", 40.0}, {"pm2.5", 18.0}]},
    P9 = {"miernik3", {52.1, 21.0}, {14, 8, 2026}, {12, 00, 0}, [{"pm10", 22.0}, {"so2", 1.0}]},
    P10 = {"miernik2", {3.21, 5.6}, {15, 8, 2026}, {18, 30, 20}, [{"pm1", 7.0}, {"pm4", 3.0}]},

    [P1, P2, P3, P4, P5, P6, P7, P8, P9, P10].

fun1(List) ->
    Swapper = fun($o) -> $a;
                 ($e) -> $o;
                 (A) -> A
              end,
    lists:map(Swapper, List).

fun2(List) ->
    Check = fun(V) when V rem 3 == 0 -> true;
               (_) -> false
            end,
    length(lists:filter(Check, List)).

fun2_(List) ->
    Sum = fun(V, S) when V rem 3 == 0 -> S + 1;
             (_, S) -> S
          end,
    lists:foldr(Sum, 0, List).


fun3(Type) -> fun3(data(), Type).
fun3(Readings, Type) ->
    Readings_a = lists:map(fun({_, _, _, _, V}) -> V end, Readings),
    Readings_b = lists:foldl(fun(List, Acc) -> Acc ++ List end, [], Readings_a),
    Readings_c = [V || {T, V} <- Readings_b, T == Type],
    lists:sum(Readings_c)/length(Readings_c).
