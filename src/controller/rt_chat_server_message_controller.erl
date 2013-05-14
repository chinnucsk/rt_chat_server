-module(rt_chat_server_message_controller, [Req]).
-compile(export_all). 

index('GET', []) ->
  Callback = Req:param("callback"),
  Messages = [[{text, "Hello World"}], [{text, "Hello World"}]],
  {jsonp, Callback, [{ messages, Messages }]}.

create('POST', []) ->
  Callback = Req:param("callback"),
  Text = Req:post_param("text"),
  Message = message:new(id, "Hello, world!"),
  {jsonp, Callback, [{error, false}, {id, Message:id()}]}.