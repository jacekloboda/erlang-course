%%%-------------------------------------------------------------------
%%% @author jacekloboda
%%% @copyright (C) 2026, <COMPANY>
%%% @doc
%%% @end
%%%-------------------------------------------------------------------
-module(pol_gen_ser).

-behaviour(gen_server).

-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2,
  code_change/3]).

-define(SERVER, ?MODULE).

-record(pol_gen_ser_state, {}).

%%%===================================================================
%%% Spawning and gen_server implementation
%%%===================================================================

start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

init([]) ->
  {ok, #pol_gen_ser_state{}}.

handle_call(_Request, _From, State = #pol_gen_ser_state{}) ->
  {reply, ok, State}.

handle_cast(_Request, State = #pol_gen_ser_state{}) ->
  {noreply, State}.

handle_info(_Info, State = #pol_gen_ser_state{}) ->
  {noreply, State}.

terminate(_Reason, _State = #pol_gen_ser_state{}) ->
  ok.

code_change(_OldVsn, State = #pol_gen_ser_state{}, _Extra) ->
  {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
