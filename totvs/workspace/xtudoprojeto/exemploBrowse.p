DEFINE QUERY q-cust FOR customer SCROLLING.

DEFINE BROWSE b-cust QUERY q-cust DISPLAY
        customer.custnum   customer.name
        customer.city       customer.country
        WITH SEPARATORS 5 DOWN SIZE 60 BY 10.

DEFINE BUTTON bt-det LABEL "Detalhe" SIZE 10 BY 1.

DEFINE FRAME f-dados
    b-cust
    bt-det
    WITH NO-LABELS.
DEFINE FRAME f-det 
    customer.custnum
    customer.NAME
    customer.salesrep
    customer.balance
    WITH 1 DOWN SIDE-LABELS THREE-D 
        1 COLUMN TITLE "Detalhes".

ON ITERATION-CHANGED OF b-cust DO:
    APPLY "choose" TO bt-det.
END.
ON CHOOSE OF bt-det DO:
    IF AVAILABLE customer THEN DO:
        DISPLAY customer.custnum
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
