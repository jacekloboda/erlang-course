-module(pingpong).
-export([ping_loop/1, pong_loop/0, start/0, stop/0, play/1]).

ping_loop(Sum) ->
    receive
        stop -> ok;
        0 -> io:format("ping 0~n"),
             pong_loop();
        N -> io:format("ping ~w, ~w~n", [N, Sum+N]),
             timer:sleep(1000),
             pong ! N-1,
             ping_loop(Sum+N)
    after
        20000 -> io:format("ping has reached timeout~n")
    end.

pong_loop() ->
    receive
        stop -> ok;
        0 -> io:format("pong 0~n"),
             pong_loop();
        N -> io:format("pong ~w~n", [N]),
             timer:sleep(1000),
             ping ! N-1,
             pong_loop()
    after
        20000 -> io:format("pong has reached timeout~n")
    end.

start() ->
    register(ping, spawn(pingpong, ping_loop, [0])),
    register(pong, spawn(pingpong, pong_loop, [])).

stop() ->
    spawn(fun() -> ping ! stop end),
    spawn(fun() -> pong ! stop end).

play(N) ->
    ping ! N.
