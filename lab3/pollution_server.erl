-module(pollution_server).
-export([start/0, stop/0, init/0, add_station/2, add_value/4, remove_value/3, get_one_value/3, get_station_min/2, get_daily_mean/2, get_maximum_gradient_station/1]).

start() ->
    register(server, spawn(?MODULE, init, [])).

stop() ->
    call_server(stop).

add_station(Name, Coords) ->
    call_server({add_st, Name, Coords}).

add_value(Station_id, Date, Type, Value) ->
    call_server({add_val, Station_id, Date, Type, Value}).

remove_value(Station_id, Date, Type) ->
    call_server({rem_val, Station_id, Date, Type}).

get_one_value(Station_id, Type, Date) ->
    call_server({one_val, Station_id, Type, Date}).

get_station_min(Station_id, Type) ->
    call_server({st_min, Station_id, Type}).

get_daily_mean(Type, Day) ->
    call_server({daily_mean, Type, Day}).

get_maximum_gradient_station(Type) ->
    call_server({max_grad, Type}).

call_server(Message) ->
    server ! {request, self(), Message},
    receive
        {reply, Reply} -> Reply
    after
        60000 -> server_not_responsive
    end.

init() ->
    M = pollution:create_monitor(),
    server(M).

new_state({error, Msg}, M, Pid) ->
    Pid ! {reply, {error, Msg}},
    server(M);
new_state(NewM, _, Pid) ->
    Pid ! {reply, ok},
    server(NewM).

server(M) ->
    receive
        {request, Pid, stop} ->
            Pid ! {reply, ok};

        {request, Pid, {add_st, Name, Coords}} ->
            new_state(pollution:add_station(Name, Coords, M), M, Pid);

        {request, Pid, {add_val, Station_id, Date, Type, Value}} ->
            new_state(pollution:add_value(Station_id, Date, Type, Value, M), M, Pid);

        {request, Pid, {rem_val, Station_id, Date, Type}} ->
            new_state(pollution:remove_value(Station_id, Date, Type, M), M, Pid);

        {request, Pid, {one_val, Station_id, Type, Date}} ->
            Res = pollution:get_one_value(Station_id, Type, Date, M),
            Pid ! {reply, Res},
            server(M);

        {request, Pid, {st_min, Station_id, Type}} ->
            Res = pollution:get_station_min(Station_id, Type, M),
            Pid ! {reply, Res},
            server(M);

        {request, Pid, {daily_mean, Type, Day}} ->
            Res = pollution:get_daily_mean(Type, Day, M),
            Pid ! {reply, Res},
            server(M);

        {request, Pid, {max_grad, Type}} ->
            Res = pollution:get_maximum_gradient_station(Type, M),
            Pid ! {reply, Res},
            server(M)
    after
        3600000 -> io:format("Server reached timeout~n")
    end.
