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
 
DEFINE QUERY qCidades FOR cidades SCROLLING.
 
DEFINE BUFFER bCid  FOR cidades.
 
DEFINE FRAME f-cidades
    SKIP(1)
    bt-pri AT 10
    bt-ant 
    bt-prox 
    bt-ult SPACE(3) 
    bt-add bt-mod bt-del bt-rel SPACE(3)
    bt-save bt-canc SPACE(3)
    bt-sair  SKIP(2)
    cidades.CodCidade  COLON 20
    cidades.NomCidade     COLON 20
    cidades.CodUF COLON 20
    WITH SIDE-LABELS THREE-D SIZE 152 BY 12
         VIEW-AS DIALOG-BOX TITLE "Gerenciamento de Cidades".
 
ON 'choose' OF bt-pri DO:
    GET FIRST qCidades.
    RUN piMostra.
END.
 
ON 'choose' OF bt-ant DO:
    GET PREV qCidades.
    IF AVAILABLE cidades THEN
        RUN piMostra.
    ELSE
        GET FIRST qCidades.
END.
 
ON 'choose' OF bt-prox DO:
    GET NEXT qCidades.
    IF AVAILABLE cidades THEN
        RUN piMostra.
    ELSE
        GET LAST qCidades.
END.
 
ON 'choose' OF bt-ult DO:
    GET LAST qCidades.
    RUN piMostra.
END.
 
ON 'choose' OF bt-add DO:
    ASSIGN cAction = "add".
    RUN piHabilitaBotoes (INPUT FALSE).
    RUN piHabilitaCampos (INPUT TRUE).
    ASSIGN cidades.CodCidade:SENSITIVE     = TRUE.
    CLEAR FRAME f-cidades.
    DISPLAY NEXT-VALUE(seqcidade) @ cidades.CodCidade WITH FRAME f-cidades.
END.
 
ON 'choose' OF bt-mod DO:
    IF TRIM(cidades.CodCidade:SCREEN-VALUE IN FRAME f-cidades) = "" THEN DO:
            MESSAGE "Registre uma cidade para poder usar essa opcao."
                VIEW-AS ALERT-BOX INFORMATION.
            RETURN NO-APPLY.
     END.
    ELSE DO:
        ASSIGN cAction = "mod".
        RUN piHabilitaBotoes (INPUT FALSE).
        RUN piHabilitaCampos (INPUT TRUE).
        DISPLAY cidades.CodCidade WITH FRAME f-cidades.
        RUN piMostra.
    END.
END.
 
ON 'choose' OF bt-del DO:
    DEFINE VARIABLE lConf AS LOGICAL     NO-UNDO.
    DEFINE BUFFER bCidades FOR cidades.
    
    IF TRIM(cidades.CodCidade:SCREEN-VALUE IN FRAME f-cidades) = "" THEN DO:
            MESSAGE "Registre uma cidade para poder usar essa opcao."
                VIEW-AS ALERT-BOX INFORMATION.
            RETURN NO-APPLY.
     END.
    
    MESSAGE "Confirma a eliminacao da Cidade?" cidades.CodCidade "?" UPDATE lConf
            VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
                TITLE "Eliminacao".
    IF  lConf THEN DO:
        FIND bCidades
            WHERE bCidades.codcidade = cidades.codcidade
            EXCLUSIVE-LOCK NO-ERROR.
            DELETE bCidades.
    END.
    GET FIRST qCidades.
    RUN piMostra.
END.
 
ON CHOOSE OF bt-save DO:
  DEFINE VARIABLE cNome AS CHARACTER NO-UNDO.
  DEFINE VARIABLE cUF   AS CHARACTER NO-UNDO.
  DEFINE VARIABLE iCod  AS INTEGER   NO-UNDO.

  ASSIGN
    cNome = TRIM(cidades.nomcidade:SCREEN-VALUE  IN FRAME f-cidades)
    cUF   = TRIM(cidades.coduf:SCREEN-VALUE      IN FRAME f-cidades).

  IF cNome = "" OR cUF = "" THEN DO:
    MESSAGE "Preencha todos os campos (Cidade e UF)." VIEW-AS ALERT-BOX INFO.
    RETURN NO-APPLY.
  END.

  IF TRIM(cidades.codcidade:SCREEN-VALUE IN FRAME f-cidades) <> "" THEN
    ASSIGN iCod = INTEGER(cidades.codcidade:SCREEN-VALUE IN FRAME f-cidades) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
    MESSAGE "C¢digo da cidade inv†lido." VIEW-AS ALERT-BOX ERROR.
    RETURN NO-APPLY.
  END.

  IF cAction = "add" THEN DO:
    CREATE bCid.
    ASSIGN
      bCid.CodCidade = iCod
      bCid.NomCidade = cNome
      bCid.CodUF     = CAPS(cUF).
  END.
  ELSE IF cAction = "mod" THEN DO:
    FIND FIRST bCid
         WHERE bCid.CodCidade = iCod
         EXCLUSIVE-LOCK NO-ERROR.
    IF NOT AVAILABLE bCid THEN DO:
      MESSAGE "Erro: Cidade n∆o encontrada para alteraá∆o!" VIEW-AS ALERT-BOX ERROR.
      RETURN NO-APPLY.
    END.
    ASSIGN
      bCid.NomCidade = cNome
      bCid.CodUF     = CAPS(cUF).
  END.

  ASSIGN cidades.CodCidade:SENSITIVE     = FALSE.
  RUN piHabilitaBotoes (TRUE).
  RUN piHabilitaCampos (FALSE).
  RUN piOpenQuery.
END.
 
ON 'choose' OF bt-canc DO:
    RUN piHabilitaBotoes (INPUT TRUE).
    ASSIGN cidades.CodCidade:SENSITIVE     = FALSE.
    RUN piHabilitaCampos (INPUT FALSE).
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
         VIEW-AS DIALOG-BOX TITLE "Exportar Cidades".
    
    IF TRIM(cidades.CodCidade:SCREEN-VALUE IN FRAME f-cidades) = "" THEN DO:
            MESSAGE "Nao ha cidades para exportar."
                VIEW-AS ALERT-BOX INFORMATION.
            RETURN NO-APPLY.
       END.
         
    ASSIGN bt-csv:SENSITIVE  = TRUE
           bt-json:SENSITIVE  = TRUE.
    
        ON CHOOSE OF bt-csv IN FRAME f-export 
            DO:           
                DEFINE VARIABLE cArq AS CHARACTER NO-UNDO.
                ASSIGN cArq = SESSION:TEMP-DIRECTORY + "cidades.csv".
                OUTPUT to value(cArq).
                
                PUT UNFORMATTED
                "CodCidade;Cidade;Estado" SKIP.
                FOR EACH cidades NO-LOCK:
                    PUT UNFORMATTED SKIP
                        cidades.CodCidade    ";"
                        cidades.NomCidade       ";"
                        cidades.CodUF      ";".
                END.
                OUTPUT close.
                OS-COMMAND NO-WAIT VALUE("notepad.exe " + cArq).
                RUN piOpenQuery.
            END.
    ON CHOOSE OF bt-json IN FRAME f-export DO:
            DEFINE VARIABLE cArq    AS CHARACTER  NO-UNDO.
            DEFINE VARIABLE oObj    AS JsonObject NO-UNDO.
            DEFINE VARIABLE aCidades   AS JsonArray  NO-UNDO.
            DEFINE VARIABLE oOrd    AS JsonObject NO-UNDO.
    
            ASSIGN cArq = SESSION:TEMP-DIRECTORY + "cidades.json".
            aCidades = NEW JsonArray(). 
            FOR EACH cidades NO-LOCK:
                oObj = NEW JsonObject().
                oObj:add("Codigo Cidade", cidades.CodCidade).
                oObj:add("Cidade", cidades.NomCidade).
                oObj:add("Estado", cidades.CodUF).
                    aCidades:add(oObj).
            END.
            DEFINE VARIABLE lcTxt AS LONGCHAR NO-UNDO.
            aCidades:WriteFile(INPUT cArq, INPUT YES, INPUT "utf-8").
    
            OS-COMMAND NO-WAIT VALUE("notepad " + cArq).
            RUN piOpenQuery.
      END.
    
    VIEW FRAME f-export.
    
    WAIT-FOR CHOOSE OF bt-csv IN FRAME f-export 
    OR CHOOSE OF bt-json IN FRAME f-export 
    OR WINDOW-CLOSE OF FRAME f-export.
END.

 
RUN piOpenQuery.
RUN piHabilitaBotoes (INPUT TRUE).
APPLY "choose" TO bt-pri.

DO WITH FRAME f-cidades:
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
    
        FRAME f-cidades:BGCOLOR = 15
        
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
END.
 
VIEW FRAME f-cidades.  
WAIT-FOR WINDOW-CLOSE OF FRAME f-cidades.
 
PROCEDURE piMostra:
    IF AVAILABLE cidades THEN DO:
        DISPLAY cidades.CodCidade cidades.NomCidade cidades.CodUF
             WITH FRAME f-cidades.
    END.
    ELSE DO:
        CLEAR FRAME f-cidades.
    END.
END PROCEDURE.
 
PROCEDURE piOpenQuery:
    DEFINE VARIABLE rRecord AS ROWID NO-UNDO.

    IF AVAILABLE cidades THEN DO:
        ASSIGN rRecord = ROWID(cidades).
    END.

    OPEN QUERY qCidades 
        FOR EACH cidades.

    REPOSITION qCidades TO ROWID rRecord NO-ERROR.
END PROCEDURE.
 
PROCEDURE piHabilitaBotoes:
    DEFINE INPUT PARAMETER pEnable AS LOGICAL NO-UNDO.
 
    DO WITH FRAME f-cidades:
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
 
    DO WITH FRAME f-cidades:
       ASSIGN cidades.NomCidade:SENSITIVE     = pEnable
              cidades.CodUF:SENSITIVE = pEnable.
    END.
END PROCEDURE.
