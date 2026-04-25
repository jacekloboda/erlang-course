-module(qsort).
-export([qs/1, data/0, sort_lists/1, qs_proc/2, receiver/0, random_elems/3, sort_lists_proc/1]).

random_elems(N, Min, Max) ->
    [rand:uniform(Max - Min + 1) + Min - 1 || _<-lists:seq(1, N)].

data() ->
    [random_elems(10000, 1, 10000) || _ <- lists:seq(1, 1000)].


less_than(List, Arg) -> [V || V<-List, V<Arg].

grt_eq_than(List, Arg) -> [V || V<-List, V>=Arg].

qs([]) -> [];
qs([Pivot|Tail]) ->
    qs(less_than(Tail, Pivot)) ++ [Pivot] ++ qs(grt_eq_than(Tail, Pivot)).

sort_lists(LL) ->
    [qs(L) || L <- LL].

qs_proc(L, PID) ->
    PID ! qs(L).

receiver() -> receiver([], 0).
receiver(LL, Cnt) ->
    receive
        L -> io:format("Received ~w~n", [Cnt]),
        receiver([LL | L], Cnt+1)
    after
        5000 -> io:format("Reached timeout~n")
    end.

sort_lists_proc(LL) ->
    register(rec, spawn(qsort, receiver, [])),
    lists:foreach(fun(L) -> spawn(qsort, qs_proc, [L, rec]) end, LL).

