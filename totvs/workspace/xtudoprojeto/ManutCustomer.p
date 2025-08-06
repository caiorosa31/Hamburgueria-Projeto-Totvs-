USING Progress.Json.ObjectModel.JsonArray FROM PROPATH.
USING Progress.Json.ObjectModel.JsonObject FROM PROPATH.

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
DEFINE BUTTON bt-rel LABEL "Relatorio".
DEFINE BUTTON bt-csv LABEL "Gerar csv".
DEFINE BUTTON bt-json LABEL "Exportar JSON".
 
DEFINE VARIABLE cAction  AS CHARACTER   NO-UNDO.
 
DEFINE QUERY qCust FOR customer, salesrep SCROLLING.
 
DEFINE BUFFER bCust  FOR customer.
DEFINE BUFFER bSales FOR salesrep.
 
DEFINE FRAME f-cust
    bt-pri AT 10
    bt-ant 
    bt-prox 
    bt-ult SPACE(3) 
    bt-add bt-mod bt-del bt-rel bt-csv bt-json SPACE(3)
    bt-save bt-canc SPACE(3)
    bt-sair  SKIP(1)
    customer.custnum  COLON 20
    customer.NAME     COLON 20
    customer.salesrep COLON 20 salesrep.repname NO-LABELS  
    customer.address  COLON 20
    customer.comments VIEW-AS EDITOR SIZE 70 BY 3 SCROLLBAR-VERTICAL COLON 20
    WITH SIDE-LABELS THREE-D SIZE 140 BY 12
         VIEW-AS DIALOG-BOX TITLE "Manutencao de Clientes".
 
ON 'choose' OF bt-pri DO:
    GET FIRST qCust.
    RUN piMostra.
END.
 
ON 'choose' OF bt-ant DO:
    GET PREV qCust.
    RUN piMostra.
END.
 
ON 'choose' OF bt-prox DO:
    GET NEXT qCust.
    RUN piMostra.
END.
 
ON 'choose' OF bt-ult DO:
    GET LAST qCust.
    RUN piMostra.
END.
 
ON 'choose' OF bt-add DO:
    ASSIGN cAction = "add".
    RUN piHabilitaBotoes (INPUT FALSE).
    RUN piHabilitaCampos (INPUT TRUE).
    CLEAR FRAME f-cust.
    DISPLAY NEXT-VALUE(NextCustNum) @ customer.custnum WITH FRAME f-cust.
    ASSIGN customer.comments:SCREEN-VALUE = "". 
END.
 
ON 'choose' OF bt-mod DO:
    ASSIGN cAction = "mod".
    RUN piHabilitaBotoes (INPUT FALSE).
    RUN piHabilitaCampos (INPUT TRUE).
    DISPLAY customer.custnum WITH FRAME f-cust.
    RUN piMostra.
    ASSIGN customer.comments:SCREEN-VALUE = "". 
END.
 
ON 'choose' OF bt-del DO:
    DEFINE VARIABLE lConf AS LOGICAL     NO-UNDO.
    DEFINE BUFFER bCustomer FOR customer.
    MESSAGE "Confirma a eliminacao do customer" customer.custnum "?" UPDATE lConf
            VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
                TITLE "Elimina‡Æo".
    IF  lConf THEN DO:
        FIND bCustomer
            WHERE bCustomer.custnum = customer.custnum
            EXCLUSIVE-LOCK NO-ERROR.
        IF  AVAILABLE bCustomer THEN DO:
            FOR EACH invoice OF customer EXCLUSIVE-LOCK:
                DELETE invoice.
            END.
            FOR EACH order OF customer EXCLUSIVE-LOCK:
                DELETE order.
            END.
            DELETE bCustomer.
            RUN piOpenQuery.
        END.
    END.
END.
 
ON 'leave' OF customer.salesrep DO:
    DEFINE VARIABLE lValid AS LOGICAL     NO-UNDO.
    RUN piValidaSalesrep (INPUT customer.salesrep:SCREEN-VALUE, 
                          OUTPUT lValid).
    IF  lValid = NO THEN DO:
        RETURN NO-APPLY.
    END.
    DISPLAY bSales.RepName @ salesrep.RepName WITH FRAME f-cust.
END.
 
ON 'choose' OF bt-save DO:
   DEFINE VARIABLE lValid AS LOGICAL     NO-UNDO.
 
   RUN piValidaSalesrep (INPUT customer.salesrep:SCREEN-VALUE, 
                         OUTPUT lValid).
   IF  lValid = NO THEN DO:
       RETURN NO-APPLY.
   END.
 
   IF cAction = "add" THEN DO:
      CREATE bCust.
      ASSIGN bCust.custNum  = INPUT customer.CustNum.
   END.
   IF  cAction = "mod" THEN DO:
       FIND FIRST bCust 
            WHERE bCust.custnum = customer.custnum
            EXCLUSIVE-LOCK NO-ERROR.
   END.
   ASSIGN bCust.NAME     = INPUT customer.NAME
          bCust.salesrep = INPUT customer.salesrep
          bCust.address  = INPUT customer.address
          bCust.comments = INPUT customer.comments.
 
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
        "Relatorio de Customers" AT 1
        TODAY TO 120
        WITH PAGE-TOP WIDTH 120.
    DEFINE FRAME f-dados
        Customer.CustNum
        Customer.Name
        Customer.State
        customer.salesrep
        Salesrep.RepName
        WITH DOWN WIDTH 120.
    ASSIGN cArq = SESSION:TEMP-DIRECTORY + "sports.txt".
    OUTPUT to value(cArq) page-size 20 paged.
    VIEW FRAME f-cab.
    FOR EACH customer NO-LOCK WITH FRAME f-dados:
        FIND FIRST salesrep 
            WHERE Salesrep.SalesRep = Customer.SalesRep 
            NO-LOCK NO-ERROR.
        DISPLAY Customer.CustNum
            Customer.Name
            Customer.State
            customer.salesrep
            Salesrep.RepName WHEN AVAILABLE salesrep
            WITH FRAME f-dados.
    END.
    OUTPUT close.
    OS-COMMAND NO-WAIT VALUE(cArq).
END.

ON CHOOSE OF bt-csv DO:
    DEFINE VARIABLE cArq AS CHARACTER NO-UNDO.
    ASSIGN cArq = SESSION:TEMP-DIRECTORY + "sports.csv".
    OUTPUT to value(cArq).
    FOR EACH customer NO-LOCK:
        FIND FIRST salesrep 
            WHERE Salesrep.SalesRep = Customer.SalesRep 
            NO-LOCK NO-ERROR.
        PUT UNFORMATTED
            Customer.CustNum    ";"
            Customer.Name       ";"
            Customer.State      ";"
            customer.salesrep   ";".
        IF AVAILABLE salesrep THEN
            PUT UNFORMATTED
                Salesrep.RepName.
            PUT UNFORMATTED SKIP.
    END.
    OUTPUT close.
    OS-COMMAND NO-WAIT VALUE("notepad " + cArq).
END.

ON CHOOSE OF bt-json DO:
    DEFINE VARIABLE cArq    AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE oObj    AS JsonObject NO-UNDO.
    DEFINE VARIABLE aCust   AS JsonArray  NO-UNDO.
    DEFINE VARIABLE aOrders AS JsonArray  NO-UNDO.
    DEFINE VARIABLE oOrd    AS JsonObject NO-UNDO.
    
    ASSIGN cArq = SESSION:TEMP-DIRECTORY + "sports.json".
    aCust = NEW JsonArray(). 
    FOR EACH customer NO-LOCK:
        FIND FIRST salesrep 
            WHERE Salesrep.SalesRep = Customer.SalesRep 
            NO-LOCK NO-ERROR.
            oObj = NEW JsonObject().
            oObj:add("CustNum", Customer.CustNum).
            oObj:add("Name", Customer.Name).
            oObj:add("State", Customer.State).
            oObj:add("Salesrep", customer.salesrep).
        IF AVAILABLE salesrep THEN
           oObj:add("Repname", Salesrep.RepName).
        aOrders = NEW JsonArray().
        FOR EACH order NO-LOCK 
            WHERE order.custnum = customer.custnum:
            oOrd = NEW JsonObject().
            oOrd:add("ordernum", Order.Ordernum).
            oOrd:add("orderdate", Order.OrderDate).
            aOrders:add(oOrd).
        END.
        oObj:add("OrderList", aOrders).
        aCust:add(oObj).
    END.
    DEFINE VARIABLE lcTxt AS LONGCHAR NO-UNDO.
    aCust:WriteFile(INPUT cArq, INPUT YES, INPUT "utf-8").
    
/*    output to value(cArq).     */
/*    put unformatted lctxt skip.*/
/*    OUTPUT close.              */
    
    OS-COMMAND NO-WAIT VALUE("notepad " + cArq).
END.
 
RUN piOpenQuery.
RUN piHabilitaBotoes (INPUT TRUE).
APPLY "choose" TO bt-pri.
 
WAIT-FOR WINDOW-CLOSE OF FRAME f-cust.
 
PROCEDURE piMostra:
    IF AVAILABLE customer THEN DO:
        DISPLAY customer.custnum customer.NAME customer.salesrep
             salesrep.repname customer.address customer.comments
             WITH FRAME f-cust.
    END.
    ELSE DO:
        CLEAR FRAME f-cust.
        ASSIGN customer.comments:SCREEN-VALUE IN FRAME f-cust = "".
    END.
END PROCEDURE.
 
PROCEDURE piOpenQuery:
    DEFINE VARIABLE rRecord AS ROWID       NO-UNDO.
    IF  AVAILABLE customer THEN DO:
        ASSIGN rRecord = ROWID(customer).
    END.
    OPEN QUERY qCust 
        FOR EACH customer, 
           FIRST salesrep WHERE salesrep.salesrep = customer.salesrep.
 
    REPOSITION qCust TO ROWID rRecord NO-ERROR.
END PROCEDURE.
 
PROCEDURE piHabilitaBotoes:
    DEFINE INPUT PARAMETER pEnable AS LOGICAL NO-UNDO.
 
    DO WITH FRAME f-cust:
       ASSIGN bt-pri:SENSITIVE  = pEnable
              bt-ant:SENSITIVE  = pEnable
              bt-prox:SENSITIVE = pEnable
              bt-ult:SENSITIVE  = pEnable
              bt-sair:SENSITIVE = pEnable
              bt-add:SENSITIVE  = pEnable
              bt-mod:SENSITIVE  = pEnable
              bt-del:SENSITIVE  = pEnable
              bt-rel:SENSITIVE  = pEnable
              bt-csv:SENSITIVE  = pEnable
              bt-json:SENSITIVE  = pEnable
              bt-save:SENSITIVE = NOT pEnable
              bt-canc:SENSITIVE = NOT pEnable.
    END.
END PROCEDURE.
 
PROCEDURE piHabilitaCampos:
    DEFINE INPUT PARAMETER pEnable AS LOGICAL NO-UNDO.
 
    DO WITH FRAME f-cust:
       ASSIGN customer.NAME:SENSITIVE     = pEnable
              customer.salesrep:SENSITIVE = pEnable
              customer.address:SENSITIVE  = pEnable
              customer.comments:SENSITIVE = pEnable.
    END.
END PROCEDURE.
 
PROCEDURE piValidaSalesrep:
    DEFINE INPUT PARAMETER pSalesrep AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pValid AS LOGICAL NO-UNDO INITIAL NO.
    FIND FIRST bSales
        WHERE bSales.salesrep = pSalesrep
        NO-LOCK NO-ERROR.
    IF  NOT AVAILABLE bSales THEN DO:
        MESSAGE "SalesRep" pSalesrep "nao existe!!!"
                VIEW-AS ALERT-BOX ERROR.
        ASSIGN pValid = NO.
    END.
    ELSE 
       ASSIGN pValid = YES.
END PROCEDURE.
