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
    bt-pri AT 10
    bt-ant 
    bt-prox 
    bt-ult SPACE(3) 
    bt-add bt-mod bt-del bt-rel SPACE(3)
    bt-save bt-canc SPACE(3)
    bt-sair  SKIP(1)
    cidades.CodCidade  COLON 20
    cidades.NomCidade     COLON 20
    cidades.CodUF COLON 20
    WITH SIDE-LABELS THREE-D SIZE 140 BY 12
         VIEW-AS DIALOG-BOX TITLE "Manutencao de Clientes".
 
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
    CLEAR FRAME f-cidades.
    DISPLAY NEXT-VALUE(seqcidade) @ cidades.CodCidade WITH FRAME f-cidades.
END.
 
ON 'choose' OF bt-mod DO:
    IF NOT AVAIL cidades THEN DO:
        MESSAGE "Este registro nao pode ser alterado pois nao possui codigo de cidade!"
            VIEW-AS ALERT-BOX ERROR BUTTONS OK.
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
    MESSAGE "Confirma a eliminacao do customer" cidades.CodCidade "?" UPDATE lConf
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
 
ON 'choose' OF bt-save DO:
 
   IF cAction = "add" THEN DO:
      CREATE bCid.
      ASSIGN bCid.codcidade  = INPUT cidades.codcidade.
   END.
   IF  cAction = "mod" THEN DO:
       FIND FIRST bCid 
            WHERE bCid.codcidade = cidades.CodCidade
            EXCLUSIVE-LOCK NO-ERROR.
       IF NOT AVAILABLE bCid THEN DO:
           MESSAGE "Erro: Cidade n∆o encontrada para alteraá∆o!" VIEW-AS ALERT-BOX ERROR.
           RETURN NO-APPLY.
       END.
   END.
   
   ASSIGN bCid.NomCidade     = INPUT cidades.nomcidade
          bCid.CodUF = INPUT cidades.coduf
          bCid.CodCidade  = INPUT cidades.CodCidade.
 
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
        "Relatorio de Cidades" AT 1
        TODAY TO 120
        WITH PAGE-TOP WIDTH 120.
    DEFINE FRAME f-dados
        cidades.CodCidade
        cidades.NomCidade
        cidades.CodUF
        WITH DOWN WIDTH 120.
    
    ASSIGN cArq = SESSION:TEMP-DIRECTORY + "cidades.txt".
    
    OUTPUT TO VALUE(cArq) PAGE-SIZE 20 PAGED.
    VIEW FRAME f-cab.
    
    FOR EACH cidades NO-LOCK:
        DISPLAY cidades.CodCidade
                cidades.NomCidade
                cidades.CodUF
                WITH FRAME f-dados.
    END.
    
    OUTPUT CLOSE.
    OS-COMMAND NO-WAIT VALUE(cArq).
END.

 
RUN piOpenQuery.
RUN piHabilitaBotoes (INPUT TRUE).
APPLY "choose" TO bt-pri.
 
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
