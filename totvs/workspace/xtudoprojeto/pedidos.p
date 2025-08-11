USING Progress.Json.ObjectModel.JsonArray FROM PROPATH.
USING Progress.Json.ObjectModel.JsonObject FROM PROPATH.

ASSIGN 
    CURRENT-WINDOW:HIDDEN = TRUE.
 
DEFINE BUTTON bt-pri LABEL "<<".
DEFINE BUTTON bt-ant LABEL "<".
DEFINE BUTTON bt-prox LABEL ">".
DEFINE BUTTON bt-ult LABEL ">>".
DEFINE BUTTON bt-add LABEL "Novo".
DEFINE BUTTON bt-mod LABEL "Modificar".
DEFINE BUTTON bt-del LABEL "Remover".
DEFINE BUTTON bt-save LABEL "Salvar".
DEFINE BUTTON bt-canc LABEL "Cancelar".
DEFINE BUTTON bt-sair LABEL "Sair" AUTO-ENDKEY.
DEFINE BUTTON bt-rel LABEL "Exportar".
DEFINE BUTTON bt-additem LABEL "Adicionar".
DEFINE BUTTON bt-moditem LABEL "Modificar".
DEFINE BUTTON bt-delitem LABEL "Eliminar".
DEFINE BUTTON bt-consult LABEL "Consultar Clientes".
 
DEFINE VARIABLE cAction  AS CHARACTER NO-UNDO.
DEFINE VARIABLE icoditem AS INTEGER   NO-UNDO.
 
DEFINE QUERY qPedidos FOR pedidos, clientes, cidades SCROLLING.
DEFINE QUERY qItens FOR itens, produtos.

DEFINE BROWSE bitens QUERY qitens DISPLAY
    Itens.CodItem Itens.CodProduto Produtos.NomProduto Itens.NumQuantidade Produtos.ValProduto Itens.ValTotal
        WITH SEPARATORS 5 DOWN SIZE 120 BY 15.
        
 
DEFINE BUFFER bPed      FOR Pedidos.
DEFINE BUFFER bClientes FOR clientes.
DEFINE BUFFER bCidades  FOR cidades.

 
DEFINE FRAME f-pedidos
    SKIP(1)
    bt-pri AT 10
    bt-ant 
    bt-prox 
    bt-ult SPACE(3) 
    bt-add bt-mod bt-del bt-rel SPACE(3)
    bt-save bt-canc SPACE(3)
    bt-sair  SKIP(1)
    pedidos.codpedido  COLON 20 Pedidos.DatPedido LABEL "Data (mm/dd/aaaa)"
    pedidos.codcliente COLON 20 Clientes.NomCliente NO-LABELS
    Clientes.CodEndereco COLON 20
    clientes.codcidade COLON 20 cidades.nomcidade NO-LABELS SKIP
    pedidos.observacao COLON 20
    bitens AT ROW 10 COL 5 SKIP(1)
    bt-additem
    bt-moditem
    bt-delitem
    bt-consult
    
    WITH SIDE-LABELS THREE-D SIZE 152 BY 30
    VIEW-AS DIALOG-BOX TITLE "Gerenciamento de Pedidos".
         
ON ITERATION-CHANGED OF bitens 
    DO: 
        icoditem = itens.coditem.
    END.
    
ON 'choose' OF bt-consult 
    DO:
        RUN consultarclientes.p.
    END.
 
ON 'choose' OF bt-pri 
    DO:
        GET FIRST qPedidos.
        RUN piMostra.
    END.
 
ON 'choose' OF bt-ant 
    DO:
        GET PREV qPedidos.
        IF AVAILABLE pedidos THEN
            RUN piMostra.
        ELSE
            GET FIRST qPedidos.
    END.
 
ON 'choose' OF bt-prox 
    DO:
        GET NEXT qPedidos.
        IF AVAILABLE pedidos THEN
            RUN piMostra.
        ELSE
            GET LAST qPedidos.
    END.
 
ON 'choose' OF bt-ult 
    DO:
        GET LAST qPedidos.
        RUN piMostra.
    END.
 
ON 'choose' OF bt-add 
    DO:
        ASSIGN 
            cAction = "add".
        RUN piHabilitaBotoes (INPUT FALSE).
        RUN piHabilitaCampos (INPUT TRUE).
        ASSIGN Pedidos.CodPedido:SENSITIVE     = TRUE.
        CLEAR FRAME f-pedidos.
        CLOSE QUERY qItens.
        DISPLAY NEXT-VALUE(seqpedido) @ pedidos.codpedido WITH FRAME f-pedidos.
        RUN piOpenQuery.
    END.
 
ON 'choose' OF bt-mod 
    DO:
        
        IF TRIM(pedidos.codpedido:SCREEN-VALUE IN FRAME f-pedidos) = "" THEN DO:
            MESSAGE "Crie um pedido antes de tentar modifica-lo."
                VIEW-AS ALERT-BOX INFORMATION.
            RETURN NO-APPLY.
       END.
        
        ASSIGN 
            cAction = "mod".
        RUN piHabilitaBotoes (INPUT FALSE).
        RUN piHabilitaCampos (INPUT TRUE).
        DISPLAY pedidos.codpedido WITH FRAME f-pedidos.
        RUN piMostra.
    END.
 
ON 'choose' OF bt-del 
    DO:
        DEFINE VARIABLE lConf        AS LOGICAL NO-UNDO.
        DEFINE VARIABLE lRemoverTudo AS LOGICAL NO-UNDO.
        DEFINE BUFFER bpedidos FOR pedidos.
        
        IF TRIM(pedidos.codpedido:SCREEN-VALUE IN FRAME f-pedidos) = "" THEN DO:
            MESSAGE "Crie um pedido antes de tentar remove-lo."
                VIEW-AS ALERT-BOX INFORMATION.
            RETURN NO-APPLY.
       END.
    
        FIND FIRST itens WHERE itens.codpedido = pedidos.codpedido NO-LOCK NO-ERROR.
        IF AVAILABLE itens THEN 
        DO:
            MESSAGE "Nao e possivel excluir este pedido, pois existem itens vinculados." SKIP
                "Gostaria de remover todos os itens e apagar o pedido?"
                VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE "Eliminacao" UPDATE lRemoverTudo.
            IF lRemoverTudo THEN 
            DO:
                FOR EACH itens WHERE itens.codpedido = pedidos.codpedido:
                    DELETE itens.
                END.
                RUN piOpenItens(INPUT pedidos.codpedido).
    
                MESSAGE "Todos os itens foram removidos. Deseja excluir o pedido?"
                    VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE "Exclusão de Pedido" UPDATE lConf.
                IF lConf THEN 
                DO:
                    FIND bpedidos
                        WHERE bpedidos.codpedido = pedidos.codpedido
                        EXCLUSIVE-LOCK NO-ERROR.
                    DELETE bpedidos.
                    GET FIRST qPedidos.
                    RUN piMostra.
                    MESSAGE "Pedido e itens excluidos com sucesso!" VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
                END.
                RETURN NO-APPLY.
            END.
            RETURN NO-APPLY.
        END.
        ELSE 
        DO:
            MESSAGE "Confirma a eliminacao do pedido " pedidos.Codpedido "?"
                VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE "Eliminação" UPDATE lConf.
            IF lConf THEN 
            DO:
                FIND bpedidos
                    WHERE bpedidos.codpedido = pedidos.codpedido
                    EXCLUSIVE-LOCK NO-ERROR.
                DELETE bpedidos.
                GET FIRST qPedidos.
                RUN piMostra.
                MESSAGE "Pedido excluido com sucesso!" VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
            END.
        END.
    END.

ON 'choose' OF bt-canc 
    DO:
        ASSIGN 
            cAction = "".
        ASSIGN Pedidos.CodPedido:SENSITIVE     = FALSE.
        RUN piHabilitaBotoes (INPUT TRUE).
        RUN piHabilitaCampos (INPUT FALSE).
 

        CLOSE QUERY qPedidos.
        RUN piOpenQuery.
        GET FIRST qPedidos.

        IF AVAILABLE pedidos THEN
            RUN piMostra.
        ELSE
            CLEAR FRAME f-pedidos.
    END.

ON 'leave' OF pedidos.codcliente 
    DO:
    
        DEFINE VARIABLE lValid AS LOGICAL NO-UNDO.
        IF cAction = "add" OR cAction = "mod" THEN 
        DO:
            RUN piValidaClientes (INPUT pedidos.codcliente:SCREEN-VALUE, 
                OUTPUT lValid).
        END.
        IF  lValid = NO THEN 
        DO:
            RETURN NO-APPLY.
        END.
        DISPLAY bclientes.nomcliente @ clientes.nomcliente
            bclientes.CodEndereco @ clientes.CodEndereco
            bclientes.CodCidade @ clientes.CodCidade
            WITH FRAME f-pedidos.
            
        FIND bcidades WHERE bcidades.codcidade = bclientes.codcidade NO-LOCK NO-ERROR.
        DISPLAY bcidades.NomCidade @ cidades.nomcidade
            WITH FRAME f-pedidos. 
    END.
 
ON 'choose' OF bt-save 
    DO:
    
        DEFINE VARIABLE lValid AS LOGICAL NO-UNDO.
 
        RUN piValidaclientes (INPUT pedidos.codcliente:SCREEN-VALUE, 
            OUTPUT lValid).
        IF  lValid = NO THEN 
        DO:
            RETURN NO-APPLY.
        END.
 
        IF cAction = "add" THEN 
        DO:
            CREATE bPed.
            ASSIGN 
                bPed.codpedido = INPUT pedidos.codpedido.
        END.
        IF  cAction = "mod" THEN 
        DO:
            FIND FIRST bPed 
                WHERE bPed.codpedido = pedidos.Codpedido
                EXCLUSIVE-LOCK NO-ERROR.
        END.
        ASSIGN 
            bped.CodPedido  = INPUT pedidos.codpedido
            bPed.DatPedido  = INPUT Pedidos.DatPedido
            bPed.CodCliente = INPUT pedidos.codcliente
            bPed.Observacao = INPUT pedidos.observacao.
 
        RUN piHabilitaBotoes (INPUT TRUE).
        RUN piHabilitaCampos (INPUT FALSE).
        RUN piOpenQuery.
    END.
    
ON 'choose' OF bt-save DO:
  DEFINE VARIABLE cObservacao AS CHARACTER NO-UNDO.
  DEFINE VARIABLE iCodCliente   AS INT NO-UNDO.
  DEFINE VARIABLE data AS DATE NO-UNDO.
  DEFINE VARIABLE iCod  AS INTEGER   NO-UNDO.

  /* 1) Leia o que está NA TELA */
  ASSIGN
    cObservacao = TRIM(Pedidos.Observacao:SCREEN-VALUE  IN FRAME f-pedidos)
    icod = INPUT Pedidos.CodPedido
    icodcliente = INPUT Pedidos.CodCliente
    data = INPUT Pedidos.DatPedido.
    
    

  IF icod = 0 OR icodcliente = 0 OR data = ? THEN DO:
    MESSAGE "Preencha todos os campos (Codigo do Pedido, Data(MM/DD/AAAA), Codigo do Cliente)." VIEW-AS ALERT-BOX INFO.
    RETURN NO-APPLY.
  END.

  IF TRIM(Pedidos.CodPedido:SCREEN-VALUE IN FRAME f-pedidos) <> "" THEN
    ASSIGN iCod = INTEGER(Pedidos.CodPedido:SCREEN-VALUE IN FRAME f-pedidos) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
    MESSAGE "Código do Pedido inválido." VIEW-AS ALERT-BOX ERROR.
    RETURN NO-APPLY.
  END.

  IF cAction = "add" THEN DO:
    CREATE bPed.
    ASSIGN  bped.CodPedido  = icod
            bPed.DatPedido  = data
            bPed.CodCliente = icodcliente
            bPed.Observacao = cObservacao.
  END.
  ELSE IF cAction = "mod" THEN DO:
    FIND FIRST bPed
         WHERE bped.CodPedido = iCod
         EXCLUSIVE-LOCK NO-ERROR.
    IF NOT AVAILABLE bPed THEN DO:
      MESSAGE "Erro: Pedido não encontrada para alteração!" VIEW-AS ALERT-BOX ERROR.
      RETURN NO-APPLY.
    END.
    ASSIGN
        bPed.DatPedido  = data
        bPed.CodCliente = icodcliente
        bPed.Observacao = cObservacao.
  END.

  ASSIGN Pedidos.CodPedido:SENSITIVE     = FALSE.
  RUN piHabilitaBotoes (TRUE).
  RUN piHabilitaCampos (FALSE).
  RUN piOpenQuery.
END.

ON 'choose' OF bt-additem 
    DO:         

       IF TRIM(pedidos.codpedido:SCREEN-VALUE IN FRAME f-pedidos) = "" THEN DO:
            MESSAGE "Crie um pedido antes de adicionar itens."
                VIEW-AS ALERT-BOX INFORMATION.
            RETURN NO-APPLY.
       END.

        RUN additens.p (INTEGER(pedidos.codpedido:SCREEN-VALUE IN FRAME f-pedidos)).
        RUN piOpenQuery.
        RUN piMostra.
    END.
ON 'choose' OF bt-moditem 
    DO:
        ASSIGN 
            icoditem = INTEGER(bitens:GET-BROWSE-COLUMN(1):SCREEN-VALUE IN FRAME f-pedidos).
            
        IF AVAILABLE itens THEN
            RUN moditens.p(INPUT pedidos.codpedido,
                INPUT icoditem).
        ELSE
            MESSAGE "Nenhum item selecionado!" VIEW-AS ALERT-BOX ERROR.
        RUN piOpenQuery.
        RUN piMostra.
       
    END.
ON 'choose' OF bt-delitem 
    DO:
        ASSIGN 
            icoditem = INTEGER(bitens:GET-BROWSE-COLUMN(1):SCREEN-VALUE IN FRAME f-pedidos).
        IF AVAILABLE itens THEN
            RUN deleteitens.p(INPUT pedidos.codpedido, INPUT itens.coditem).
        ELSE
            MESSAGE "Selecione um item valido!" VIEW-AS ALERT-BOX ERROR.
        RUN piOpenQuery.
        RUN piMostra.
    END.
 
ON CHOOSE OF bt-rel DO:
        ASSIGN CURRENT-WINDOW:HIDDEN = TRUE.
    DEFINE BUTTON bt-csv LABEL "CSV".
    DEFINE BUTTON bt-json LABEL "JSON".
    
    DEFINE FRAME f-export
    bt-csv AT 12
    bt-json 
    WITH SIDE-LABELS THREE-D SIZE 40 BY 3
         VIEW-AS DIALOG-BOX TITLE "Exportar clientes".
         
         IF TRIM(pedidos.codpedido:SCREEN-VALUE IN FRAME f-pedidos) = "" THEN DO:
            MESSAGE "Nao ha pedidos para exportar."
                VIEW-AS ALERT-BOX INFORMATION.
            RETURN NO-APPLY.
       END.
         
    ASSIGN bt-csv:SENSITIVE  = TRUE
           bt-json:SENSITIVE  = TRUE.
    
        ON CHOOSE OF bt-csv IN FRAME f-export DO:
    DEFINE VARIABLE cArq AS CHARACTER NO-UNDO.
    ASSIGN 
        cArq = SESSION:TEMP-DIRECTORY + "pedidos.csv".
    OUTPUT TO VALUE(cArq).
    
    PUT UNFORMATTED
  "CodPedido;DatPedido;ValPedido;NomCliente;Endereco;Cidade;CodItem;NomProduto;ValProduto;NumQuantidade;ValTotal" SKIP.

FOR EACH pedidos NO-LOCK:
  FIND FIRST clientes WHERE clientes.codcliente = pedidos.codcliente NO-LOCK NO-ERROR.
  IF AVAILABLE clientes THEN
    FIND FIRST cidades WHERE cidades.codcidade = clientes.codcidade NO-LOCK NO-ERROR.
  ELSE
    RELEASE cidades.

  IF CAN-FIND(FIRST itens WHERE itens.codpedido = pedidos.codpedido) THEN DO:
    FOR EACH itens WHERE itens.codpedido = pedidos.codpedido NO-LOCK:
      FIND FIRST produtos WHERE produtos.codproduto = itens.codproduto NO-LOCK NO-ERROR.

      PUT UNFORMATTED
        pedidos.CodPedido ";"
        STRING(pedidos.DatPedido, "99/99/9999") ";"
        STRING(pedidos.ValPedido) ";"
        (IF AVAILABLE clientes THEN clientes.NomCliente ELSE "") ";"
        (IF AVAILABLE clientes THEN STRING(Clientes.CodEndereco) ELSE "") ";"
        (IF AVAILABLE cidades  THEN cidades.NomCidade ELSE "") ";"
        itens.CodItem ";"
        (IF AVAILABLE produtos THEN produtos.NomProduto ELSE "") ";"
        (IF AVAILABLE produtos THEN STRING(produtos.ValProduto) ELSE "") ";"
        STRING(itens.NumQuantidade) ";"
        STRING(itens.ValTotal)
        SKIP.
    END.
  END.
  ELSE DO:
    PUT UNFORMATTED
      pedidos.CodPedido ";"
      STRING(pedidos.DatPedido, "99/99/9999") ";"
      STRING(pedidos.ValPedido) ";"
      (IF AVAILABLE clientes THEN clientes.NomCliente ELSE "") ";"
      (IF AVAILABLE clientes THEN STRING(Clientes.CodEndereco) ELSE "") ";"
      (IF AVAILABLE cidades  THEN cidades.NomCidade ELSE "") ";"
      ";;;;"
      SKIP.
  END.
END.
    
    OUTPUT CLOSE.
    OS-COMMAND NO-WAIT VALUE("notepad.exe " + cArq).
END.

    ON CHOOSE OF bt-json IN FRAME f-export DO:
            DEFINE VARIABLE cArq    AS CHARACTER  NO-UNDO.
            DEFINE VARIABLE oObj    AS JsonObject NO-UNDO.
            DEFINE VARIABLE aClientes   AS JsonArray  NO-UNDO.
            DEFINE VARIABLE aItens AS JsonArray  NO-UNDO.
            DEFINE VARIABLE oIt    AS JsonObject NO-UNDO.
    
            ASSIGN cArq = SESSION:TEMP-DIRECTORY + "pedidos.json".
            aClientes = NEW JsonArray(). 
            FOR EACH pedidos NO-LOCK:
                FIND FIRST clientes WHERE clientes.codcliente = pedidos.codcliente NO-LOCK NO-ERROR.
                FIND FIRST cidades WHERE cidades.codcidade = clientes.codcidade NO-LOCK NO-ERROR.
                    oObj = NEW JsonObject().
                    oObj:add("Codigo Pedido", Pedidos.CodPedido).
                    oObj:add("Data", Pedidos.DatPedido).
                    oObj:add("Valor Pedido", Pedidos.ValPedido).
                    IF AVAILABLE clientes THEN
                        oObj:add("Codigo Cliente", Clientes.CodCliente).
                        oObj:add("Nome Cliente", Clientes.NomCliente).
                        oObj:add("Endereco", Clientes.CodEndereco).
                    IF AVAILABLE cidades THEN
                        oObj:add("Cidades", cidades.nomcidade).
                        
                aItens = NEW JsonArray().
                
                FOR EACH itens WHERE itens.codpedido = pedidos.codpedido NO-LOCK:
                    FIND FIRST produtos WHERE produtos.codproduto = itens.codproduto NO-LOCK NO-ERROR. 
                    oIt = NEW JsonObject().
                    oIt:add("Codigo Item", Itens.CodItem).
                    oIt:add("Produto", Produtos.NomProduto).
                    oIt:add("Valor Produto", Produtos.ValProduto).
                    oIt:add("Quantidade", Itens.NumQuantidade).
                    oIt:add("Valor Total itens", Itens.ValTotal).
                    aItens:add(oIt).
                END.
                oObj:add("Itens", aItens).
                aClientes:add(oObj).
            END.
            DEFINE VARIABLE lcTxt AS LONGCHAR NO-UNDO.
            aClientes:WriteFile(INPUT cArq, INPUT YES, INPUT "utf-8").
    
            OS-COMMAND NO-WAIT VALUE("notepad " + cArq).
      END.
    
    VIEW FRAME f-export.
    
    WAIT-FOR CHOOSE OF bt-csv IN FRAME f-export 
    OR CHOOSE OF bt-json IN FRAME f-export 
    OR WINDOW-CLOSE OF FRAME f-export.
END.

 
RUN piOpenQuery.
RUN piHabilitaBotoes (INPUT TRUE).
APPLY "choose" TO bt-pri.

VIEW FRAME f-pedidos.

DO WITH FRAME f-pedidos:
    
    ASSIGN
        bt-pri:WIDTH = 6
        bt-pri:HEIGHT = 1.5
        bt-pri:FONT = 3
        bt-pri:FGCOLOR = 0
    
        bt-ant:WIDTH = 6
        bt-ant:HEIGHT = 1.5
        bt-ant:FONT = 3
        bt-ant:FGCOLOR = 0
    
        bt-prox:WIDTH = 6
        bt-prox:HEIGHT = 1.5
        bt-prox:FONT = 3
        bt-prox:FGCOLOR = 0
    
        bt-ult:WIDTH = 6
        bt-ult:HEIGHT = 1.5
        bt-ult:FONT = 3
        bt-ult:FGCOLOR = 0
    
        bt-add:WIDTH = 12
        bt-add:HEIGHT = 1.5
        bt-add:FONT = 3
        bt-add:FGCOLOR = 15 
    
        bt-mod:WIDTH = 17
        bt-mod:HEIGHT = 1.5
        bt-mod:FONT = 3
        bt-mod:FGCOLOR = 15
    
        bt-del:WIDTH = 15
        bt-del:HEIGHT = 1.5
        bt-del:FONT = 3
        bt-del:FGCOLOR = 15
    
        bt-rel:WIDTH = 15
        bt-rel:HEIGHT = 1.5
        bt-rel:FONT = 3
        bt-rel:FGCOLOR = 0
    
        bt-save:WIDTH = 13
        bt-save:HEIGHT = 1.5
        bt-save:FONT = 3
        bt-save:FGCOLOR = 15
    
        bt-canc:WIDTH = 15
        bt-canc:HEIGHT = 1.5
        bt-canc:FONT = 3
        bt-canc:FGCOLOR = 0
    
        bt-sair:WIDTH = 12
        bt-sair:HEIGHT = 1.5
        bt-sair:FONT = 3
        bt-sair:FGCOLOR = 15
        
        bt-additem:WIDTH = 18
        bt-additem:HEIGHT = 1.5
        bt-additem:FONT = 3
        bt-additem:FGCOLOR = 15
        
        bt-moditem:WIDTH = 18
        bt-moditem:HEIGHT = 1.5
        bt-moditem:FONT = 3
        bt-moditem:FGCOLOR = 15
        
        bt-delitem:WIDTH = 18
        bt-delitem:HEIGHT = 1.5
        bt-delitem:FONT = 3
        bt-delitem:FGCOLOR = 15
        
        bt-consult:WIDTH = 28
        bt-consult:HEIGHT = 1.5
        bt-consult:FONT = 3
        bt-consult:FGCOLOR = 15
    
        FRAME f-pedidos:BGCOLOR = 15 
        
        bt-pri:COL = 7
        bt-ant:COL = 13
        bt-prox:COL = 19
        bt-ult:COL = 25
        
        bt-add:COL = 38.
        bt-mod:COL = 50.
        bt-del:COL = 67.
        bt-rel:COL = 82.
        bt-save:COL = 97.
        bt-canc:COL = 110.
        bt-sair:COL = 133.
        bt-additem:COL = 6.
        bt-moditem:COL = 24.
        bt-delitem:COL = 42.
        bt-consult:COL = 97.
END.

ENABLE bitens WITH FRAME f-pedidos. 
WAIT-FOR GO OF FRAME f-pedidos OR WINDOW-CLOSE OF FRAME f-pedidos.

PROCEDURE piOpenItens:
    DEFINE INPUT PARAMETER pCodPedido AS INTEGER NO-UNDO.

    OPEN QUERY qItens
        FOR EACH itens WHERE itens.codpedido = pCodPedido NO-LOCK,
        EACH produtos WHERE produtos.codproduto = itens.codproduto NO-LOCK.
END PROCEDURE.
 
PROCEDURE piMostra:
    IF AVAILABLE pedidos THEN 
    DO:
        DISPLAY pedidos.codpedido
            Pedidos.DatPedido
            pedidos.codcliente
            pedidos.observacao
            Clientes.NomCliente
            Clientes.CodEndereco
            clientes.codcidade 
            WITH FRAME f-pedidos.
                
        IF AVAILABLE cidades THEN
            DISPLAY cidades.nomcidade WITH FRAME f-pedidos.
                
        RUN piOpenItens(INPUT pedidos.codpedido).
    END.
    ELSE 
    DO:
        CLEAR FRAME f-pedidos.
    END.
END PROCEDURE.
 
PROCEDURE piOpenQuery:
    DEFINE VARIABLE rRecord AS ROWID NO-UNDO.

    IF AVAILABLE pedidos THEN
        ASSIGN rRecord = ROWID(pedidos).

    OPEN QUERY qPedidos
        FOR EACH pedidos NO-LOCK,
        EACH clientes WHERE clientes.codcliente = pedidos.codcliente NO-LOCK,
        EACH cidades WHERE cidades.codcidade = clientes.codcidade NO-LOCK.

    IF rRecord <> ? THEN
        REPOSITION qPedidos TO ROWID rRecord NO-ERROR.
    ELSE
        GET FIRST qPedidos.
END PROCEDURE.
 
PROCEDURE piHabilitaBotoes:
    DEFINE INPUT PARAMETER pEnable AS LOGICAL NO-UNDO.
 
    DO WITH FRAME f-pedidos:
        ASSIGN 
            bt-pri:SENSITIVE     = pEnable
            bt-ant:SENSITIVE     = pEnable
            bt-prox:SENSITIVE    = pEnable
            bt-ult:SENSITIVE     = pEnable
            bt-sair:SENSITIVE    = pEnable
            bt-add:SENSITIVE     = pEnable
            bt-mod:SENSITIVE     = pEnable
            bt-del:SENSITIVE     = pEnable
            bt-rel:SENSITIVE     = pEnable
            bt-additem:SENSITIVE = pEnable
            bt-moditem:SENSITIVE = pEnable
            bt-delitem:SENSITIVE = pEnable
            bt-save:SENSITIVE    = NOT pEnable
            bt-canc:SENSITIVE    = NOT pEnable.
            bt-consult:SENSITIVE    = NOT pEnable.
    END.
END PROCEDURE.
 
PROCEDURE piHabilitaCampos:
    DEFINE INPUT PARAMETER pEnable AS LOGICAL NO-UNDO.
 
    DO WITH FRAME f-pedidos:
        ASSIGN   
            Pedidos.DatPedido:SENSITIVE  = pEnable
            pedidos.codcliente:SENSITIVE = pEnable
            pedidos.observacao:SENSITIVE = pEnable. 
       
    END.
END PROCEDURE.

PROCEDURE piValidaClientes:
    DEFINE INPUT  PARAMETER pCodCliente AS INTEGER NO-UNDO.
    DEFINE OUTPUT PARAMETER pValid     AS LOGICAL NO-UNDO INITIAL YES.
  
    FIND FIRST bclientes
        WHERE bclientes.codcliente = pCodCliente
        NO-LOCK NO-ERROR.
      
    IF NOT AVAILABLE bclientes THEN 
    DO:
        MESSAGE "Cliente" pCodCliente "nao existe!!!"
            VIEW-AS ALERT-BOX ERROR BUTTONS OK.
        RUN consultarclientes.p.
        ASSIGN 
            pValid = NO.
    END.

END PROCEDURE.