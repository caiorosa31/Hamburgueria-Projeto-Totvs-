ASSIGN CURRENT-WINDOW:HIDDEN = TRUE.

DEFINE BUTTON bt-cidades LABEL "Cidades" SIZE 15 BY 2 FONT 3.
DEFINE BUTTON bt-produtos LABEL "Produtos".
DEFINE BUTTON bt-clientes LABEL "Clientes".
DEFINE BUTTON bt-pedidos LABEL "Pedidos".
DEFINE BUTTON bt-relatcliente LABEL "Relatorio de Clientes".
DEFINE BUTTON bt-relatpedido LABEL "Relatorio de Pedidos".
DEFINE BUTTON bt-sair LABEL "Sair" AUTO-ENDKEY.

DEFINE IMAGE imgLogo FILENAME "C:\totvs\workspace\xtudoprojeto\hamburguer.bmp" SIZE 40 BY 9.
DEFINE VARIABLE txtTitulo AS CHARACTER NO-UNDO
    FORMAT "x(21)" 
    INITIAL "MENU DE GERENCIAMENTO" 
    VIEW-AS FILL-IN SIZE 50 BY 5 
    FONT 6. 


DEFINE FRAME f-menu
    imgLogo AT ROW 1 COL 57 SKIP(1)
    txtTitulo AT ROW 10 COL 59.3 NO-LABEL SKIP
    bt-cidades bt-produtos bt-clientes bt-pedidos bt-sair SKIP(1)
    bt-relatcliente bt-relatpedido 
    WITH SIDE-LABELS THREE-D SIZE 160 BY 22
         VIEW-AS DIALOG-BOX  TITLE "Gerenciamento de hamburgueria".
 
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
    RUN pedidos.p.
END.
ON 'choose' OF bt-relatcliente DO:
    DEFINE VARIABLE cArq AS CHARACTER NO-UNDO.

    ASSIGN cArq = SESSION:TEMP-DIRECTORY + "clientes.txt".

    OUTPUT TO VALUE(cArq) PAGE-SIZE 20 PAGED.

    PUT UNFORMATTED
        FILL(" ", 57) + "RELATORIO DE CLIENTES" SKIP(1)
        "Codigo     Nome                      Endereco                                 Cidade                Observacao" SKIP
        "--------  ------------------------- ---------------------------------------- --------------------- ----------------------------------------" SKIP.

    FOR EACH clientes NO-LOCK:
        FIND FIRST cidades WHERE cidades.codcidade = clientes.codcidade NO-LOCK NO-ERROR.

        PUT UNFORMATTED
            STRING(clientes.codcliente, ">>>>9") + "      "
            clientes.nomcliente FORMAT "x(25)" + " "
            clientes.codendereco FORMAT "x(38)"
            STRING(clientes.codcidade, ">>>>9") + "-" + (IF AVAILABLE cidades THEN cidades.nomcidade ELSE "") FORMAT "x(20)" + "     "
            clientes.observacao FORMAT "x(40)"
            SKIP.
    END.

    OUTPUT CLOSE.
    OS-COMMAND NO-WAIT VALUE(cArq).
END.
ON 'choose' OF bt-relatpedido DO:
    DEFINE VARIABLE cArq AS CHARACTER NO-UNDO.
    
    ASSIGN cArq = SESSION:TEMP-DIRECTORY + "pedidos.txt".

    OUTPUT TO VALUE(cArq) PAGE-SIZE 20 PAGED.
    
    PUT UNFORMATTED
    FILL(" ", 10) + "RELATORIO DE PEDIDOS" SKIP(1).

    FOR EACH pedidos NO-LOCK WITH FRAME f-ped:
        FIND clientes WHERE Clientes.CodCliente = Pedidos.CodCliente NO-LOCK NO-ERROR.
        FIND cidades WHERE cidades.CodCidade = Clientes.CodCidade NO-LOCK NO-ERROR.
        
        PUT UNFORMATTED
        SKIP(2) FILL("-", 84) SKIP(1)
        FILL(" ", 19) + "PEDIDO" SKIP(2).
        
        
        PUT UNFORMATTED
            "    Pedido: " + string(Pedidos.CodPedido) + "             " + "Data: " + string(Pedidos.DatPedido) SKIP.           
                IF AVAILABLE clientes THEN DO:
                    PUT UNFORMATTED
                    "      Nome: " + string(Clientes.CodCliente) + "-" + Clientes.NomCliente SKIP.     
                END.
                IF AVAILABLE cidades THEN
                PUT UNFORMATTED
                "  Endereco: " + Clientes.CodEndereco + " / " + cidades.NomCidade SKIP.
                PUT UNFORMATTED
                "Observacao: " + Pedidos.Observacao SKIP(2).
                
        PUT UNFORMATTED
            " Item      Produto         Valor Produto    Quantidade      Valor Total item         " SKIP
            "--------  --------------  ---------------  --------------  --------------------      " SKIP.
                
        FOR EACH itens WHERE Itens.CodPedido = Pedidos.CodPedido NO-LOCK.
            FIND produtos WHERE Produtos.CodProduto = Itens.CodProduto NO-LOCK NO-ERROR.
                
            PUT UNFORMATTED
            STRING(Itens.CodItem, ">>>9") + "       "    
            Produtos.NomProduto FORMAT "x(14)" + ""
            STRING(Produtos.ValProduto, ">>>>>>>9.99") + "          "
            STRING(Itens.NumQuantidade, ">>>9") + "          "
            STRING(Itens.ValTotal, ">>>>>>>9.99") SKIP(1).
                
        END.
        
        PUT UNFORMATTED
            SKIP(1) "Valor total do pedido: " + string(Pedidos.ValPedido, ">>>>>>>9.99") SKIP(1).
        
     END.
     

    OUTPUT CLOSE.
    OS-COMMAND NO-WAIT VALUE(cArq).
END.
RUN piHabilitaBotoes (INPUT TRUE).
VIEW FRAME f-menu.

DO WITH FRAME f-menu:
    ASSIGN
        bt-cidades:WIDTH = 20
        bt-cidades:HEIGHT = 2.5
        bt-cidades:FONT = 4
        bt-cidades:FGCOLOR = 15

        bt-produtos:WIDTH = 20
        bt-produtos:HEIGHT = 2.5
        bt-produtos:FONT = 4
        bt-produtos:FGCOLOR = 15

        bt-clientes:WIDTH = 20
        bt-clientes:HEIGHT = 2.5
        bt-clientes:FONT = 4
        bt-clientes:FGCOLOR = 15

        bt-pedidos:WIDTH = 20
        bt-pedidos:HEIGHT = 2.5
        bt-pedidos:FONT = 4
        bt-pedidos:FGCOLOR = 15

        bt-relatcliente:WIDTH = 28
        bt-relatcliente:HEIGHT = 2.5
        bt-relatcliente:FONT = 4
        bt-relatcliente:FGCOLOR = 15

        bt-relatpedido:WIDTH = 28
        bt-relatpedido:HEIGHT = 2.5
        bt-relatpedido:FONT = 4
        bt-relatpedido:FGCOLOR = 15

        bt-sair:WIDTH = 15
        bt-sair:HEIGHT = 2.5
        bt-sair:FONT = 4
        bt-sair:FGCOLOR = 15 

        txtTitulo:SCREEN-VALUE = "MENU DE GERENCIAMENTO"
        txtTitulo:SENSITIVE = FALSE
        txtTitulo:FGCOLOR = 4 
        FRAME f-menu:BGCOLOR = 15
        
        bt-cidades:COL = 30
        bt-produtos:COL = 50
        bt-clientes:COL = 70
        bt-pedidos:COL = 90
        bt-relatcliente:COL = 50
        bt-relatpedido:COL = 78
        bt-sair:COL = 110.
END.

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
 