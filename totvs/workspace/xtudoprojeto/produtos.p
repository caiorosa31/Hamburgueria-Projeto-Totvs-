CURRENT-WINDOW:WIDTH = 251.
 
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
 
DEFINE VARIABLE cAction  AS CHARACTER   NO-UNDO.
 
DEFINE QUERY qProdutos FOR produtos SCROLLING.
 
DEFINE BUFFER bProdutos  FOR produtos.
 
DEFINE FRAME f-produtos
    bt-pri AT 10
    bt-ant 
    bt-prox 
    bt-ult SPACE(3) 
    bt-add bt-mod bt-del bt-rel SPACE(3)
    bt-save bt-canc SPACE(3)
    bt-sair  SKIP(1)
    Produtos.CodProduto  COLON 20
    Produtos.NomProduto     COLON 20
    Produtos.ValProduto COLON 20
    WITH SIDE-LABELS THREE-D SIZE 140 BY 12
         VIEW-AS DIALOG-BOX TITLE "Manutencao de Clientes".
 
ON 'choose' OF bt-pri DO:
    GET FIRST qProdutos.
    RUN piMostra.
END.
 
ON 'choose' OF bt-ant DO:
    GET PREV qProdutos.
    IF AVAILABLE produtos THEN
        RUN piMostra.
    ELSE
        GET First qProdutos.
END.
 
ON 'choose' OF bt-prox DO:
    GET NEXT qProdutos.
    IF AVAILABLE produtos THEN
        RUN piMostra.
    ELSE
        GET last qProdutos.
END.
 
ON 'choose' OF bt-ult DO:
    GET LAST qProdutos.
    RUN piMostra.
END.
 
ON 'choose' OF bt-add DO:
    ASSIGN cAction = "add".
    RUN piHabilitaBotoes (INPUT FALSE).
    RUN piHabilitaCampos (INPUT TRUE).
    CLEAR FRAME f-produtos.
    DISPLAY NEXT-VALUE(seqproduto) @ Produtos.CodProduto WITH FRAME f-produtos.
END.
 
ON 'choose' OF bt-mod DO:
    ASSIGN cAction = "mod".
    RUN piHabilitaBotoes (INPUT FALSE).
    RUN piHabilitaCampos (INPUT TRUE).
    DISPLAY Produtos.CodProduto WITH FRAME f-produtos.
    RUN piMostra.
END.
 
ON 'choose' OF bt-del DO:
    DEFINE VARIABLE lConf AS LOGICAL     NO-UNDO.
    DEFINE BUFFER bProdutosb FOR produtos.
    MESSAGE "Confirma a eliminacao do customer" Produtos.CodProduto "?" UPDATE lConf
            VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
                TITLE "Eliminacao".
    IF  lConf THEN DO:
        FIND bProdutosb
            WHERE bProdutosb.CodProduto = Produtos.CodProduto
            EXCLUSIVE-LOCK NO-ERROR.
            DELETE bProdutosb.
            message "Produto deletado com sucesso!" view-as alert-box buttons ok.
    END.
    GET FIRST qProdutos.
    RUN piMostra.
END.
 
ON 'choose' OF bt-save DO:
 
   IF cAction = "add" THEN DO:
      CREATE bProdutos.
      ASSIGN bProdutos.CodProduto  = INPUT Produtos.CodProduto.
      message "Produto adicionado com sucesso!" view-as alert-box buttons ok.
   END.
   IF  cAction = "mod" THEN DO:
       FIND FIRST bProdutos 
            WHERE bProdutos.CodProduto = Produtos.CodProduto
            EXCLUSIVE-LOCK NO-ERROR.
       message "Produto alterado com sucesso!" view-as alert-box buttons ok.
   END.
   ASSIGN bProdutos.CodProduto  = INPUT Produtos.CodProduto
          bProdutos.NomProduto     = INPUT Produtos.NomProduto
          bProdutos.ValProduto = INPUT Produtos.ValProduto.
          
 
   RUN piHabilitaBotoes (INPUT TRUE).
   RUN piHabilitaCampos (INPUT FALSE).
   RUN piOpenQuery.
END.
 
ON 'choose' OF bt-canc DO:
    RUN piHabilitaBotoes (INPUT TRUE).
    RUN piHabilitaCampos (INPUT FALSE).
    RUN piMostra.
END.
 
ON CHOOSE OF bt-rel DO:
    DEFINE VARIABLE cArq AS CHARACTER NO-UNDO.
    DEFINE FRAME f-cab HEADER
        "Relatorio de Produtos" AT 1
        TODAY TO 120
        WITH PAGE-TOP WIDTH 120.
    DEFINE FRAME f-dados
        Produtos.CodProduto
        Produtos.NomProduto
        Produtos.ValProduto
        WITH DOWN WIDTH 120.
    
    ASSIGN cArq = SESSION:TEMP-DIRECTORY + "produtos.txt".
    
    OUTPUT TO VALUE(cArq) PAGE-SIZE 20 PAGED.
    VIEW FRAME f-cab.
    
    FOR EACH Produtos NO-LOCK:
        DISPLAY Produtos.CodProduto
                Produtos.NomProduto
                Produtos.ValProduto
                WITH FRAME f-dados.
    END.
    
    OUTPUT CLOSE.
    OS-COMMAND NO-WAIT VALUE(cArq).
END.

 
RUN piOpenQuery.
RUN piHabilitaBotoes (INPUT TRUE).
APPLY "choose" TO bt-pri.
 
WAIT-FOR WINDOW-CLOSE OF FRAME f-produtos.
 
PROCEDURE piMostra:
    IF AVAILABLE Produtos THEN DO:
        DISPLAY Produtos.CodProduto
                Produtos.NomProduto
                Produtos.ValProduto
                WITH FRAME f-produtos.
    END.
    ELSE DO:
        CLEAR FRAME f-produtos.
    END.
END PROCEDURE.
 
PROCEDURE piOpenQuery:
    DEFINE VARIABLE rRecord AS ROWID NO-UNDO.

    IF AVAILABLE Produtos THEN DO:
        ASSIGN rRecord = ROWID(cidades).
    END.

    OPEN QUERY qProdutos 
        FOR EACH Produtos.

    REPOSITION qProdutos TO ROWID rRecord NO-ERROR.
END PROCEDURE.
 
PROCEDURE piHabilitaBotoes:
    DEFINE INPUT PARAMETER pEnable AS LOGICAL NO-UNDO.
 
    DO WITH FRAME f-produtos:
       ASSIGN bt-pri:SENSITIVE  = pEnable
              bt-ant:SENSITIVE  = pEnable
              bt-prox:SENSITIVE = pEnable
              bt-ult:SENSITIVE  = pEnable
              bt-sair:SENSITIVE = pEnable
              bt-add:SENSITIVE  = pEnable
              bt-mod:SENSITIVE  = pEnable
              bt-del:SENSITIVE  = pEnable
              bt-rel:SENSITIVE  = pEnable
              bt-save:SENSITIVE = NOT pEnable
              bt-canc:SENSITIVE = NOT pEnable.
    END.
END PROCEDURE.
 
PROCEDURE piHabilitaCampos:
    DEFINE INPUT PARAMETER pEnable AS LOGICAL NO-UNDO.
 
    DO WITH FRAME f-produtos:
       ASSIGN Produtos.NomProduto:SENSITIVE     = pEnable
              Produtos.ValProduto:SENSITIVE = pEnable.
    END.
END PROCEDURE.
