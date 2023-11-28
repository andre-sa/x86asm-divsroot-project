
; ---------------------------------------------------------------------------------------------------
; INSTITUTO POLITÉCNICO DE TOMAR
; 2022-2023
; ARQUITETURA DE COMPUTADORES
;
; Aluno:
; - André Sá ( aluno21296@ipt.pt )
; - João Batista ( aluno21079@ipt.pt )
;
; Trabalho Prático 2
;
; O código é de nossa autoria e apenas pode ser usado
;   para fins educacionais em instituições para esse efeito.
; ---------------------------------------------------------------------------------------------------

; ----- [Definir o segmento de pilha] ---------------------------------------------------------------

stack segment para stack
    db  64  dup(' ')
stack ends

; ----- [Definir o segmento para os dados] ----------------------------------------------------------

data segment para 'data'
    
    ; ----- [Variável de testes] --------------------------------------------------------------------
    
    varTeste            dw      ?
    
    ; ----- [Strings para o menu principal] ---------------------------------------------------------
    
    strTitulo           db      '      ===== Menu Principal =====      $'                           ; String título do menu principal
    strBtDivisao        db      '[1]  Divisao$'                                                     ; String para o botão divisão
    strBtRaizQ          db      '[2]  Raiz$'                                                        ; String para o botão raiz
    strBtSair           db      '[0]  Sair$'                                                        ; String para o botão sair
    
    ; ----- [Strings Divisão] -----------------------------------------------------------------------
    
    strDivisaoTitulo    db      '       ======> DIVISAO <======       $'                            ; String título do menu da divisão
    strPedirDividendo   db      'Insira o dividendo: $'                                             ; String para pedir o dividendo
    strPedirDivisor     db      '  Insira o divisor: $'                                             ; String para pedir o divisor
    
    ; ----- [Strings Raiz Quadrada] -----------------------------------------------------------------
    
    strRaizQTitulo      db      '       ===> RAIZ QUADRADA <===       $'                            ; String título do menu da raiz
    strPedirRadicando   db      'Insira o radicando: $'                                             ; String para pedir o radicando
    
    ; ----- [Strings de informação] -----------------------------------------------------------------
    
    strInfoNumeros1     db      '--> Maximo 10 algarismos (!)$'                                     ; String alerta para o máximo de algarismos do ...
                                                                                                    ;   ... dividendo/radicando
    strInfoNumeros2     db      '--> Valor maximo: 9999 (!)$'                                      	; String alerta para o valor máximo do divisor
    
    ; ----- [String para o teclado virtual] ---------------------------------------------------------
    
	strTecVirTitulo		db		'=== [ TECLADO VIRTUAL ] ===$'                                      ; String para o título do teclado virtual
    strBackspace        db      'BACKSPACE$'                                                        ; String para o botão "Backspace" do teclado virtual
    strEnter            db      '  ENTER  $'                                                        ; String para o botão "Enter" do teclado virtual
    
    ; ----- [String para os botões de "Guardar" e "Voltar ao menu principal"] -----------------------
    
    strVoltar           db      'VOLTAR$'                                                           ; String para o botão "Voltar" para voltar ao menu principal
    strGuardar          db      'GUARDAR$'                                                          ; String para guardar os dados num ficheiro de texto
    
    ; ----- [Auxiliares para a criação de botões] ---------------------------------------------------
    
    auxInicial_X        dw      0                                                                   ; Ponto coluna inicial (X)
    auxInicial_Y        dw      0                                                                   ; Ponto linha inicial (Y)
    auxCompr_X          dw      0                                                                   ; Comprimento no eixo X
    auxCompr_Y          dw      0                                                                   ; Comprimento no eixo Y
    
    ; ----- [Números auxiliares] --------------------------------------------------------------------
    
    numAleat            dw      10 dup(' ')                                                         ; Array com os números de 0-9 gerados aleatóriamente
    numAux              db      0                                                                   ; Variável que guarda números auxiliares
    x1                  dw      0                                                                   ; Variável que guarda o valor da coluna inicial
    x2                  dw      0                                                                   ; Variável que guarda o valor da coluna final
    y1                  dw      0                                                                   ; Variável que guarda o valor da linha inicial
    y2                  dw      0                                                                   ; Variável que guarda o valor da linha final
    index               dw      0                                                                   ; Variável auxiliar para guardar o index atual de uma variável
    iVirgula            dw      0                                                                   ; Variável que indica se o número atual tem vírgula
                                                                                                    ;   0 -> Não tem vírgula // <> 0 -> Tem vírgula
    ho                  db      0                                                                                                
    
    space               db      ' $'
    
    ; ----- [Flags] ---------------------------------------------------------------------------------
    
    flagSinal           db      0                                                                   ; Variável que define o sinal do resultado (positivo ou negativo)
                                                                                                    ;   0 -> positivo // 1 -> negativo
    flagOperacao        db      0                                                                   ; Variável que define qual operação estamos a fazer
                                                                                                    ;   0 -> divisão // 1 -> raiz
    
    ; ----- [Variáveis para a Divisão] --------------------------------------------------------------
    
    dividendo           db      10 dup(' ')                                                         ; Variável que guarda o valor do dividendo num array
    divisor             dw      0                                                                   ; Variável que guarda o valor do divisor em número
    quociente           db      10 dup(' ')                                                         ; Variável que guarda o valor do quociente
    
    ; ----- [Variável para a Divisão e Raiz Quadrada] -----------------------------------------------
    
    resto               dw      0                                                                   ; Variável que guarda o valor do resto
    
    ; ----- [Variáveis para a Raiz Quadrada] --------------------------------------------------------
    
    radicando           db      10 dup(' ')                                                         ; Variável que guarda o valor do radicando
    radicandoPares		db		10 dup(100)															; Variável que guarda os pares do radicando
	iRadicandoPares     dw      0																	; Variável que guarda o index atual do array radicandoPares
	raiz                dw      0                                                                   ; Variável que guarda o valor da raiz                                                                                                    
    alfa                dw      0																	; Variável auxiliar para encontrar o "alfa" ao executar a raiz quadrada	
    
    ; ----- [Ficheiros] -----------------------------------------------------------------------------
    
    nomeFicheiro        db      '.\dados.txt', 0                                                    ; Diretoria do ficheiro
    handle              dw      ?    																; FileHandle do ficheiro que estamos a manipular
    bufferEscrita       db      64 dup('$')                                                         ; Dados para escrever no ficheiro
    bufferEscrita_I     db      0																	; Index para o bufferEscrita

data ends

; ----- [Definir o segmento para o código] ----------------------------------------------------------

code segment para 'code'
    
    ; ----- [Código principal] ----------------------------------------------------------------------
    
    Main proc far
        
        ; ----- [Definir os segmentos] --------------------------------------------------------------
        
        assume cs:code,ds:data,ss:stack
        push    ds                                                                                  ; Guarda na pilha o segmento ds
        xor     ax, ax                                                                              ; Garante zero em ax
        push    ax                                                                                  ; Guarda ax na pilha
        mov     ax, data                                                                            ; Coloca em ax a posição dos dados
        mov     ds, ax                                                                              ; Coloca essa posição no register ds
        
        ; ----- [Definir o modo gráfico] ------------------------------------------------------------
        
        call    InitModoGrafico                                                                     ; Executa o procedimento
        
        ; ----- [Inicializa o rato] -----------------------------------------------------------------
        
        mov     ax, 0000h                                                                           ; Define para inicializar o rato
        int     33h                                                                                 ; Executa a interrupção
        
        ; ----- [Mostra o menu principal] -----------------------------------------------------------
		
        Main_Loop:
        call    ResetVariaveis																		; Executa o procedimento
        call    MostraMenuPrincipal                                                                 ; Executa o procedimento    
        call    Delay																				; Executa o procedimento
        
        ; ----- [Espera uma tecla ser pressionada ou um clique no mouse 1] --------------------------
        
        Main_Loop_01:
        mov     ax, 0001h                                                                           ; Define para mostrar o ponteiro do rato
        int     33h                                                                                 ; Executa a interrupção
        mov     ax, 00003h                                                                          ; Define para receber  a posição e o status do rato
        int     33h                                                                                 ; Executa a interrupção
        cmp     bx, 1                                                                               ; Compara bx com 1 (bx == 1) (Mouse1) 
        je      Main_Next_01                                                                        ; Se sim, salta       
        mov     ah, 01h                                                                             ; Define para verificar se alguma tecla foi pressionada
        int     16h                                                                                 ; Executa a interrupção
        jz      Main_Loop_01                                                                        ; Se sim, reloop
        
        ; ----- [Verifica se alguma opção foi selecionada] ------------------------------------------
        
        mov     ah, 00h                                                                             ; Define para limpar o buffer do teclado
        int     16h                                                                                 ; Executa a interrupção
        cmp     al, '1'                                                                             ; Compara al com '1'
        je      Main_Divisao                                                                        ; Igual, salta para a divisão
        cmp     al, '2'                                                                             ; Compara al com '2'
        je      Main_RaizQ                                                                          ; Igual, salta para a raiz quadrada
        cmp     al, '0'                                                                             ; Compara al com '0'
        je      Main_Sair                                                                           ; Igual, salta para sair
        jmp     Main_Loop_01                                                                        ; Reloop
        
        ; ----- [Verifica se foi pressionado num botão] --------------------------------------------- 
        
        Main_Next_01:
        cmp     cx, 0070h                                                                           ; Compara se está acima da margem esquerda dos botões
        jb      Main_Loop_01                                                                        ; Não, reloop
        cmp     cx, 020ch                                                                           ; Compara se está abaixo da margem direita dos botões
        jg      Main_Loop_01                                                                        ; Não, reloop
        cmp     dx, 0023h                                                                           ; Compara se está abaixo da margem superior do botão "Divisao"
        jb      Main_Loop_01                                                                        ; Não, reloop
        cmp     dx, 0042h                                                                           ; Compara se está acima da margem inferior do botão "Divisao"
        jb      Main_Divisao                                                                        ; Sim, salta para a divisão
        cmp     dx, 004bh                                                                           ; Compara se está abaixo da margem superior do botão "Raiz"
        jb      Main_Loop_01                                                                        ; Não, reloop
        cmp     dx, 006ah                                                                           ; Compara se está acima da margem inferior do botão "Raiz"
        jb      Main_RaizQ                                                                          ; Sim, salta para a raiz
        cmp     dx, 0073h                                                                           ; Compara se está abaixo da margem superior do botão "Sair"
        jb      Main_Loop_01                                                                        ; Não, reloop
        cmp     dx, 0092h                                                                           ; Compara se está acima da margem inferior do botão "Sair"
        jb      Main_Sair                                                                           ; Sim, salta para sair
        jmp     Main_Loop_01                                                                        ; Reloop
        
        ; ----- [Divisão] ---------------------------------------------------------------------------
        
        Main_Divisao:
        mov     flagOperacao, 0                                                                     ; Atribui 0 a flagOperacao (divisão)
        call    Divisao                                                                             ; Executa o procedimento
        jmp     Main_Loop																			; Reloop
        
        ; ----- [Raiz Quadrada] ---------------------------------------------------------------------
        
        Main_RaizQ:
        mov     flagOperacao, 1                                                                     ; Atribui 0 a flagOperacao (raiz quadrada)
        call    RaizQuadrada                                                                       	; Executa o procedimento
        jmp		Main_Loop																			; Reloop
		
        ; ----- [Termina o programa] ---------------------------------------------------------------- 
        
        Main_Sair:
        call	InitModoGrafico																		; Executa o procedimento
		mov     ah, 4ch                                                                             ; Define para terminar o programa
        int     21h                                                                                 ; Executa a interrupção
        
    Main endp    
    
    ; ----- [Desenhar menu principal] ---------------------------------------------------------------
    
    MostraMenuPrincipal proc near
        
        ; ----- [Limpa o ecrã] ----------------------------------------------------------------------
        
        call    InitModoGrafico                                                                     ; Executa o procedimento
        
        ; ----- [Apresentar o título] ---------------------------------------------------------------
        
        mov     ah, 02h                                                                             ; Define para posicionar o cursor
        mov     bh, 00h                                                                             ; Define o número da página
        mov     dh, 1                                                                               ; Define a linha
        mov     dl, 1                                                                               ; Define a coluna
        int     10h                                                                                 ; Executa a interrupção
        mov     ah, 09h                                                                             ; Define para escrever texto
        lea     dx, strTitulo                                                                       ; Define o apontador para o início da variável string
        int     21h                                                                                 ; Executa a interrupção 
        
        ; ----- [Desenha os botões do menu] ---------------------------------------------------------
        
        mov     cx, 3                                                                               ; Contador para o número de botões a serem desenhados
        mov     auxInicial_X, 56                                                                    ; auxInicial_X recebe posição no eixo X inicial
        mov     auxInicial_Y, 35                                                                    ; auxInicial_Y recebe posição no eixo Y inicial
        mov     auxCompr_X, 206                                                                     ; auxCompr_X recebe o comprimento do botão no eixo X
        mov     auxCompr_Y, 31                                                                      ; auxCompr_Y recebe o comprimento do botão no eixo Y
        Desenha_3_Botoes_01:
        push    cx                                                                                  ; Guarda o valor 3 na pilha    
        call    DesenhaBotao                                                                        ; Executa o procedimento   
        pop     cx                                                                                  ; Retira o valor 3 da pilha
        add     auxInicial_Y, 40                                                                    ; (Próximo botão) auxInicial_Y = auxInicial_Y + 40
        loop    Desenha_3_Botoes_01                                                                 ; Reloop até cx = 0
        
        ; ----- [Coloca o título dos botões nos respetivos botões] ----------------------------------
        
        mov     ah, 02h                                                                             ; Define para posicionar o cursor
        mov     bh, 00h                                                                             ; Define o número da página
        mov     dh, 6                                                                               ; Define a linha
        mov     dl, 14                                                                              ; Define a coluna
        int     10h                                                                                 ; Executa a interrupção
        mov     ah, 09h                                                                             ; Define para escrever texto
        lea     dx, strBtDivisao                                                                    ; Define o apontador para o início da variável string
        int     21h                                                                                 ; Executa a interrupção
        
        mov     ah, 02h                                                                             ; Define para posicionar o cursor
        mov     bh, 00h                                                                             ; Define o número da página
        mov     dh, 11                                                                              ; Define a linha
        mov     dl, 14                                                                              ; Define a coluna
        int     10h                                                                                 ; Executa a interrupção
        mov     ah, 09h                                                                             ; Define para escrever texto
        lea     dx, strBtRaizQ                                                                      ; Define o apontador para o início da variável string
        int     21h                                                                                 ; Executa a interrupção
        
        mov     ah, 02h                                                                             ; Define para posicionar o cursor
        mov     bh, 00h                                                                             ; Define o número da página
        mov     dh, 16                                                                              ; Define a linha
        mov     dl, 14                                                                              ; Define a coluna
        int     10h                                                                                 ; Executa a interrupção
        mov     ah, 09h                                                                             ; Define para escrever texto
        lea     dx, strBtSair                                                                       ; Define o apontador para o início da variável string
        int     21h                                                                                 ; Executa a interrupção
        
        ret
        
    MostraMenuPrincipal endp    
    
    ; ----- [Desenhar um botão] ---------------------------------------------------------------------
    ; ----- [Input: cx = auxInicial_X, dx = auxInicial_Y] -------------------------------------------
    ; ----- [Input: auxCompr_X = Comprimento no eixo X, auxCompr_Y = Comprimento no eixo Y] ---------
    
    DesenhaBotao proc near
        
        ; ----- [Configura as definições iniciais para pintar um píxel] ----------------------------- 
        
        mov     ah, 0ch                                                                             ; Define para pintar um pixel
        mov     al, 07h                                                                             ; Define a cor do pixel
        mov     cx, auxInicial_X                                                                    ; Define coluna inicial    
        mov     dx, auxInicial_Y                                                                    ; Define linha inicial
        
        ; ----- [Inicializa o processo de desenhar linhas horizontais] ------------------------------
        
        Desenha_Botao_Loop_01:
        int     10h                                                                                 ; Executa a interrupção
        add     dx, auxCompr_Y                                                                      ; Dx = dx + auxCompr_Y      
        int     10h                                                                                 ; Executa a interrupção
        sub     dx, auxCompr_Y                                                                      ; Dx = dx - auxCompr_Y
        inc     cx                                                                                  ; Incrementa cx
        mov     bx, auxInicial_X                                                                    ; Bx recebe auxInicial_X
        add     bx, auxCompr_X                                                                      ; Bx = bx + auxCompr_X
        cmp     cx, bx                                                                              ; Compara cx com bx (cx <= bx)
        jng     Desenha_Botao_Loop_01                                                               ; Sim, reloop
        sub     cx, auxCompr_X                                                                      ; Cx = cx - auxCompr_X
        dec     cx                                                                                  ; Decrementa cx
        inc     dx                                                                                  ; Incrementa dx
        
        ; ----- [Inicializa o processo de desenhar linhas verticais] --------------------------------
        
        Desenha_Botao_Loop_02:
        int     10h                                                                                 ; Executa a interrupção
        add     cx, auxCompr_X                                                                      ; Cx = cx + auxCompr_X
        int     10h                                                                                 ; Executa a interrupção
        sub     cx, auxCompr_X                                                                      ; Cx = cx - auxCompr_X
        inc     dx                                                                                  ; Incrementa dx
        mov     bx, auxInicial_Y                                                                    ; Bx recebe auxInicial_Y
        add     bx, auxCompr_Y                                                                      ; Bx = bx + auxCompr_Y
        cmp     dx, bx                                                                              ; Compara dx com bx (dx <= bx)
        jbe     Desenha_Botao_Loop_02                                                               ; Sim, reloop
        
        ret
            
    DesenhaBotao endp        
    
    ; ----- [Procedimento principal para a divisão] -------------------------------------------------
    
    Divisao proc near
        
        ; ----- [Mostra o menu para receber dados] --------------------------------------------------
        
        call    DivisaoInicio                                                                       ; Executa o procedimento
        
        ; ----- [Executa o processo da divisão] -----------------------------------------------------
        
        call    DivisaoExecuta                                                                      ; Executa o procedimento
        
        ; ----- [Mostra os botões para...] ----------------------------------------------------------
        ; ----- [- Voltar ao menu principal] --------------------------------------------------------
        ; ----- [- Guardar os dados no ficheiro] ----------------------------------------------------
        
        mov     auxInicial_X, 30
        mov     auxInicial_Y, 60                                                                    ; auxInicial_Y recebe posição no eixo Y inicial
        mov     auxCompr_X, 80                                                                      ; auxCompr_X recebe o comprimento do botão no eixo X
        mov     auxCompr_Y, 40																		; auxCompr_Y recebe o comprimento do botão no eixo Y (altura)
        call    DesenhaBotao                                                                        ; Executa o procedimento
        add     auxInicial_Y, 45                                                                    ; auxInicial_Y = auxInicial_Y + 25
        call    DesenhaBotao                                                                        ; Executa o procedimento
        
        ; ----- [Coloca o título dos botões] --------------------------------------------------------
        
        mov     ah, 02h                                                                             ; Define para posicionar o cursor
        mov     bh, 00h                                                                             ; Define o número da página
        mov     dh, 10                                                                              ; Define a linha
        mov     dl, 6                                                                               ; Define a coluna
        int     10h                                                                                 ; Executa a interrupção
        mov     ah, 09h                                                                             ; Define para escrever texto
        lea     dx, strVoltar                                                                       ; Define o apontador para o início da variável string
        int     21h                                                                                 ; Executa a interrupção
        
        mov     ah, 02h                                                                             ; Define para posicionar o cursor
        mov     bh, 00h                                                                             ; Define o número da página
        mov     dh, 15                                                                              ; Define a linha
        mov     dl, 5                                                                               ; Define a coluna
        int     10h                                                                                 ; Executa a interrupção
        mov     ah, 09h                                                                             ; Define para escrever texto
        lea     dx, strGuardar                                                                      ; Define o apontador para o início da variável string
        int     21h                                                                                 ; Executa a interrupção
         
        call    ResultadosEsperaBotao																; Executa o procedimento
        
        ret																							
            
    Divisao endp      
    
	RaizQuadrada proc near
		
		; ----- [Mostra menu para receber os dados] -------------------------------------------------
		
		call	RaizQInicio																			; Executa o procedimento
		
		; ----- [Executa o processo da raiz quadrada] -----------------------------------------------
		
		call	RaizQExecuta																		; Executa o procedimento
		
		; ----- [Mostra os resultados] --------------------------------------------------------------
		
		call    RaizQMostraResultados                                                               ; Executa o procedimento    
		
		ret
	
	RaizQuadrada endp
	
	; ----- [Procedimento para mostrar os resultados da raiz quadrada] ------------------------------
	
	RaizQMostraResultados proc near
	    
	    
	    ; ----- [Limpa o ecrã] ----------------------------------------------------------------------
	    
	    call    InitModoGrafico                                                                     ; Executa o procedimento
		
		; ----- [Posicionar o cursor] ---------------------------------------------------------------
		
		mov     ah, 02h                                                                             ; Define para posicionar o cursor
        mov     bh, 00h                                                                             ; Define o número da página
        mov     dh, 3                                                                               ; Define a linha
        mov     dl, 5                                                                               ; Define a coluna
        int     10h                                                                                 ; Executa a interrupção
		
		; ----- [Apresenta o radicando] -------------------------------------------------------------
		
		mov		index, 0																			; Index recebe zero 0
		
		RaizQ_Mostra_Resultados_02:
		mov		si, offset radicando																; Si aponta para a variável radicando
		add		si, index																			; Si = si + index
		mov		bx, [si]																			; Bx recebe o valor apontado por si
		mov		bh, 0																				; Garante zero no bh
		
		cmp		bl, ' '																				; Compara bl com um espaço (bl == " ")
		je		RaizQ_Mostra_Resultados_03															; Sim, salta
		cmp		bl, ','																				; Compara bl com uma vírgula (bl == ",")
		je		RaizQ_Mostra_Resultados_03															; Sim, salta
		
		add		bl, 30h																				; Bl = bl + 30h
		
		RaizQ_Mostra_Resultados_03:
		mov		dl, bl																				; Dl recebe bl
		int		21h																					; Executa a interrupção
		
		mov		ah, 02h																				; Define para posicionar o cursor/escrever um caracter 	
		inc		dl																					; Incrementa dl
		inc		index																				; Incrementa o index
		
		cmp		index, 10																			; Compara index com 10 (index == 10)
		je		RaizQ_Mostra_Resultados_04															; Sim, salta
		
		jmp		RaizQ_Mostra_Resultados_02															; Reloop
		
		RaizQ_Mostra_Resultados_04:
		
		; ----- [Posicionar o cursor] ---------------------------------------------------------------
		
		mov     ah, 02h                                                                             ; Define para posicionar o cursor
        mov     bh, 00h                                                                             ; Define o número da página
        mov     dh, 3                                                                               ; Define a linha
        mov     dl, 18                                                                              ; Define a coluna
        int     10h                                                                                 ; Executa a interrupção
		
		; ----- [Apresenta a raiz] ------------------------------------------------------------------
		
		mov		ax, raiz																			; Ax recebe raiz
		call	PrintNumero																			; Executa o procedimento
		
		; ----- [Desenha linha gráfica horizontal] --------------------------------------------------
		
		mov		cx, 28																				; Cx recebe 28
		
		RaizQ_Mostra_Resultados_05:
		mov     ah, 02h                                                                             ; Define para posicionar o cursor/escrever um caracter
        mov     bh, 00h                                                                             ; Define o número da página
        mov     dh, 4                                                                               ; Define a linha
        mov     dl, cl                                                                              ; Define a coluna
        int     10h                                                                                 ; Executa a interrupção
		mov		dl, 205																				; Dl recebe o caracter em ASCII-decimal 205
		int		21h																					; Executa a interrupção
		dec		cx																					; Decrementa o cx
		cmp		cx, 4																				; Compara cx com 4 (cx <> 4)		
		jne		RaizQ_Mostra_Resultados_05															; Sim, Reloop
		
		; ----- [Desenhar linha gráfica vertical] ---------------------------------------------------
		
		mov     ah, 02h                                                                             ; Define para posicionar o cursor
        mov     bh, 00h                                                                             ; Define o número da página
        mov     dh, 3                                                                               ; Define a linha
        mov     dl, 16                                                                              ; Define a coluna
        int     10h                                                                                 ; Executa a interrupção
		mov		dl, 186																				; Dl recebe o caracter em ASCII-decimal 186
		int		21h																					; Executa a interrupção
		mov     ah, 02h                                                                             ; Define para posicionar o cursor
        mov     bh, 00h                                                                             ; Define o número da página
        mov     dh, 4                                                                               ; Define a linha
        mov     dl, 16                                                                              ; Define a coluna
        int     10h                                                                                 ; Executa a interrupção
		mov		dl, 206																				; Dl recebe o caracter em ASCII-decimal 206
		int		21h																					; Executa a interrupção
		mov     ah, 02h                                                                             ; Define para posicionar o cursor
        mov     bh, 00h                                                                             ; Define o número da página
        mov     dh, 5                                                                               ; Define a linha
        mov     dl, 16                                                                              ; Define a coluna
        int     10h                                                                                 ; Executa a interrupção
		mov		dl, 186																				; Dl recebe o caracter em ASCII-decimal 186
		int		21h																					; Executa a interrupção
		
		; ----- [Apresenta o resto] -----------------------------------------------------------------
		
		mov     ah, 02h                                                                             ; Define para posicionar o cursor
        mov     bh, 00h                                                                             ; Define o número da página
        mov     dh, 5                                                                               ; Define a linha
        mov     dl, 5                                                                               ; Define a coluna
        int     10h                                                                                 ; Executa a interrupção
        
        mov     ax, resto																			; Ax recebe o resto	
        call    PrintNumero																			; Executa o procedimento
		
		; ----- [Mostra os botões para...] ----------------------------------------------------------
        ; ----- [- Voltar ao menu principal] --------------------------------------------------------
        ; ----- [- Guardar os dados no ficheiro] ----------------------------------------------------
        
        mov     auxInicial_X, 30
        mov     auxInicial_Y, 60                                                                    ; auxInicial_Y recebe posição no eixo Y inicial
        mov     auxCompr_X, 80                                                                      ; auxCompr_X recebe o comprimento do botão no eixo X
        mov     auxCompr_Y, 40																		; auxCompr_Y recebe o comprimento do botão no eixo Y (altura)
        call    DesenhaBotao                                                                        ; Executa o procedimento
        add     auxInicial_Y, 45                                                                    ; auxInicial_Y = auxInicial_Y + 25
        call    DesenhaBotao                                                                        ; Executa o procedimento
        
        ; ----- [Coloca o título dos botões] --------------------------------------------------------
        
        mov     ah, 02h                                                                             ; Define para posicionar o cursor
        mov     bh, 00h                                                                             ; Define o número da página
        mov     dh, 10                                                                              ; Define a linha
        mov     dl, 6                                                                               ; Define a coluna
        int     10h                                                                                 ; Executa a interrupção
        mov     ah, 09h                                                                             ; Define para escrever texto
        lea     dx, strVoltar                                                                       ; Define o apontador para o início da variável string
        int     21h                                                                                 ; Executa a interrupção
        
        mov     ah, 02h                                                                             ; Define para posicionar o cursor
        mov     bh, 00h                                                                             ; Define o número da página
        mov     dh, 15                                                                              ; Define a linha
        mov     dl, 5                                                                               ; Define a coluna
        int     10h                                                                                 ; Executa a interrupção
        mov     ah, 09h                                                                             ; Define para escrever texto
        lea     dx, strGuardar                                                                      ; Define o apontador para o início da variável string
        int     21h                                                                                 ; Executa a interrupção
         
        call    ResultadosEsperaBotao																; Executa o procedimento
		
	    ret
	    
	RaizQMostraResultados endp    
	
	; ----- [Procedimento para executa a raiz quadrada] ---------------------------------------------
	
	RaizQExecuta proc near
		
		; ----- [Organiza o radicando em pares] -----------------------------------------------------
		
		call	RaizQSetPares																		; Executa o procedimento
		
		; ----- [Calcula a raiz quadrada] -----------------------------------------------------------
		
		mov     index, 0																			; Index recebe zero 0
		
		; ----- [Identifica o par HO] ---------------------------------------------------------------
		
		RaizQ_Executa_01:
		mov     si, offset radicandoPares															; Si aponta para a variável radicandoPares
		add     si, index																			; Si = si + index
		mov     bx, [si]																			; Bx recebe o valor apontado por si
		mov     bh, 0																				; Garante zero no bh
		cmp     bl, 100																				; Compara bl com 100 (bl >= 100)
		jnb     RaizQ_Executa_02																	; Sim, salta	
		
		; ----- [Concatena o par HO ao resto] -------------------------------------------------------
		
		mov     ax, resto																			; Ax recebe resto	
		mov     cx, 100																				; Cx recebe 100	
		mul     cx																					; Ax = ax * cx
		add     ax, bx																				; Ax = ax + bx
		mov     resto, ax																			; Resto recebe ax
		mov     alfa, 0																				; Alfa recebe zero 0	
		
		; ----- [Calcula a expressão "(2*raiz*10+alfa)*alfa"] ---------------------------------------
		
		RaizQ_Executa_04:
		mov     ax, raiz																			; Ax recebe raiz
		mov     cx, 2																				; Cx recebe 2
		mul     cx																					; Ax = ax * cx
		mov     cx, 10																				; Cx recebe 10
		mul     cx																					; Ax = ax * cx
		mov     cx, alfa																			; Cx recebe alfa
		add     ax, cx																				; Ax = ax + cx
		mul     cx																					; Ax = ax * cx
		cmp     ax, resto																			; Compara ax com resto (ax > resto)
		jg      RaizQ_Executa_03																	; Sim salta
		inc     alfa																				; Incrementa o alfa
		jmp     RaizQ_Executa_04																	; Reloop
		
		RaizQ_Executa_03:
		dec     alfa																				; Decrementa o alfa
		mov     ax, raiz																			; Ax recebe raiz		
		mov     cx, 2																				; Cx recebe 2
		mul     cx																					; Ax = ax * 2
		mov     cx, 10																				; Cx recebe 10
		mul     cx																					; Ax = ax * cx
		mov     cx, alfa																			; Cx recebe alfa
		add     ax, cx																				; Ax = ax + cx
		mul     cx																					; Ax = ax * cx
		sub     resto, ax																			; Resto = resto - ax
		mov     ax, raiz																			; Ax recebe raiz
		mov     cx, 10																				; Cx recebe 10	
		mul     cx																					; Ax = ax * cx
		add     ax, alfa																			; Ax = ax + alfa
		mov     raiz, ax																			; Raiz recebe ax
		inc     index																				; Incrementa o index
		mov     cx, index																			; Cx recebe index
		cmp     cx, 10																				; Compara cx com 10 (cx <= 10)
		jng     RaizQ_Executa_01																	; Sim, reloop
		
		RaizQ_Executa_02:
		ret
		
	RaizQExecuta endp
	
	; ----- [Procedimento para organizar o radicando em pares] --------------------------------------
	
	RaizQSetPares proc near
		
		; ----- [Inicializa variáveis] --------------------------------------------------------------
		
		mov		index, 0																			; Index recebe zero 0
		mov     iRadicandoPares, 0																	; iRadicandoPares recebe zero 0
		mov     cx, 0																				; Cx recebe zero 0
		RaizQ_Set_Pares_06:
		mov     si, offset radicando																; Si aponta para a variável radicando
		add     si, cx																				; Si = si + cx
		mov     bx, [si]																			; Bx recebe o valor apontado por si
		inc     cx																					; Incrementa cx	
		cmp     bl, ' '																				; Compara bl com espaço (bl <> " ")
		jne     RaizQ_Set_Pares_06																	; Sim, reloop
	    		
		; ----- [Verifica se o index da vírgula é par ou impar] -------------------------------------
		
		mov		ax, iVirgula																		; Ax recebe iVirgula
		and		al, 01h																				; Verifica o último bit de al (0 é par, 1 é impar)	
		jz		RaizQ_Set_Pares_07																	; É par, salta
				
		; ----- [Número de inteiros é impar, o primeiro par é zero:primeiro_algarismo] --------------
		
		RaizQ_Set_Pares_08:
		mov		si, offset radicando																; Si aponta para a variável radicando	
		add		si, index																			; Si = si + index
		mov		bx, [si]																			; Bx recebe o valor apontado por si
		mov		si, offset radicandoPares															; Si aponta para a variável radicandoPares
		mov		[si], bl																			; Coloca na posição si o valor de bl
		inc     iRadicandoPares																		; Incrementa iRadicandoPares	
		inc     index																				; Incrementa o index
		jmp     RaizQ_Set_Pares_01																	; Salta
		
		RaizQ_Set_Pares_07:
		cmp     iVirgula, 0																			; Compara iVirgula com 0 (iVirgula <> 0)
		jne     RaizQ_Set_Pares_01																	; Sim, salta
		and     cx, 01h																				; Verifica o último bit de cx (0 é par, 1 é impar)
		jz      RaizQ_Set_Pares_08																	; É par, salta
		
		RaizQ_Set_Pares_01:	     
		mov		si, offset radicando																; Si aponta para a variável radicando
		add		si, index																			; Si = si + index
		mov		bx, [si]																			; Bx recebe o valor apontado por si
		cmp     bh, ','																				; Compara bh com uma vírgula (bh == ",")
		je      RaizQ_Set_Pares_04																	; Sim, salta
		cmp     bl, ','																				; Compara bl com uma vírgula (bl == ",")
		je      RaizQ_Set_Pares_05																	; Sim, salta
		cmp		bl, ' '																				; Compara bl com um espaço (bl == " ")
		je		RaizQ_Set_Pares_02																	; Sim, salta
		cmp     bh, ' '																				; Compara bh com um espaço (bh <> " ")
		jne     RaizQ_Set_Pares_03																	; Sim, salta
		mov     bh, 00h																				; Garante zero no bh
		RaizQ_Set_Pares_03:
		xor		ax, ax																				; Garante zero no ax
		mov		al, bl																				; Al recebe bl
		mov		cx, 10																				; Cx recebe 10
		mul		cx																					; Ax = ax * cx
		add		al, bh																				; Al = al + bh
		mov		si, offset radicandoPares															; Si aponta para a variável radicandoPares		
		add		si, iRadicandoPares																	; Si = si + iRadicandoPares	
		mov		[si], al																			; Coloca na posição apontada por si o valor de al
		inc     iRadicandoPares																		; Incrementa iRadicandoPares
		inc		index																				; Incrementa index
		inc		index																				; Incrementa index
		jmp		RaizQ_Set_Pares_01																	; Reloop
		
		RaizQ_Set_Pares_04:
		mov     si, offset radicandoPares															; Si aponta para a variável radicandoPares		
		add     si, iRadicandoPares																	; Si = si + iRadicandoPares	
		mov     [si], bl 																			; Coloca na posição apontada por si o valor de bl
		inc     iRadicandoPares																		; Incrementa iRadicandoPares
		
		; ----- [Identificar os pares da parte decimal do radicando] --------------------------------
		
		RaizQ_Set_Pares_05:
		inc     index																				; Incrementa index
		RaizQ_Set_Pares_09:	
		mov     si, offset radicando																; Si aponta para a variável radicando
		add     si, index																			; Si = si + index
		xor     ax, ax																				; Garante zero no ax
		mov     bx, [si]																			; Bx recebe o valor apontado por si
		mov		si, offset radicandoPares															; Si aponta para a variável radicandoPares
		add		si, iRadicandoPares																	; Si = si + iRadicandoPares
		cmp     bl, ' '																				; Compara bl com um espaço (bl == " ")
		je      RaizQ_Set_Pares_02																	; Sim, salta
		cmp     bh, ' '																				; Compara bh com um espaço (bh <> " ")
		jne     RaizQ_Set_Pares_10																	; Sim, salta
		mov     [si], bl																			; Coloca na posição apontada por si o valor de bl
		inc     iRadicandoPares																		; Incrementa iRadicandoPares
		jmp     RaizQ_Set_Pares_02																	; Salta	
		
		RaizQ_Set_Pares_10:
		mov     al, bl																				; Al recebe bl
		mov     cx, 10																				; Cx recebe 10
		mul     cx																					; Ax = ax * cx
		add     al, bh																				; Al = al + bh
		mov		[si], al																			; Coloca na posição apontada por si o valor de al
		inc     iRadicandoPares																		; Incrementa iRadicandoPares	
		inc     index																				; Incrementa index
		inc     index																				; Incrementa index	
		jmp     RaizQ_Set_Pares_09 																	; Salta
		
		RaizQ_Set_Pares_02:
		
		ret
		
	RaizQSetPares endp
	
	; ----- [Procedimento que mostra o menu para receber os dados do utilizador] --------------------
	
	RaizQInicio proc near
		
		; ----- [Limpa o ecrã] ----------------------------------------------------------------------
        
        call    InitModoGrafico                                                                     ; Executa o procedimento
        
        ; ----- [Apresenta o título da página] ------------------------------------------------------
        
        mov     ah, 02h                                                                             ; Define para posicionar o cursor
        mov     bh, 00h                                                                             ; Define o número da página
        mov     dh, 1                                                                               ; Define a linha
        mov     dl, 1                                                                               ; Define a coluna
        int     10h                                                                                 ; Executa a interrupção
        mov     ah, 09h                                                                             ; Define para escrever texto
        lea     dx, strRaizQTitulo                                                                	; Define o apontador para o início da variável string
        int     21h                                                                                 ; Executa a interrupção
        
        ; ----- [Apresenta informação] --------------------------------------------------------------
        
        mov     ah, 02h                                                                             ; Define para posicionar o cursor
        mov     bh, 00h                                                                             ; Define o número da página
        mov     dh, 4                                                                               ; Define a linha
        mov     dl, 1                                                                               ; Define a coluna
        int     10h                                                                                 ; Executa a interrupção
        mov     ah, 09h                                                                             ; Define para escrever texto
        lea     dx, strInfoNumeros1                                                                 ; Define o apontador para o início da variável string
        int     21h                                                                                 ; Executa a interrupção 
        
        mov     ah, 02h                                                                             ; Define para posicionar o cursor
        mov     bh, 00h                                                                             ; Define o número da página
        mov     dh, 6                                                                               ; Define a linha
        mov     dl, 1                                                                               ; Define a coluna
        int     10h                                                                                 ; Executa a interrupção
        mov     ah, 09h                                                                             ; Define para escrever texto
        lea     dx, strPedirRadicando                                                               ; Define o apontador para o início da variável string
        int     21h                                                                                 ; Executa a interrupção
		
		; ----- [Inicializa as variáveis] -----------------------------------------------------------
        
        mov     index, 0                                                                            ; Garante zero no index
        
        ; ----- [Mostra o teclado] ------------------------------------------------------------------
        
        call    MostraTeclado                                                                       ; Executa o procedimento
        
        ; ----- [Prepara para escrever o dividendo] -------------------------------------------------
        
        mov     ah, 02h                                                                             ; Define para posicionar o cursor
        mov     bh, 00h                                                                             ; Define o número da página
        mov     dh, 6                                                                               ; Define a linha
        mov     dl, 19                                                                              ; Define a coluna
        int     10h                                                                                 ; Executa a interrupção
		
		; ----- [Verifica qual botão do teclado virtual foi pressionado] ----------------------------
        
		RaizQ_Inicio_01:
        call    Delay                                                                               ; Executa o procedimento
        call    EsperaTecladoVirtual                                                                ; Executa o procedimento
        cmp     numAux, '?'																			; Compara numAux com '?' (numAux == '?')
        je     	RaizQ_Inicio_01																		; Sim, reloop
		
		; ----- [Executa procedimentos dependendo do botão pressionado] -----------------------------
		
		cmp     numAux, 0                                                                           ; Compara numAux com 0 (numAux == 0)
		je      RaizQ_Inicio_02                                                                   	; Sim, salta
		cmp     numAux, 1                                                                           ; Compara numAux com 1 (numAux == 1)
		je      RaizQ_Inicio_02                                                                   	; Sim, salta
		cmp     numAux, 2                                                                           ; Compara numAux com 2 (numAux == 2)
		je      RaizQ_Inicio_02                                                                   	; Sim, salta
		cmp     numAux, 3                                                                           ; Compara numAux com 3 (numAux == 3)
		je      RaizQ_Inicio_02                                                                   	; Sim, salta
		cmp     numAux, 4                                                                           ; Compara numAux com 4 (numAux == 4)
		je      RaizQ_Inicio_02                                                                   	; Sim, salta
		cmp     numAux, 5                                                                           ; Compara numAux com 5 (numAux == 5)
		je      RaizQ_Inicio_02                                                                   	; Sim, salta
		cmp     numAux, 6                                                                           ; Compara numAux com 6 (numAux == 6)
		je      RaizQ_Inicio_02                                                                   	; Sim, salta
		cmp     numAux, 7                                                                           ; Compara numAux com 7 (numAux == 7)
		je      RaizQ_Inicio_02                                                                   	; Sim, salta
		cmp     numAux, 8                                                                           ; Compara numAux com 8 (numAux == 8)
		je      RaizQ_Inicio_02                                                                   	; Sim, salta
		cmp     numAux, 9                                                                           ; Compara numAux com 9 (numAux == 9)
		je      RaizQ_Inicio_02                                                                   	; Sim, salta
		cmp     numAux, 10                                                                          ; Compara numAux com 10 (numAux == 10)
		je      RaizQ_Inicio_03                                                                   	; Sim, salta
		cmp     numAux, 11                                                                          ; Compara numAux com 11 (numAux == 11)
		je      RaizQ_Inicio_04                                                                   	; Sim, salta
		cmp     numAux, 12                                                                          ; Compara numAux com 12 (numAux == 12)
		je      RaizQ_Inicio_05                                                                   	; Sim, salta
		cmp     numAux, 13                                                                          ; Compara numAux com 13 (numAux == 13)
		je      RaizQ_Inicio_06                                                                   	; Sim, salta
		
		; ----- [Apresenta no dividendo o número indicado] ------------------------------------------

		RaizQ_Inicio_02:    
		call    RaizQInicioRadicando                                                              	; Executa o procedimento
		jmp     RaizQ_Inicio_01                                                                   	; Salta
		
		; ----- [Se for um '-'] ---------------------------------------------------------------------
		
		RaizQ_Inicio_03:
		mov     dh, 6                                                                               ; Define a coluna para apresentar o caracter
		;call    AlternarSinal                                                                       ; Executa o procedimento
		jmp     RaizQ_Inicio_01                                                                   	; Salta
		
		; ----- [Se for um ','] ---------------------------------------------------------------------
		
		RaizQ_Inicio_04:
        ;call    RaizQInicioVirgula                                                                  ; Executa o procedimento    
		jmp     RaizQ_Inicio_01                                                                   	; Salta
		
		; ----- [Se for um 'BACKSPACE'] -------------------------------------------------------------
		
		RaizQ_Inicio_05:
		call    RaizQInicioBackspace                                                                ; Executa o procedimento    
		jmp     RaizQ_Inicio_01                                                                   	; Salta
		
		; ----- [Se for um 'ENTER'] -----------------------------------------------------------------
		
		RaizQ_Inicio_06:
		
		ret
		
	RaizQInicio endp
	
	; ----- [Procediomento para colocar uma vírguala no radicando] ----------------------------------
	
	RaizQInicioVirgula proc near
	    
	    ; ----- [Verifica se já existe vírgula] -----------------------------------------------------
        
        cmp     iVirgula,0                                                                          ; Compara iVirgula com 1 (iVirgula == 0)
        je      RaizQ_Inicio_Virgula_01                                                             ; Sim, salta
        ret
        
        RaizQ_Inicio_Virgula_01:
        cmp     index,0                                                                             ; Compara index com 0 (index <> 0)
        jne     RaizQ_Inicio_Virgula_02                                                             ; Sim, salta
        ret
        RaizQ_Inicio_Virgula_02:
        cmp     index,8                                                                             ; Compara index com 8 (index < 8)
        jng     RaizQ_Inicio_Virgula_03                                                             ; Sim, salta
        ret
        
        ; ----- [Insere o algarismo pretendido no dividendo] ----------------------------------------
        
        RaizQ_Inicio_Virgula_03:
        mov     al, 2ch																				; Al recebe 2ch -> código hexadecimal para a vírgula na tabela ASCII
		call    SetRadicando                                                                        ; Executa o procedimento    
		
		; ----- [Apresenta o algarismo no ecrã] -----------------------------------------------------
		
		mov     ah, 02h                                                                             ; Define para posicionar o cursor
        mov     bh, 00h                                                                             ; Define o número da página
        mov     dl, 22                                                                              ; Define a coluna
        add     dx, index                                                                           ; Dx = dx + index
        mov     dh, 6                                                                               ; Define a linha
        int     10h                                                                                 ; Executa a interrupção
		mov     dl, ','                                                                             ; Define o caractere a apresentar
        int     21h                                                                                 ; Executa a interrupção
		mov     cx, index																			; Cx recebe index
		mov     iVirgula, cx                                                                        ; iVirgula = 1
		inc     index																				; Incrementa o index						
        
        ret
	        
	RaizQInicioVirgula endp    
	
	; ----- [Procedimento para fazer um backspace ao radicando] -------------------------------------
	
	RaizQInicioBackspace proc near
		
		cmp     index, 0																			; Compara index com zero (index == 0)
		jne     RaizQ_Inicio_Backspace_01															; Não, salta
		ret
		RaizQ_Inicio_Backspace_01:
		mov     al, ' '																			    ; Al recebe ' ' (espaço)
		dec     index																				; Decrementa o index
		call    SetRadicando																		; Executa o procedimento
		mov     ah, 02h                                                                             ; Define para posicionar o cursor
        mov     bh, 00h                                                                             ; Define o número da página
        mov     dl, 22                                                                              ; Define a coluna
        add     dx, index                                                                           ; Dx = dx + index
        mov     dh, 6                                                                               ; Define a linha
        int     10h                                                                                 ; Executa a interrupção
		mov     dl, ' '                                                                             ; Define o caractere a apresentar
        int     21h                                                                                 ; Executa a interrupção
		mov     cx, iVirgula																		; Cx recebe iVirgula
		cmp     index, cx																			; Compara index com cx (index <> cx)
		jne     RaizQ_Inicio_05_01																	; Sim, salta
		mov     iVirgula, 0																			; iVirgula recebe 0
		
		RaizQ_Inicio_05_01:
		ret
		
	RaizQInicioBackspace endp
	
	; ----- [Procedimento para popular o radicando e mostrar valor] ---------------------------------
	
	RaizQInicioRadicando proc near
		
		call    GetNumeroAleat                                                                      ; Executa o procedimento
		
		; ----- [Verifica se o radicando está cheio] ------------------------------------------------
		
		cmp     index, 10                                                                           ; Compara index com 10 (index < 10)
		jb      RaizQ_Inicio_Radicando_01                                                         	; Sim, salta
		ret
		
		; ----- [Insere o algarismo pretendido no radicando] ----------------------------------------
		RaizQ_Inicio_Radicando_01:
		call    SetRadicando                                                                        ; Executa o procedimento
		
		; ----- [Verifica se o primeiro algarismo do radicando é um zero] --------------------------- 
        
        cmp     index, 0                                                                            ; Compara index com zero (index <> 0)
        jne     RaizQ_Inicio_Radicando_02                                                         	; Sim, salta
        cmp     al, 0                                                                               ; Compara al com zero (al <> 0)
        jne     RaizQ_Inicio_Radicando_02                                                         	; Sim, salta
		ret
		
		; ----- [Apresenta o algarismo no ecrã] -----------------------------------------------------
		RaizQ_Inicio_Radicando_02:
		mov     ah, 02h                                                                             ; Define para posicionar o cursor
        mov     bh, 00h                                                                             ; Define o número da página
        mov     dl, 22                                                                              ; Define a coluna
        add     dx, index                                                                           ; Dx = dx + index
        mov     dh, 6                                                                               ; Define a linha
        int     10h                                                                                 ; Executa a interrupção
		add     al, 30h                                                                             ; Al = al + 30h
		mov     dl, al                                                                              ; Define o caractere a apresentar
        int     21h                                                                                 ; Executa a interrupção		
		inc     index																				; Incrementa o index	

		ret
		
	RaizQInicioRadicando endp
	
	; ----- [Procedimento para colocar no radicando o número pretendido] ----------------------------
	
	SetRadicando proc near
		
		; ----- [Verifica se o primeiro algarismo do radicando é um zero] --------------------------- 
        
        cmp     index, 0                                                                            ; Compara index com zero (index <> 0)
        jne     Set_Radicando_01                                                                    ; Sim, salta
        cmp     al, 0                                                                               ; Compara al com zero (al <> 0)
        jne     Set_Radicando_01                                                                    ; Sim, salta
        
        ret
        
        ; ----- [Definir o próximo algarismo do radicando] ------------------------------------------
        
        Set_Radicando_01:
        mov     cx, index                                                                           ; Cx recebe o index
        mov     si, offset radicando                                                                ; Si aponta para a variável radicando
        add     si, cx                                                                              ; Si = si + cx
        
        ; ----- [Colocar o número pressionado no radicando] -----------------------------------------
        
        mov     [si], al                                                                            ; Coloca al na memória apontada por si
                
        ret
		
	SetRadicando endp
	
    ; ----- [Procedimento que espera o utilizador pressionar os botões de guardar e voltar] ---------
    
    ResultadosEsperaBotao proc near
        
        ; ----- [Prepara variável auxiliar] ---------------------------------------------------------
        
        mov     numAux, '?'                                                                         ; Variável para saber qual botão foi pressionado
        
        ; ----- [Mostrar o rato] --------------------------------------------------------------------
        
        mov     ax, 0001h                                                                           ; Define para mostrar o ponteiro do rato
        int     33h                                                                                 ; Executa a interrupção
        
        ; ----- [Verificar se o rato foi pressionado] -----------------------------------------------
        
        Resultados_Espera_Botao_01:
        mov     ax, 0001h                                                                           ; Define para mostrar o ponteiro do rato
        int     33h                                                                                 ; Executa a interrupção
        mov     ax, 00003h                                                                          ; Define para receber  a posição e o status do rato
        int     33h                                                                                 ; Executa a interrupção
        cmp     bx, 1                                                                               ; Compara bx com 1 (bx == 1) (Mouse1) 
        je      Resultados_Espera_Botao_02                                                          ; Se sim, salta 
        jmp     Resultados_Espera_Botao_01                                                          ; Reloop
        
        ; ----- [Voltar] ----------------------------------------------------------------------------
        
        Resultados_Espera_Botao_02:
        mov     x1, 003ch                                                                           ; x1 recebe a coluna inicial do botão
        mov     x2, 00dch                                                                           ; x2 recebe a coluna final do botão
        mov     y1, 003ch                                                                           ; y1 recebe a linha inicial do botão
        mov     y2, 0064h                                                                           ; y2 recebe a linha final do botão
        mov     numAux, 0                                                                           ; numAux recebe 0
        call    VerificaBotao                                                                       ; Executa o procedimento
        cmp     numAux, '?'                                                                         ; Compara numAux com '?' (numAux == '?')
		je		Resultados_Espera_Botao_03                                                          ; Sim, salta
        ret                                                                                         
        
        ; ----- [Guardar] ---------------------------------------------------------------------------
        
		Resultados_Espera_Botao_03:
        mov     x1, 003ch                                                                           ; x1 recebe a coluna inicial do botão
        mov     x2, 00dch                                                                           ; x2 recebe a coluna final do botão
        mov     y1, 0069h                                                                           ; y1 recebe a linha inicial do botão
        mov     y2, 0091h                                                                           ; y2 recebe a linha final do botão
        mov     numAux, 1                                                                           ; numAux recebe 1
        call    VerificaBotao                                                                       ; Executa o procedimento
        cmp     numAux, '?'                                                                         ; Compara numAux com '?' (numAux == '?')
        je     	Resultados_Espera_Botao_01                                                          ; Sim, salta
        
        call    EscreverFicheiro                                                                    ; Executa o procedimento
        
        ret
            
    ResultadosEsperaBotao endp    
    
    ; ----- [Inicializar o modo gráfico / Limpar ecrã] ----------------------------------------------
    
    InitModoGrafico proc near
        
        mov     ah, 00h                                                                             ; Define o modo gráfico
        mov     al, 13h                                                                             ; Modo gráfico - 320x200 - 256 cores
        int     10h                                                                                 ; Executa a interrupção
        
        ret
            
    InitModoGrafico endp    
    
    ; ----- [Procedimento para executar a divisão] --------------------------------------------------
    
    DivisaoExecuta proc near
        
        call    DivisaoExecutaAtualizacao															; Executa o procedimento
        mov     index, 0																			; Index recebe zero 0
                            
        ; ----- [Controla o dividendo] --------------------------------------------------------------
        
        Divisao_Executa_Loop:
                       
        mov     si, offset dividendo																; Si aponta para a variável dividendo
        add     si, index																			; Si = si + index
        
        ; ----- [Recebe o algarismo High-Order] -----------------------------------------------------
        
        mov     ax, [si]																			; Ax recebe o valor apontado por si	
        mov     ah, 0																				; Garante zero no ah
        cmp     al, ' '																				; Compara al com um espaço (al == " ")	
        je      Divisao_Executa_Fim																	; Sim, salta
        cmp     al, ','																				; Compara al com uma vírgula (al <> ",")
        jne     Divisao_Executa_Continua															; Sim, salta
        
        ; ----- [Concatenar a vírgula ao quociente] -------------------------------------------------
        
        mov     bx, offset quociente																; Bx aponta para a variável quociente	
        add     bx, index																			; Bx = bx + index
        mov     [bx], al																			; Coloca na posição apontada por bx o valor de al
        inc     index																				; Incrementa o index
        cmp     index, 10																			; Compara index com 10 (index < 10)
        jb      Divisao_Executa_Loop																; Sim, reloop
        jmp     Divisao_Executa_Fim																	; Salta	
        
        ; ----- [Concatena o algarismo ao resto] ----------------------------------------------------
        
        Divisao_Executa_Continua:
        mov     ho, al																				; ho recebe al
        mov     ax, resto																			; Ax recebe resto		
        mov     cx, 10																				; Cx recebe 10
        mul     cx																					; Ax = ax * cx		
        mov     resto, ax																			; resto recebe ax
        mov     bh, 0																				; Bh recebe zero 0
        mov     bl, ho																				; Bl recebe ho
        add     resto, bx																			; resto = resto + bx
        
        ; ----- [Procedimento para encontrar o valor ótimo de alfa] ---------------------------------
        
        mov     cx, 0																				; Garante zero no cx
        
        call    DivisaoExecuta2																		; Executa o procedimento
        
        ; ----- [Concatenar o alfa ao quociente] ----------------------------------------------------
        
        mov     bx, offset quociente																; Bx aponta para a variável quociente
        add     bx, index																			; Bx = bx + index
        mov     [bx], cl																			; Coloca na posição apontada por bx o valor de cl
        inc     index																				; Incrementa o index
        mov     cx, 10																				; Cx recebe 10
        
        push    index       																		; Guarda index na pilha
        mov     index, 0																			; index recebe zero 0
        call    DivisaoExecutaAtualizacao2															; Executa o procedimento
        pop     index																				; Retira da pilha o valor de index
        
        cmp     index, 10																			; Compara index com 10 (index < 10)
        jb      Divisao_Executa_Loop																; Sim, reloop
        
        Divisao_Executa_Fim:
        ret
        
    DivisaoExecuta endp    
    
    ; ----- [Procedimento para verificar o alfa na divisão] -----------------------------------------
    
    DivisaoExecuta2 proc near
        
        Divisao_Executa_Alfa:
        mov     ax, divisor																			; Ax recebe divisor
        mul     cx																					; Ax = ax * cx
        
        ; ----- [Verifica se o alfa é correto] ------------------------------------------------------
        
        cmp     ax, resto																			; Compara ax com resto (ax > resto)
        jg      Divisao_Executa_Alfa_Fim															; Sim, salta
        inc     cx																					; Incrementa cx
        jmp     Divisao_Executa_Alfa																; Salta
        
        Divisao_Executa_Alfa_Fim:
        cmp     ax, resto																			; Compara ax com resto (ax < resto)
        jng     Divisao_Executa_Fim2																; Sim, salta
        mov     ax, divisor																			; Ax recebe divisor
        dec     cx																					; Decrementa cx
        mul     cx																					; Ax = ax * cx	
        
        Divisao_Executa_Fim2:
        sub     resto, ax																			; resto = resto - ax
        
        ret
            
    DivisaoExecuta2 endp    
    
    ; ----- [Atualiza o ecrã onde mostra o quociente a ser calculado] -------------------------------
    
    DivisaoExecutaAtualizacao2 proc near
        
        mov     ah, 02h                                                                             ; Define para posicionar o cursor
        mov     bh, 00h                                                                             ; Define o número da página
        mov     dh, 4                                                                               ; Define a linha
        mov     dl, 15                                                                              ; Define a coluna
        int     10h                                                                                 ; Executa a interrupção
        mov     dl, 0ceh                                                                            ; Define o caractere para output
        int     21h                                                                                 ; Executa a interrupção
        mov     ah, 02h                                                                             ; Define para posicionar o cursor
        mov     bh, 00h                                                                             ; Define o número da página
        mov     dh, 5                                                                               ; Define a linha
        mov     dl, 15                                                                              ; Define a coluna
        int     10h                                                                                 ; Executa a interrupção
        mov     dl, 0bah                                                                            ; Define o caractere para output
        int     21h                                                                                 ; Executa a interrupção
        
        ; ----- [Mostra o resto] --------------------------------------------------------------------
        
        mov     ah, 02h                                                                             ; Define para posicionar o cursor
        mov     bh, 00h                                                                             ; Define o número da página
        mov     dh, 5                                                                               ; Define a linha
        mov     dl, 5                                                                               ; Define a coluna
        int     10h                                                                                 ; Executa a interrupção
        
        mov     ax, resto																			; Ax recebe resto
        call    PrintNumero																			; Executa o procedimento	
        
        ; ----- [Mostra o quociente] ----------------------------------------------------------------
                
        cmp     flagSinal, 0																		; Compara flagSinal com zero (flagSinal == 0)
        je      D_E_A_2_NEXT																		; Sim, salta
        mov     ah, 02h                                                                             ; Define para posicionar o cursor
        mov     bh, 00h                                                                             ; Define o número da página
        mov     dh, 5                                                                               ; Define a linha
        mov     dl, 16                                                                              ; Define a coluna
        int     10h                                                                                 ; Executa a interrupção
        mov     dl, '-'                                                                             ; Define o caractere para output
        int     21h 																				; Executa a interrupção
        
        D_E_A_2_NEXT:
        mov     ah, 02h                                                                             ; Define para posicionar o cursor
        mov     bh, 00h                                                                             ; Define o número da página
        mov     dh, 5                                                                               ; Define a linha
        mov     dl, 17                                                                              ; Define a coluna
        int     10h                                                                                 ; Executa a interrupção    
        
        D_E_A_2_1:
        mov     si, offset quociente																; Si aponta para a variável quociente	
        add     si, index																			; Si = si + index	
        mov     bx, [si]																			; Bx recebe o valor apontado por si
        mov     bh, 0																				; Garante zero no bh
        
        cmp     bl, ' '																				; Compara bl com um espaço (bl == " ")
        je      D_E_A_2_3																			; Sim, salta
        cmp     bl, ','																				; Compara bl com uma vírgula (bl == ",")
        je      D_E_A_2_3																			; Sim, salta
        
        add     bl, 30h																				; Bl = bl + 30h
        
        D_E_A_2_3:
        mov     dl, bl                                                                              ; Define o caractere para output
        int     21h                                                                                 ; Executa a interrupção
        
        mov     ah, 02h																				; Define para posicionar o cursor/escrever no ecrã
        inc     dl																					; Incrementa dl	
        inc     index																				; Incrementa index
        
        cmp     index, 10																			; Compara index com 10 (index == 10)
        je      D_E_A_2_Fim																			; Sim, salta
        
        jmp     D_E_A_2_1																			; Reloop
        
        D_E_A_2_Fim:
        ret
            
    DivisaoExecutaAtualizacao2 endp    
    
    ; ----- [Atualiza o ecrã onde mostra o quociente a ser calculado] -------------------------------
    
    DivisaoExecutaAtualizacao proc near
        
        ; ----- [Limpa o ecrã] ----------------------------------------------------------------------
        
        call    InitModoGrafico																		; Executa o procedimento
        
        ; ----- [Inicializa o index] ----------------------------------------------------------------
        
        mov     index, 0																			; index recebe zero 0
        
        ; ----- [Posicionar o cursor] ---------------------------------------------------------------
        
        mov     ah, 02h                                                                             ; Define para posicionar o cursor
        mov     bh, 00h                                                                             ; Define o número da página
        mov     dh, 3                                                                               ; Define a linha
        mov     dl, 5                                                                               ; Define a coluna
        int     10h                                                                                 ; Executa a interrupção     
        
        ; ----- [Escrever o dividendo] --------------------------------------------------------------
        
        Divisao_Executa_Atualizacao_01:
        mov     si, offset dividendo																; Si aponta para a variável dividendo
        add     si, index																			; Si = si + index
        mov     bx, [si]																			; Bx recebe o valor apontado por si
        mov     bh, 0																				; Garante zero no bh
        
        cmp     bl, ' '																				; Compara bl com um espaço (bl == " ")
        je      Divisao_Executa_Atualizacao_03														; Sim, salta
        cmp     bl, ','																				; Compara bl com uma vírgula (bl == ",")
        je      Divisao_Executa_Atualizacao_03														; Sim, salta
                
        add     bl, 30h																				; Bl = bl + 30h
        Divisao_Executa_Atualizacao_03:
        mov     dl, bl                                                                              ; Define o caractere para output
        int     21h                                                                                 ; Executa a interrupção
        
        mov     ah, 02h																				; Define para posicionar o cursor/escrever no ecrã
        inc     dl																					; Incrementa dl
        inc     index																				; Incrementa index	
        
        cmp     index, 10																			; Compara index com 10 (index == 10)
        je      Divisao_Executa_Atualizacao_Fim														; Sim, salta
        
        jmp     Divisao_Executa_Atualizacao_01														; Reloop
        
        Divisao_Executa_Atualizacao_Fim:
        
        ; ----- [Desenhos gráficos] -----------------------------------------------------------------
        
        mov     dl, 0bah                                                                            ; Define o caractere para output
        int     21h                                                                                 ; Executa a interrupção
        mov     dl, ' '																				; Dl recebe um espaço " "
        int     21h																					; Executa a interrupção
        
        ; ----- [Escrever o divisor] ----------------------------------------------------------------
        
        mov     ax, divisor																			; Ax recebe divisor
        call    PrintNumero																			; Executa o procedimento
        
        ; ----- [Desenhos gráficos] -----------------------------------------------------------------
        
        mov     ah, 02h                                                                             ; Define para posicionar o cursor
        mov     bh, 00h                                                                             ; Define o número da página
        mov     dh, 4                                                                               ; Define a linha
        mov     dl, 5                                                                               ; Define a coluna
        int     10h                                                                                 ; Executa a interrupção
        mov     cx, 17																				; Cx recebe 17
        Divisao_Executa_Atualizacao_02:
        mov     ah, 02h                                                                             ; Define para posicionar o cursor
        mov     bh, 00h                                                                             ; Define o número da página
        mov     dl, 0cdh																			; Define o caractere para output
        int     21h																					; Executa a interrupção
        loop    Divisao_Executa_Atualizacao_02														; Reloop até cx==0		
        
        ret 
        
    DivisaoExecutaAtualizacao endp    
    
    ; ----- [Mostra menu da divisão para receber o dividendo e o divisor] ---------------------------
    
    DivisaoInicio proc near
        
        ; ----- [Limpa o ecrã] ----------------------------------------------------------------------
        
        call    InitModoGrafico                                                                     ; Executa o procedimento
        
        ; ----- [Apresenta o título da página] ------------------------------------------------------
        
        mov     ah, 02h                                                                             ; Define para posicionar o cursor
        mov     bh, 00h                                                                             ; Define o número da página
        mov     dh, 1                                                                               ; Define a linha
        mov     dl, 1                                                                               ; Define a coluna
        int     10h                                                                                 ; Executa a interrupção
        mov     ah, 09h                                                                             ; Define para escrever texto
        lea     dx, strDivisaoTitulo                                                                ; Define o apontador para o início da variável string
        int     21h                                                                                 ; Executa a interrupção
        
        ; ----- [Apresenta informação] --------------------------------------------------------------
        
        mov     ah, 02h                                                                             ; Define para posicionar o cursor
        mov     bh, 00h                                                                             ; Define o número da página
        mov     dh, 4                                                                               ; Define a linha
        mov     dl, 1                                                                               ; Define a coluna
        int     10h                                                                                 ; Executa a interrupção
        mov     ah, 09h                                                                             ; Define para escrever texto
        lea     dx, strInfoNumeros1                                                                 ; Define o apontador para o início da variável string
        int     21h                                                                                 ; Executa a interrupção 
        
        mov     ah, 02h                                                                             ; Define para posicionar o cursor
        mov     bh, 00h                                                                             ; Define o número da página
        mov     dh, 6                                                                               ; Define a linha
        mov     dl, 1                                                                               ; Define a coluna
        int     10h                                                                                 ; Executa a interrupção
        mov     ah, 09h                                                                             ; Define para escrever texto
        lea     dx, strPedirDividendo                                                               ; Define o apontador para o início da variável string
        int     21h                                                                                 ; Executa a interrupção 
        
        ; ----- [Inicializa as variáveis] -----------------------------------------------------------
        
        mov     index, 0                                                                            ; Garante zero no index
        
        ; ----- [Mostra o teclado] ------------------------------------------------------------------
        
        call    MostraTeclado                                                                       ; Executa o procedimento
        
        ; ----- [Prepara para escrever o dividendo] -------------------------------------------------
        
        mov     ah, 02h                                                                             ; Define para posicionar o cursor
        mov     bh, 00h                                                                             ; Define o número da página
        mov     dh, 6                                                                               ; Define a linha
        mov     dl, 19                                                                              ; Define a coluna
        int     10h                                                                                 ; Executa a interrupção
        
        ; ----- [Verifica qual botão do teclado virtual foi pressionado] ----------------------------
        
		Divisao_Inicio_01:
        call    Delay                                                                               ; Executa o procedimento
        call    EsperaTecladoVirtual                                                                ; Executa o procedimento
        cmp     numAux, '?'																			; Compara numAux com '?' (numAux == '?')
        je     	Divisao_Inicio_01																	; Sim, reloop
		
		; ----- [Executa procedimentos dependendo do botão pressionado] -----------------------------
		
		cmp     numAux, 0                                                                           ; Compara numAux com 0 (numAux == 0)
		je      Divisao_Inicio_02                                                                   ; Sim, salta
		cmp     numAux, 1                                                                           ; Compara numAux com 1 (numAux == 1)
		je      Divisao_Inicio_02                                                                   ; Sim, salta
		cmp     numAux, 2                                                                           ; Compara numAux com 2 (numAux == 2)
		je      Divisao_Inicio_02                                                                   ; Sim, salta
		cmp     numAux, 3                                                                           ; Compara numAux com 3 (numAux == 3)
		je      Divisao_Inicio_02                                                                   ; Sim, salta
		cmp     numAux, 4                                                                           ; Compara numAux com 4 (numAux == 4)
		je      Divisao_Inicio_02                                                                   ; Sim, salta
		cmp     numAux, 5                                                                           ; Compara numAux com 5 (numAux == 5)
		je      Divisao_Inicio_02                                                                   ; Sim, salta
		cmp     numAux, 6                                                                           ; Compara numAux com 6 (numAux == 6)
		je      Divisao_Inicio_02                                                                   ; Sim, salta
		cmp     numAux, 7                                                                           ; Compara numAux com 7 (numAux == 7)
		je      Divisao_Inicio_02                                                                   ; Sim, salta
		cmp     numAux, 8                                                                           ; Compara numAux com 8 (numAux == 8)
		je      Divisao_Inicio_02                                                                   ; Sim, salta
		cmp     numAux, 9                                                                           ; Compara numAux com 9 (numAux == 9)
		je      Divisao_Inicio_02                                                                   ; Sim, salta
		cmp     numAux, 10                                                                          ; Compara numAux com 10 (numAux == 10)
		je      Divisao_Inicio_03                                                                   ; Sim, salta
		cmp     numAux, 11                                                                          ; Compara numAux com 11 (numAux == 11)
		je      Divisao_Inicio_04                                                                   ; Sim, salta
		cmp     numAux, 12                                                                          ; Compara numAux com 12 (numAux == 12)
		je      Divisao_Inicio_05                                                                   ; Sim, salta
		cmp     numAux, 13                                                                          ; Compara numAux com 13 (numAux == 13)
		je      Divisao_Inicio_06                                                                   ; Sim, salta
		
		; ----- [Apresenta no dividendo o número indicado] ------------------------------------------

		Divisao_Inicio_02:    
		call    DivisaoInicioDividendo                                                              ; Executa o procedimento
		jmp     Divisao_Inicio_01                                                                   ; Salta
		
		; ----- [Se for um '-'] ---------------------------------------------------------------------
		
		Divisao_Inicio_03:
		mov     dh, 6                                                                               ; Define a coluna para apresentar o caracter
		call    AlternarSinal                                                                       ; Executa o procedimento
		jmp     Divisao_Inicio_01                                                                   ; Salta
		
		; ----- [Se for um ','] ---------------------------------------------------------------------
		
		Divisao_Inicio_04:
        call    DivisaoInicioVirgula                                                                ; Executa o procedimento    
		jmp     Divisao_Inicio_01                                                                   ; Salta
		
		; ----- [Se for um 'BACKSPACE'] -------------------------------------------------------------
		
		Divisao_Inicio_05:
		call    DivisaoInicioBackspace                                                              ; Executa o procedimento    
		jmp     Divisao_Inicio_01                                                                   ; Salta
		
		; ----- [Se for um 'ENTER'] -----------------------------------------------------------------
		
		Divisao_Inicio_06:
	    
	    ; ----- [Inicializa as variáveis] -----------------------------------------------------------
        
        mov     index, 0                                                                            ; Garante zero no index
		
		; ----- [Mostra o teclado novamente] --------------------------------------------------------
        
        call    MostraTeclado                                                                       ; Executa o procedimento
	    
		; ----- [Apresenta informação] --------------------------------------------------------------
        
        mov     ah, 02h                                                                             ; Define para posicionar o cursor
        mov     bh, 00h                                                                             ; Define o número da página
        mov     dh, 8                                                                               ; Define a linha
        mov     dl, 1                                                                               ; Define a coluna
        int     10h                                                                                 ; Executa a interrupção
        mov     ah, 09h                                                                             ; Define para escrever texto
        lea     dx, strInfoNumeros2                                                                 ; Define o apontador para o início da variável string
        int     21h                                                                                 ; Executa a interrupção 
        
        mov     ah, 02h                                                                             ; Define para posicionar o cursor
        mov     bh, 00h                                                                             ; Define o número da página
        mov     dh, 10                                                                              ; Define a linha
        mov     dl, 1                                                                               ; Define a coluna
        int     10h                                                                                 ; Executa a interrupção
        mov     ah, 09h                                                                             ; Define para escrever texto
        lea     dx, strPedirDivisor                                                                 ; Define o apontador para o início da variável string
        int     21h                                                                                 ; Executa a interrupção

        ; ----- [Prepara para escrever o divisor] ---------------------------------------------------
        
        mov     ah, 02h                                                                             ; Define para posicionar o cursor
        mov     bh, 00h                                                                             ; Define o número da página
        mov     dh, 10                                                                              ; Define a linha
        mov     dl, 19                                                                              ; Define a coluna
        int     10h                                                                                 ; Executa a interrupção
		
		; ----- [Verifica qual botão do teclado virtual foi pressionado] ----------------------------
        
		Divisao_Inicio_07:
        call    Delay                                                                               ; Executa o procedimento
        call    EsperaTecladoVirtual                                                                ; Executa o procedimento
        cmp     numAux, '?'																			; Compara numAux com '?' (numAux == '?')
        je     	Divisao_Inicio_07																	; Sim, reloop
		
		; ----- [Executa procedimentos dependendo do botão pressionado] -----------------------------
		
		cmp     numAux, 0                                                                           ; Compara numAux com 0 (numAux == 0)
		je      Divisao_Inicio_08                                                                   ; Sim, salta
		cmp     numAux, 1                                                                           ; Compara numAux com 1 (numAux == 1)
		je      Divisao_Inicio_08                                                                   ; Sim, salta
		cmp     numAux, 2                                                                           ; Compara numAux com 2 (numAux == 2)
		je      Divisao_Inicio_08                                                                   ; Sim, salta
		cmp     numAux, 3                                                                           ; Compara numAux com 3 (numAux == 3)
		je      Divisao_Inicio_08                                                                   ; Sim, salta
		cmp     numAux, 4                                                                           ; Compara numAux com 4 (numAux == 4)
		je      Divisao_Inicio_08                                                                   ; Sim, salta
		cmp     numAux, 5                                                                           ; Compara numAux com 5 (numAux == 5)
		je      Divisao_Inicio_08                                                                   ; Sim, salta
		cmp     numAux, 6                                                                           ; Compara numAux com 6 (numAux == 6)
		je      Divisao_Inicio_08                                                                   ; Sim, salta
		cmp     numAux, 7                                                                           ; Compara numAux com 7 (numAux == 7)
		je      Divisao_Inicio_08                                                                   ; Sim, salta
		cmp     numAux, 8                                                                           ; Compara numAux com 8 (numAux == 8)
		je      Divisao_Inicio_08                                                                   ; Sim, salta
		cmp     numAux, 9                                                                           ; Compara numAux com 9 (numAux == 9)
		je      Divisao_Inicio_08                                                                   ; Sim, salta
		cmp     numAux, 10                                                                          ; Compara numAux com 10 (numAux == 10)
		je      Divisao_Inicio_09                                                                   ; Sim, salta
		cmp     numAux, 11                                                                          ; Compara numAux com 11 (numAux == 11)
		je      Divisao_Inicio_10                                                                   ; Sim, salta
		cmp     numAux, 12                                                                          ; Compara numAux com 12 (numAux == 12)
		je      Divisao_Inicio_11                                                                   ; Sim, salta
		cmp     numAux, 13                                                                          ; Compara numAux com 13 (numAux == 13)
		je      Divisao_Inicio_12                                                                   ; Sim, salta
		
		; ----- [Apresenta no divisor o número indicado] --------------------------------------------

		Divisao_Inicio_08:    
		call    DivisaoInicioDivisor                                                                ; Executa o procedimento
		jmp     Divisao_Inicio_07                                                                   ; Salta
		
		; ----- [Se for um '-'] ---------------------------------------------------------------------
		
		Divisao_Inicio_09:
		mov     dh, 10                                                                              ; Define a coluna para apresentar o caracter
		call    AlternarSinal                                                                       ; Executa o procedimento
		jmp     Divisao_Inicio_07                                                                   ; Salta
		
		; ----- [Se for um ','] ---------------------------------------------------------------------
		
		Divisao_Inicio_10:
        call    DivisaoInicioVirgula                                                                ; Executa o procedimento    
		jmp     Divisao_Inicio_07                                                                   ; Salta
		
		; ----- [Se for um 'BACKSPACE'] -------------------------------------------------------------
		
		Divisao_Inicio_11:
		call    DivisorBackspace                                                                    ; Executa o procedimento    
		call    PrintNumero																			; Executa o procedimento  
		jmp     Divisao_Inicio_07                                                                   ; Salta
		
		; ----- [Se for um 'ENTER'] -----------------------------------------------------------------
		
		Divisao_Inicio_12:
		
        ret
            
    DivisaoInicio endp    
    
    ; ----- [Procedimento para fazer um backspace ao divisor] ---------------------------------------
    
    DivisorBackspace proc near
        
        mov     ah, 02h                                                                             ; Define para posicionar o cursor
        mov     bh, 00h                                                                             ; Define o número da página
        mov     dh, 10                                                                              ; Define a linha
        mov     dl, 22                                                                              ; Define a coluna
        int     10h                                                                                 ; Executa a interrupção
        
        mov     cx, 10                                                                              ; Cx recebe 10 (contador)
        mov     dl, ' '                                                                             ; Define o caractere a apresentar
        Divisor_Backspace_Loop:
        int     21h                                                                                 ; Executa a interrupção
        loop    Divisor_Backspace_Loop                                                              ; Reloop
        
        mov     ah, 02h                                                                             ; Define para posicionar o cursor
        mov     bh, 00h                                                                             ; Define o número da página
        mov     dh, 10                                                                              ; Define a linha
        mov     dl, 22                                                                              ; Define a coluna
        int     10h                                                                                 ; Executa a interrupção
        
        mov     ax, divisor                                                                         ; Ax recebe divisor
        mov     bx, 10                                                                              ; Bx recebe 10
        xor     dx, dx                                                                              ; Garante zero no dx
        div     bx                                                                                  ; Ax = ax / bx
        mov     divisor, ax                                                                         ; Divisor recebe ax
        
        ret
        
    DivisorBackspace endp    
    
    ; ----- [Procedimento para popular o divisor e mostrar valor] -----------------------------------
    
    DivisaoInicioDivisor proc near
        
        call    GetNumeroAleat                                                                      ; Executa o procedimento
		
		; ----- [Insere o algarismo pretendido no dividendo] ----------------------------------------
		Divisao_Inicio_Divisor_01:
		call    SetDivisor                                                                          ; Executa o procedimento
				
		; ----- [Apresenta o algarismo no ecrã] -----------------------------------------------------
		Divisao_Inicio_Divisor_02:
		mov     ah, 02h                                                                             ; Define para posicionar o cursor
        mov     bh, 00h                                                                             ; Define o número da página
        mov     dh, 10                                                                              ; Define a linha
        mov     dl, 22                                                                              ; Define a coluna
        int     10h                                                                                 ; Executa a interrupção
		
		mov     ax, divisor																			; Ax recebe divisor
		call    PrintNumero                                                                         ; Executa o procedimento    	
		
		ret
            
    DivisaoInicioDivisor endp    
    
    ; ----- [Procedimento que colocar no dividendo o número pretendido] -----------------------------
    
    SetDivisor proc near
        
        ; ----- [Recebe o valor atual do divisor] ---------------------------------------------------
        
        mov     cx, divisor                                                                         ; Cx recebe divisor
        
        ; ----- [Verifica se o divisor é suportado < 10000] -----------------------------------------
        
        cmp     cx, 999                                                                             ; Compara cx com 999 (cx <= 999)
        jbe     Set_Divisor_01                                                                      ; Sim, salta
        ret    
        
        ; ----- [Incrementa o algarismo ao divisor] -------------------------------------------------
        
        Set_Divisor_01:
        mov     bx, ax                                                                              ; Bx recebe ax
        mov     ax, cx                                                                              ; Ax recebe cx
        mov     cx, 10                                                                              ; Cx recebe 10
        mul     cx                                                                                  ; Ax = ax * cx
        add     ax, bx                                                                              ; Ax = ax + bx
        mov     divisor, ax                                                                         ; Divisor recebe ax
        
        ret
            
    SetDivisor endp    
    
    ; ----- [Procedimento para escrevre um número] --------------------------------------------------
    ; ----- [INPUT: Ax tem o valor do número] -------------------------------------------------------
    
    PrintNumero proc near
        
        push    dx																					; Guarda na pilha o valor de dx
        push    cx																					; Guarda na pilha o valor de cx
        push    bx																					; Guarda na pilha o valor de bx
        
        xor     cx, cx																				; Garante zero no cx
        mov     bx, 10																				; Bx recebe 10	
        
        P_N_1:
        xor     dx, dx																				; Garante zero no dx
        div     bx																					; Ax = ax / bx
        push    dx																					; Guarda na pilha o valor de dx
        inc     cx																					; Incrementa cx
        or      ax, ax																				; Verifica se ax tem zero																	
        jnz     P_N_1																				; Não, reloop
        
        P_N_2:
        pop     dx																					; Retira o valor do topo da pilha para dx	
        mov     ah, 06h																				; Define para escrever no ecrã
        add     dl, 30h																				; Dl = dl + 30h
        int     21h																					; Executa a interrupção
        loop    P_N_2																				; Reloop até cx == 0
        
        pop     bx																					; Retira o valor do topo da pilha para bx
        pop     cx																					; Retira o valor do topo da pilha para cx
        pop     dx																					; Retira o valor do topo da pilha para dx	
                
        ret
            
    PrintNumero endp   
    
    ; ----- [Procedimento para fazer um backspace ao dividendo] -------------------------------------
    
    DivisaoInicioBackspace proc near
        
        cmp     index, 0																			; Compara index com zero (index == 0)
		jne     Divisao_Inicio_Backspace_01															; Não, salta
		ret
		Divisao_Inicio_Backspace_01:
		mov     al, ' '																				; Al recebe ' ' (espaço)
		dec     index																				; Decrementa o index
		call    SetDividendo																		; Executa o procedimento
		mov     ah, 02h                                                                             ; Define para posicionar o cursor
        mov     bh, 00h                                                                             ; Define o número da página
        mov     dl, 22                                                                              ; Define a coluna
        add     dx, index                                                                           ; Dx = dx + index
        mov     dh, 6                                                                               ; Define a linha
        int     10h                                                                                 ; Executa a interrupção
		mov     dl, ' '                                                                             ; Define o caractere a apresentar
        int     21h                                                                                 ; Executa a interrupção
		mov     cx, iVirgula																		; Cx recebe iVirgula
		cmp     index, cx																			; Compara index com cx (index <> cx)
		jne     Divisao_Inicio_05_01																; Sim, salta
		mov     iVirgula, 0																			; iVirgula recebe 0
		Divisao_Inicio_05_01:
    
        ret
        
    DivisaoInicioBackspace endp    
    
    ; ----- [Procedimento para manipular a vírgula no dividendo e mostrar] --------------------------
    
    DivisaoInicioVirgula proc near
        
        ; ----- [Verifica se já existe vírgula] -----------------------------------------------------
        
        cmp     iVirgula,0                                                                          ; Compara iVirgula com 1 (iVirgula == 0)
        je      Divisao_Inicio_Virgula_01                                                           ; Sim, salta
        ret
        
        Divisao_Inicio_Virgula_01:
        cmp     index,0                                                                             ; Compara index com 0 (index <> 0)
        jne     Divisao_Inicio_Virgula_02                                                           ; Sim, salta
        ret
        Divisao_Inicio_Virgula_02:
        cmp     index,8                                                                             ; Compara index com 8 (index < 8)
        jng     Divisao_Inicio_Virgula_03                                                           ; Sim, salta
        ret
        
        ; ----- [Insere o algarismo pretendido no dividendo] ----------------------------------------
        
        Divisao_Inicio_Virgula_03:
        mov     al, 2ch																				; Al recebe 2ch -> "," em hexadecimal
		call    SetDividendo                                                                        ; Executa o procedimento    
		
		; ----- [Apresenta o algarismo no ecrã] -----------------------------------------------------
		
		mov     ah, 02h                                                                             ; Define para posicionar o cursor
        mov     bh, 00h                                                                             ; Define o número da página
        mov     dl, 22                                                                              ; Define a coluna
        add     dx, index                                                                           ; Dx = dx + index
        mov     dh, 6                                                                               ; Define a linha
        int     10h                                                                                 ; Executa a interrupção
		mov     dl, ','                                                                             ; Define o caractere a apresentar
        int     21h                                                                                 ; Executa a interrupção
		mov     cx, index																			; Cx recebe index
		mov     iVirgula, cx                                                                        ; iVirgula = 1
		inc     index																				; Incrementa o index						
        
        ret
            
    DivisaoInicioVirgula endp    
    
    ; ----- [Procedimento para popular o dividendo e mostrar valor] ---------------------------------
    
    DivisaoInicioDividendo proc near
        
        call    GetNumeroAleat                                                                      ; Executa o procedimento
		
		; ----- [Verifica se o dividendo está cheio] ------------------------------------------------
		
		cmp     index, 10                                                                           ; Compara index com 10 (index < 10)
		jb      Divisao_Inicio_Dividendo_01                                                         ; Sim, salta
		ret
		
		; ----- [Insere o algarismo pretendido no dividendo] ----------------------------------------
		Divisao_Inicio_Dividendo_01:
		call    SetDividendo                                                                        ; Executa o procedimento
		
		; ----- [Verifica se o primeiro algarismo do dividendo é um zero] --------------------------- 
        
        cmp     index, 0                                                                            ; Compara index com zero (index <> 0)
        jne     Divisao_Inicio_Dividendo_02                                                         ; Sim, salta
        cmp     al, 0                                                                               ; Compara al com zero (al <> 0)
        jne     Divisao_Inicio_Dividendo_02                                                         ; Sim, salta
		ret
		
		; ----- [Apresenta o algarismo no ecrã] -----------------------------------------------------
		Divisao_Inicio_Dividendo_02:
		mov     ah, 02h                                                                             ; Define para posicionar o cursor
        mov     bh, 00h                                                                             ; Define o número da página
        mov     dl, 22                                                                              ; Define a coluna
        add     dx, index                                                                           ; Dx = dx + index
        mov     dh, 6                                                                               ; Define a linha
        int     10h                                                                                 ; Executa a interrupção
		add     al, 30h                                                                             ; Al = al + 30h
		mov     dl, al                                                                              ; Define o caractere a apresentar
        int     21h                                                                                 ; Executa a interrupção		
		inc     index																				; Incrementa o index	
		
		ret
            
    DivisaoInicioDividendo endp    
        
    ; ----- [Procedimento que colocar no dividendo o número pretendido] -----------------------------
    
    SetDividendo proc near
        
        ; ----- [Verifica se o primeiro algarismo do dividendo é um zero] --------------------------- 
        
        cmp     index, 0                                                                            ; Compara index com zero (index <> 0)
        jne     Set_Dividendo_01                                                                    ; Sim, salta
        cmp     al, 0                                                                               ; Compara al com zero (al <> 0)
        jne     Set_Dividendo_01                                                                    ; Sim, salta
        
        ret
        
        ; ----- [Definir o próximo algarismo do dividendo] ------------------------------------------
        
        Set_Dividendo_01:
        mov     cx, index                                                                           ; Cx recebe o index
        mov     si, offset dividendo                                                                ; Si aponta para a variável dividendo
        add     si, cx                                                                              ; Si = si + cx
        
        ; ----- [Colocar o número pressionado no dividendo] -----------------------------------------
        
        mov     [si], al                                                                            ; Coloca al na memória apontada por si
                
        ret
            
    SetDividendo endp    
     
    ; ----- [Procedimento que retorna em al o número pressionado] -----------------------------------
    
    GetNumeroAleat proc near
        
        mov     ch, 00h                                                                             ; Garante zero no ch
        mov     cl, numAux                                                                          ; Cl recebe numAux
        mov     ax, cx                                                                              ; Ax recebe cx
        mov     bx, 2                                                                               ; Bx recebe 2
        mul     bx                                                                                  ; Ax = ax * bx
        mov     si, offset numAleat                                                                 ; Si aponta para a variável numAleat
        add     si, ax                                                                              ; Si = si + ax
        mov     ax, [si]                                                                            ; Ax recebe o valor que está a ser apontado por si
 
        ret    
        
    GetNumeroAleat endp    
    
    ; ----- [Procedimento para ler se um botão do teclado virtual foi pressionado] ------------------
       
    EsperaTecladoVirtual proc near
        
        ; ----- [Prepara variável auxiliar] ---------------------------------------------------------
        
        mov     numAux, '?'                                                                         ; Variável para saber qual botão foi pressionado
        
        ; ----- [Mostrar o rato] --------------------------------------------------------------------
        
        mov     ax, 0001h                                                                           ; Define para mostrar o ponteiro do rato
        int     33h                                                                                 ; Executa a interrupção
        
        ; ----- [Verificar se o rato foi pressionado] -----------------------------------------------
        
        Espera_Teclado_Virtual_01:
        mov     ax, 0001h                                                                           ; Define para mostrar o ponteiro do rato
        int     33h                                                                                 ; Executa a interrupção
        mov     ax, 00003h                                                                          ; Define para receber  a posição e o status do rato
        int     33h                                                                                 ; Executa a interrupção
        cmp     bx, 1                                                                               ; Compara bx com 1 (bx == 1) (Mouse1) 
        je      Espera_Teclado_Virtual_02                                                           ; Se sim, salta 
        jmp     Espera_Teclado_Virtual_01                                                           ; Reloop
        
        ; ----- [Verifica se um botão foi pressionado] ----------------------------------------------
        
        Espera_Teclado_Virtual_02:
        cmp     dx, 0082h                                                                           ; Compara dx com 0082h (dx < 0082h)
        jb      Espera_Teclado_Virtual_01                                                           ; Sim, salta
        cmp     dx, 00ach                                                                           ; Compara dx com 00ach (dx > 00ach)
        jg      Espera_Teclado_Virtual_01                                                           ; Sim, salta
        cmp     cx, 0054h                                                                           ; Compara cx com 0054h (cx < 0054h)
        jb      Espera_Teclado_Virtual_01                                                           ; Sim, salta
        cmp     cx, 0214h                                                                           ; Compara cx com 0214h (cx > 0214h)
        jg      Espera_Teclado_Virtual_01                                                           ; Sim, salta
                
        ; ----- [0] ---------------------------------------------------------------------------------
        
        mov     x1, 0084h                                                                           ; x1 recebe a coluna inicial do botão
        mov     x2, 00a8h                                                                           ; x2 recebe a coluna final do botão
        mov     y1, 0082h                                                                           ; y1 recebe a linha inicial do botão
        mov     y2, 0094h                                                                           ; y2 recebe a linha final do botão
        mov     numAux, 0                                                                           ; numAux recebe 0
        call    VerificaBotao                                                                       ; Executa o procedimento
        cmp     numAux, '?'                                                                         ; Compara numAux com '?' (numAux == '?')
		je		Espera_Teclado_Virtual_03                                                           ; Sim, salta
        ret                                                                                         
        
        ; ----- [1] ---------------------------------------------------------------------------------
        
		Espera_Teclado_Virtual_03:
        mov     x1, 00b4h                                                                           ; x1 recebe a coluna inicial do botão
        mov     x2, 00d8h                                                                           ; x2 recebe a coluna final do botão
        mov     y1, 0082h                                                                           ; y1 recebe a linha inicial do botão
        mov     y2, 0094h                                                                           ; y2 recebe a linha final do botão
        mov     numAux, 1                                                                           ; numAux recebe 1
        call    VerificaBotao                                                                       ; Executa o procedimento
        cmp     numAux, '?'                                                                         ; Compara numAux com '?' (numAux == '?')
        je     	Espera_Teclado_Virtual_04                                                           ; Sim, salta
        ret
		
        ; ----- [2] ---------------------------------------------------------------------------------
        
		Espera_Teclado_Virtual_04:
        mov     x1, 00e4h                                                                           ; x1 recebe a coluna inicial do botão
        mov     x2, 0108h                                                                           ; x2 recebe a coluna final do botão
        mov     y1, 0082h                                                                           ; y1 recebe a linha inicial do botão
        mov     y2, 0094h                                                                           ; y2 recebe a linha final do botão
        mov     numAux, 2                                                                           ; numAux recebe 2
        call    VerificaBotao                                                                       ; Executa o procedimento
        cmp     numAux, '?'                                                                         ; Compara numAux com '?' (numAux == '?')
        je     	Espera_Teclado_Virtual_05                                                           ; Sim, salta
        ret
		
        ; ----- [3] ---------------------------------------------------------------------------------
        
		Espera_Teclado_Virtual_05:
        mov     x1, 0114h                                                                           ; x1 recebe a coluna inicial do botão
        mov     x2, 0138h                                                                           ; x2 recebe a coluna final do botão
        mov     y1, 0082h                                                                           ; y1 recebe a linha inicial do botão
        mov     y2, 0094h                                                                           ; y2 recebe a linha final do botão
        mov     numAux, 3                                                                           ; numAux recebe 3
        call    VerificaBotao                                                                       ; Executa o procedimento
        cmp     numAux, '?'                                                                         ; Compara numAux com '?' (numAux == '?')
        je     	Espera_Teclado_Virtual_06                                                           ; Sim, salta
        ret
		
        ; ----- [4] ---------------------------------------------------------------------------------
        
		Espera_Teclado_Virtual_06:
        mov     x1, 0144h                                                                           ; x1 recebe a coluna inicial do botão
        mov     x2, 0168h                                                                           ; x2 recebe a coluna final do botão
        mov     y1, 0082h                                                                           ; y1 recebe a linha inicial do botão
        mov     y2, 0094h                                                                           ; y2 recebe a linha final do botão
        mov     numAux, 4                                                                           ; numAux recebe 4
        call    VerificaBotao                                                                       ; Executa o procedimento
        cmp     numAux, '?'                                                                         ; Compara numAux com '?' (numAux == '?')
        je     	Espera_Teclado_Virtual_07                                                           ; Sim, salta
        ret
		
        ; ----- [5] ---------------------------------------------------------------------------------
        
		Espera_Teclado_Virtual_07:
        mov     x1, 0084h                                                                           ; x1 recebe a coluna inicial do botão    
        mov     x2, 00a8h                                                                           ; x2 recebe a coluna final do botão
        mov     y1, 009ah                                                                           ; y1 recebe a linha inicial do botão
        mov     y2, 00ach                                                                           ; y2 recebe a linha final do botão
        mov     numAux, 5                                                                           ; numAux recebe 5
        call    VerificaBotao                                                                       ; Executa o procedimento
        cmp     numAux, '?'                                                                         ; Compara numAux com '?' (numAux == '?')
        je     	Espera_Teclado_Virtual_08                                                           ; Sim, salta
        ret
		
        ; ----- [6] ---------------------------------------------------------------------------------
        
		Espera_Teclado_Virtual_08:
        mov     x1, 00b4h                                                                           ; x1 recebe a coluna inicial do botão
        mov     x2, 00d8h                                                                           ; x2 recebe a coluna final do botão
        mov     y1, 009ah                                                                           ; y1 recebe a linha inicial do botão
        mov     y2, 00ach                                                                           ; y2 recebe a linha final do botão
        mov     numAux, 6                                                                           ; numAux recebe 6
        call    VerificaBotao                                                                       ; Executa o procedimento
        cmp     numAux, '?'                                                                         ; Compara numAux com '?' (numAux == '?')
        je     	Espera_Teclado_Virtual_09                                                           ; Sim, salta
        ret
		
        ; ----- [7] ---------------------------------------------------------------------------------
        
		Espera_Teclado_Virtual_09:
        mov     x1, 00e4h                                                                           ; x1 recebe a coluna inicial do botão
        mov     x2, 0108h                                                                           ; x2 recebe a coluna final do botão
        mov     y1, 009ah                                                                           ; y1 recebe a linha inicial do botão
        mov     y2, 00ach                                                                           ; y2 recebe a linha final do botão
        mov     numAux, 7                                                                           ; numAux recebe 7
        call    VerificaBotao                                                                       ; Executa o procedimento
        cmp     numAux, '?'                                                                         ; Compara numAux com '?' (numAux == '?')
        je     	Espera_Teclado_Virtual_10                                                           ; Sim, salta
        ret
		
        ; ----- [8] ---------------------------------------------------------------------------------
        
		Espera_Teclado_Virtual_10:
        mov     x1, 0114h                                                                           ; x1 recebe a coluna inicial do botão
        mov     x2, 0138h                                                                           ; x2 recebe a coluna final do botão
        mov     y1, 009ah                                                                           ; y1 recebe a linha inicial do botão
        mov     y2, 00ach                                                                           ; y2 recebe a linha final do botão
        mov     numAux, 8                                                                           ; numAux recebe 8
        call    VerificaBotao                                                                       ; Executa o procedimento
        cmp     numAux, '?'                                                                         ; Compara numAux com '?' (numAux == '?')
        je     	Espera_Teclado_Virtual_11                                                           ; Sim, salta
        ret
		
        ; ----- [9] ---------------------------------------------------------------------------------
        
		Espera_Teclado_Virtual_11:
        mov     x1, 0144h                                                                           ; x1 recebe a coluna inicial do botão
        mov     x2, 0168h                                                                           ; x2 recebe a coluna final do botão
        mov     y1, 009ah                                                                           ; y1 recebe a linha inicial do botão
        mov     y2, 00ach                                                                           ; y2 recebe a linha final do botão
        mov     numAux, 9                                                                           ; numAux recebe 9
        call    VerificaBotao                                                                       ; Executa o procedimento
        cmp     numAux, '?'                                                                         ; Compara numAux com '?' (numAux == '?')
        je     	Espera_Teclado_Virtual_12                                                           ; Sim, salta
        ret
		
        ; ----- [-] ---------------------------------------------------------------------------------
        
		Espera_Teclado_Virtual_12:
        mov     x1, 0054h                                                                           ; x1 recebe a coluna inicial do botão
        mov     x2, 0078h                                                                           ; x2 recebe a coluna final do botão
        mov     y1, 0082h                                                                           ; y1 recebe a linha inicial do botão
        mov     y2, 0094h                                                                           ; y2 recebe a linha final do botão
        mov     numAux, 10                                                                          ; numAux recebe 10
        call    VerificaBotao                                                                       ; Executa o procedimento
        cmp     numAux, '?'                                                                         ; Compara numAux com '?' (numAux == '?')
        je     	Espera_Teclado_Virtual_13                                                           ; Sim, salta
        ret
		
        ; ----- [,] ---------------------------------------------------------------------------------
        
		Espera_Teclado_Virtual_13:
        mov     x1, 0054h                                                                           ; x1 recebe a coluna inicial do botão
        mov     x2, 0078h                                                                           ; x2 recebe a coluna final do botão
        mov     y1, 009ah                                                                           ; y1 recebe a linha inicial do botão
        mov     y2, 00ach                                                                           ; y2 recebe a linha final do botão
        mov     numAux, 11                                                                          ; numAux recebe 11
        call    VerificaBotao                                                                       ; Executa o procedimento
        cmp     numAux, '?'                                                                         ; Compara numAux com '?' (numAux == '?')
        je     	Espera_Teclado_Virtual_14                                                           ; Sim, salta
        ret
		
        ; ----- [BACKSPACE] -------------------------------------------------------------------------
        
		Espera_Teclado_Virtual_14:
        mov     x1, 0174h                                                                           ; x1 recebe a coluna inicial do botão
        mov     x2, 0214h                                                                           ; x2 recebe a coluna final do botão
        mov     y1, 0082h                                                                           ; y1 recebe a linha inicial do botão
        mov     y2, 0094h                                                                           ; y2 recebe a linha final do botão
        mov     numAux, 12                                                                          ; numAux recebe 12
        call    VerificaBotao                                                                       ; Executa o procedimento
        cmp     numAux, '?'                                                                         ; Compara numAux com '?' (numAux == '?')
        je     	Espera_Teclado_Virtual_15                                                           ; Sim, salta
        ret
		
        ; ----- [ENTER] -----------------------------------------------------------------------------
        
		Espera_Teclado_Virtual_15:
        mov     x1, 0174h                                                                           ; x1 recebe a coluna inicial do botão
        mov     x2, 0214h                                                                           ; x2 recebe a coluna final do botão
        mov     y1, 009ah                                                                           ; y1 recebe a linha inicial do botão
        mov     y2, 00ach                                                                           ; y2 recebe a linha final do botão
        mov     numAux, 13                                                                          ; numAux recebe 13
        call    VerificaBotao                                                                       ; Executa o procedimento
        ret
                                     
    EsperaTecladoVirtual endp    
    
    ; ----- [Procedimento para verificar se um clique está dentro da área de um botão] --------------
    ; ----- [Input: x1, x2, y1, y2] -----------------------------------------------------------------
    
    VerificaBotao proc near
        
        ; ----- [Compara] ---------------------------------------------------------------------------
         
        cmp     cx, x1                                                                              ; Compara cx com x1 (cx < x1)
        jb      VerificaBotao_01                                                                    ; Sim, salta
        cmp     cx, x2                                                                              ; Compara cx com x2 (cx > x2)
        jg      VerificaBotao_01                                                                    ; Sim, salta
        cmp     dx, y1                                                                              ; Compara dx com y1 (dx < y1)
        jb      VerificaBotao_01                                                                    ; Sim, salta
        cmp     dx, y2                                                                              ; Compara dx com y2 (dx > y2)
        jg      VerificaBotao_01                                                                    ; Sim, salta
        
        ; ----- [Positivo] --------------------------------------------------------------------------
        
        ret
        
        ; ----- [Negativo] --------------------------------------------------------------------------
        
        VerificaBotao_01:
        mov     numAux, '?'                                                                         ; numAux recebe '?'
        ret
            
    VerificaBotao endp    
    
    ; ----- [Procedimento que mostra um teclado virtual] --------------------------------------------
    
    MostraTeclado proc near
        
		; ----- [Mostra o título do teclado virtual] ------------------------------------------------
		
		mov     ah, 02h                                                                             ; Define para posicionar o cursor
        mov     bh, 00h                                                                             ; Define o número da página
        mov     dh, 14                                                                              ; Define a linha
        mov     dl, 6                                                                               ; Define a coluna
        int     10h                                                                                 ; Executa a interrupção
        mov     ah, 09h                                                                             ; Define para escrever texto
        lea     dx, strTecVirTitulo                                                                 ; Define o apontador para o início da variável string
        int     21h                                                                                 ; Executa a interrupção
		
        ; ----- [Desenha os botões do teclado virtual : Primeira Linha de Números] ------------------
        
        mov     cx, 6                                                                               ; Contador para o número de botões a serem desenhados
        mov     auxInicial_X, 42                                                                    ; auxInicial_X recebe posição no eixo X inicial
        mov     auxInicial_Y, 130                                                                   ; auxInicial_Y recebe posição no eixo Y inicial
        mov     auxCompr_X, 18                                                                      ; auxCompr_X recebe o comprimento do botão no eixo X
        mov     auxCompr_Y, 18                                                                      ; auxCompr_Y recebe o comprimento do botão no eixo Y
        Desenha_Teclado_Nums_01:
        push    cx                                                                                  ; Guarda o valor cx na pilha    
        call    DesenhaBotao                                                                        ; Executa o procedimento   
        pop     cx                                                                                  ; Retira o valor cx da pilha
        add     auxInicial_X, 24                                                                    ; auxInicial_X = auxInicial_X + 25 (Próximo botão)
        loop    Desenha_Teclado_Nums_01                                                             ; Reloop até cx = 0
        
        ; ----- [Desenha os botões do teclado virtual : Segunda Linha de Números] -------------------
        
        mov     cx, 6                                                                               ; Contador para o número de botões a serem desenhados
        mov     auxInicial_X, 42                                                                    ; auxInicial_X recebe posição no eixo X inicial
        add     auxInicial_Y, 24                                                                    ; auxInicial_Y = auxInicial_Y + 25 (Próxima linha) 
        Desenha_Teclado_Nums_02:
        push    cx                                                                                  ; Guarda o valor cx na pilha    
        call    DesenhaBotao                                                                        ; Executa o procedimento   
        pop     cx                                                                                  ; Retira o valor cx da pilha
        add     auxInicial_X, 24                                                                    ; auxInicial_X = auxInicial_X + 25 (Próximo botão)
        loop    Desenha_Teclado_Nums_02                                                             ; Reloop até cx = 0
        
        ; ----- [Desenha os botões "Backspace" e "Enter"] -------------------------------------------
        
        mov     auxInicial_Y, 130                                                                   ; auxInicial_Y recebe posição no eixo Y inicial
        mov     auxCompr_X, 80                                                                      ; auxCompr_X recebe o comprimento do botão no eixo X
        call    DesenhaBotao                                                                        ; Executa o procedimento
        add     auxInicial_Y, 24                                                                    ; auxInicial_Y = auxInicial_Y + 25
        call    DesenhaBotao                                                                        ; Executa o procedimento
        
        ; ----- [Limpa o array dos números aleatórios] ----------------------------------------------
        
        mov     index, 0                                                                            ; index recebe zero
        Limpa_Array_Numeros:                                                                        
        mov     si, offset numAleat                                                                 ; Si aponta para a variável numAleat
        add     si, index                                                                           ; Si = si + index
        mov     al, ' '                                                                             ; Al recebe ' '
        mov     [si], al                                                                            ; Coloca na posição si o valor de al
        inc     index                                                                               ; Incrementa o index
        inc     index                                                                               ; Incrementa o index
        cmp     index, 20                                                                           ; Compara index com 10 (index == 10)
        jne     Limpa_Array_Numeros                                                                 ; Não, reloop
        mov     index, 0                                                                            ; index recebe zero
        
        ; ----- [Gera números aleatórios] -----------------------------------------------------------

        call    GeraNumerosAleatorios                                                               ; Executa o procedimento

        ; ----- [Coloca o texto dos botões não aleatórios] ------------------------------------------
        
        mov     ah, 02h                                                                             ; Define para posicionar o cursor
        mov     bh, 00h                                                                             ; Define o número da página
        mov     dh, 17                                                                              ; Define a linha
        mov     dl, 6                                                                               ; Define a coluna
        int     10h                                                                                 ; Executa a interrupção
        mov     dl, '-'                                                                             ; Define o caractere para output
        int     21h                                                                                 ; Executa a interrupção
        mov     dh, 20                                                                              ; Define a linha
        mov     dl, 6                                                                               ; Define a coluna    
        int     10h                                                                                 ; Executa a interrupção
        mov     dl, ','                                                                             ; Define o caractere para output
        int     21h                                                                                 ; Executa a interrupção    
        mov     ah, 02h                                                                             ; Define para posicionar o cursor
        mov     dh, 17                                                                              ; Define a linha
        mov     dl, 24                                                                              ; Define a coluna
        int     10h                                                                                 ; Executa a interrupção
        mov     ah, 09h                                                                             ; Define para escrever texto
        lea     dx, strBackspace                                                                    ; Define o apontador para o início da variável string
        int     21h                                                                                 ; Executa a interrupção
        mov     ah, 02h                                                                             ; Define para posicionar o cursor
        mov     dh, 20                                                                              ; Define a linha
        mov     dl, 24                                                                              ; Define a coluna
        int     10h                                                                                 ; Executa a interrupção
        mov     ah, 09h                                                                             ; Define para escrever texto
        lea     dx, strEnter                                                                        ; Define o apontador para o início da variável string
        int     21h                                                                                 ; Executa a interrupção
        
        ; ----- [Coloca os dígitos gerados aleatóriamente nos botões] -------------------------------
        
        mov     ah, 02h                                                                             ; Define para posicionar o cursor
        mov     bh, 00h                                                                             ; Define o número da página
        mov     dh, 17                                                                              ; Define a linha
        mov     dl, 9                                                                               ; Define a coluna
        int     10h                                                                                 ; Executa a interrupção
        mov     si, offset numAleat                                                                 ; Si é um apontador para a variável numAleat    
        mov     dx, [si]                                                                            ; Dx recebe o valor apontado por si
        add     dl, 30h                                                                             ; Dl = dl + 30h
        int     21h                                                                                 ; Executa a interrupção
        
        mov     dh, 17                                                                              ; Define a linha
        mov     dl, 12                                                                              ; Define a coluna
        int     10h                                                                                 ; Executa a interrupção
        inc     si                                                                                  ; Incrementa si
        inc     si                                                                                  ; Incrementa si
        mov     dx, [si]                                                                            ; Dx recebe o valor apontado por si
        add     dl, 30h                                                                             ; Dl = dl + 30h
        int     21h                                                                                 ; Executa a interrupção
        
        mov     dh, 17                                                                              ; Define a linha
        mov     dl, 15                                                                              ; Define a coluna
        int     10h                                                                                 ; Executa a interrupção
        inc     si                                                                                  ; Incrementa si
        inc     si                                                                                  ; Incrementa si
        mov     dx, [si]                                                                            ; Dx recebe o valor apontado por si
        add     dl, 30h                                                                             ; Dl = dl + 30h
        int     21h                                                                                 ; Executa a interrupção
        
        mov     dh, 17                                                                              ; Define a linha
        mov     dl, 18                                                                              ; Define a coluna
        int     10h                                                                                 ; Executa a interrupção
        inc     si                                                                                  ; Incrementa si
        inc     si                                                                                  ; Incrementa si
        mov     dx, [si]                                                                            ; Dx recebe o valor apontado por si
        add     dl, 30h                                                                             ; Dl = dl + 30h
        int     21h                                                                                 ; Executa a interrupção    
        
        mov     dh, 17                                                                              ; Define a linha
        mov     dl, 21                                                                              ; Define a coluna
        int     10h                                                                                 ; Executa a interrupção
        inc     si                                                                                  ; Incrementa si
        inc     si                                                                                  ; Incrementa si
        mov     dx, [si]                                                                            ; Dx recebe o valor apontado por si
        add     dl, 30h                                                                             ; Dl = dl + 30h
        int     21h                                                                                 ; Executa a interrupção
        
        mov     dh, 20                                                                              ; Define a linha
        mov     dl, 9                                                                               ; Define a coluna
        int     10h                                                                                 ; Executa a interrupção
        inc     si                                                                                  ; Incrementa si
        inc     si                                                                                  ; Incrementa si
        mov     dx, [si]                                                                            ; Dx recebe o valor apontado por si
        add     dl, 30h                                                                             ; Dl = dl + 30h
        int     21h                                                                                 ; Executa a interrupção
        
        mov     dh, 20                                                                              ; Define a linha
        mov     dl, 12                                                                              ; Define a coluna
        int     10h                                                                                 ; Executa a interrupção    
        inc     si                                                                                  ; Incrementa si
        inc     si                                                                                  ; Incrementa si
        mov     dx, [si]                                                                            ; Dx recebe o valor apontado por si
        add     dl, 30h                                                                             ; Dl = dl + 30h
        int     21h                                                                                 ; Executa a interrupção
        
        mov     dh, 20                                                                              ; Define a linha
        mov     dl, 15                                                                              ; Define a coluna
        int     10h                                                                                 ; Executa a interrupção
        inc     si                                                                                  ; Incrementa si
        inc     si                                                                                  ; Incrementa si
        mov     dx, [si]                                                                            ; Dx recebe o valor apontado por si
        add     dl, 30h                                                                             ; Dl = dl + 30h
        int     21h                                                                                 ; Executa a interrupção
        
        mov     dh, 20                                                                              ; Define a linha
        mov     dl, 18                                                                              ; Define a coluna
        int     10h                                                                                 ; Executa a interrupção
        inc     si                                                                                  ; Incrementa si
        inc     si                                                                                  ; Incrementa si
        mov     dx, [si]                                                                            ; Dx recebe o valor apontado por si
        add     dl, 30h                                                                             ; Dl = dl + 30h
        int     21h                                                                                 ; Executa a interrupção    
        
        mov     dh, 20                                                                              ; Define a linha
        mov     dl, 21                                                                              ; Define a coluna
        int     10h                                                                                 ; Executa a interrupção    
        inc     si                                                                                  ; Incrementa si
        inc     si                                                                                  ; Incrementa si
        mov     dx, [si]                                                                            ; Dx recebe o valor apontado por si
        add     dl, 30h                                                                             ; Dl = dl + 30h
        int     21h                                                                                 ; Executa a interrupção
        
        ret
        
    MostraTeclado endp    
    
    ; ----- [Procedimento para gerar números aleatórios de 0-9] -------------------------------------
    
    GeraNumerosAleatorios proc near
        
        mov     numAux, 0                                                                           ; Garante zero no numAux
        
        ; ----- [Gera um número aleatório a partir do relógio] --------------------------------------
        
        Gera_Numeros_Aleatorios_01:
		mov     cx, 04h                                                                             ; Define o valor em microsegundos nos HighOrder bits
        mov     dx, 032h	                                                                        ; Define o valor em microsegundos nos LowOrder bits
        mov     ah, 86h                                                                             ; Define para fazer um delay
        int     15h                                                                                 ; Executa a interrupção
		mov     ax, 00h                                                                             ; Define para obter o relógio do sistema
        int     1ah                                                                                 ; Executa a interrupção
        mov     ax, dx                                                                              ; Ax recebe dx
        mov     dx, 0                                                                               ; Dx = 0
        mov     bx, 10                                                                              ; Bx = 10
        div     bx                                                                                  ; AX:DX = AX / BX
        
        ; ----- [Verifica se o número gerado já existe] ---------------------------------------------
        
        mov     cx, 0                                                                               ; Cx = 0
        Gera_Numeros_Aleatorios_02:
        mov     si, offset numAleat                                                                 ; SI aponta para a variável numAleat
        add     si, cx                                                                              ; SI = SI + Cx
        mov     bx, [si]                                                                            ; Bx recebe o valor que está na posição apontada por SI
        cmp     bx, dx                                                                              ; Compara bx com dx (bx == dx)
        je      Gera_Numeros_Aleatorios_01                                                          ; Sim, reloop
        cmp     bx, ' '                                                                             ; Compara bx com ' ' (bx == ' ')
        je      Gera_Numeros_Aleatorios_03                                                          ; Sim, salta
        inc     cx                                                                                  ; Incrementa cx
        inc     cx                                                                                  ; Incrementa cx
        cmp     cx, 18                                                                              ; Compara cx com 18 (cx > 18)
        jg      Gera_Numeros_Aleatorios_04                                                          ; Sim, salta
        jmp     Gera_Numeros_Aleatorios_02                                                          ; Reloop
        
        ; ----- [Adiciona o número gerado ao array "numAleat"] --------------------------------------
        
        Gera_Numeros_Aleatorios_03:
        mov     [si], dx                                                                            ; Coloca na variável apontada por SI o valor de dx
        inc     numAux                                                                              ; Incrementa numAux
        cmp     numAux, 10                                                                          ; Compara numAux com 10 (numAux == 10)
        je      Gera_Numeros_Aleatorios_04                                                          ; Sim, reloop
        jmp     Gera_Numeros_Aleatorios_02                                                          ; Salta
        
        Gera_Numeros_Aleatorios_04:
        ret
            
    GeraNumerosAleatorios endp     
    
    ; ----- [Procedimento que indica se o número é negativo ou positivo] ----------------------------
    ; ----- [Input: DH recebe a linha para apresentar caracter] -------------------------------------
    
    AlternarSinal proc near
    
        ; ----- [Verifica o atual estado do sinal] --------------------------------------------------
        
        cmp     flagSinal, 0                                                                        ; Compara flagSinal com 0 (flagSinal == 0)
        je      Alternar_Sinal_01                                                                   ; Sim, salta
        cmp     flagSinal, 1                                                                        ; Compara flagSinal com 1 (flagSinal == 1)
        je      Alternar_Sinal_02                                                                   ; Sim, salta
        
        ; ----- [Alternar o sinal para: Negativo] ---------------------------------------------------
        ; ----- [Input: DH recebe a linha para apresentar caracter] ---------------------------------
        
        Alternar_Sinal_01:
        mov     flagSinal, 1                                                                        ; flagSinal recebe 1
        mov     ah, 02h                                                                             ; Define para posicionar o cursor
        mov     bh, 00h                                                                             ; Define o número da página
        mov     dl, 21 																				; Define a coluna
		int     10h                                                                                 ; Executa a interrupção
        mov     dl, '-'                                                                             ; Define o caractere a apresentar
        int     21h                                                                                 ; Executa a interrupção
        
        ret
        
        ; ----- [Alternar o sinal para: Positivo] ---------------------------------------------------
        ; ----- [Input: DH recebe a linha para apresentar caracter] ---------------------------------
        
        Alternar_Sinal_02:
        mov     flagSinal, 0                                                                        ; flagSinal recebe 0
        mov     ah, 02h                                                                             ; Define para posicionar o cursor
        mov     bh, 00h                                                                             ; Define o número da página
		mov     dl, 21 																				; Define a coluna
		int     10h                                                                                 ; Executa a interrupção
		mov     dl, ' '                                                                             ; Define o caractere a apresentar
        int     21h                                                                                 ; Executa a interrupção
        
        ret
        
    AlternarSinal endp      
    
    ; ----- [Procedimento para fazer um delay de 0,5 segundos] --------------------------------------
    ; ----- [Converter os "ms" para hexadecimal] ----------------------------------------------------
    ; ----- [Bits mais significativos para o CX] ----------------------------------------------------
    ; ----- [Bits menos significativos para o DX] ---------------------------------------------------
    ; ----- [1 segundo = 1 000 000 ms; 0,5 segundos = 500 000 ms] -----------------------------------
	; ----- [500 000d = 0007h 0A120h] ---------------------------------------------------------------
    
    Delay proc near
        
        mov     cx, 04h                                                                             ; Define o valor em microsegundos nos HighOrder bits
        mov     dx, 0a120h                                                                          ; Define o valor em microsegundos nos LowOrder bits
        mov     ah, 86h                                                                             ; Define para fazer um delay
        int     15h                                                                                 ; Executa a interrupção
        
        ret
        
    Delay endp    
    
    ; ----- [Procedimento para colocar as variáveis a zero] -----------------------------------------
    
    ResetVariaveis proc near
                
        ; ----- [Dividendo] -------------------------------------------------------------------------
        
        mov     index, 0																			; Index recebe zero 0
        R_V_Dividendo:
        mov     si, offset dividendo																; Si aponta para a variável dividendo
        add     si, index																			; Si = si + index
        mov     bl, space																			; Bl recebe space
        mov     [si], bl																			; Coloca na posição apontada por si o valor de bl
        inc     index																				; Incrementa o index
        cmp     index, 9																			; Compara index com 10 (index <> 10)
        jne     R_V_Dividendo																		; Sim, reloop
        
		; ----- [Radicando] -------------------------------------------------------------------------
		
		mov		index, 0																			; Index recebe zero 0	
		R_V_Radicando:
		mov		si, offset radicando																; Si aponta para a variável radicando
		add		si, index																			; Si = si + index
		mov		bl, space																			; Bl recebe space
		mov		[si], bl																			; Coloca na posição apontada por si o valor de bl
		inc		index																				; Incrementa o index
		cmp		index, 9																			; Compara index com 10 (index <> 10)
		jne		R_V_Radicando																		; Sim, reloop
		
		; ----- [Pares do Radicando] ----------------------------------------------------------------
		
		mov		index, 0																			; Index recebe zero 0	
		R_V_Radicando_Pares:
		mov		si, offset radicandoPares															; Si aponta para a variável radicandoPares
		add		si, index																			; Si = si + index
		mov		bl, 100																				; Bl recebe space
		mov		[si], bl																			; Coloca na posição apontada por si o valor de bl
		inc		index																				; Incrementa o index
		cmp		index, 9																			; Compara index com 10 (index <> 10)
		jne		R_V_Radicando_Pares																	; Sim, reloop
		
        ; ----- [Divisor] ---------------------------------------------------------------------------
        
        mov     divisor, 0																			; Divisor recebe zero 0
        
        ; ----- [Resto] -----------------------------------------------------------------------------
        
        mov     resto, 0																			; Resto recebe zero 0
        
        ; ----- [Quociente] -------------------------------------------------------------------------
        
        mov     index, 0																			; Index recebe zero 0
        R_V_Quociente:
        mov     si, offset quociente																; Si aponta para a variável quociente
        add     si, index																			; Si = si + index
        mov     bl, space																			; Bl recebe space
        mov     [si], bl																			; Coloca na posição apontada por si o valor de bl
        inc     index																				; Incrementa o index
        cmp     index, 9																			; Compara index com 10 (index <> 10)
        jne     R_V_Quociente																		; Sim, reloop
        
        ; ----- [Raiz] ------------------------------------------------------------------------------
        
        mov     raiz, 0																				; Raiz recebe zero 0
        
        ; ----- [Ho] --------------------------------------------------------------------------------
        
        mov     ho, 0                                                                               ; Ho recebe zero 0
        
        ret
            
    ResetVariaveis endp    
    
    ; ----- [Manipular Ficheiros: Abrir o ficheiro] -------------------------------------------------
    
    AbrirFicheiro proc near
        
        ;mov     ah, 3ch
;        lea     dx, nomeFicheiro
;        mov     cl, 0
;        int     21h
;        mov     handle, ax
;        
;        call    FecharFicheiro
                
        mov     al, 02h																				; Define o modo de read/write file
        mov     ah, 3dh																				; Define para abrir um ficheiro existente
        lea     dx, nomeFicheiro																	; Define a diretoria do ficheiro
        int     21h																					; Executa a interrupção
        mov     handle, ax																			; Handle recebe ax
        
        ret
        
    AbrirFicheiro endp
    
    ; ----- [Manipular Ficheiros: Fechar o ficheiro] ------------------------------------------------
    
    FecharFicheiro proc near
    
        mov     ah, 3eh																				; Define para fechar um ficheiro
        mov     bx, handle																			; Define o ficheiro a fechar cujo valor está no handle	
        int     21h																					; Executa a interrupção	
        
        ret
        
    FecharFicheiro endp
    
    ; ----- [Manipular Ficheiros: Escrever] ---------------------------------------------------------
    
    EscreverFicheiro proc near
        
        call    AbrirFicheiro																		; Executa o procedimento
        
        ; ----- [Prepara conteúdo para escrever no ficheiro] ----------------------------------------
        
        mov     bufferEscrita_I, 0																	; bufferEscrita_I recebe zero 0
        mov     si, offset bufferEscrita															; Si aponta para a variável bufferEscrita	
        mov     al, flagOperacao																	; Al recebe flagOperacao
        add     al, 30h																				; Al = al + 30h
        mov     [si], al																			; Coloca na posição apontada por si o valor de al
        inc     si																					; Incrementa si
        mov     al, space																			; Al recebe space
        mov     [si], al																			; Coloca na posição apontada por si o valor de al
        inc     si																					; Incrementa si
        mov     al, flagSinal																		; Al recebe flagSinal	
        add     al, 30h																				; Al = al + 30h
        mov     [si], al																			; Coloca na posição apontada por si o valor de al
        inc     si																					; Incrementa si
        mov     al, space																			; Al recebe space
        mov     [si], al																			; Coloca na posição apontada por si o valor de al
        inc     si																					; Incrementa si
        
		cmp		flagOperacao, 1																		; Compara flagOperacao com 1 (flagOperacao == 1)
		je		Escrever_Ficheiro_01																; Sim, salta
		
        ; ----- [Dividendo] -------------------------------------------------------------------------
        
        mov     index, 0																			; Index recebe zero 0
        E_F_1:
        mov     bx, offset dividendo																; Bx aponta para a variável dividendo
        add     bx, index																			; Bx = bx + index
        mov     ax, [bx]																			; Ax recebe o valor apontado por bx
        add     al, 30h																				; Al = al + 30h
        cmp     al, 'P'																				; Compara al com "P" (al == "P")	
        je      E_F_2																				; Sim, salta
        mov     [si], al																			; Coloca na posição apontada por si o valor de al
        inc     si																					; Incrementa si
        inc     index																				; Incrementa index
        cmp     index, 10																			; Compara index com 10 (index < 10)			
        jb      E_F_1																				; Sim, reloop
        E_F_2:
        mov     al, space																			; Al recebe space
        mov     [si], al																			; Coloca na posição apontada por si o valor de al
        inc     si																					; Incrementa si
        
        ; ----- [Divisor] ---------------------------------------------------------------------------
        
        mov     ax, divisor																			; Ax recebe divisor
        
        push    dx																					; Guarda na pilha o valor de dx
        push    cx																					; Guarda na pilha o valor de cx
        push    bx																					; Guarda na pilha o valor de bx
        
        xor     cx, cx																				; Garante zero no cx
        mov     bx, 10																				; Bx recebe 10
        
        E_F_3:
        xor     dx, dx																				; Garante zero no dx
        div     bx																					; Ax = ax / bx
        push    dx																					; Guarda na pilha o valor de dx
        inc     cx																					; Incrementa cx
        or      ax, ax																				; Verifica se ax tem zero
        jnz     E_F_3																				; Não, reloop
        
        E_F_4:
        pop     dx																					; Retira o valor do topo da pilha para dx
        add     dl, 30h																				; Dl = dl + 30h
        mov     [si], dl																			; Coloca na posição apontada por si o valor de dl
        inc     si																					; Incrementa si
        loop    E_F_4
        
        pop     bx																					; Retira o valor do topo da pilha para bx
        pop     cx																					; Retira o valor do topo da pilha para cx
        pop     dx																					; Retira o valor do topo da pilha para dx
        
		
        ; ----- [Quociente] -------------------------------------------------------------------------
        
        mov     al, space																			; Al recebe space
        mov     [si], al																			; Coloca na posição apontada por si o valor de al
        inc     si																					; Incrementa si
        
        mov     index, 0																			; Index recebe zero 0
        E_F_5:
        mov     bx, offset quociente																; Bx aponta para a variável quociente
        add     bx, index																			; Bx = bx + index
        mov     ax, [bx]																			; Ax recebe o valor apontado por bx
        add     al, 30h																				; Al = al + 30h
        cmp     al, 'P'																				; Compara al com "P" (al == "P")
        je      E_F_6																				; Sim, salta
        mov     [si], al																			; Coloca na posição apontada por si o valor de al
        inc     si																					; Incrementa si
        inc     index																				; Incrementa index
        cmp     index, 10																			; Compara index com 10 (index < 10)
        jb      E_F_5																				; Sim, reloop
        E_F_6:
        mov     al, space																			; Al recebe space
        mov     [si], al																			; Coloca na posição apontada por si o valor de al
        inc     si																					; Incrementa si
        
		jmp		Escrever_Ficheiro_02
		
		; ----- [Radicando] -------------------------------------------------------------------------
		
		Escrever_Ficheiro_01:
		mov		index, 0																			; Index recebe zero 0
		Escrever_Ficheiro_04:
		mov		bx, offset radicando																; Bx aponta para a variável radicando
		add		bx, index																			; Bx = bx + index
		mov		ax, [bx]																			; Ax recebe o valor apontado por bx
		add		al, 30h																				; Al = al + 30h
		cmp		al, 'P'																				; Compara al com "P" (al == "P")
		je		Escrever_Ficheiro_03																; Sim, salta
		mov		[si], al																			; Coloca na posição apontada por si o valor de al
		inc		si																					; Incrementa si
		inc		index																				; Incrementa index
		cmp		index, 0																			; Compara index com 0 (index < 0)
		jb		Escrever_Ficheiro_04																; Sim, reloop
		Escrever_Ficheiro_03:
		mov		al, space																			; Al recebe space
		mov		[si], al																			; Coloca na posição apontada por si o valor de al
		inc		si																					; Incrementa si
		
		; ----- [Raiz] ------------------------------------------------------------------------------
		
		mov		ax, raiz																			; Ax recebe raiz
		
		push    dx																					; Guarda na pilha o valor de dx
        push    cx																					; Guarda na pilha o valor de cx
        push    bx																					; Guarda na pilha o valor de bx
        
        xor     cx, cx																				; Garante zero no cx
        mov     bx, 10																				; Bx recebe 10
        
        Escrever_Ficheiro_05:
        xor     dx, dx																				; Garante zero no dx
        div     bx																					; Ax = ax / bx
        push    dx																					; Guarda na pilha o valor de dx
        inc     cx																					; Incrementa cx
        or      ax, ax																				; Verifica se ax tem zero
        jnz     Escrever_Ficheiro_05																; Não, reloop	
        
        Escrever_Ficheiro_06:
        pop     dx																					; Retira o valor do topo da pilha para dx
        add     dl, 30h																				; Dl = dl + 30h
        mov     [si], dl																			; Coloca na posição apontada por si o valor de dl
        inc     si																					; Incrementa si
        loop    Escrever_Ficheiro_06																; Reloop até cx == 0
        
        pop     bx																					; Retira o valor do topo da pilha para bx
        pop     cx																					; Retira o valor do topo da pilha para cx
        pop     dx																					; Retira o valor do topo da pilha para dx
		
		mov     al, space																			; Al recebe space
        mov     [si], al																			; Coloca na posição apontada por si o valor de al
        inc     si																					; Incrementa si
		
        ; ----- [Resto]------------------------------------------------------------------------------
        
		Escrever_Ficheiro_02:
		mov     ax, resto																			; Ax recebe resto
        
        push    dx																					; Guarda na pilha o valor de dx
        push    cx																					; Guarda na pilha o valor de cx
        push    bx																					; Guarda na pilha o valor de bx
        
        xor     cx, cx																				; Garante zero no cx
        mov     bx, 10																				; Bx recebe 10
        
        E_F_7:
        xor     dx, dx																				; Garante zero no dx
        div     bx																					; Ax = ax / bx
        push    dx																					; Guarda na pilha o valor de dx
        inc     cx																					; Incrementa cx
        or      ax, ax																				; Verifica se ax tem zero
        jnz     E_F_7																				; Não, reloop	
        
        E_F_8:
        pop     dx																					; Retira o valor do topo da pilha para dx
        add     dl, 30h																				; Dl = dl + 30h
        mov     [si], dl																			; Coloca na posição apontada por si o valor de dl
        inc     si																					; Incrementa si
        loop    E_F_8																				; Reloop até cx == 0
        
        pop     bx																					; Retira o valor do topo da pilha para bx
        pop     cx																					; Retira o valor do topo da pilha para cx
        pop     dx																					; Retira o valor do topo da pilha para dx
        
        ; ----- [Enter] -----------------------------------------------------------------------------    
        
        mov     al, 0ah																				; Al recebe 0ah (código hexadecimal para o enter)
        mov     [si], al																			; Coloca na posição apontada por si o valor de al
        
        mov     ah, 40h																				; Define para escrever num ficheiro (write file)
        mov     bx, handle																			; Define o ficheiro que está no handle
        mov     cx, 64																				; Define o tamanho, em bytes, para escrever
        lea     dx, bufferEscrita																	; Define os dados que queremos escrever
        int     21h 																				; Executa a interrupção	
        
        call    FecharFicheiro    																	; Executa o procedimento
        
        ret
        
    EscreverFicheiro endp    
    
code ends
end
