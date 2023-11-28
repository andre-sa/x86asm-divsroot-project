; ----- [Definir o segmento de pilha] ---------------------------------------------------------------

stack segment para stack
    db  64  dup(' ')
stack ends

; ----- [Definir o segmento para os dados] ----------------------------------------------------------

data segment para 'data'
    
data ends

; ----- [Definir o segmento para o c�digo] ----------------------------------------------------------

code segment para 'code'
    
    ; ----- [C�digo principal] ----------------------------------------------------------------------
    
    Main proc far
        
        ; ----- [Definir os segmentos] --------------------------------------------------------------
        
        assume cs:code,ds:data,ss:stack
        push    ds                                                                                  ; Guarda na pilha o segmento ds
        xor     ax, ax                                                                              ; Garante zero em ax
        push    ax                                                                                  ; Guarda ax na pilha
        mov     ax, data                                                                            ; Coloca em ax a posi��o dos dados
        mov     ds, ax                                                                              ; Coloca essa posi��o no register ds
        
        ; ----- [Inicializar o modo gr�fico] --------------------------------------------------------
        
        mov     ah, 00h                                                                             ; Define o modo gr�fico
        mov     al, 13h                                                                             ; Modo gr�fico - 320x200 - 256 cores
        int     10h                                                                                 ; Executa a interrup��o
        
        ; ----- [Inicializar o rato] ----------------------------------------------------------------
        
        mov     ax, 0000h                                                                           ; Define para inicializar o rato
        int     33h                                                                                 ; Executa a interrup��o
        
        ; ----- [Mostra o ponteiro do rato] ---------------------------------------------------------
        
        mov     ax, 0001h																			; Define para mostrar o ponteiro do rato
        int     33h																					; Executa a interrup��o		
        
        ; ----- [Espera por uma tecla e retorna a posi��o do rato e o status] -----------------------
        Main_Loop_01:
        mov     ax, 0003h                                                                           ; Define para receber a posi��o do rato e o seu status
        int     33h                                                                                 ; Executa a interrup��o
        
        ; ----- [Espera uma tecla ser pressionada] --------------------------------------------------
        
        xor     ax, ax                                                                              ; Garante zero no ax
        mov     ah, 01h                                                                             ; Define para verificar se alguma tecla foi pressionada
        int     16h                                                                                 ; Executa a interrup��o
        jz      Main_Loop_01                                                                        ; Se n�o foi pressionada, reloop
        
        ret
        
    Main endp    

code ends
end
