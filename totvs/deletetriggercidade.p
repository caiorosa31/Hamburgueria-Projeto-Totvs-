TRIGGER PROCEDURE FOR DELETE OF cidades.

FIND FIRST clientes OF cidades EXCLUSIVE-LOCK NO-ERROR.

IF NOT AVAILABLE clientes THEN DO:
    RETURN.
END.
ELSE DO:
    MESSAGE "Existem registros de clientes associados a esta cidade. Exclusão não permitida."
        VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
    RETURN ERROR.
END.
