> terraform console
> "Hello ${var.hello}!" 
> "Hello %{if var.hello == "world"}Mars%{else}World%{endif}"