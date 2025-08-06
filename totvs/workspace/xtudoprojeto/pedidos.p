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
    bt-pri AT 10
    bt-ant 
    bt-prox 
    bt-ult SPACE(3) 
    bt-add bt-mod bt-del bt-rel SPACE(3)
    bt-save bt-canc SPACE(3)
    bt-sair  SKIP(1)
    pedidos.codpedido  COLON 20 Pedidos.DatPedido
    pedidos.codcliente COLON 20 Clientes.NomCliente NO-LABELS
    Clientes.CodEndereco COLON 20
    clientes.codcidade COLON 20 cidades.nomcidade NO-LABELS SKIP
    pedidos.observacao COLON 20
    bitens AT ROW 10 COL 5 SKIP(1)
    bt-additem AT 10
    bt-moditem
    bt-delitem
    
    WITH SIDE-LABELS THREE-D SIZE 150 BY 30
    VIEW-AS DIALOG-BOX TITLE "Pedidos".
         
ON ITERATION-CHANGED OF bitens 
    DO:
        
        icoditem = itens.coditem.
   
    
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
        CLEAR FRAME f-pedidos.
        CLOSE QUERY qItens.
        DISPLAY NEXT-VALUE(seqpedido) @ pedidos.codpedido WITH FRAME f-pedidos.
    END.
 
ON 'choose' OF bt-mod 
    DO:
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
    
        FIND FIRST itens WHERE itens.codpedido = pedidos.codpedido NO-LOCK NO-ERROR.
        IF AVAILABLE itens THEN 
        DO:
            MESSAGE "Nao e possivel excluir este pedido, pois existem itens vinculados." SKIP
                "Gostaria de remover todos os itens e apagar o pedido?"
                VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE "Eliminacao" UPDATE lRemoverTudo.
            IF lRemoverTudo THEN 
            DO:
                /* Remove todos os itens do pedido */
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
            /* Se não quiser remover tudo, não faz nada */
            RETURN NO-APPLY.
        END.
        ELSE 
        DO:
            /* Fluxo para pedido SEM itens: confirma e exclui normalmente */
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

ON 'choose' OF bt-additem 
    DO:
        RUN additens.p(INPUT pedidos.codpedido).
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
 
ON CHOOSE OF bt-rel 
    DO:
        DEFINE VARIABLE cArq AS CHARACTER NO-UNDO.
        DEFINE FRAME f-cab HEADER
            "Relatorio de pedidos" AT 1
            TODAY TO 120
            WITH PAGE-TOP WIDTH 120.
        DEFINE FRAME f-dados
            pedidos.codpedido
            Pedidos.DatPedido
            pedidos.codcliente
            pedidos.observacao
            WITH DOWN WIDTH 120.
    
        ASSIGN 
            cArq = SESSION:TEMP-DIRECTORY + "pedidos.txt".
    
        OUTPUT TO VALUE(cArq) PAGE-SIZE 20 PAGED.
        VIEW FRAME f-cab.
    
        FOR EACH pedidos NO-LOCK:
            DISPLAY pedidos.codpedido
                Pedidos.DatPedido
                pedidos.codcliente
                pedidos.observacao
                WITH FRAME f-dados.
        END.
    
        OUTPUT CLOSE.
        OS-COMMAND NO-WAIT VALUE(cArq).
    END.

 
RUN piOpenQuery.
RUN piHabilitaBotoes (INPUT TRUE).
APPLY "choose" TO bt-pri.

VIEW FRAME f-pedidos.
ENABLE bitens WITH FRAME f-pedidos. 
WAIT-FOR GO OF FRAME f-pedidos.
WAIT-FOR WINDOW-CLOSE OF FRAME f-pedidos.

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
        MESSAGE "Cliente" pCodCliente "não existe!!!"
            VIEW-AS ALERT-BOX ERROR BUTTONS OK.
        ASSIGN 
            pValid = NO.
    END.

/* Se não encontrou, avisa e sinaliza erro */
END PROCEDURE.