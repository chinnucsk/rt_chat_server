-module(rt_chat_server_message_controller, [Req]).
-compile(export_all). 

index('GET', []) ->
  Callback = Req:param("callback"),
  Messages = boss_db:find(message, []),
  {jsonp, Callback, [{ messages, Messages }]}.

create('OPTIONS', []) ->
  Headers = [{'Access-Control-Allow-Origin', "*"},
    {'Access-Control-Allow-Methods',  "OPTIONS"},
    {'Access-Control-Allow-Headers', "X-Requested-With, Content-Type"},
    {'Access-Control-Max-Age', "180"}],
  {json, [], Headers};

create('POST', []) ->
  Headers = [{'Access-Control-Allow-Origin', "*"},
    {'Access-Control-Allow-Methods',  "POST, OPTIONS"},
    {'Access-Control-Allow-Headers', "X-Requested-With"},
    {'Access-Control-Max-Age', "180"}],
  Text = Req:param("text"),
  io:format(Text),
  NewMessage = message:new(id, Text),
  case NewMessage:save() of
    {ok, SavedMessage} ->
      {json, [{error, false}, {message, SavedMessage}], Headers};
    {error, ErrorList} ->
      {json, [{errors, ErrorList}, {new_msg, NewMessage}], Headers}
  end.

pull('GET', [LastTimestamp]) ->
  Callback = Req:param("callback"),
  {ok, Timestamp, Messages} = boss_mq:pull("new-messages",
    list_to_integer(LastTimestamp)),
  {jsonp, Callback, [{timestamp, Timestamp}, {messages, Messages}]}.

live('GET', []) ->
  Callback = Req:param("callback"),
  Messages = boss_db:find(message, []),
  Timestamp = boss_mq:now("new-messages"),
  {jsonp, Callback, [{messages, Messages}, {timestamp, Timestamp}]}.