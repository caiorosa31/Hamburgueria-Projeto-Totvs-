TRIGGER PROCEDURE FOR DELETE OF produtos.

FIND FIRST itens WHERE itens.codproduto = produtos.codproduto NO-LOCK NO-ERROR.

IF NOT AVAILABLE itens THEN DO:
    RETURN.
END.
ELSE DO:
    MESSAGE "Esse produto não pode ser excluído, pois está presente em um pedido."
        VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
    RETURN ERROR.
END.
