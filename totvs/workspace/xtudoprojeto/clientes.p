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
DEFINE BUTTON bt-consult LABEL "Consultar Cidades".
 
DEFINE VARIABLE cAction  AS CHARACTER   NO-UNDO.
 
DEFINE QUERY qClientes FOR clientes SCROLLING.
 
DEFINE BUFFER bClientes  FOR clientes.
DEFINE BUFFER bCidades FOR cidades.
 
DEFINE FRAME f-clientes
    SKIP(1)
    bt-pri AT 10
    bt-ant 
    bt-prox 
    bt-ult SPACE(3) 
    bt-add bt-mod bt-del bt-rel SPACE(3)
    bt-save bt-canc SPACE(3)
    bt-sair  SKIP(1)
    Clientes.CodCliente  COLON 20
    Clientes.NomCliente     COLON 20
    Clientes.CodCidade      COLON 20 cidades.nomcidade NO-LABELS
    Clientes.CodEndereco    COLON 20
    Clientes.Observacao     COLON 20 SKIP(1)
    bt-consult
    WITH SIDE-LABELS THREE-D SIZE 152 BY 13
         VIEW-AS DIALOG-BOX TITLE "Gerenciamento de Clientes".


ON 'choose' OF bt-consult DO:
    RUN consultarcidades.p.
END. 
 
 
ON 'choose' OF bt-pri DO:
    GET FIRST qClientes.
    RUN piMostra.
END.
 
ON 'choose' OF bt-ant DO:
    GET PREV qClientes.
    IF AVAILABLE clientes THEN
        RUN piMostra.
    ELSE
        GET FIRST qClientes.
END.
 
ON 'choose' OF bt-prox DO:
    GET NEXT qClientes.
    IF AVAILABLE clientes THEN
        RUN piMostra.
    ELSE
        GET LAST qClientes.
END.
 
ON 'choose' OF bt-ult DO:
    GET LAST qClientes.
    RUN piMostra.
END.
 
ON 'choose' OF bt-add DO:
    ASSIGN cAction = "add".
    RUN piHabilitaBotoes (INPUT FALSE).
    RUN piHabilitaCampos (INPUT TRUE).
    ASSIGN Clientes.CodCliente:SENSITIVE     = TRUE.
    CLEAR FRAME f-clientes.
    DISPLAY NEXT-VALUE(seqcliente) @ Clientes.CodCliente WITH FRAME f-clientes.
END.
 
ON 'choose' OF bt-mod DO:
    ASSIGN cAction = "mod".
    
    IF TRIM(Clientes.CodCliente:SCREEN-VALUE IN FRAME f-clientes) = "" THEN DO:
            MESSAGE "Registre um cliente para poder usar essa opcao."
                VIEW-AS ALERT-BOX INFO.
            RETURN NO-APPLY.
       END.
    
    RUN piHabilitaBotoes (INPUT FALSE).
    RUN piHabilitaCampos (INPUT TRUE).
    DISPLAY Clientes.CodCliente WITH FRAME f-clientes.
    RUN piMostra.
END.
 
ON 'choose' OF bt-del DO:
    DEFINE VARIABLE lConf AS LOGICAL     NO-UNDO.
    DEFINE BUFFER bClientesomer FOR Clientes.
    
    IF TRIM(Clientes.CodCliente:SCREEN-VALUE IN FRAME f-clientes) = "" THEN DO:
            MESSAGE "Registre um cliente para poder usar essa opcao."
                VIEW-AS ALERT-BOX INFO.
            RETURN NO-APPLY.
       END.
    
    MESSAGE "Confirma a eliminacao do Cliente" Clientes.CodCliente "?" UPDATE lConf
            VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
                TITLE "Eliminacao".
    IF  lConf THEN DO:
        FIND bClientesomer
            WHERE bClientesomer.Codcliente = Clientes.CodCliente
            EXCLUSIVE-LOCK NO-ERROR.
            DELETE bClientesomer.
    END.
    GET FIRST qClientes.
    RUN piMostra.
END.
 
ON 'leave' OF clientes.codcidade DO:
    DEFINE VARIABLE lValid AS LOGICAL     NO-UNDO.
    RUN piValidaCidades (INPUT clientes.codcidade:SCREEN-VALUE, 
                          OUTPUT lValid).
    IF  lValid = NO THEN DO:
        RETURN NO-APPLY.
    END.
    DISPLAY bCidades.nomcidade @ cidades.nomcidade WITH FRAME f-clientes.
    
END.

ON 'choose' OF bt-save DO:
  DEFINE VARIABLE cCliente AS CHARACTER NO-UNDO.
  DEFINE VARIABLE iCodCidade   AS INT NO-UNDO.
  DEFINE VARIABLE cEndereco AS CHARACTER NO-UNDO.
  DEFINE VARIABLE cObservacao AS CHARACTER NO-UNDO.
  DEFINE VARIABLE iCod  AS INTEGER   NO-UNDO.

  ASSIGN
    cCliente = TRIM(Clientes.NomCliente:SCREEN-VALUE  IN FRAME f-clientes)
    cEndereco = TRIM(Clientes.CodEndereco:SCREEN-VALUE  IN FRAME f-clientes)
    cObservacao = TRIM(Clientes.Observacao:SCREEN-VALUE  IN FRAME f-clientes)
    icod = INPUT Clientes.CodCliente
    icodcidade = INPUT Clientes.CodCidade.
    

  IF cCliente = "" OR icod = 0 OR icodcidade = 0 OR cEndereco = "" THEN DO:
    MESSAGE "Preencha todos os campos (Nome do Cliente, Codigo do cliente, Codigo da cidade, Endereco e a Observacao)." VIEW-AS ALERT-BOX INFO.
    RETURN NO-APPLY.
  END.


  IF TRIM(Clientes.CodCliente:SCREEN-VALUE IN FRAME f-clientes) <> "" THEN
    ASSIGN iCod = INTEGER(Clientes.CodCliente:SCREEN-VALUE IN FRAME f-clientes) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
    MESSAGE "C¢digo do Cliente inv†lido." VIEW-AS ALERT-BOX ERROR.
    RETURN NO-APPLY.
  END.


  IF cAction = "add" THEN DO:
    CREATE bClientes.
    ASSIGN bClientes.CodCliente  = icod
           bClientes.NomCliente     = cCliente
           bClientes.CodCidade = icodCidade
           bClientes.CodEndereco = cEndereco
           bClientes.Observacao = cObservacao.
  END.
  ELSE IF cAction = "mod" THEN DO:
    FIND FIRST bClientes
         WHERE bClientes.CodCliente = iCod
         EXCLUSIVE-LOCK NO-ERROR.
    IF NOT AVAILABLE bClientes THEN DO:
      MESSAGE "Erro: Cliente n∆o encontrada para alteraá∆o!" VIEW-AS ALERT-BOX ERROR.
      RETURN NO-APPLY.
    END.
    ASSIGN
      bClientes.NomCliente     = cCliente
      bClientes.CodCidade = icodCidade
      bClientes.CodEndereco = cEndereco
      bClientes.Observacao = cObservacao.
  END.

  ASSIGN Clientes.CodCliente:SENSITIVE     = FALSE.
  RUN piHabilitaBotoes (TRUE).
  RUN piHabilitaCampos (FALSE).
  RUN piOpenQuery.
END.
 
ON 'choose' OF bt-canc DO:
    RUN piHabilitaBotoes (INPUT TRUE).
    RUN piHabilitaCampos (INPUT FALSE).
    ASSIGN Clientes.CodCliente:SENSITIVE     = FALSE.
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
         
    IF TRIM(Clientes.CodCliente:SCREEN-VALUE IN FRAME f-clientes) = "" THEN DO:
            MESSAGE "Nao ha clientes para exportar."
                VIEW-AS ALERT-BOX INFO.
            RETURN NO-APPLY.
       END.
         
    ASSIGN bt-csv:SENSITIVE  = TRUE
           bt-json:SENSITIVE  = TRUE.
    
        ON CHOOSE OF bt-csv IN FRAME f-export 
            DO:           
                DEFINE VARIABLE cArq AS CHARACTER NO-UNDO.
                ASSIGN 
                    cArq = SESSION:TEMP-DIRECTORY + "clientes.csv".
                OUTPUT to value(cArq).
                
                PUT UNFORMATTED
                "CodCliente;NomCliente;CodEndereco;NomCidade" SKIP.
                FOR EACH clientes NO-LOCK:
                    FIND FIRST cidades
                        WHERE cidades.codcidade = clientes.codcidade 
                        NO-LOCK NO-ERROR.
                    PUT UNFORMATTED
                        Clientes.CodCliente    ";"
                        Clientes.NomCliente       ";"
                        Clientes.CodEndereco      ";"
                        Clientes.Observacao      ";".
                    IF AVAILABLE cidades THEN
                        PUT UNFORMATTED
                            cidades.nomcidade.
                    PUT UNFORMATTED SKIP.
                END.
                OUTPUT close.
                OS-COMMAND NO-WAIT VALUE("notepad.exe " + cArq).
            END.
    ON CHOOSE OF bt-json IN FRAME f-export DO:
            DEFINE VARIABLE cArq    AS CHARACTER  NO-UNDO.
            DEFINE VARIABLE oObj    AS JsonObject NO-UNDO.
            DEFINE VARIABLE aClientes   AS JsonArray  NO-UNDO.
            DEFINE VARIABLE oOrd    AS JsonObject NO-UNDO.
    
            ASSIGN cArq = SESSION:TEMP-DIRECTORY + "clientes.json".
            aClientes = NEW JsonArray(). 
            FOR EACH clientes NO-LOCK:
                FIND FIRST cidades
                    WHERE cidades.codcidade = clientes.codcidade 
                    NO-LOCK NO-ERROR.
                oObj = NEW JsonObject().
                oObj:add("Codigo Cliente", Clientes.CodCliente).
                oObj:add("Nome", Clientes.NomCliente).
                oObj:add("Endereco", Clientes.CodEndereco).
                oObj:add("Observacao", Clientes.Observacao).
                IF AVAILABLE cidades THEN
                    oObj:add("Cidades", cidades.nomcidade).
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

DO WITH FRAME f-clientes:
    ASSIGN
        /* Bot‰es de navegaá∆o */
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
        
        bt-consult:WIDTH = 29
        bt-consult:HEIGHT = 1.5
        bt-consult:FONT = 3
        bt-consult:FGCOLOR = 15
        
    
        FRAME f-clientes:BGCOLOR = 15 
        
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
        bt-consult:COL = 7.
END.

VIEW FRAME f-clientes.  
WAIT-FOR WINDOW-CLOSE OF FRAME f-clientes.
 
PROCEDURE piMostra:
    IF AVAILABLE Clientes THEN DO:
        DISPLAY Clientes.CodCliente
                Clientes.NomCliente
                Clientes.CodCidade
                Clientes.CodEndereco
                Clientes.Observacao
                WITH FRAME f-clientes.
    END.
    ELSE DO:
        CLEAR FRAME f-clientes.
    END.
END PROCEDURE.
 
PROCEDURE piOpenQuery:
    DEFINE VARIABLE rRecord AS ROWID NO-UNDO.

    IF AVAILABLE Clientes THEN DO:
        ASSIGN rRecord = ROWID(clientes).
    END.

    OPEN QUERY qClientes 
        FOR EACH Clientes.

    REPOSITION qClientes TO ROWID rRecord NO-ERROR.
END PROCEDURE.
 
PROCEDURE piHabilitaBotoes:
    DEFINE INPUT PARAMETER pEnable AS LOGICAL NO-UNDO.
 
    DO WITH FRAME f-clientes:
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
              bt-consult:SENSITIVE = NOT pEnable
              bt-canc:SENSITIVE = NOT pEnable.
    END.
END PROCEDURE.
 
PROCEDURE piHabilitaCampos:
    DEFINE INPUT PARAMETER pEnable AS LOGICAL NO-UNDO.
 
    DO WITH FRAME f-clientes:
       ASSIGN   Clientes.NomCliente:SENSITIVE = pEnable
                Clientes.CodCidade:SENSITIVE = pEnable
                Clientes.CodEndereco:SENSITIVE = pEnable
                Clientes.Observacao:SENSITIVE = pEnable.
    END.
END PROCEDURE.

PROCEDURE piValidaCidades:
    DEFINE INPUT PARAMETER pCodCidade AS INTEGER NO-UNDO.
    DEFINE OUTPUT PARAMETER pValid AS LOGICAL NO-UNDO INITIAL NO.
    FIND FIRST bCidades
        WHERE bCidades.codcidade = pCodCidade
        NO-LOCK NO-ERROR.
    IF  NOT AVAILABLE bCidades THEN DO:
        MESSAGE "Cidade" pCodCidade "nao existe!!!"
                VIEW-AS ALERT-BOX ERROR.
        RUN consultarcidades.p.
        ASSIGN pValid = NO.
    END.
    ELSE 
       ASSIGN pValid = YES.
END PROCEDURE.
