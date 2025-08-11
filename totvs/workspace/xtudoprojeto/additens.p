DEFINE BUTTON bt-Save LABEL "Salvar".
DEFINE BUTTON bt-Canc LABEL "Cancelar" AUTO-ENDKEY.

DEFINE INPUT PARAMETER pCodPedido AS INTEGER NO-UNDO.

DEFINE BUFFER bItens   FOR itens.
DEFINE BUFFER bPedidos  FOR pedidos.
DEFINE BUFFER bProdutos FOR produtos.


DEFINE FRAME f-itens
    Itens.CodProduto LABEL "Produto" Produtos.NomProduto NO-LABELS SKIP
    Itens.NumQuantidade LABEL "Quantidade" SKIP
    Itens.ValTotal LABEL "Valor Total" SKIP
    bt-save bt-canc
    WITH SIDE-LABELS THREE-D VIEW-AS DIALOG-BOX 
         TITLE "Item" SIZE 55 BY 10.
         
ENABLE Itens.CodProduto Itens.NumQuantidade WITH FRAME f-itens.

ON 'leave' OF itens.codproduto DO:
    DEFINE VARIABLE lValid AS LOGICAL NO-UNDO.
    IF TRIM(itens.codproduto:SCREEN-VALUE) = "" THEN
        RETURN.

    RUN piValidaProdutos (INPUT INTEGER(itens.codproduto:SCREEN-VALUE), OUTPUT lValid).
    IF lValid = NO THEN DO:
        RETURN NO-APPLY.
    END.
    DISPLAY bProdutos.NomProduto @ Produtos.NomProduto WITH FRAME f-itens.
END.

ON 'leave' OF Itens.NumQuantidade DO:
    DEFINE VARIABLE vtotal AS DECIMAL NO-UNDO.
    RUN piValor (INPUT itens.codproduto:SCREEN-VALUE).
    vtotal = DECIMAL(INPUT Itens.NumQuantidade) * bprodutos.ValProduto.
    DISPLAY vtotal @ itens.valtotal WITH FRAME f-itens.
END.
       
ON 'choose' OF bt-save DO:
   DEFINE VARIABLE vtotal AS DECIMAL NO-UNDO. 
   DEFINE VARIABLE lValid AS LOGICAL     NO-UNDO.
   DEFINE VARIABLE iProxItem  AS INTEGER NO-UNDO. 
   DEFINE VARIABLE pedtotal AS DECIMAL INITIAL 0 NO-UNDO.
   
   RUN piValidaProdutos (INPUT itens.codproduto:SCREEN-VALUE, 
                         OUTPUT lValid).
   IF  lValid = NO THEN DO:
       RETURN NO-APPLY.
   END.
   RUN piValor (INPUT itens.codproduto:SCREEN-VALUE).
   vtotal = DECIMAL(INPUT Itens.NumQuantidade) * bprodutos.ValProduto.
   
   iProxItem = 1.
   FOR LAST bItens NO-LOCK WHERE bItens.codpedido = pCodPedido BY bItens.CodItem:
        iProxItem = bItens.CodItem + 1.
   END.
   
   
   CREATE itens.
   ASSIGN Itens.CodPedido     = pCodPedido
          Itens.CodItem = iproxitem
          Itens.CodProduto = INPUT Itens.CodProduto
          Itens.NumQuantidade = INPUT Itens.NumQuantidade
          Itens.ValTotal = vtotal.
          
   FIND FIRST pedidos WHERE pedidos.codpedido = Itens.CodPedido.
   FOR EACH bItens WHERE bItens.CodPedido = pedidos.codpedido:
       pedtotal = pedtotal + bItens.ValTotal. 
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
