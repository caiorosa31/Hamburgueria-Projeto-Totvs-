DEFINE VARIABLE lValid AS LOGICAL NO-UNDO. 

DEFINE INPUT PARAMETER pCodPedido AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER iCodItem AS INTEGER NO-UNDO.
DEFINE VARIABLE pedtotal AS DECIMAL INITIAL 0 NO-UNDO.

MESSAGE "Voce deseja excluir o item numero " icoditem "?"
    VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE lValid.

IF lValid = TRUE THEN DO:
    FIND itens WHERE itens.codpedido = pCodPedido AND itens.coditem = iCodItem EXCLUSIVE-LOCK NO-ERROR.
    IF AVAILABLE itens THEN
        DELETE itens.
    ELSE
        MESSAGE "Registro do item n∆o est† mais dispon°vel!"
            VIEW-AS ALERT-BOX ERROR.
END.

FIND FIRST pedidos WHERE pedidos.codpedido = pCodPedido.
FOR EACH itens WHERE Itens.CodPedido = pcodpedido:
       pedtotal = pedtotal + Itens.ValTotal. 
   END.
ASSIGN Pedidos.ValPedido = pedtotal.
    

