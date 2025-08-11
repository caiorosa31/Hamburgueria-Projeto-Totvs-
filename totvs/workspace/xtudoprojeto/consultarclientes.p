ASSIGN CURRENT-WINDOW:HIDDEN = TRUE.

DEFINE QUERY qClientes FOR clientes.

DEFINE BUTTON btClose LABEL "Fechar" AUTO-GO.

DEFINE BROWSE brclientes
  QUERY qClientes
  DISPLAY
    Clientes.CodCliente      LABEL "Codigo" FORMAT ">>>9"
    Clientes.NomCliente      LABEL "Nome" FORMAT "x(30)"
    Clientes.CodEndereco     LABEL "Endereco" FORMAT "x(40)"
  WITH SEPARATORS
       SIZE 83 BY 12.

DEFINE FRAME f-bclientes
  brclientes
  btClose AT ROW 14 COL 2
  WITH THREE-D
       VIEW-AS DIALOG-BOX
       TITLE "clientes cadastrados"
       SIZE 85 BY 17.

ON WINDOW-CLOSE OF FRAME f-bclientes DO:
  APPLY "CHOOSE" TO btClose IN FRAME f-bclientes.
END.

OPEN QUERY qClientes
  FOR EACH clientes NO-LOCK BY Clientes.NomCliente.
  
  DO WITH FRAME f-bclientes:
    ENABLE brclientes btClose.
    ASSIGN
        btClose:WIDTH = 15
        btClose:HEIGHT = 1.5
        btClose:FONT = 3
        btClose:FGCOLOR = 0
        
    
        FRAME f-bclientes:BGCOLOR = 15
        
        btClose:COL = 35.
END.


VIEW FRAME f-bclientes.

WAIT-FOR CHOOSE OF btClose IN FRAME f-bclientes
     OR WINDOW-CLOSE OF FRAME f-bclientes.