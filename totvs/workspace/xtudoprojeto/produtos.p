USING Progress.Json.ObjectModel.JsonArray FROM PROPATH.
USING Progress.Json.ObjectModel.JsonObject FROM PROPATH.
ASSIGN CURRENT-WINDOW:HIDDEN = TRUE.

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
    SKIP(1)
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
    WITH SIDE-LABELS THREE-D SIZE 152 BY 12
         VIEW-AS DIALOG-BOX TITLE "Gerenciamento de Produtos".
 
ON 'choose' OF bt-pri DO:
    GET FIRST qProdutos.
    RUN piMostra.
END.
 
ON 'choose' OF bt-ant DO:
    GET PREV qProdutos.
    IF AVAILABLE produtos THEN
        RUN piMostra.
    ELSE
        GET FIRST qProdutos.
END.
 
ON 'choose' OF bt-prox DO:
    GET NEXT qProdutos.
    IF AVAILABLE produtos THEN
        RUN piMostra.
    ELSE
        GET LAST qProdutos.
END.
 
ON 'choose' OF bt-ult DO:
    GET LAST qProdutos.
    RUN piMostra.
END.
 
ON 'choose' OF bt-add DO:
    ASSIGN cAction = "add".
    RUN piHabilitaBotoes (INPUT FALSE).
    RUN piHabilitaCampos (INPUT TRUE).
    ASSIGN Produtos.CodProduto:SENSITIVE     = TRUE.
    CLEAR FRAME f-produtos.
    DISPLAY NEXT-VALUE(seqproduto) @ Produtos.CodProduto WITH FRAME f-produtos.
END.
 
ON 'choose' OF bt-mod DO:
    ASSIGN cAction = "mod".
    
    IF TRIM(Produtos.CodProduto:SCREEN-VALUE IN FRAME f-produtos) = "" THEN DO:
            MESSAGE "Registre um produto para poder usar essa opcao."
                VIEW-AS ALERT-BOX INFO.
            RETURN NO-APPLY.
    END.
       
    RUN piHabilitaBotoes (INPUT FALSE).
    RUN piHabilitaCampos (INPUT TRUE).
    DISPLAY Produtos.CodProduto WITH FRAME f-produtos.
    RUN piMostra.
END.
 
ON 'choose' OF bt-del DO:
    DEFINE VARIABLE lConf AS LOGICAL     NO-UNDO.
    DEFINE BUFFER bProdutosb FOR produtos.
    
    IF TRIM(Produtos.CodProduto:SCREEN-VALUE IN FRAME f-produtos) = "" THEN DO:
            MESSAGE "Registre um produto para poder usar essa opcao."
                VIEW-AS ALERT-BOX INFO.
            RETURN NO-APPLY.
       END.
       
    MESSAGE "Confirma a eliminacao do produtos" Produtos.CodProduto "?" UPDATE lConf
            VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
                TITLE "Eliminacao".
    IF  lConf THEN DO:
        FIND bProdutosb
            WHERE bProdutosb.CodProduto = Produtos.CodProduto
            EXCLUSIVE-LOCK NO-ERROR.
            DELETE bProdutosb.
            MESSAGE "Produto deletado com sucesso!" VIEW-AS ALERT-BOX BUTTONS OK.
    END.
    GET FIRST qProdutos.
    RUN piMostra.
END.

ON 'choose' OF bt-save DO:
  DEFINE VARIABLE cProduto AS CHARACTER NO-UNDO.
  DEFINE VARIABLE dValor   AS DECIMAL FORMAT ">>>>>>>9.99" NO-UNDO.
  DEFINE VARIABLE iCod  AS INTEGER   NO-UNDO.

  ASSIGN
    cProduto = TRIM(Produtos.NomProduto:SCREEN-VALUE  IN FRAME f-produtos)
    dValor   = INPUT Produtos.ValProduto.

  IF cProduto = "" OR dValor = 0 THEN DO:
    MESSAGE "Preencha todos os campos (Nome do Produto e Valor)." VIEW-AS ALERT-BOX INFO.
    RETURN NO-APPLY.
  END.

  IF TRIM(Produtos.CodProduto:SCREEN-VALUE IN FRAME f-produtos) <> "" THEN
    ASSIGN iCod = INTEGER(Produtos.CodProduto:SCREEN-VALUE IN FRAME f-produtos) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
    MESSAGE "C¢digo do Produto inv†lido." VIEW-AS ALERT-BOX ERROR.
    RETURN NO-APPLY.
  END.

  IF cAction = "add" THEN DO:
    CREATE bProdutos.
    ASSIGN
      bProdutos.CodProduto = iCod
      bProdutos.NomProduto = cProduto
      bProdutos.ValProduto = dValor.
  END.
  ELSE IF cAction = "mod" THEN DO:
    FIND FIRST bProdutos
         WHERE bProdutos.CodProduto = iCod
         EXCLUSIVE-LOCK NO-ERROR.
    IF NOT AVAILABLE bProdutos THEN DO:
      MESSAGE "Erro: Produto n∆o encontrada para alteraá∆o!" VIEW-AS ALERT-BOX ERROR.
      RETURN NO-APPLY.
    END.
    ASSIGN
      bProdutos.NomProduto = cProduto
      bProdutos.ValProduto = dValor.
  END.

  ASSIGN Produtos.CodProduto:SENSITIVE     = FALSE.
  RUN piHabilitaBotoes (TRUE).
  RUN piHabilitaCampos (FALSE).
  RUN piOpenQuery.
END.
 
ON 'choose' OF bt-canc DO:
    RUN piHabilitaBotoes (INPUT TRUE).
    RUN piHabilitaCampos (INPUT FALSE).
    ASSIGN Produtos.CodProduto:SENSITIVE     = FALSE.
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
         VIEW-AS DIALOG-BOX TITLE "Exportar Produtos".
         
    IF TRIM(Produtos.CodProduto:SCREEN-VALUE IN FRAME f-produtos) = "" THEN DO:
            MESSAGE "Nao ha produtos para exportar."
                VIEW-AS ALERT-BOX INFO.
            RETURN NO-APPLY.
       END.
         
    ASSIGN bt-csv:SENSITIVE  = TRUE
           bt-json:SENSITIVE  = TRUE.
    
        ON CHOOSE OF bt-csv IN FRAME f-export 
            DO:           
                DEFINE VARIABLE cArq AS CHARACTER NO-UNDO.
                ASSIGN 
                    cArq = SESSION:TEMP-DIRECTORY + "produtos.csv".
                OUTPUT to value(cArq).
                
                PUT UNFORMATTED
                "CodProduto;NomProduto;ValProduto" SKIP.
                FOR EACH produtos NO-LOCK:
                    PUT UNFORMATTED SKIP
                        Produtos.CodProduto    ";"
                        Produtos.NomProduto       ";"
                        Produtos.ValProduto      ";".
                END.
                OUTPUT close.
                OS-COMMAND NO-WAIT VALUE("notepad.exe " + cArq).
            END.
    ON CHOOSE OF bt-json IN FRAME f-export DO:
            DEFINE VARIABLE cArq    AS CHARACTER  NO-UNDO.
            DEFINE VARIABLE oObj    AS JsonObject NO-UNDO.
            DEFINE VARIABLE aProdutos   AS JsonArray  NO-UNDO.
            DEFINE VARIABLE oOrd    AS JsonObject NO-UNDO.
    
            ASSIGN cArq = SESSION:TEMP-DIRECTORY + "produtos.json".
            aProdutos = NEW JsonArray(). 
            FOR EACH produtos NO-LOCK:
                oObj = NEW JsonObject().
                oObj:add("Codigo Produto", Produtos.CodProduto).
                oObj:add("Produto", Produtos.NomProduto).
                oObj:add("Valor", Produtos.ValProduto).
                    aProdutos:add(oObj).
            END.
            DEFINE VARIABLE lcTxt AS LONGCHAR NO-UNDO.
            aProdutos:WriteFile(INPUT cArq, INPUT YES, INPUT "utf-8").
    
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

DO WITH FRAME f-produtos:
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
    
        FRAME f-produtos:BGCOLOR = 15 
        
        bt-pri:COL = 7
        bt-ant:COL = 13
        bt-prox:COL = 19
        bt-ult:COL = 25
        
        bt-add:COL = 38
        bt-mod:COL = 50
        bt-del:COL = 67
        bt-rel:COL = 82
        bt-save:COL = 97
        bt-canc:COL = 110
        bt-sair:COL = 133.
END.

VIEW FRAME f-produtos. 
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
        ASSIGN rRecord = ROWID(produtos).
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
