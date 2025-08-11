DEFINE BUTTON bt-Save LABEL "Salvar".
DEFINE BUTTON bt-Canc LABEL "Cancelar" AUTO-ENDKEY.

DEFINE INPUT PARAMETER pCodPedido AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER iCodItem AS INTEGER NO-UNDO.

DEFINE BUFFER bProdutos FOR produtos.

FIND FIRST Itens WHERE Itens.CodPedido = pCodPedido AND Itens.CodItem = iCodItem NO-LOCK NO-ERROR.


DEFINE FRAME f-itens
    Itens.CodProduto LABEL "Produto" Produtos.NomProduto NO-LABELS SKIP
    Itens.NumQuantidade LABEL "Quantidade" SKIP
    Itens.ValTotal LABEL "Valor Total" SKIP
    bt-save bt-canc
    WITH SIDE-LABELS THREE-D VIEW-AS DIALOG-BOX 
         TITLE "Item" SIZE 55 BY 10.
         
IF AVAILABLE Itens THEN DO:
    DISPLAY Itens.CodProduto
            Itens.NumQuantidade
            Itens.ValTotal
            WITH FRAME f-itens.
END.
         
ENABLE Itens.CodProduto Itens.NumQuantidade WITH FRAME f-itens.

ON 'leave' OF itens.codproduto DO:
    DEFINE VARIABLE lValid AS LOGICAL     NO-UNDO.
    RUN piValidaProdutos (INPUT itens.codproduto:SCREEN-VALUE, 
                          OUTPUT lValid).
    IF  lValid = NO THEN DO:
        RETURN NO-APPLY.
    END.
    DISPLAY bProdutos.NomProduto @ Produtos.NomProduto WITH FRAME f-itens.
END.

ON 'leave' OF Itens.NumQuantidade DO:
    DEFINE VARIABLE vtotal AS INTEGER NO-UNDO.
    RUN piValor (INPUT itens.codproduto:SCREEN-VALUE).
    vtotal = INPUT Itens.NumQuantidade * bprodutos.ValProduto.
    DISPLAY vtotal @ itens.valtotal WITH FRAME f-itens.
END.
       
ON 'choose' OF bt-save DO:
   DEFINE VARIABLE vtotal AS INTEGER NO-UNDO. 
   DEFINE VARIABLE lValid AS LOGICAL     NO-UNDO.
      DEFINE VARIABLE pedtotal AS DECIMAL INITIAL 0 NO-UNDO.
   
   FIND itens WHERE icoditem = Itens.CodItem AND pcodpedido = Itens.CodPedido. 
 
   RUN piValidaProdutos (INPUT itens.codproduto:SCREEN-VALUE, 
                         OUTPUT lValid).
   IF  lValid = NO THEN DO:
       RETURN NO-APPLY.
   END.
   RUN piValor (INPUT itens.codproduto:SCREEN-VALUE).
   vtotal = INPUT Itens.NumQuantidade * bprodutos.ValProduto.
   

   ASSIGN Itens.CodPedido     = pCodPedido
          Itens.CodItem = icoditem
          Itens.CodProduto = INPUT Itens.CodProduto
          Itens.NumQuantidade = INPUT Itens.NumQuantidade
          Itens.ValTotal = vtotal.
          
   FIND FIRST pedidos WHERE pedidos.codpedido = Itens.CodPedido.
   FOR EACH itens WHERE Itens.CodPedido = pedidos.codpedido:
       pedtotal = pedtotal + Itens.ValTotal. 
   END.
   ASSIGN Pedidos.ValPedido = pedtotal. 
          
   APPLY "WINDOW-CLOSE" TO FRAME f-itens.
 
END.


VIEW FRAME f-itens.
ENABLE bt-save bt-canc WITH FRAME f-itens.

WAIT-FOR CHOOSE OF bt-canc OR WINDOW-CLOSE OF FRAME f-itens.

PROCEDURE piValidaProdutos:
    DEFINE INPUT PARAMETER pCodProduto AS INTEGER NO-UNDO.
    DEFINE OUTPUT PARAMETER pValid AS LOGICAL NO-UNDO INITIAL NO.
    FIND FIRST bProdutos
        WHERE bProdutos.codproduto = pCodProduto
        NO-LOCK NO-ERROR.
    IF  NOT AVAILABLE bProdutos THEN DO:
        MESSAGE "Produto" pCodProduto "nao existe!!!"
                VIEW-AS ALERT-BOX ERROR.
        RUN consultarprodutos.p.
        ASSIGN pValid = NO.
    END.
    ELSE 
       ASSIGN pValid = YES.
END PROCEDURE.

PROCEDURE piValor:
    DEFINE INPUT PARAMETER pCodProduto AS INTEGER NO-UNDO.
    FIND FIRST bProdutos
        WHERE bProdutos.codproduto = pCodProduto
        NO-LOCK NO-ERROR. 
END PROCEDURE.
