DEF QUERY q-cust FOR customer SCROLLING.

DEF BROWSE b-cust QUERY q-cust DISPLAY
        customer.custnum   customer.name
        customer.city       customer.country
        WITH SEPARATORS 5 DOWN SIZE 60 BY 10.

DEF BUTTON bt-det LABEL "Detalhe" SIZE 10 BY 1.

DEF FRAME f-dados
    b-cust
    bt-det
    WITH NO-LABELS.
DEF FRAME f-det 
    customer.custnum
    customer.NAME
    customer.salesrep
    customer.balance
    WITH 1 DOWN SIDE-LABELS THREE-D 
        1 COLUMN TITLE "Detalhes".

ON ITERATION-CHANGED OF b-cust DO:
/*    MESSAGE customer.NAME
        VIEW-AS ALERT-BOX INFO BUTTONS OK. */
    APPLY "choose" TO bt-det.
END.
ON choose OF bt-det DO:
    IF AVAIL customer THEN DO:
        DISP customer.custnum
             customer.NAME
             customer.salesrep
             customer.balance
             WITH FRAME f-det.
    END.
END.

OPEN QUERY q-cust 
    FOR EACH customer NO-LOCK.

ENABLE ALL WITH FRAME f-dados.
WAIT-FOR GO OF FRAME f-dados.
