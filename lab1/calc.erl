-module(calc).

-export([data/0, number_of_readings/2, calculate_min_and_max/2, calculate_mean/2]).

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

number_of_readings(Readings, Date) ->
    number_of_readings(Readings, Date, 0).
number_of_readings([], _, Cnt) -> Cnt;
number_of_readings([{_, _, Date, _, _}|T], Date, Cnt) ->
    number_of_readings(T, Date, Cnt+1);
number_of_readings([_|T], Date, Cnt) ->
    number_of_readings(T, Date, Cnt).

read_value([], _) -> -1;
read_value([{Type, Value}|_], Type) -> Value;
read_value([_|T], Type) -> read_value(T, Type).

min_and_max(Value, {-1, -1}) ->
    {Value, Value};
min_and_max(Value, {Min, Max}) ->
    {min(Value, Min), max(Value, Max)}.

calculate_min_and_max(Readings, Type) ->
    calculate_min_and_max(Readings, Type, {-1, -1}).
calculate_min_and_max([], _, {-1, -1}) ->
    type_not_existing;
calculate_min_and_max([] , _, Min_Max) ->
    Min_Max;
calculate_min_and_max([{_, _, _, _, Values}|T], Type, Min_Max) ->
    case read_value(Values, Type) of
        -1 -> calculate_min_and_max(T, Type, Min_Max);
        Value -> calculate_min_and_max(T, Type, min_and_max(Value, Min_Max))
    end.

calculate_mean(Readings, Type) ->
    calculate_mean(Readings, Type, 0, 0).
calculate_mean([], _, 0, 0) ->
    type_not_existing;
calculate_mean([], _, Sum, Cnt) ->
    Sum/Cnt;
calculate_mean([{_, _, _, _, Values}|T], Type, Sum, Cnt) ->
    case read_value(Values, Type) of
        -1 -> calculate_mean(T, Type, Sum, Cnt);
        Value -> calculate_mean(T, Type, Sum+Value, Cnt+1)
    end.

