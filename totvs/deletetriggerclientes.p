TRIGGER PROCEDURE FOR DELETE OF Clientes.

find first pedidos of clientes EXCLUSIVE-LOCK NO-ERROR.

if not avail pedidos then do:
   return.
end.
else do:
   Message "Esse cliente Tem pedidos salvos no sistema."
   view-as alert-box information buttons ok.
   return error.
end.
