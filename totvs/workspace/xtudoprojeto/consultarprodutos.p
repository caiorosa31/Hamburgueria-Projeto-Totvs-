ASSIGN CURRENT-WINDOW:HIDDEN = TRUE.

DEFINE QUERY qprodutos FOR produtos.

DEFINE BUTTON btClose LABEL "Fechar" AUTO-GO.

DEFINE BROWSE brprodutos
  QUERY qprodutos
  DISPLAY
    Produtos.CodProduto      LABEL "Codigo" FORMAT ">>>9"
    Produtos.NomProduto      LABEL "Nome" FORMAT "x(30)"
    Produtos.ValProduto     LABEL "Valor" FORMAT ">>>>>>>9.99"
  WITH SEPARATORS
       SIZE 57 BY 12.

/* Dialog que cont‚m o browse */
DEFINE FRAME f-bprodutos
  brprodutos
  btClose AT ROW 14 COL 2
  WITH THREE-D
       VIEW-AS DIALOG-BOX
       TITLE "produtos cadastrados"
       SIZE 59 BY 17.

ON WINDOW-CLOSE OF FRAME f-bprodutos DO:
  APPLY "CHOOSE" TO btClose IN FRAME f-bprodutos.
END.

OPEN QUERY qprodutos
  FOR EACH produtos NO-LOCK BY Produtos.NomProduto.
  
  DO WITH FRAME f-bprodutos:
    ENABLE brprodutos btClose.
    ASSIGN
        btClose:WIDTH = 15
        btClose:HEIGHT = 1.5
        btClose:FONT = 3
        btClose:FGCOLOR = 0
        
    
        FRAME f-bprodutos:BGCOLOR = 15
        
        btClose:COL = 22.
END.


VIEW FRAME f-bprodutos.

WAIT-FOR CHOOSE OF btClose IN FRAME f-bprodutos
     OR WINDOW-CLOSE OF FRAME f-bprodutos.