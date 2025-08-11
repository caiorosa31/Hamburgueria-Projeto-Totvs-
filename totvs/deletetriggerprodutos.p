TRIGGER PROCEDURE FOR DELETE OF produtos.

     DEFINE BUFFER bItens FOR itens.
    DEFINE BUFFER bPed   FOR pedidos.

    /* Se existir algum item desse produto cujo pedido ainda existe ? bloqueia */
    IF CAN-FIND(
         FIRST bItens NO-LOCK
         WHERE bItens.codproduto = produtos.codproduto
           AND CAN-FIND(FIRST bPed NO-LOCK
                        WHERE bPed.codpedido = bItens.codpedido)
       ) THEN DO:
        MESSAGE "Esse produto n�o pode ser exclu�do, pois est� em pedidos existentes."
            VIEW-AS ALERT-BOX INFORMATION.
        RETURN ERROR.
    END.
    /* caso contr�rio, permite excluir normalmente */
