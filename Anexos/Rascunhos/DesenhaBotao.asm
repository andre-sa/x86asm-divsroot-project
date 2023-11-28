
; ----- [Definir o segmento de pilha] ---------------------------------------------------------------

stack segment para stack
    db  64  dup(' ')
stack ends

; ----- [Definir o segmento para os dados] ----------------------------------------------------------

data segment para 'data'
    auxInicial_X        dw  0
    auxInicial_Y        dw  0
    auxCompr_X          dw  0
    auxCompr_Y          dw  0
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
        
        mov     ah, 00h                                                                             ; Define o modo gráfico
        mov     al, 13h                                                                             ; Modo gráfico - 320x200 - 256 cores
        int     10h                                                                                 ; Executa a interrupção
        
        ; ----- [Cria os botões] --------------------------------------------------------------------
        
        mov     auxInicial_X, 30
        mov     auxInicial_Y, 30
        mov     auxCompr_X, 100
        mov     auxCompr_Y, 50
        
        call    DesenhaBotao
        
        ; ----- [Termina o programa] ----------------------------------------------------------------
        
        mov     ah, 4ch
        int     21h 
        
    Main endp    
    
    ; ----- [Desenhar um botao : Algoritmo no Excel] ------------------------------------------------
    
    DesenhaBotao proc near
     
        mov     ah, 0ch
        mov     al, 07h
        mov     cx, auxInicial_X
        mov     dx, auxInicial_Y        
        Desenha_Botao_Loop_01:
        ; ----- [003]
        int     10h
        ; ----- [004]
        add     dx, auxCompr_Y
        ; ----- [005]         
        int     10h
        ; ----- [006]
        sub     dx, auxCompr_Y
        ; ----- [007]
        inc     cx
        ; ----- [008]
        mov     bx, auxInicial_X
        add     bx, auxCompr_X
        cmp     cx, bx    
        ; ----- [009]
        jng     Desenha_Botao_Loop_01
        ; ----- [010]
        sub     cx, auxCompr_X
        dec     cx
        ; ----- [011]         
        inc     dx
        ; ----- [012]
        Desenha_Botao_Loop_02:
        int     10h
        ; ----- [013]
        add     cx, auxCompr_X
        ; ----- [014]
        int     10h
        ; ----- [015]
        sub     cx, auxCompr_X
        ; ----- [016] 
        inc     dx
        ; ----- [017]
        mov     bx, auxInicial_Y
        add     bx, auxCompr_Y
        cmp     dx, bx
        jbe     Desenha_Botao_Loop_02
        
        ret
            
    DesenhaBotao endp    
    
code ends
end