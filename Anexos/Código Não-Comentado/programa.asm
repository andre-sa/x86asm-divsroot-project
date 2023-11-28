stack segment para stack
    db  64  dup(' ')
stack ends

data segment para 'data'

    varTeste            dw      ?

    strTitulo           db      '      ===== Menu Principal =====      $'                   
    strBtDivisao        db      '[1]  Divisao$'                                               
    strBtRaizQ          db      '[2]  Raiz$'                                                 
    strBtSair           db      '[0]  Sair$'                                                     
    
    strDivisaoTitulo    db      '       ======> DIVISAO <======       $'                      
    strPedirDividendo   db      'Insira o dividendo: $'                                      
    strPedirDivisor     db      '  Insira o divisor: $'                                        

    strRaizQTitulo      db      '       ===> RAIZ QUADRADA <===       $'                          
    strPedirRadicando   db      'Insira o radicando: $'                                           
    
    strInfoNumeros1     db      '--> Maximo 10 algarismos (!)$'                                                                                                                                
    strInfoNumeros2     db      '--> Valor maximo: 9999 (!)$'                                   
    
	strTecVirTitulo		db		'=== [ TECLADO VIRTUAL ] ===$'                                 
    strBackspace        db      'BACKSPACE$'                                                    
    strEnter            db      '  ENTER  $'                                                   

    strVoltar           db      'VOLTAR$'                                                   
    strGuardar          db      'GUARDAR$'                                                      

    auxInicial_X        dw      0                                                              
    auxInicial_Y        dw      0                                                                
    auxCompr_X          dw      0                                                                  
    auxCompr_Y          dw      0                                                                   

    numAleat            dw      10 dup(' ')                                                       
    numAux              db      0
    x1                  dw      0                                                            
    x2                  dw      0                                                                  
    y1                  dw      0                                                                
    y2                  dw      0                                                                  
    index               dw      0                                                                 
    iVirgula            dw      0                                                                                                                                                         
    ho                  db      0                                                                                                    
    space               db      ' $'
    
    flagSinal           db      0                                                                
                                                                                                 
    flagOperacao        db      0                                                            

    dividendo           db      10 dup(' ')                                                 
    divisor             dw      0                                                               
    quociente           db      10 dup(' ')                                               

    resto               dw      0                                                                

    radicando           db      10 dup(' ')                                             
    radicandoPares		db		10 dup(100)												
	iRadicandoPares     dw      0															
	raiz                dw      0                                                                                                                                                  
    alfa                dw      0															

    nomeFicheiro        db      '.\dados.txt', 0                                      
    handle              dw      ?    													
    bufferEscrita       db      64 dup('$')                                                 
    bufferEscrita_I     db      0														

data ends

code segment para 'code'

    Main proc far
        
        assume cs:code,ds:data,ss:stack
        push    ds                                                                               
        xor     ax, ax                                                                          
        push    ax                                                                           
        mov     ax, data                                                                        
        mov     ds, ax                                                                            

        call    InitModoGrafico                                                                  

        mov     ax, 0000h                                                               
        int     33h                                                                              

        Main_Loop:
        call    ResetVariaveis																
        call    MostraMenuPrincipal                                                            
        call    Delay																			

        Main_Loop_01:
        mov     ax, 0001h                                                                       
        int     33h                                                                               
        mov     ax, 00003h                                                                     
        int     33h                                                                          
        cmp     bx, 1                                                                          
        je      Main_Next_01                                                                    
        mov     ah, 01h                                                                           
        int     16h                                                                              
        jz      Main_Loop_01                                                                    

        mov     ah, 00h                                                                       
        int     16h                                                                         
        cmp     al, '1'                                                                     
        je      Main_Divisao                                                                  
        cmp     al, '2'                                                                      
        je      Main_RaizQ                                                                   
        cmp     al, '0'                                                                    
        je      Main_Sair                                                              
        jmp     Main_Loop_01                                                                  

        Main_Next_01:
        cmp     cx, 0070h                                                                      
        jb      Main_Loop_01                                                                  
        cmp     cx, 020ch                                                                   
        jg      Main_Loop_01                                                                     
        cmp     dx, 0023h                                                                
        jb      Main_Loop_01                                                            
        cmp     dx, 0042h                                                                   
        jb      Main_Divisao                                                                 
        cmp     dx, 004bh                                                             
        jb      Main_Loop_01                                                                
        cmp     dx, 006ah                                                                  
        jb      Main_RaizQ                                                                     
        cmp     dx, 0073h                                                            
        jb      Main_Loop_01                                                               
        cmp     dx, 0092h                                                                  
        jb      Main_Sair                                                                   
        jmp     Main_Loop_01                                                                   

        Main_Divisao:
        mov     flagOperacao, 0                                                                   
        call    Divisao                                                                         
        jmp     Main_Loop																	

        Main_RaizQ:
        mov     flagOperacao, 1                                                                 
        call    RaizQuadrada                                                                    
        jmp		Main_Loop																	

        Main_Sair:
        call	InitModoGrafico																
		mov     ah, 4ch                                                                         
        int     21h                                                                            
        
    Main endp    

    MostraMenuPrincipal proc near

        call    InitModoGrafico                                                                

        mov     ah, 02h                                                                        
        mov     bh, 00h                                                                        
        mov     dh, 1                                                                             
        mov     dl, 1                                                                            
        int     10h                                                                            
        mov     ah, 09h                                                                        
        lea     dx, strTitulo                                                                
        int     21h                                                                              

        mov     cx, 3                                                                           
        mov     auxInicial_X, 56                                                                 
        mov     auxInicial_Y, 35                                                                
        mov     auxCompr_X, 206                                                             
        mov     auxCompr_Y, 31                                                                  
        Desenha_3_Botoes_01:
        push    cx                                                                            
        call    DesenhaBotao                                                                   
        pop     cx                                                                              
        add     auxInicial_Y, 40                                                                
        loop    Desenha_3_Botoes_01                                                    

        mov     ah, 02h                                                                         
        mov     bh, 00h                                                                      
        mov     dh, 6                                                                        
        mov     dl, 14                                                                        
        int     10h                                                                             
        mov     ah, 09h                                                                  
        lea     dx, strBtDivisao                                                         
        int     21h                                                                        
        
        mov     ah, 02h                                                                      
        mov     bh, 00h                                                                     
        mov     dh, 11                                                                    
        mov     dl, 14                                                                    
        int     10h                                                                        
        mov     ah, 09h                                                                   
        lea     dx, strBtRaizQ                                                           
        int     21h                                                                       
        
        mov     ah, 02h                                                                
        mov     bh, 00h                                                                    
        mov     dh, 16                                                                      
        mov     dl, 14                                                                   
        int     10h                                                                         
        mov     ah, 09h                                                                    
        lea     dx, strBtSair                                                               
        int     21h                                                                         
        
        ret
        
    MostraMenuPrincipal endp    

    DesenhaBotao proc near
         
        mov     ah, 0ch                                                                     
        mov     al, 07h                                                                         
        mov     cx, auxInicial_X                                                            
        mov     dx, auxInicial_Y                                                              
		
        Desenha_Botao_Loop_01:
        int     10h                                                                            
        add     dx, auxCompr_Y                                                                   
        int     10h                                                                         
        sub     dx, auxCompr_Y                                                                 
        inc     cx                                                                                
        mov     bx, auxInicial_X                                                                
        add     bx, auxCompr_X                                                                   
        cmp     cx, bx                                                                         
        jng     Desenha_Botao_Loop_01                                                             
        sub     cx, auxCompr_X                                                                 
        dec     cx                                                                                
        inc     dx                                                                               

        Desenha_Botao_Loop_02:
        int     10h                                                                                
        add     cx, auxCompr_X                                                                     
        int     10h                                                                             
        sub     cx, auxCompr_X                                                                 
        inc     dx                                                                           
        mov     bx, auxInicial_Y                                                               
        add     bx, auxCompr_Y                                                               
        cmp     dx, bx                                                                         
        jbe     Desenha_Botao_Loop_02                                                        
        
        ret
            
    DesenhaBotao endp        

    Divisao proc near

        call    DivisaoInicio                                                                

        call    DivisaoExecuta                                                                   

        mov     auxInicial_X, 30
        mov     auxInicial_Y, 60                                                           
        mov     auxCompr_X, 80                                                            
        mov     auxCompr_Y, 40																
        call    DesenhaBotao                                                               
        add     auxInicial_Y, 45                                                        
        call    DesenhaBotao                                                             

        mov     ah, 02h                                                                        
        mov     bh, 00h                                                                          
        mov     dh, 10                                                                     
        mov     dl, 6                                                                         
        int     10h                                                                             
        mov     ah, 09h                                                                       
        lea     dx, strVoltar                                                                    
        int     21h                                                                             
        
        mov     ah, 02h                                                                   
        mov     bh, 00h                                                                    
        mov     dh, 15                                                                       
        mov     dl, 5                                                                          
        int     10h                                                                              
        mov     ah, 09h                                                                           
        lea     dx, strGuardar                                                                   
        int     21h                                                                            
         
        call    ResultadosEsperaBotao															
        
        ret																							
            
    Divisao endp      
    
	RaizQuadrada proc near

		call	RaizQInicio																		

		call	RaizQExecuta																	

		call    RaizQMostraResultados                                                              
		
		ret
	
	RaizQuadrada endp

	RaizQMostraResultados proc near

	    call    InitModoGrafico                                                                  

		mov     ah, 02h                                                                      
        mov     bh, 00h                                                                         
        mov     dh, 3                                                                        
        mov     dl, 5                                                                        
        int     10h                                                                             

		mov		index, 0																		
		
		RaizQ_Mostra_Resultados_02:
		mov		si, offset radicando															
		add		si, index																		
		mov		bx, [si]																		
		mov		bh, 0																			
		
		cmp		bl, ' '																		
		je		RaizQ_Mostra_Resultados_03												
		cmp		bl, ','																		
		je		RaizQ_Mostra_Resultados_03													
		
		add		bl, 30h																			
		
		RaizQ_Mostra_Resultados_03:
		mov		dl, bl																			
		int		21h																				
		
		mov		ah, 02h																		
		inc		dl																			
		inc		index																	
		
		cmp		index, 10														
		je		RaizQ_Mostra_Resultados_04												
		
		jmp		RaizQ_Mostra_Resultados_02													
		
		RaizQ_Mostra_Resultados_04:

		mov     ah, 02h                                                               
        mov     bh, 00h                                                                  
        mov     dh, 3                                                                   
        mov     dl, 18                                                                   
        int     10h                                                                     

		mov		ax, raiz																
		call	PrintNumero																	

		mov		cx, 28																			
		
		RaizQ_Mostra_Resultados_05:
		mov     ah, 02h                                                         
        mov     bh, 00h                                                                
        mov     dh, 4                                                                      
        mov     dl, cl                                                                   
        int     10h                                                                     
		mov		dl, 205																
		int		21h																			
		dec		cx																			
		cmp		cx, 4																		
		jne		RaizQ_Mostra_Resultados_05													

		mov     ah, 02h                                                                    
        mov     bh, 00h                                                                     
        mov     dh, 3                                                                 
        mov     dl, 16                                                                  
        int     10h                                                                          
		mov		dl, 186																			
		int		21h																				
		mov     ah, 02h                                                                    
        mov     bh, 00h                                                                 
        mov     dh, 4                                                                     
        mov     dl, 16                                                                      
        int     10h                                                                      
		mov		dl, 206																			
		int		21h																				
		mov     ah, 02h                                                                     
        mov     bh, 00h                                                                      
        mov     dh, 5                                                                
        mov     dl, 16                                                              
        int     10h                                                                          
		mov		dl, 186																		
		int		21h																			

		mov     ah, 02h                                                                   
        mov     bh, 00h                                                                        
        mov     dh, 5                                                                       
        mov     dl, 5                                                                     
        int     10h                                                                      
        
        mov     ax, resto																		
        call    PrintNumero																		

        mov     auxInicial_X, 30
        mov     auxInicial_Y, 60                                                              
        mov     auxCompr_X, 80                                                             
        mov     auxCompr_Y, 40																
        call    DesenhaBotao                                                              
        add     auxInicial_Y, 45                                                          
        call    DesenhaBotao                                                                

        mov     ah, 02h                                                                
        mov     bh, 00h                                                                   
        mov     dh, 10                                                                     
        mov     dl, 6                                                                      
        int     10h                                                                             
        mov     ah, 09h                                                                     
        lea     dx, strVoltar                                                             
        int     21h                                                                          
        
        mov     ah, 02h                                                                         
        mov     bh, 00h                                                                     
        mov     dh, 15                                                                     
        mov     dl, 5                                                                        
        int     10h                                                                           
        mov     ah, 09h                                                                     
        lea     dx, strGuardar                                                                
        int     21h                                                                      
         
        call    ResultadosEsperaBotao															
		
	    ret
	    
	RaizQMostraResultados endp    

	RaizQExecuta proc near

		call	RaizQSetPares																	

		mov     index, 0																		

		RaizQ_Executa_01:
		mov     si, offset radicandoPares													
		add     si, index																	
		mov     bx, [si]																	
		mov     bh, 0																		
		cmp     bl, 100																		
		jnb     RaizQ_Executa_02															

		mov     ax, resto																	
		mov     cx, 100																		
		mul     cx																				
		add     ax, bx																		
		mov     resto, ax																		
		mov     alfa, 0																		

		RaizQ_Executa_04:
		mov     ax, raiz																		
		mov     cx, 2																		
		mul     cx																			
		mov     cx, 10																	
		mul     cx																		
		mov     cx, alfa																	
		add     ax, cx																	
		mul     cx																			
		cmp     ax, resto																		
		jg      RaizQ_Executa_03															
		inc     alfa																			
		jmp     RaizQ_Executa_04															
		
		RaizQ_Executa_03:
		dec     alfa																			
		mov     ax, raiz																				
		mov     cx, 2																		
		mul     cx																			
		mov     cx, 10																			
		mul     cx																		
		mov     cx, alfa																	
		add     ax, cx																	
		mul     cx																			
		sub     resto, ax																	
		mov     ax, raiz																
		mov     cx, 10																
		mul     cx																	
		add     ax, alfa																
		mov     raiz, ax																	
		inc     index																	
		mov     cx, index																	
		cmp     cx, 10																		
		jng     RaizQ_Executa_01														
		
		RaizQ_Executa_02:
		ret
		
	RaizQExecuta endp

	RaizQSetPares proc near

		mov		index, 0																	
		mov     iRadicandoPares, 0													
		mov     cx, 0																		
		RaizQ_Set_Pares_06:
		mov     si, offset radicando													
		add     si, cx													
		mov     bx, [si]														
		inc     cx																			
		cmp     bl, ' '																	
		jne     RaizQ_Set_Pares_06															

		mov		ax, iVirgula															
		and		al, 01h																			
		jz		RaizQ_Set_Pares_07														

		RaizQ_Set_Pares_08:
		mov		si, offset radicando													
		add		si, index															
		mov		bx, [si]														
		mov		si, offset radicandoPares											
		mov		[si], bl																
		inc     iRadicandoPares													
		inc     index																
		jmp     RaizQ_Set_Pares_01													
		
		RaizQ_Set_Pares_07:
		cmp     iVirgula, 0																	
		jne     RaizQ_Set_Pares_01															
		and     cx, 01h																	
		jz      RaizQ_Set_Pares_08														
		
		RaizQ_Set_Pares_01:	     
		mov		si, offset radicando														
		add		si, index																
		mov		bx, [si]																
		cmp     bh, ','														
		je      RaizQ_Set_Pares_04												
		cmp     bl, ','																
		je      RaizQ_Set_Pares_05											
		cmp		bl, ' '															
		je		RaizQ_Set_Pares_02														
		cmp     bh, ' '																
		jne     RaizQ_Set_Pares_03															
		mov     bh, 00h																		
		RaizQ_Set_Pares_03:
		xor		ax, ax																	
		mov		al, bl																	
		mov		cx, 10																		
		mul		cx																	
		add		al, bh																
		mov		si, offset radicandoPares													
		add		si, iRadicandoPares													
		mov		[si], al															
		inc     iRadicandoPares													
		inc		index																	
		inc		index																	
		jmp		RaizQ_Set_Pares_01												
		
		RaizQ_Set_Pares_04:
		mov     si, offset radicandoPares											
		add     si, iRadicandoPares										
		mov     [si], bl 																
		inc     iRadicandoPares															

		RaizQ_Set_Pares_05:
		inc     index																
		RaizQ_Set_Pares_09:	
		mov     si, offset radicando													
		add     si, index																	
		xor     ax, ax																	
		mov     bx, [si]																
		mov		si, offset radicandoPares											
		add		si, iRadicandoPares														
		cmp     bl, ' '																	
		je      RaizQ_Set_Pares_02														
		cmp     bh, ' '																	
		jne     RaizQ_Set_Pares_10															
		mov     [si], bl																		
		inc     iRadicandoPares																	
		jmp     RaizQ_Set_Pares_02																
		
		RaizQ_Set_Pares_10:
		mov     al, bl																			
		mov     cx, 10																			
		mul     cx																				
		add     al, bh																			
		mov		[si], al																		
		inc     iRadicandoPares																	
		inc     index																			
		inc     index																		
		jmp     RaizQ_Set_Pares_09 																
		
		RaizQ_Set_Pares_02:
		
		ret
		
	RaizQSetPares endp

	RaizQInicio proc near

        call    InitModoGrafico                                                      

        mov     ah, 02h                                                                      
        mov     bh, 00h                                                                       
        mov     dh, 1                                                                      
        mov     dl, 1                                                                          
        int     10h                                                                        
        mov     ah, 09h                                                                        
        lea     dx, strRaizQTitulo                                                       
        int     21h                                                                     

        mov     ah, 02h                                                                        
        mov     bh, 00h                                                              
        mov     dh, 4                                                                   
        mov     dl, 1                                                                     
        int     10h                                                                         
        mov     ah, 09h                                                                   
        lea     dx, strInfoNumeros1                                             
        int     21h                                                                      
        
        mov     ah, 02h                                                                       
        mov     bh, 00h                                                                 
        mov     dh, 6                                                                     
        mov     dl, 1                                                                
        int     10h                                                                     
        mov     ah, 09h                                                                    
        lea     dx, strPedirRadicando                                                  
        int     21h                                                                 

        mov     index, 0                                                                    

        call    MostraTeclado                                                                  
 
        mov     ah, 02h                                                                  
        mov     bh, 00h                                                              
        mov     dh, 6                                                                
        mov     dl, 19                                                                 
        int     10h                                                                      

		RaizQ_Inicio_01:
        call    Delay                                                             
        call    EsperaTecladoVirtual                                                        
        cmp     numAux, '?'																	
        je     	RaizQ_Inicio_01															

		cmp     numAux, 0                                                                  
		je      RaizQ_Inicio_02                                                       
		cmp     numAux, 1                                                                    
		je      RaizQ_Inicio_02                                                          
		cmp     numAux, 2                                                                 
		je      RaizQ_Inicio_02                                                           
		cmp     numAux, 3                                                               
		je      RaizQ_Inicio_02                                                              
		cmp     numAux, 4                                                                    
		je      RaizQ_Inicio_02                                                             
		cmp     numAux, 5                                                                     
		je      RaizQ_Inicio_02                                                             
		cmp     numAux, 6                                                                  
		je      RaizQ_Inicio_02                                                              
		cmp     numAux, 7                                                                  
		je      RaizQ_Inicio_02                                                            
		cmp     numAux, 8                                                                     
		je      RaizQ_Inicio_02                                                             
		cmp     numAux, 9                                                                        
		je      RaizQ_Inicio_02                                                           
		cmp     numAux, 10                                                                 
		je      RaizQ_Inicio_03                                                         
		cmp     numAux, 11                                                                  
		je      RaizQ_Inicio_04                                                      
		cmp     numAux, 12                                                                     
		je      RaizQ_Inicio_05                                                       
		cmp     numAux, 13                                                               
		je      RaizQ_Inicio_06                                                           

		RaizQ_Inicio_02:    
		call    RaizQInicioRadicando                                                         
		jmp     RaizQ_Inicio_01                                                     

		RaizQ_Inicio_03:
		mov     dh, 6                                                                       
		jmp     RaizQ_Inicio_01                                                               

		RaizQ_Inicio_04:
		jmp     RaizQ_Inicio_01                                                          

		RaizQ_Inicio_05:
		call    RaizQInicioBackspace                                                                
		jmp     RaizQ_Inicio_01                                                              

		RaizQ_Inicio_06:
		
		ret
		
	RaizQInicio endp

	RaizQInicioVirgula proc near

        cmp     iVirgula,0                                                               
        je      RaizQ_Inicio_Virgula_01                                           
        ret
        
        RaizQ_Inicio_Virgula_01:
        cmp     index,0                                                               
        jne     RaizQ_Inicio_Virgula_02                                                     
        ret
        RaizQ_Inicio_Virgula_02:
        cmp     index,8                                                                       
        jng     RaizQ_Inicio_Virgula_03                                                   
        ret

        RaizQ_Inicio_Virgula_03:
        mov     al, 2ch																		
		call    SetRadicando                                                                  

		mov     ah, 02h                                                                  
        mov     bh, 00h                                                                    
        mov     dl, 22                                                                       
        add     dx, index                                                                  
        mov     dh, 6                                                                         
        int     10h                                                                        
		mov     dl, ','                                                                    
        int     21h                                                                          
		mov     cx, index																		
		mov     iVirgula, cx                                                               
		inc     index																									
        
        ret
	        
	RaizQInicioVirgula endp    

	RaizQInicioBackspace proc near
		
		cmp     index, 0																	
		jne     RaizQ_Inicio_Backspace_01													
		ret
		RaizQ_Inicio_Backspace_01:
		mov     al, ' '																		
		dec     index																	
		call    SetRadicando																
		mov     ah, 02h                                                                         
        mov     bh, 00h                                                                      
        mov     dl, 22                                                                      
        add     dx, index                                                                 
        mov     dh, 6                                                                    
        int     10h                                                                          
		mov     dl, ' '                                                                     
        int     21h                                                                       
		mov     cx, iVirgula														
		cmp     index, cx																
		jne     RaizQ_Inicio_05_01															
		mov     iVirgula, 0																	
		
		RaizQ_Inicio_05_01:
		ret
		
	RaizQInicioBackspace endp

	RaizQInicioRadicando proc near
		
		call    GetNumeroAleat                                                              

		cmp     index, 10                                                                    
		jb      RaizQ_Inicio_Radicando_01                                                   
		ret

		RaizQ_Inicio_Radicando_01:
		call    SetRadicando                                                                  

        cmp     index, 0                                                             
        jne     RaizQ_Inicio_Radicando_02                                             
        cmp     al, 0                                                                    
        jne     RaizQ_Inicio_Radicando_02                                               
		ret

		RaizQ_Inicio_Radicando_02:
		mov     ah, 02h                                                                   
        mov     bh, 00h                                                                    
        mov     dl, 22                                                                  
        add     dx, index                                                                 
        mov     dh, 6                                                                     
        int     10h                                                                           
		add     al, 30h                                                                 
		mov     dl, al                                                                      
        int     21h                                                                      		
		inc     index																			

		ret
		
	RaizQInicioRadicando endp

	SetRadicando proc near

        cmp     index, 0                                                         
        jne     Set_Radicando_01                                                     
        cmp     al, 0                                                             
        jne     Set_Radicando_01                                                 
        
        ret

        Set_Radicando_01:
        mov     cx, index                                                              
        mov     si, offset radicando                                                       
        add     si, cx                                                                      

        mov     [si], al                                                                    
                
        ret
		
	SetRadicando endp

    ResultadosEsperaBotao proc near

        mov     numAux, '?'                                                                

        mov     ax, 0001h                                                                  
        int     33h                                                                      

        Resultados_Espera_Botao_01:
        mov     ax, 0001h                                                                
        int     33h                                                                          
        mov     ax, 00003h                                                                 
        int     33h                                                                       
        cmp     bx, 1                                                                      
        je      Resultados_Espera_Botao_02                                               
        jmp     Resultados_Espera_Botao_01                                                 

        Resultados_Espera_Botao_02:
        mov     x1, 003ch                                                           
        mov     x2, 00dch                                                               
        mov     y1, 003ch                                                                    
        mov     y2, 0064h                                                                     
        mov     numAux, 0                                                                     
        call    VerificaBotao                                                                
        cmp     numAux, '?'                                                                 
		je		Resultados_Espera_Botao_03                                                   
        ret                                                                                         

		Resultados_Espera_Botao_03:
        mov     x1, 003ch                                                        
        mov     x2, 00dch                                                                    
        mov     y1, 0069h                                                           
        mov     y2, 0091h                                                               
        mov     numAux, 1                                                        
        call    VerificaBotao                                                    
        cmp     numAux, '?'                                                       
        je     	Resultados_Espera_Botao_01                                           
        
        call    EscreverFicheiro                                                                
        
        ret
            
    ResultadosEsperaBotao endp    

    InitModoGrafico proc near
        
        mov     ah, 00h                                                                  
        mov     al, 13h                                                                   
        int     10h                                                                       
        
        ret
            
    InitModoGrafico endp    

    DivisaoExecuta proc near
        
        call    DivisaoExecutaAtualizacao													
        mov     index, 0																

        Divisao_Executa_Loop:
                       
        mov     si, offset dividendo														
        add     si, index																

        mov     ax, [si]														
        mov     ah, 0																
        cmp     al, ' '																	
        je      Divisao_Executa_Fim														
        cmp     al, ','																		
        jne     Divisao_Executa_Continua													

        mov     bx, offset quociente														
        add     bx, index																
        mov     [bx], al																
        inc     index																	
        cmp     index, 10																
        jb      Divisao_Executa_Loop													
        jmp     Divisao_Executa_Fim														

        Divisao_Executa_Continua:
        mov     ho, al																		
        mov     ax, resto																
        mov     cx, 10																
        mul     cx														
        mov     resto, ax													
        mov     bh, 0																	
        mov     bl, ho														
        add     resto, bx																	

        mov     cx, 0																		
        
        call    DivisaoExecuta2																	

        mov     bx, offset quociente												
        add     bx, index																
        mov     [bx], cl																	
        inc     index																	
        mov     cx, 10																			
        
        push    index       															
        mov     index, 0																
        call    DivisaoExecutaAtualizacao2													
        pop     index																
        
        cmp     index, 10														
        jb      Divisao_Executa_Loop													
        
        Divisao_Executa_Fim:
        ret
        
    DivisaoExecuta endp    

    DivisaoExecuta2 proc near
        
        Divisao_Executa_Alfa:
        mov     ax, divisor																
        mul     cx																		

        cmp     ax, resto																
        jg      Divisao_Executa_Alfa_Fim													
        inc     cx																				
        jmp     Divisao_Executa_Alfa													
        
        Divisao_Executa_Alfa_Fim:
        cmp     ax, resto																
        jng     Divisao_Executa_Fim2												
        mov     ax, divisor																	
        dec     cx																			
        mul     cx																			
        
        Divisao_Executa_Fim2:
        sub     resto, ax																	
        
        ret
            
    DivisaoExecuta2 endp    

    DivisaoExecutaAtualizacao2 proc near
        
        mov     ah, 02h                                                                     
        mov     bh, 00h                                                                       
        mov     dh, 4                                                                     
        mov     dl, 15                                                            
        int     10h                                                              
        mov     dl, 0ceh                                                            
        int     21h                                                                 
        mov     ah, 02h                                                          
        mov     bh, 00h                                                              
        mov     dh, 5                                                             
        mov     dl, 15                                                         
        int     10h                                                                   
        mov     dl, 0bah                                                            
        int     21h                                                                       

        mov     ah, 02h                                                                        
        mov     bh, 00h                                                           
        mov     dh, 5                                                          
        mov     dl, 5                                                                    
        int     10h                                                                          
        
        mov     ax, resto																			
        call    PrintNumero																	
  
        cmp     flagSinal, 0
        je      D_E_A_2_NEXT
        mov     ah, 02h                                                                         
        mov     bh, 00h                                                                    
        mov     dh, 5                                                                   
        mov     dl, 16                                                                 
        int     10h                                                            
        mov     dl, '-'                                                                
        int     21h 																
        
        D_E_A_2_NEXT:
        mov     ah, 02h                                                                      
        mov     bh, 00h                                                                       
        mov     dh, 5                                                                          
        mov     dl, 17                                                                          
        int     10h                                                                           
        
        D_E_A_2_1:
        mov     si, offset quociente															
        add     si, index																	
        mov     bx, [si]																	
        mov     bh, 0																
        
        cmp     bl, ' '																
        je      D_E_A_2_3															
        cmp     bl, ','																	
        je      D_E_A_2_3																
        
        add     bl, 30h														
        
        D_E_A_2_3:
        mov     dl, bl                                                                     
        int     21h                                                              
        
        mov     ah, 02h													
        inc     dl																	
        inc     index																	
        
        cmp     index, 10																
        je      D_E_A_2_Fim																	
        
        jmp     D_E_A_2_1																	
        
        D_E_A_2_Fim:
        ret
            
    DivisaoExecutaAtualizacao2 endp    

    DivisaoExecutaAtualizacao proc near

        call    InitModoGrafico												

        mov     index, 0																

        mov     ah, 02h                                                                  
        mov     bh, 00h                                                                 
        mov     dh, 3                                                                  
        mov     dl, 5                                                                  
        int     10h                                                                               

        Divisao_Executa_Atualizacao_01:
        mov     si, offset dividendo														
        add     si, index																
        mov     bx, [si]																
        mov     bh, 0																			
        
        cmp     bl, ' '																		
        je      Divisao_Executa_Atualizacao_03											
        cmp     bl, ','																			
        je      Divisao_Executa_Atualizacao_03												
                
        add     bl, 30h																			
        Divisao_Executa_Atualizacao_03:
        mov     dl, bl                                                                     
        int     21h                                                                          
        
        mov     ah, 02h																
        inc     dl																			
        inc     index																		
        
        cmp     index, 10															
        je      Divisao_Executa_Atualizacao_Fim											
        
        jmp     Divisao_Executa_Atualizacao_01												
        
        Divisao_Executa_Atualizacao_Fim:

        mov     dl, 0bah                                                                  
        int     21h                                                                           
        mov     dl, ' '																		
        int     21h																				

        mov     ax, divisor																
        call    PrintNumero																

        mov     ah, 02h                                                                   
        mov     bh, 00h                                                                 
        mov     dh, 4                                                                
        mov     dl, 5                                                                
        int     10h                                                                      
        mov     cx, 17																	
        Divisao_Executa_Atualizacao_02:
        mov     ah, 02h                                                             
        mov     bh, 00h                                                                  
        mov     dl, 0cdh																
        int     21h																			
        loop    Divisao_Executa_Atualizacao_02													
        
        ret 
        
    DivisaoExecutaAtualizacao endp    

    DivisaoInicio proc near

        call    InitModoGrafico                                                        

        mov     ah, 02h                                                           
        mov     bh, 00h                                                            
        mov     dh, 1                                                                        
        mov     dl, 1                                                                    
        int     10h                                                                    
        mov     ah, 09h                                                                    
        lea     dx, strDivisaoTitulo                                                        
        int     21h                                                                             
       
        mov     ah, 02h                                                                      
        mov     bh, 00h                                                                       
        mov     dh, 4                                                                    
        mov     dl, 1                                                                    
        int     10h                                                                   
        mov     ah, 09h                                                                 
        lea     dx, strInfoNumeros1                                                           
        int     21h                                                                         
        
        mov     ah, 02h                                                                       
        mov     bh, 00h                                                                   
        mov     dh, 6                                                                    
        mov     dl, 1                                                                 
        int     10h                                                                      
        mov     ah, 09h                                                                     
        lea     dx, strPedirDividendo                                                     
        int     21h                                                                          

        mov     index, 0                                                                          

        call    MostraTeclado                                                                   

        mov     ah, 02h                                                                     
        mov     bh, 00h                                                                        
        mov     dh, 6                                                                       
        mov     dl, 19                                                                         
        int     10h                                                                           

		Divisao_Inicio_01:
        call    Delay                                                                        
        call    EsperaTecladoVirtual                                                           
        cmp     numAux, '?'																	
        je     	Divisao_Inicio_01																

		cmp     numAux, 0                                                                  
		je      Divisao_Inicio_02                                                                
		cmp     numAux, 1                                                                     
		je      Divisao_Inicio_02                                                       
		cmp     numAux, 2                                                                     
		je      Divisao_Inicio_02                                                          
		cmp     numAux, 3                                                                 
		je      Divisao_Inicio_02                                                          
		cmp     numAux, 4                                                                
		je      Divisao_Inicio_02                                                                
		cmp     numAux, 5                                                               
		je      Divisao_Inicio_02                                                   
		cmp     numAux, 6                                                                   
		je      Divisao_Inicio_02                                                     
		cmp     numAux, 7                                                             
		je      Divisao_Inicio_02                                                       
		cmp     numAux, 8                                                             
		je      Divisao_Inicio_02                                             
		cmp     numAux, 9                                                            
		je      Divisao_Inicio_02                                                     
		cmp     numAux, 10                                                       
		je      Divisao_Inicio_03                                              
		cmp     numAux, 11                                                      
		je      Divisao_Inicio_04                                                  
		cmp     numAux, 12                                                             
		je      Divisao_Inicio_05                                                       
		cmp     numAux, 13                                                               
		je      Divisao_Inicio_06                                                         

		Divisao_Inicio_02:    
		call    DivisaoInicioDividendo                                                           
		jmp     Divisao_Inicio_01                                                           

		Divisao_Inicio_03:
		mov     dh, 6                                                                    
		call    AlternarSinal                                                          
		jmp     Divisao_Inicio_01                                                       

		Divisao_Inicio_04:
        call    DivisaoInicioVirgula                                                               
		jmp     Divisao_Inicio_01                                                         

		Divisao_Inicio_05:
		call    DivisaoInicioBackspace                                                          
		jmp     Divisao_Inicio_01                                                          

		Divisao_Inicio_06:

        mov     index, 0                                                                         

        call    MostraTeclado                                                             

        mov     ah, 02h                                                                        
        mov     bh, 00h                                                                        
        mov     dh, 8                                                                        
        mov     dl, 1                                                                      
        int     10h                                                                             
        mov     ah, 09h                                                                        
        lea     dx, strInfoNumeros2                                                        
        int     21h                                                                       
        
        mov     ah, 02h                                                                       
        mov     bh, 00h                                                                     
        mov     dh, 10                                                                 
        mov     dl, 1                                                                    
        int     10h                                                                   
        mov     ah, 09h                                                       
        lea     dx, strPedirDivisor                                                     
        int     21h                                                                             

        mov     ah, 02h                                                              
        mov     bh, 00h                                                                   
        mov     dh, 10                                                             
        mov     dl, 19                                                        
        int     10h                                                                   

		Divisao_Inicio_07:
        call    Delay                                                                           
        call    EsperaTecladoVirtual                                                         
        cmp     numAux, '?'																	
        je     	Divisao_Inicio_07																

		cmp     numAux, 0                                                                      
		je      Divisao_Inicio_08                                                              
		cmp     numAux, 1                                                                        
		je      Divisao_Inicio_08                                                                
		cmp     numAux, 2                                                                       
		je      Divisao_Inicio_08                                                           
		cmp     numAux, 3                                                                    
		je      Divisao_Inicio_08                                                         
		cmp     numAux, 4                                                                   
		je      Divisao_Inicio_08                                                           
		cmp     numAux, 5                                                                      
		je      Divisao_Inicio_08                                                         
		cmp     numAux, 6                                                                
		je      Divisao_Inicio_08                                                     
		cmp     numAux, 7                                                          
		je      Divisao_Inicio_08                                                   
		cmp     numAux, 8                                                                  
		je      Divisao_Inicio_08                                                         
		cmp     numAux, 9                                                             
		je      Divisao_Inicio_08                                                        
		cmp     numAux, 10                                                             
		je      Divisao_Inicio_09                                                           
		cmp     numAux, 11                                                               
		je      Divisao_Inicio_10                                                         
		cmp     numAux, 12                                                               
		je      Divisao_Inicio_11                                                             
		cmp     numAux, 13                                                                    
		je      Divisao_Inicio_12                                                             

		Divisao_Inicio_08:    
		call    DivisaoInicioDivisor                                                       
		jmp     Divisao_Inicio_07                                                        

		Divisao_Inicio_09:
		mov     dh, 10                                                                        
		call    AlternarSinal                                                                 
		jmp     Divisao_Inicio_07                                                            

		Divisao_Inicio_10:
        call    DivisaoInicioVirgula                                                   
		jmp     Divisao_Inicio_07                                                     
		
		Divisao_Inicio_11:
		call    DivisorBackspace                                                                   
		call    PrintNumero																		
		jmp     Divisao_Inicio_07                                                               

		Divisao_Inicio_12:	
        ret
            
    DivisaoInicio endp    

    DivisorBackspace proc near
        
        mov     ah, 02h                                                                          
        mov     bh, 00h                                                                     
        mov     dh, 10                                                                       
        mov     dl, 22                                                                    
        int     10h                                                                          
        
        mov     cx, 10                                                                      
        mov     dl, ' '                                                                   
        Divisor_Backspace_Loop:
        int     21h                                                                         
        loop    Divisor_Backspace_Loop                                                        
        
        mov     ah, 02h                                                   
        mov     bh, 00h                                                       
        mov     dh, 10                                                             
        mov     dl, 22                                                              
        int     10h                                                                  
        
        mov     ax, divisor                                                                
        mov     bx, 10                                                               
        xor     dx, dx                                                              
        div     bx                                                                            
        mov     divisor, ax                                                             
        
        ret
        
    DivisorBackspace endp    

    DivisaoInicioDivisor proc near
        
        call    GetNumeroAleat                                                              

		Divisao_Inicio_Divisor_01:
		call    SetDivisor                                                                     

		Divisao_Inicio_Divisor_02:
		mov     ah, 02h                                                                      
        mov     bh, 00h                                                                     
        mov     dh, 10                                                                
        mov     dl, 22                                                                      
        int     10h                                                                         
		
		mov     ax, divisor																	
		call    PrintNumero                                                                    	
		
		ret
            
    DivisaoInicioDivisor endp    

    SetDivisor proc near

        mov     cx, divisor                                                                 

        cmp     cx, 999                                                                      
        jbe     Set_Divisor_01                                                                  
        ret    

        Set_Divisor_01:
        mov     bx, ax                                                                     
        mov     ax, cx                                                                         
        mov     cx, 10                                                                        
        mul     cx                                                                          
        add     ax, bx                                                                 
        mov     divisor, ax                                                                  
        
        ret
            
    SetDivisor endp    

    PrintNumero proc near
        
        push    dx																			
        push    cx																				
        push    bx																			
        
        xor     cx, cx																			
        mov     bx, 10																		
        
        P_N_1:
        xor     dx, dx																		
        div     bx																		
        push    dx																		
        inc     cx																			
        or      ax, ax																																		
        jnz     P_N_1																		
        
        P_N_2:
        pop     dx																	
        mov     ah, 06h																		
        add     dl, 30h																
        int     21h																				
        loop    P_N_2																		
        
        pop     bx																		
        pop     cx																			
        pop     dx																			
                
        ret
            
    PrintNumero endp   

    DivisaoInicioBackspace proc near
        
        cmp     index, 0																	
		jne     Divisao_Inicio_Backspace_01													
		ret
		Divisao_Inicio_Backspace_01:
		mov     al, ' '																		
		dec     index																		
		call    SetDividendo																
		mov     ah, 02h                                                                   
        mov     bh, 00h                                                                    
        mov     dl, 22                                                               
        add     dx, index                                                                     
        mov     dh, 6                                                                      
        int     10h                                                                      
		mov     dl, ' '                                                                      
        int     21h                                                                            
		mov     cx, iVirgula																
		cmp     index, cx																	
		jne     Divisao_Inicio_05_01													
		mov     iVirgula, 0																		
		Divisao_Inicio_05_01:
    
        ret
        
    DivisaoInicioBackspace endp    

    DivisaoInicioVirgula proc near

        cmp     iVirgula,0                                                                 
        je      Divisao_Inicio_Virgula_01                                                     
        ret
        
        Divisao_Inicio_Virgula_01:
        cmp     index,0                                                                      
        jne     Divisao_Inicio_Virgula_02                                                    
        ret
        Divisao_Inicio_Virgula_02:
        cmp     index,8                                                                   
        jng     Divisao_Inicio_Virgula_03                                                     
        ret

        Divisao_Inicio_Virgula_03:
        mov     al, 2ch																			
		call    SetDividendo                                                                    

		mov     ah, 02h                                                                     
        mov     bh, 00h                                                                       
        mov     dl, 22                                                                     
        add     dx, index                                                                    
        mov     dh, 6                                                                         
        int     10h                                                                            
		mov     dl, ','                                                                        
        int     21h                                                                            
		mov     cx, index																		
		mov     iVirgula, cx                                                              
		inc     index																									
        
        ret
            
    DivisaoInicioVirgula endp    

    DivisaoInicioDividendo proc near
        
        call    GetNumeroAleat                                                               

		cmp     index, 10                                                                  
		jb      Divisao_Inicio_Dividendo_01                                                  
		ret

		Divisao_Inicio_Dividendo_01:
		call    SetDividendo                                                                  

        cmp     index, 0                                                                   
        jne     Divisao_Inicio_Dividendo_02                                              
        cmp     al, 0                                                                            
        jne     Divisao_Inicio_Dividendo_02                                                      
		ret

		Divisao_Inicio_Dividendo_02:
		mov     ah, 02h                                                                   
        mov     bh, 00h                                                                    
        mov     dl, 22                                                                    
        add     dx, index                                                                  
        mov     dh, 6                                                                      
        int     10h                                                                         
		add     al, 30h                                                                   
		mov     dl, al                                                                     
        int     21h                                                                      	
		inc     index																		
		
		ret
            
    DivisaoInicioDividendo endp    

    SetDividendo proc near

        cmp     index, 0                                                              
        jne     Set_Dividendo_01                                                     
        cmp     al, 0                                                                  
        jne     Set_Dividendo_01                                                     
        
        ret

        Set_Dividendo_01:
        mov     cx, index                                                            
        mov     si, offset dividendo                                                       
        add     si, cx                                                                

        mov     [si], al                                                                  
                
        ret
            
    SetDividendo endp    

    GetNumeroAleat proc near
        
        mov     ch, 00h                                                                       
        mov     cl, numAux                                                                    
        mov     ax, cx                                                                 
        mov     bx, 2                                                                     
        mul     bx                                                                       
        mov     si, offset numAleat                                                      
        add     si, ax                                                                 
        mov     ax, [si]                                                                  
 
        ret    
        
    GetNumeroAleat endp    

    EsperaTecladoVirtual proc near

        mov     numAux, '?'                                                                

        mov     ax, 0001h                                                                         
        int     33h                                                                           

        Espera_Teclado_Virtual_01:
        mov     ax, 0001h                                                                        
        int     33h                                                                              
        mov     ax, 00003h                                                                     
        int     33h                                                                         
        cmp     bx, 1                                                                          
        je      Espera_Teclado_Virtual_02                                                      
        jmp     Espera_Teclado_Virtual_01                                                       

        Espera_Teclado_Virtual_02:
        cmp     dx, 0082h                                                                      
        jb      Espera_Teclado_Virtual_01                                                      
        cmp     dx, 00ach                                                                        
        jg      Espera_Teclado_Virtual_01                                                   
        cmp     cx, 0054h                                                                    
        jb      Espera_Teclado_Virtual_01                                                      
        cmp     cx, 0214h                                                                   
        jg      Espera_Teclado_Virtual_01                                                     
  
        mov     x1, 0084h                                                                 
        mov     x2, 00a8h                                                            
        mov     y1, 0082h                                                               
        mov     y2, 0094h                                                         
        mov     numAux, 0                                                                    
        call    VerificaBotao                                                           
        cmp     numAux, '?'                                                                   
		je		Espera_Teclado_Virtual_03                                                
        ret                                                                                         

		Espera_Teclado_Virtual_03:
        mov     x1, 00b4h                                                                     
        mov     x2, 00d8h                                                                 
        mov     y1, 0082h                                                                     
        mov     y2, 0094h                                                                   
        mov     numAux, 1                                                               
        call    VerificaBotao                                                                 
        cmp     numAux, '?'                                                                   
        je     	Espera_Teclado_Virtual_04                                                    
        ret

		Espera_Teclado_Virtual_04:
        mov     x1, 00e4h                                                                    
        mov     x2, 0108h                                                               
        mov     y1, 0082h                                                                   
        mov     y2, 0094h                                                                 
        mov     numAux, 2                                                             
        call    VerificaBotao                                                                  
        cmp     numAux, '?'                                                                
        je     	Espera_Teclado_Virtual_05                                               
        ret

		Espera_Teclado_Virtual_05:
        mov     x1, 0114h                                                           
        mov     x2, 0138h                                                            
        mov     y1, 0082h                                                                   
        mov     y2, 0094h                                                                  
        mov     numAux, 3                                                        
        call    VerificaBotao                                                      
        cmp     numAux, '?'                                                            
        je     	Espera_Teclado_Virtual_06                                         
        ret
		
		Espera_Teclado_Virtual_06:
        mov     x1, 0144h                                                                     
        mov     x2, 0168h                                                                 
        mov     y1, 0082h                                                                
        mov     y2, 0094h                                                                 
        mov     numAux, 4                                                          
        call    VerificaBotao                                                         
        cmp     numAux, '?'                                                            
        je     	Espera_Teclado_Virtual_07                                                  
        ret

		Espera_Teclado_Virtual_07:
        mov     x1, 0084h                                                               
        mov     x2, 00a8h                                                           
        mov     y1, 009ah                                                            
        mov     y2, 00ach                                                                 
        mov     numAux, 5                                                                  
        call    VerificaBotao                                                           
        cmp     numAux, '?'                                                          
        je     	Espera_Teclado_Virtual_08                                                  
        ret

		Espera_Teclado_Virtual_08:
        mov     x1, 00b4h                                                                 
        mov     x2, 00d8h                                                                         
        mov     y1, 009ah                                                                  
        mov     y2, 00ach                                                               
        mov     numAux, 6                                                                       
        call    VerificaBotao                                                                    
        cmp     numAux, '?'                                                                
        je     	Espera_Teclado_Virtual_09                                             
        ret

		Espera_Teclado_Virtual_09:
        mov     x1, 00e4h                                                               
        mov     x2, 0108h                                                              
        mov     y1, 009ah                                                            
        mov     y2, 00ach                                                               
        mov     numAux, 7                                                               
        call    VerificaBotao                                                           
        cmp     numAux, '?'                                                                 
        je     	Espera_Teclado_Virtual_10                                                     
        ret

		Espera_Teclado_Virtual_10:
        mov     x1, 0114h                                                                     
        mov     x2, 0138h                                                                   
        mov     y1, 009ah                                                                  
        mov     y2, 00ach                                                                      
        mov     numAux, 8                                                                    
        call    VerificaBotao                                                                 
        cmp     numAux, '?'                                                                    
        je     	Espera_Teclado_Virtual_11                                                       
        ret

		Espera_Teclado_Virtual_11:
        mov     x1, 0144h                                                                   
        mov     x2, 0168h                                                                     
        mov     y1, 009ah                                                                       
        mov     y2, 00ach                                                                      
        mov     numAux, 9                                                                       
        call    VerificaBotao                                                                
        cmp     numAux, '?'                                                               
        je     	Espera_Teclado_Virtual_12                                                
        ret

		Espera_Teclado_Virtual_12:
        mov     x1, 0054h                                                               
        mov     x2, 0078h                                                                        
        mov     y1, 0082h                                                               
        mov     y2, 0094h                                                         
        mov     numAux, 10                                                           
        call    VerificaBotao                                                                
        cmp     numAux, '?'                                                             
        je     	Espera_Teclado_Virtual_13                                           
        ret

		Espera_Teclado_Virtual_13:
        mov     x1, 0054h                                                                       
        mov     x2, 0078h                                                          
        mov     y1, 009ah                                                              
        mov     y2, 00ach                                                          
        mov     numAux, 11                                                  
        call    VerificaBotao                                                        
        cmp     numAux, '?'                                                    
        je     	Espera_Teclado_Virtual_14                                      
        ret

		Espera_Teclado_Virtual_14:
        mov     x1, 0174h                                                            
        mov     x2, 0214h                                                            
        mov     y1, 0082h                                                           
        mov     y2, 0094h                                                             
        mov     numAux, 12                                                             
        call    VerificaBotao                                                         
        cmp     numAux, '?'                                                                
        je     	Espera_Teclado_Virtual_15                                                
        ret

		Espera_Teclado_Virtual_15:
        mov     x1, 0174h                                                                    
        mov     x2, 0214h                                                                
        mov     y1, 009ah                                                               
        mov     y2, 00ach                                                                   
        mov     numAux, 13                                                           
        call    VerificaBotao                                                           
        ret
                                     
    EsperaTecladoVirtual endp    

    VerificaBotao proc near

        cmp     cx, x1                                                               
        jb      VerificaBotao_01                                                 
        cmp     cx, x2                                                                
        jg      VerificaBotao_01                                                             
        cmp     dx, y1                                                                 
        jb      VerificaBotao_01                                                  
        cmp     dx, y2                                                              
        jg      VerificaBotao_01                                               

        ret

        VerificaBotao_01:
        mov     numAux, '?'                                                                         
        ret
            
    VerificaBotao endp    

    MostraTeclado proc near

		mov     ah, 02h                                                                           
        mov     bh, 00h                                                                       
        mov     dh, 14                                                                     
        mov     dl, 6                                                                 
        int     10h                                                                      
        mov     ah, 09h                                                                    
        lea     dx, strTecVirTitulo                                                     
        int     21h                                                                      

        mov     cx, 6                                                                           
        mov     auxInicial_X, 42                                                             
        mov     auxInicial_Y, 130                                                              
        mov     auxCompr_X, 18                                                                   
        mov     auxCompr_Y, 18                                                               
        Desenha_Teclado_Nums_01:
        push    cx                                                                                   
        call    DesenhaBotao                                                                
        pop     cx                                                                              
        add     auxInicial_X, 24                                                            
        loop    Desenha_Teclado_Nums_01                                                        

        mov     cx, 6                                                                               
        mov     auxInicial_X, 42                                                               
        add     auxInicial_Y, 24                                                             
        Desenha_Teclado_Nums_02:
        push    cx                                                                             
        call    DesenhaBotao                                                                
        pop     cx                                                                             
        add     auxInicial_X, 24                                                                  
        loop    Desenha_Teclado_Nums_02                                                     

        mov     auxInicial_Y, 130                                                          
        mov     auxCompr_X, 80                                                               
        call    DesenhaBotao                                                              
        add     auxInicial_Y, 24                                                              
        call    DesenhaBotao                                                                

        mov     index, 0                                                           
        Limpa_Array_Numeros:                                                                        
        mov     si, offset numAleat                                                  
        add     si, index                                                          
        mov     al, ' '                                                                    
        mov     [si], al                                                                
        inc     index                                                                       
        inc     index                                                                          
        cmp     index, 20                                                                     
        jne     Limpa_Array_Numeros                                                   
        mov     index, 0                                                                   

        call    GeraNumerosAleatorios                                                      

        mov     ah, 02h                                                        
        mov     bh, 00h                                                     
        mov     dh, 17                                                         
        mov     dl, 6                                                                
        int     10h                                                                
        mov     dl, '-'                                                                
        int     21h                                                                         
        mov     dh, 20                                                                  
        mov     dl, 6                                                                        
        int     10h                                                                      
        mov     dl, ','                                                               
        int     21h                                                                       
        mov     ah, 02h                                                                      
        mov     dh, 17                                                              
        mov     dl, 24                                                                 
        int     10h                                                                
        mov     ah, 09h                                                                       
        lea     dx, strBackspace                                              
        int     21h                                                             
        mov     ah, 02h                                                     
        mov     dh, 20                                                      
        mov     dl, 24                                                          
        int     10h                                                                      
        mov     ah, 09h                                                                
        lea     dx, strEnter                                                
        int     21h                                                                     

        mov     ah, 02h                                                                      
        mov     bh, 00h                                                              
        mov     dh, 17                                                                  
        mov     dl, 9                                                             
        int     10h                                                        
        mov     si, offset numAleat                                            
        mov     dx, [si]                                                                       
        add     dl, 30h                                                                  
        int     21h                                                                          
        
        mov     dh, 17                                                            
        mov     dl, 12                                                           
        int     10h                                                             
        inc     si                                                                   
        inc     si                                                                       
        mov     dx, [si]                                                                   
        add     dl, 30h                                                                  
        int     21h                                                             
        
        mov     dh, 17                                                                  
        mov     dl, 15                                                                
        int     10h                                                                   
        inc     si                                                              
        inc     si                                                               
        mov     dx, [si]                                                    
        add     dl, 30h                                                         
        int     21h                                                                  
        
        mov     dh, 17                                              
        mov     dl, 18                                                        
        int     10h                                                 
        inc     si                                                
        inc     si                                          
        mov     dx, [si]                                      
        add     dl, 30h                                                 
        int     21h                                                
        
        mov     dh, 17                                                       
        mov     dl, 21                                                        
        int     10h                                                           
        inc     si                                                               
        inc     si                                                              
        mov     dx, [si]                                                         
        add     dl, 30h                                                         
        int     21h                                                                     
        
        mov     dh, 20                                                               
        mov     dl, 9                                                               
        int     10h                                                                  
        inc     si                                                     
        inc     si                                                 
        mov     dx, [si]                                                      
        add     dl, 30h                                              
        int     21h                                                       
        
        mov     dh, 20                                                     
        mov     dl, 12                                                
        int     10h                                                               
        inc     si                                                     
        inc     si                                                        
        mov     dx, [si]                                                              
        add     dl, 30h                                                               
        int     21h                                                             
        
        mov     dh, 20                                                    
        mov     dl, 15                                                 
        int     10h                                                               
        inc     si                                                            
        inc     si                                                             
        mov     dx, [si]                                                          
        add     dl, 30h                                                         
        int     21h                                                                 
        
        mov     dh, 20                                                           
        mov     dl, 18                                                                 
        int     10h                                                                    
        inc     si                                                                     
        inc     si                                                                 
        mov     dx, [si]                                                        
        add     dl, 30h                                                                   
        int     21h                                                                          
        
        mov     dh, 20                                                               
        mov     dl, 21                                                                
        int     10h                                                                       
        inc     si                                                                    
        inc     si                                                                 
        mov     dx, [si]                                                               
        add     dl, 30h                                                              
        int     21h                                                                        
        
        ret
        
    MostraTeclado endp    

    GeraNumerosAleatorios proc near
        
        mov     numAux, 0                                                            
 
        Gera_Numeros_Aleatorios_01:
		mov     cx, 04h                                                           
        mov     dx, 032h	                                                               
        mov     ah, 86h                                                                      
        int     15h                                                                   
		mov     ax, 00h                                                                 
        int     1ah                                                             
        mov     ax, dx                                                    
        mov     dx, 0                                                       
        mov     bx, 10                                                       
        div     bx                                                                   

        mov     cx, 0                                                                             
        Gera_Numeros_Aleatorios_02:
        mov     si, offset numAleat                                                        
        add     si, cx                                                                     
        mov     bx, [si]                                                                         
        cmp     bx, dx                                                                      
        je      Gera_Numeros_Aleatorios_01                                                
        cmp     bx, ' '                                                                         
        je      Gera_Numeros_Aleatorios_03                                                 
        inc     cx                                                                      
        inc     cx                                                                       
        cmp     cx, 18                                                                       
        jg      Gera_Numeros_Aleatorios_04                                                  
        jmp     Gera_Numeros_Aleatorios_02                                              

        Gera_Numeros_Aleatorios_03:
        mov     [si], dx                                                                   
        inc     numAux                                                            
        cmp     numAux, 10                                                                 
        je      Gera_Numeros_Aleatorios_04                                            
        jmp     Gera_Numeros_Aleatorios_02                                            
        
        Gera_Numeros_Aleatorios_04:
        ret
            
    GeraNumerosAleatorios endp     

    AlternarSinal proc near

        cmp     flagSinal, 0                                                             
        je      Alternar_Sinal_01                                                  
        cmp     flagSinal, 1                                                      
        je      Alternar_Sinal_02                                         

        Alternar_Sinal_01:
        mov     flagSinal, 1                                                      
        mov     ah, 02h                                                           
        mov     bh, 00h                                                            
        mov     dl, 21 																			
		int     10h                                                                   
        mov     dl, '-'                                                           
        int     21h                                                                   
        
        ret

        Alternar_Sinal_02:
        mov     flagSinal, 0                                                          
        mov     ah, 02h                                                                        
        mov     bh, 00h                                                                
		mov     dl, 21 																
		int     10h                                                                  
		mov     dl, ' '                                                                      
        int     21h                                                                        
        
        ret
        
    AlternarSinal endp      

    Delay proc near
        
        mov     cx, 04h                                                           
        mov     dx, 0a120h                                                                   
        mov     ah, 86h                                                               
        int     15h                                                                 
        
        ret
        
    Delay endp    

    ResetVariaveis proc near

        mov     index, 0														
        R_V_Dividendo:
        mov     si, offset dividendo											
        add     si, index																
        mov     bl, space													
        mov     [si], bl														
        inc     index																
        cmp     index, 9												
        jne     R_V_Dividendo														
        
		mov		index, 0																		
		R_V_Radicando:
		mov		si, offset radicando														
		add		si, index																
		mov		bl, space																
		mov		[si], bl																	
		inc		index																
		cmp		index, 9																	
		jne		R_V_Radicando																	

		mov		index, 0																	
		R_V_Radicando_Pares:
		mov		si, offset radicandoPares											
		add		si, index																
		mov		bl, 100																
		mov		[si], bl														
		inc		index																
		cmp		index, 9															
		jne		R_V_Radicando_Pares															

        mov     divisor, 0																		

        mov     resto, 0																		

        mov     index, 0																	
        R_V_Quociente:
        mov     si, offset quociente												
        add     si, index															
        mov     bl, space																
        mov     [si], bl																	
        inc     index																
        cmp     index, 9															
        jne     R_V_Quociente														

        mov     raiz, 0																			
 
        mov     ho, 0                                                                     
        
		mov		flagSinal, 0
		
        ret
            
    ResetVariaveis endp    

    AbrirFicheiro proc near

        mov     al, 02h																			
        mov     ah, 3dh																	
        lea     dx, nomeFicheiro														
        int     21h																	
        mov     handle, ax														
        
        ret
        
    AbrirFicheiro endp

    FecharFicheiro proc near
    
        mov     ah, 3eh																		
        mov     bx, handle																
        int     21h																			
        
        ret
        
    FecharFicheiro endp

    EscreverFicheiro proc near
        
        call    AbrirFicheiro																

        mov     bufferEscrita_I, 0														
        mov     si, offset bufferEscrita												
        mov     al, flagOperacao														
        add     al, 30h																	
        mov     [si], al																
        inc     si																		
        mov     al, space														
        mov     [si], al																	
        inc     si																		
        mov     al, flagSinal															
        add     al, 30h																	
        mov     [si], al														
        inc     si																	
        mov     al, space																
        mov     [si], al																	
        inc     si																				
        
		cmp		flagOperacao, 1																	
		je		Escrever_Ficheiro_01														

        mov     index, 0															
        E_F_1:
        mov     bx, offset dividendo														
        add     bx, index																
        mov     ax, [bx]																	
        add     al, 30h																	
        cmp     al, 'P'																		
        je      E_F_2																	
        mov     [si], al																
        inc     si																		
        inc     index																	
        cmp     index, 10																			
        jb      E_F_1																		
        E_F_2:
        mov     al, space																	
        mov     [si], al																		
        inc     si																			

        mov     ax, divisor																
        
        push    dx																			
        push    cx																			
        push    bx																			
        
        xor     cx, cx																		
        mov     bx, 10																	
        
        E_F_3:
        xor     dx, dx																		
        div     bx																			
        push    dx																	
        inc     cx																		
        or      ax, ax																			
        jnz     E_F_3																		
        
        E_F_4:
        pop     dx																		
        add     dl, 30h																
        mov     [si], dl																
        inc     si																	
        loop    E_F_4
        
        pop     bx																
        pop     cx																		
        pop     dx																			
  
        mov     al, space																	
        mov     [si], al																
        inc     si																			
        
        mov     index, 0																
        E_F_5:
        mov     bx, offset quociente												
        add     bx, index													
        mov     ax, [bx]																
        add     al, 30h																
        cmp     al, 'P'																	
        je      E_F_6																	
        mov     [si], al																	
        inc     si																			
        inc     index																	
        cmp     index, 10															
        jb      E_F_5																	
        E_F_6:
        mov     al, space																
        mov     [si], al															
        inc     si																		
        
		jmp		Escrever_Ficheiro_02

		Escrever_Ficheiro_01:
		mov		index, 0															
		Escrever_Ficheiro_04:
		mov		bx, offset radicando												
		add		bx, index														
		mov		ax, [bx]															
		add		al, 30h															
		cmp		al, 'P'																
		je		Escrever_Ficheiro_03											
		mov		[si], al															
		inc		si																
		inc		index															
		cmp		index, 0																	
		jb		Escrever_Ficheiro_04														
		Escrever_Ficheiro_03:
		mov		al, space															
		mov		[si], al																
		inc		si																			

		mov		ax, raiz															
		
		push    dx																	
        push    cx															
        push    bx																		
        
        xor     cx, cx																
        mov     bx, 10														
        
        Escrever_Ficheiro_05:
        xor     dx, dx																	
        div     bx																		
        push    dx															
        inc     cx																			
        or      ax, ax																			
        jnz     Escrever_Ficheiro_05														
        
        Escrever_Ficheiro_06:
        pop     dx																			
        add     dl, 30h																
        mov     [si], dl																
        inc     si																		
        loop    Escrever_Ficheiro_06														
        
        pop     bx																	
        pop     cx																				
        pop     dx																			
		
		mov     al, space																
        mov     [si], al															
        inc     si																	

		Escrever_Ficheiro_02:
		mov     ax, resto																
        
        push    dx																		
        push    cx																		
        push    bx																			
        
        xor     cx, cx																	
        mov     bx, 10																
        
        E_F_7:
        xor     dx, dx																	
        div     bx																		
        push    dx																			
        inc     cx																				
        or      ax, ax																		
        jnz     E_F_7																	
        
        E_F_8:
        pop     dx																			
        add     dl, 30h																			
        mov     [si], dl																		
        inc     si																			
        loop    E_F_8																	
        
        pop     bx																		
        pop     cx																		
        pop     dx																					

        mov     al, 0ah																	
        mov     [si], al																
        
        mov     ah, 40h																		
        mov     bx, handle																	
        mov     cx, 64																			
        lea     dx, bufferEscrita															
        int     21h 																		
        
        call    FecharFicheiro    															
        
        ret
        
    EscreverFicheiro endp    
    
code ends
end
