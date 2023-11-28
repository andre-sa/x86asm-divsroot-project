
stack segment para stack
    db  64  dup(' ')
stack ends

; ----- [Definir o segmento para os dados] ----------------------------------------------------------

data segment para 'data'
    ; ----- [Variáveis] -----

    numAleat    dw  10  dup(' ')
    aux         db  0
    
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
        
        call    GeraNumerosAleatorios
        
        mov     ah, 4ch
        int     21h 
        
    Main endp    
    
    GeraNumerosAleatorios proc
    
        ; ----- [Passo 2 - Gera um número aleatório] -------------------------------------------
        label1:
        mov     ah, 00h
        int     1ah
        mov     ax, dx
        mov     dx, 0
        mov     bx, 10
        div     bx
        ; ----- dl tem o número gerado
        ;mov     aux, dl
        
        xor     ax, ax
        xor     bx, bx
        xor     cx, cx
        
        ; ----- [Passo 3 - Verifica se o número gerado já existe] ------------------------------ 
        
        mov     cx, 0
        loop1:
        mov     si, offset numAleat
        add     si, cx
        mov     bx, [si]
        cmp     bx, dx
        je      label1
        cmp     bx, ' '
        je      next1
        inc     cx
        inc     cx
        cmp     cx, 18
        jg      fim
        jmp     loop1
        
        next1:
        mov     [si], dx
        inc     aux
        cmp     aux, 10
        je      fim
        jmp     label1
        
        ; ----- Terminar o programa
        fim:
          
        ret
    GeraNumerosAleatorios endp        
   
code ends
end