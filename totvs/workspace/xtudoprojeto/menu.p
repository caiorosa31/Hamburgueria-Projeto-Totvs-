ASSIGN CURRENT-WINDOW:HIDDEN = TRUE.

DEFINE BUTTON bt-cidades LABEL "Cidades".
DEFINE BUTTON bt-produtos LABEL "Produtos".
DEFINE BUTTON bt-clientes LABEL "Clientes".
DEFINE BUTTON bt-pedidos LABEL "Pedidos".
DEFINE BUTTON bt-relatcliente LABEL "Relatorio de Clientes".
DEFINE BUTTON bt-relatpedido LABEL "Relatorio de Pedidos".
DEFINE BUTTON bt-sair LABEL "Sair" AUTO-ENDKEY.

DEFINE FRAME f-menu
    bt-cidades bt-produtos bt-clientes bt-pedidos bt-sair SKIP
    bt-relatcliente bt-relatpedido 
    WITH SIDE-LABELS THREE-D SIZE 140 BY 12
         VIEW-AS DIALOG-BOX TITLE "Hamburgueria XTudo".
 
ON 'choose' OF bt-cidades DO:
   RUN cidades.p.
END.
ON 'choose' OF bt-produtos DO:
    RUN produtos.p.
END.
ON 'choose' OF bt-clientes DO:
    RUN clientes.p.
END.
ON 'choose' OF bt-pedidos DO:
    run pedidos.p.
END.
ON 'choose' OF bt-relatcliente DO:
    MESSAGE "Relatorio clientes" VIEW-AS ALERT-BOX BUTTONS OK.
END.
ON 'choose' OF bt-relatpedido DO:
    MESSAGE "Relatorio Pedidos" VIEW-AS ALERT-BOX BUTTONS OK.
END.
RUN piHabilitaBotoes (INPUT TRUE).
VIEW FRAME f-menu. 
WAIT-FOR WINDOW-CLOSE OF FRAME f-menu.
 
 
PROCEDURE piHabilitaBotoes:
    DEFINE INPUT PARAMETER pEnable AS LOGICAL NO-UNDO.
 
    DO WITH FRAME f-menu:
       ASSIGN bt-cidades:SENSITIVE  = pEnable
              bt-produtos:SENSITIVE  = pEnable
              bt-clientes:SENSITIVE  = pEnable
              bt-pedidos:SENSITIVE  = pEnable
              bt-relatcliente:SENSITIVE  = pEnable
              bt-relatpedido:SENSITIVE  = pEnable
              bt-sair:SENSITIVE  = pEnable.
    END.
END PROCEDURE.
 