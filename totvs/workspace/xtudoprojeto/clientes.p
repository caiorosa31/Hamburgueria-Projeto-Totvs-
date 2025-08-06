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
 
DEFINE QUERY qClientes FOR clientes SCROLLING.
 
DEFINE BUFFER bClientes  FOR clientes.
DEFINE BUFFER bCidades FOR cidades.
 
DEFINE FRAME f-clientes
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
    Clientes.Observacao     COLON 20
    WITH SIDE-LABELS THREE-D SIZE 140 BY 12
         VIEW-AS DIALOG-BOX TITLE "Manutencao de Clientes".
 
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
    CLEAR FRAME f-clientes.
    DISPLAY NEXT-VALUE(seqcliente) @ Clientes.CodCliente WITH FRAME f-clientes.
END.
 
ON 'choose' OF bt-mod DO:
    ASSIGN cAction = "mod".
    RUN piHabilitaBotoes (INPUT FALSE).
    RUN piHabilitaCampos (INPUT TRUE).
    DISPLAY Clientes.CodCliente WITH FRAME f-clientes.
    RUN piMostra.
END.
 
ON 'choose' OF bt-del DO:
    DEFINE VARIABLE lConf AS LOGICAL     NO-UNDO.
    DEFINE BUFFER bClientesomer FOR Clientes.
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
    
   DEFINE VARIABLE lValid AS LOGICAL     NO-UNDO.
 
   RUN piValidaCidades (INPUT clientes.codcidade:SCREEN-VALUE, 
                         OUTPUT lValid).
   IF  lValid = NO THEN DO:
       RETURN NO-APPLY.
   END.
 
   IF cAction = "add" THEN DO:
      CREATE bClientes.
      ASSIGN bClientes.Codcliente  = INPUT Clientes.CodCliente.
   END.
   IF  cAction = "mod" THEN DO:
       FIND FIRST bClientes 
            WHERE bClientes.Codcliente = Clientes.CodCliente
            EXCLUSIVE-LOCK NO-ERROR.
   END.
   ASSIGN bClientes.CodCliente  = INPUT Clientes.CodCliente
          bClientes.NomCliente     = INPUT Clientes.NomCliente
          bClientes.CodCidade = INPUT Clientes.CodCidade
          bClientes.CodEndereco = INPUT Clientes.CodEndereco
          bClientes.Observacao = INPUT Clientes.Observacao.
 
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
        "Relatorio de Clientes" AT 1
        TODAY TO 150
        WITH PAGE-TOP WIDTH 150.
    DEFINE FRAME f-dados
        Clientes.CodCliente  FORMAT "9999"         LABEL "Codigo"    
        Clientes.NomCliente  FORMAT "x(25)"        LABEL "Nome"     
        Clientes.CodCidade   FORMAT "999"          LABEL "Cidade"   
        Clientes.CodEndereco FORMAT "x(40)"         LABEL "Endereco"  
        Clientes.Observacao  FORMAT "x(50)"        LABEL "Observacoes"
        WITH DOWN WIDTH 150.
    
    ASSIGN cArq = SESSION:TEMP-DIRECTORY + "clientes.txt".
    
    OUTPUT TO VALUE(cArq) PAGE-SIZE 25 PAGED.
    VIEW FRAME f-cab.
    
    FOR EACH Clientes NO-LOCK:
        DISPLAY Clientes.CodCliente
                Clientes.NomCliente
                Clientes.CodCidade
                Clientes.CodEndereco
                Clientes.Observacao
                WITH FRAME f-dados.
    END.
    
    OUTPUT CLOSE.
    OS-COMMAND NO-WAIT VALUE(cArq).
END.

 
RUN piOpenQuery.
RUN piHabilitaBotoes (INPUT TRUE).
APPLY "choose" TO bt-pri.
 
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
        ASSIGN rRecord = ROWID(cidades).
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
        ASSIGN pValid = NO.
    END.
    ELSE 
       ASSIGN pValid = YES.
END PROCEDURE.
