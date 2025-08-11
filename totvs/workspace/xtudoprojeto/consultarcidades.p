ASSIGN CURRENT-WINDOW:HIDDEN = TRUE.

DEFINE QUERY qCidades FOR cidades.

DEFINE BUTTON btClose LABEL "Fechar" AUTO-GO.

DEFINE BROWSE brCidades
  QUERY qCidades
  DISPLAY
    cidades.CodCidade LABEL "Codigo" FORMAT ">>>9"
    cidades.NomCidade LABEL "Cidade" FORMAT "x(30)"
    cidades.CodUF     LABEL "UF" FORMAT "x(15)"
  WITH SEPARATORS
       SIZE 58 BY 12.

DEFINE FRAME f-bcidades
  brCidades
  btClose AT ROW 14 COL 2
  WITH THREE-D
       VIEW-AS DIALOG-BOX
       TITLE "Cidades cadastradas"
       SIZE 60 BY 17.

ON WINDOW-CLOSE OF FRAME f-bcidades DO:
  APPLY "CHOOSE" TO btClose IN FRAME f-bcidades.
END.

OPEN QUERY qCidades
  FOR EACH cidades NO-LOCK BY cidades.NomCidade.
  
  DO WITH FRAME f-bcidades:
    ENABLE brCidades btClose.
    ASSIGN
        btClose:WIDTH = 15
        btClose:HEIGHT = 1.5
        btClose:FONT = 3
        btClose:FGCOLOR = 0
        
    
        FRAME f-bcidades:BGCOLOR = 15
        
        btClose:COL = 22.
END.


VIEW FRAME f-bcidades.

WAIT-FOR CHOOSE OF btClose IN FRAME f-bcidades
     OR WINDOW-CLOSE OF FRAME f-bcidades.