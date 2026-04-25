-module(pollution).
-export([create_monitor/0, add_station/3, add_value/5, remove_value/4, get_one_value/4, get_station_min/3, get_daily_mean/3, get_maximum_gradient_station/2]).

-record(reading, {type, value, date}).
-record(station, {name, coords, readings=[]}).

create_monitor() -> [].

add_station(Name, Coords, Monitor) ->
    case {[S || S <- Monitor, S#station.name == Name],
          [S || S <- Monitor, S#station.coords == Coords]} of
        {[], []} -> [#station{name=Name, coords=Coords} | Monitor];
        {_, _} -> {error, "Station with this Name or Coords already exists!"}
    end.

add_value(Station_id, Date, Type, Value, Monitor) ->
    case [S || S <- Monitor, S#station.name == Station_id orelse S#station.coords == Station_id] of
        [] -> {error, "Given station doesn't exists!"};
        [Station] ->
            case [R || R <- Station#station.readings,
                       R#reading.type == Type,
                       R#reading.date == Date] of
                [] -> New_reading = #reading{type=Type, value=Value, date=Date},
                      lists:map(
                        fun(S) when S == Station -> S#station{readings = [New_reading | S#station.readings]};
                           (S) -> S end,
                        Monitor);
                _ -> {error, "Given station already has this reading!"}
            end
    end.

remove_value(Station_id, Date, Type, Monitor) ->
    case [S || S <- Monitor, S#station.name == Station_id orelse S#station.coords == Station_id] of
        [] -> {error, "Given station doesn't exists!"};
        [Station] ->
            case [R || R <- Station#station.readings,
                       R#reading.type == Type,
                       R#reading.date == Date] of
                [] -> {error, "Given station doesn't have this reading!"};
                _ -> lists:map(
                       fun(S) when S == Station ->
                               New_readings = lists:filter(
                                 fun(R) when R#reading.date == Date, R#reading.type == Type -> false;
                                    (_) -> true
                                 end,
                                 S#station.readings),
                               S#station{readings=New_readings};
                          (S) -> S
                                 end,

                      Monitor)
            end
    end.

get_one_value(Station_id, Type, Date, Monitor) ->
    case [S || S <- Monitor, S#station.name == Station_id orelse S#station.coords == Station_id] of
        [] -> {error, "Given station doesn't exists!"};
        [Station] ->
            case [R || R <- Station#station.readings,
                       R#reading.type == Type,
                       R#reading.date == Date] of
                [] -> {error, "Given station doesn't have this reading!"};
                [R] -> R#reading.value
            end
    end.


get_station_min(Station_id, Type, Monitor) ->
    case [S || S <- Monitor, S#station.name == Station_id orelse S#station.coords == Station_id] of
        [] -> {error, "Given station doesn't exists!"};
        [Station] ->
            case [R#reading.value || R <- Station#station.readings,
                       R#reading.type == Type] of
                [] -> {error, "Given station doesn't have this type of reading!"};
                Values -> lists:min(Values)
            end
    end.

get_daily_mean(Type, Day, Monitor) ->
    Readings = [S#station.readings || S <- Monitor],
    Readings_flat = lists:foldr(fun(R, Acc) -> Acc ++ R end, [], Readings),
    Readings_filtered = lists:filter(
                          fun(#reading{date={D, _}, type=T}) when D == Day, T ==Type -> true;
                             (_) -> false
                          end,
                          Readings_flat),
    Values = [R#reading.value || R <- Readings_filtered],
    case length(Values) of
        0 -> {error, "No readings found"};
        _ -> {Sum, Cnt} = lists:foldr(fun(V, {S, C}) -> {S+V, C+1} end, {0, 0}, Values),
             Sum/Cnt
    end.

calc_gradient({V1, D1}, {V2, D2}) ->
   V_delta = abs(V2 - V1),
   T_delta = calendar:datetime_to_gregorian_seconds(D2) - calendar:datetime_to_gregorian_seconds(D1),
   V_delta/T_delta.

find_max_gradient(List) -> find_max_gradient(List, 0).
find_max_gradient([R1, R2 | T], Max_gradient) ->
    Gradient = calc_gradient({R1#reading.value, R1#reading.date}, {R2#reading.value, R2#reading.date}),
    New_max = max(Gradient, Max_gradient),
    find_max_gradient([R2 | T], New_max);
find_max_gradient(_, Max_gradient) -> Max_gradient.


get_maximum_gradient_station(Type, Monitor) ->
    Gradients = [{S, find_max_gradient(lists:keysort(#reading.date, [R || R <- S#station.readings, R#reading.type == Type]))} || S <- Monitor],
    lists:foldr(fun({S, G}, {_, G_max}) when G > G_max -> {S, G};
                   (_, {S_max, G_max}) -> {S_max, G_max} end,
                {none, 0}, Gradients).

