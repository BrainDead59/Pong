title "Proyecto"
	.model small 
	.386		
	.stack 64 	
	.data	


;==================================DATOS==================================
;============================================================================

;Definición de constantes
;Valor ASCII de caracteres para el marco del programa
marcoEsqInfIzq 		equ 200d ;'╚'
marcoEsqInfDer 		equ 188d ;'╝'
marcoEsqSupDer 		equ 187d ;'╗'
marcoEsqSupIzq 		equ 201d ;'╔'
marcoCruceVerSup 	equ 203d ;'╦'
marcoCruceHorDer 	equ 185d ;'╣'
marcoCruceVerInf 	equ 202d ;'╩'
marcoCruceHorIzq 	equ 204d ;'╠'
marcoCruce 			equ 206d ;'╬'
marcoHor 			equ 205d ;'═'
marcoVer 			equ 186d ;'║'

;Atributos de color de BIOS
;Valores de color para carácter
cNegro 			equ 00h
cAzul 			equ 01h
cVerde 			equ 02h
cCyan 			equ 03h
cRojo 			equ 04h
cMagenta 		equ 05h
cCafe 			equ 06h
cGrisClaro 		equ 07h
cGrisOscuro 	equ 08h
cAzulClaro 		equ 09h
cVerdeClaro 	equ 0Ah
cCyanClaro 		equ 0Bh
cRojoClaro 		equ 0Ch
cMagentaClaro 	equ 0Dh
cAmarillo		equ 0Eh
cBlanco 		equ 0Fh

;Valores de color para fondo de carácter
bgNegro 		equ 00h
bgAzul 			equ 10h
bgVerde 		equ 20h
bgCyan 			equ 30h
bgRojo 			equ 40h
bgMagenta 		equ 50h
bgCafe 			equ 60h
bgGrisClaro 	equ 70h
bgGrisOscuro	equ 80h
bgAzulClaro 	equ 90h
bgVerdeClaro 	equ 0A0h
bgCyanClaro 	equ 0B0h
bgRojoClaro 	equ 0C0h
bgMagentaClaro 	equ 0D0h
bgAmarillo 		equ 0E0h
bgBlanco 		equ 0F0h

;Definicion de variables
titulo 			db "PONJ"
player1 		db "Player 1"
player2 		db "Player 2","$"
tiempo_cadena 	db "0:00"
tiempo_s 		db 0
p1_score 		db 0
p2_score 		db 0
;variables para guardar la posición del player 1
p1_col 	db 6
p1_ren 	db 14
;variables para guardar la posición del player 2
p2_col 	db 73
p2_ren 	db 14
;variables para guardar una posición auxiliar
;sirven como variables globales para algunos procedimientos
col_aux db 0
ren_aux db 0
;variable que se utiliza como valor 10 auxiliar en divisiones
diez 	dw 10
;Una variable contador para algunos loops
conta 	db 0
;Variables que sirven de parametros para el procedimiento IMPRIME_BOTON
boton_caracter	db 0
boton_renglon 	db 0
boton_columna 	db 0
boton_color 	db 0
boton_bg_color 	db 0
;Auxiliar para calculo de coordenadas del mouse
ocho db 8
;Cuando el driver del mouse no esta disponible
no_mouse db "No se encuentra driver de mouse"
Presione db "[enter] para salir","$"


; Variables CRONOMETRO
t_inicial		dw 		0,0		;guarda números de ticks inicial
tick_ms			dw 		55 		;55 ms por cada tick del sistema, esta variable se usa para operación de MUL convertir ticks a segundos
mil				dw		1000 	;dato de valor decimal 1000 para operación DIV entre 1000
cien 			db 		100 	;dato de valor decimal 100 para operación DIV entre 100
sesenta 		db 		60		;dato de valor decimal 60 para operación DIV entre 60
contador 		dw		0		;variable contador
milisegundos	dw		0		;variable para guardar la cantidad de milisegundos
segundos		db		0 		;variable para guardar la cantidad de segundos
minutos 		db		0		;variable para guardar la cantidad de minutos
max_time_min        db      1
max_time_sec        db      0 


ren_bola	db	0
col_bola	db	0
dir_hor 	db  0
dir_ver 	db 	0
mil_aux		dw	0

p1_win 		db 	"PLAYER 1 WIN$"
p2_win 		db "PLAYER 2 WIN$"
empate 		db "EMPATE$"
ganador 	db 0

;================================== MACROS ==================================
;============================================================================
clear macro
	mov ax,0003h ;ah = 00h, selecciona modo video
	;al = 03h. Modo texto, 16 colores
	int 10h ;llama interrupcion 10h con opcion 00h.
	;Establece modo de video limpiando pantalla
endm
;NOTA
;Parace ser que es durante el prigrama, veremos como funciona 
posiciona_cursor macro renglon,columna
	mov dh,renglon ;dh = renglon
	mov dl,columna ;dl = columna
	mov bx,0
	mov ax,0200h ;preparar ax para interrupcion, opcion 02h
	int 10h ;interrupcion 10h y opcion 02h. Cambia posicion del cursor
endm

muestra_cursor_mouse macro
	mov ax,1 ;opcion 0001h
	int 33h ;int 33h para manejo del mouse. Opcion AX=0001h
	;Habilita la visibilidad del cursor del mouse en el programa
endm

oculta_cursor_teclado macro
	mov ah,01h ;Opcion 01h
	mov cx,2607h ;Parametro necesario para ocultar cursor
	int 10h ;int 10, opcion 01h. Cambia la visibilidad del cursor del teclado
endm

apaga_cursor_parpadeo macro
	mov ax,1003h ;Opcion 1003h
	xor bl,bl ;BL = 0, parámetro para int 10h opción 1003h
	int 10h ;int 10, opcion 01h. Cambia la visibilidad del cursor del teclado
endm

imprime_caracter_color macro caracter,color,bg_color
	mov ah,09h ;preparar AH para interrupcion, opcion 09h QUIEN SABE PORQUE PERO LO ESCRIBE ASI 
	;PORQUE SON REGISROS DIFERENTES NO ES LO MISMO 0090H PARA AX QUE 09H PARA AH
	mov al,caracter ;AL = caracter a imprimir
	mov bh,0 ;BH = numero de pagina
	mov bl,color
	or bl,bg_color ;BL = color del caracter
	;'color' define los 4 bits menos significativos
	;'bg_color' define los 4 bits más significativos
	mov cx,1 ;CX = numero de veces que se imprime el caracter
	;CX es un argumento necesario para opcion 09h de int 10h
	int 10h ;int 10h, AH=09h, imprime el caracter en AL con el color BL
endm

inicializa_ds_es macro
	mov ax,@data
	mov ds,ax
	mov es,ax ;Este registro se va a usar, junto con BP, para imprimir cadenas utilizando interrupción 10h
endm

imprime_cadena_color macro cadena,long_cadena,color,bg_color
	mov ah,13h ;preparar AH para interrupcion, opcion 13h
	lea bp,cadena ;BP como apuntador a la cadena a imprimir
	mov bh,0 ;BH = numero de pagina
	mov bl,color
	or bl,bg_color ;BL = color del caracter
	;'color' define los 4 bits menos significativos 
	;'bg_color' define los 4 bits más significativos
	mov cx,long_cadena ;CX = longitud de la cadena,se tomarán este número de localidades a partir del apuntador a la cadena
	int 10h ;int 10h, AH=09h, imprime el caracter en AL con el color BL
endm
;lee_mouse - Revisa el estado del mouse
;Devuelve:
;;BX - estado de los botones
;;;Si BX = 0000h, ningun boton presionado
;;;Si BX = 0001h, boton izquierdo presionado
;;;Si BX = 0002h, boton derecho presionado
;;;Si BX = 0003h, boton izquierdo y derecho presionados
; (400,120) => 80x25 =>Columna: 400 x 80 / 640 = 50; Renglon: (120 x25 / 200) = 15 => 50,15
;;CX - columna en la que se encuentra el mouse en resolucion 640x200 (columnas x renglones)
;;DX - renglon en el que se encuentra el mouse en resolucion 640x200 (columnas x renglones)
lee_mouse macro
	mov ax,0003h
	int 33h
endm

;comprueba_mouse - Revisa si el driver del mouse existe
comprueba_mouse macro	
	mov ax,0 ;opcion 0
	int 33h ;llama interrupcion 33h para manejo del mouse, devuelve un valor en AX
	;Si AX = 0000h, no existe eldriver. Si AX = FFFFh, existe driver
endm

;Cuando se tienen decimas en el marcador se limpia el valor de las unidades
limpia_marcador macro 
	posiciona_cursor 2,5
	imprime_caracter_color dl,cNegro,bgNegro
	posiciona_cursor 2,77
	imprime_caracter_color dl,cNegro,bgNegro
endm 





;================================== CODIGO ==================================
;============================================================================

	.code
inicio: 
	inicializa_ds_es
	comprueba_mouse ;macro para revisar driver de mouse
	xor ax,0FFFFh ;compara el valor de AX con FFFFh, si el resultado es zero, entonces existe el driver de mouse
	jz imprime_ui ;Si existe el driver del mouse, entonces salta a 'imprime_ui'
	
	;Si no existe el driver del mouse entonces se muestra un mensaje
	lea dx,[no_mouse]
	mov ax,0900h ;opcion 9 para interrupcion 21h
	int 21h ;interrupcion 21h. Imprime cadena.
	jmp teclado ;salta a 'teclado'

	imprime_ui:
		clear ;limpia pantalla
		oculta_cursor_teclado ;oculta cursor del mouse
		apaga_cursor_parpadeo ;Deshabilita parpadeo del cursor
		call DIBUJA_UI ;procedimiento que dibuja marco de la interfaz
		muestra_cursor_mouse ;hace visible el cursor del mouse
		;Revisar que el boton izquierdo del mouse no esté presionado
		;Si el botón no está suelto, no continúa


	;Lee el mouse y avanza hasta que se haga clic en el boton izquierdo
	mouse_start:
		lee_mouse
		test bx, 0001h ;Para revisar si el boton izquierdo del mouse fue presionado
		jz mouse_start ;Si el boton izquierdo no fue presionado, vuelve a leer el estado del mouse
		
		;Leer la posicion del mouse y hacer la conversion a resolucion
		;80x25 (columnas x renglones) en modo texto
		mov ax,dx ;Copia DX en AX. DX es un valor entre 0 y 199 (renglon)
		div [ocho] ;Division de 8 bits
		;divide el valor del renglon en resolucion 640x200 en donde se encuentra el mouse
		;para obtener el valor correspondiente en resolucion 80x25
		xor ah,ah ;Descartar el residuo de la division anterior
		mov dx,ax ;Copia AX en DX. AX es un valor entre 0 y 24 (renglon)
		mov ax,cx ;Copia CX en AX. CX es un valor entre 0 y 639 (columna)
		div [ocho] ;Division de 8 bits
		;divide el valor de la columna en resolucion 640x200 en donde se encuentra el mouse
		;para obtener el valor correspondiente en resolucion 80x25
		xor ah,ah ;Descartar el residuo de la division anterior
		mov cx,ax ;Copia AX en CX. AX es un valor entre 0 y 79 (columna)


		;dx - renglones
		;cx - columnas 

		;Si el mouse fue presionado en el renglon 0
		;se va a revisar si fue dentro del boton [X]
		cmp dx,0
		je boton_x


		;jb Menor que 
		;ja mayor que
		;jae Mayor o igual que  
		;jbe Menor o igual que 

		cmp dx, 1
		jae validar_renglon
		;jmp validar2

		; boton stop - renglon (1, 3), columna (34, 36)
		; boton start - renglon (1, 3), columna (43, 45)

		
		; comprueba si se dio clic en el renglon 3 o antes
		validar_renglon:
			cmp dx,3
			jbe validar_columna_izq
			jmp mouse_start
		validar_columna_izq:
			cmp cx, 43d
			jae validar_columna_der
			jmp mouse_start

		validar_columna_der:
			cmp cx, 45d
			jbe boton_start
			jmp mouse_start

	;Lógica para revisar si el mouse fue presionado en [X]
	;[X] se encuentra en renglon 0 y entre columnas 76 y 78
	boton_x:
		cmp cx,76
		jge boton_x2
		jmp mouse_start
	boton_x2:
		cmp cx,78
		jbe boton_x3
		jmp mouse_start
	boton_x3:
		;Se cumplieron todas las condiciones
		jmp salir

	boton_start:

		call LIMPIA_GANADOR ;Limpia la cadena del jugador que gano si ya se jugo

		;Inicializacion de datos del juego (direccion y velocidad)
		mov [dir_hor], 1d
		mov [dir_ver], -1d
		mov [mil_aux], 0
		
		;Lee el valor del contador de ticks y lo guarda en variable t_inicial
		mov ah, 00h
		int 1Ah
		mov [t_inicial],dx
		mov [t_inicial + 2],cx

		loopstart:

			call BARRAS			;Comprueba si hay movimiento de los jugadores
			call MOV_BOLA		;Mueve la bola acorde a las condiciones
			call CRONO			

			;ve si el tiempo del cronometro se acabo
			cmp [max_time_sec], 0
			jne mouse_in_game 
			cmp [max_time_min], 0
			jne mouse_in_game 
			
			call IMPRIME_GANADOR	
			call BOLA_ORIGEN
			limpia_marcador
			call DIBUJA_UI

			; si se acabo el tiempo se regresa al inicio para volver a comenzar el juego o salir
			jmp mouse_start

			;Lee el mouse y avanza hasta que se haga clic en el boton izquierdo
			mouse_in_game:
				lee_mouse
				test bx, 0001h ;Para revisar si el boton izquierdo del mouse fue presionado
				jz mouse_in_game_salida ;Si el boton izquierdo no fue presionado, continua con el juego

				;Leer la posicion del mouse y hacer la conversion a resolucion
				;80x25 (columnas x renglones) en modo texto
				mov ax,dx ;Copia DX en AX. DX es un valor entre 0 y 199 (renglon)
				div [ocho] ;Division de 8 bits
				;divide el valor del renglon en resolucion 640x200 en donde se encuentra el mouse
				;para obtener el valor correspondiente en resolucion 80x25
				xor ah,ah ;Descartar el residuo de la division anterior
				mov dx,ax ;Copia AX en DX. AX es un valor entre 0 y 24 (renglon)
				mov ax,cx ;Copia CX en AX. CX es un valor entre 0 y 639 (columna)
				div [ocho] ;Division de 8 bits
				;divide el valor de la columna en resolucion 640x200 en donde se encuentra el mouse
				;para obtener el valor correspondiente en resolucion 80x25
				xor ah,ah ;Descartar el residuo de la division anterior
				mov cx,ax ;Copia AX en CX. AX es un valor entre 0 y 79 (columna)


				;dx - renglones
				;cx - columnas 

				;Si el mouse fue presionado en el renglon 0
				;se va a revisar si fue dentro del boton [X]
				cmp dx,0
				je boton_x_in_game

				cmp dx, 1
				jae validar_renglon_stop
				;jmp validar2

				; boton stop - renglon (1, 3), columna (34, 36)
				; boton start - renglon (1, 3), columna (43, 45)

				validar_renglon_stop:
					cmp dx, 3
					jbe validar_columna_izq_stop
					jmp mouse_in_game_salida
				validar_columna_izq_stop:
					cmp cx, 34d
					jae validar_columna_der_stop
					jmp mouse_in_game_salida

				validar_columna_der_stop:
					cmp cx, 36d
					jbe boton_stop
					jmp mouse_in_game_salida

			boton_stop:
				call IMPRIME_GANADOR
				call BOLA_ORIGEN
				limpia_marcador
				call DIBUJA_UI
				jmp mouse_start

			boton_x_in_game:
				cmp cx,76
				jge boton_x2_in_game
				jmp mouse_in_game_salida
				
			boton_x2_in_game:
				cmp cx,78
				jbe boton_x3_in_game
				jmp mouse_in_game_salida
			boton_x3_in_game:
				;Se cumplieron todas las condiciones
				jmp salir

			mouse_in_game_salida:
				mov [max_time_min], 1
				mov [max_time_sec], 0

		jmp loopstart 

	;Si no se encontró el driver del mouse, muestra un mensaje y el usuario debe salir tecleando [enter]
	teclado:
		mov ah,08h
		int 21h
		cmp al,0Dh ;compara la entrada de teclado si fue [enter]
		jnz teclado ;Sale del ciclo hasta que presiona la tecla [enter]


salir: ;inicia etiqueta salir
	clear ;limpia pantalla
	mov ax,4C00h ;AH = 4Ch, opción para terminar programa, AL = 0 Exit Code, código devuelto al finalizar el programa
	int 21h ;señal 21h de interrupción, pasa el control al sistema operativo

;==================================PROCEDIMIENTOS==================================
;==================================================================================

DIBUJA_UI proc
	;imprimir esquina superior izquierda del marco
	posiciona_cursor 0,0
	imprime_caracter_color marcoEsqSupIzq,cAmarillo,bgNegro
	;imprimir esquina superior derecha del marco
	posiciona_cursor 0,79
	imprime_caracter_color marcoEsqSupDer,cAmarillo,bgNegro
	;imprimir esquina inferior izquierda del marco
	posiciona_cursor 24,0
	imprime_caracter_color marcoEsqInfIzq,cAmarillo,bgNegro
	;imprimir esquina inferior derecha del marco
	posiciona_cursor 24,79
	imprime_caracter_color marcoEsqInfDer,cAmarillo,bgNegro
	;imprimir marcos horizontales, superior e inferior
	mov cx,78 ;CX = 004Eh => CH = 00h, CL = 4Eh
	marcos_horizontales:
		mov [col_aux],cl
		;Superior
		posiciona_cursor 0,[col_aux]
		imprime_caracter_color marcoHor,cAmarillo,bgNegro
		;Inferior
		posiciona_cursor 24,[col_aux]
		imprime_caracter_color marcoHor,cAmarillo,bgNegro
		;Limite mouse
		posiciona_cursor 4,[col_aux]
		imprime_caracter_color marcoHor,cAmarillo,bgNegro
		mov cl,[col_aux]
		loop marcos_horizontales
		;imprimir marcos verticales, derecho e izquierdo
		mov cx,23 ;CX = 0017h => CH = 00h, CL = 17h
	marcos_verticales:
		mov [ren_aux],cl
		;Izquierdo
		posiciona_cursor [ren_aux],0
		imprime_caracter_color marcoVer,cAmarillo,bgNegro
		;Inferior
		posiciona_cursor [ren_aux],79
		imprime_caracter_color marcoVer,cAmarillo,bgNegro
		mov cl,[ren_aux]
		loop marcos_verticales
		;imprimir marcos verticales internos
		mov cx,3 ;CX = 0003h => CH = 00h, CL = 03h
	marcos_verticales_internos:
		mov [ren_aux],cl
		;Interno izquierdo (marcador player 1)
		posiciona_cursor [ren_aux],7
		imprime_caracter_color marcoVer,cAmarillo,bgNegro
		;Interno derecho (marcador player 2)
		posiciona_cursor [ren_aux],72
		imprime_caracter_color marcoVer,cAmarillo,bgNegro
		jmp marcos_verticales_internos_aux1

	marcos_verticales_internos_aux2:
		jmp marcos_verticales_internos

	marcos_verticales_internos_aux1:
		;Interno central izquierdo (Timer)
		posiciona_cursor [ren_aux],32
		imprime_caracter_color marcoVer,cAmarillo,bgNegro
	
		;Interno central derecho (Timer)
		posiciona_cursor [ren_aux],47
		imprime_caracter_color marcoVer,cAmarillo,bgNegro
		mov cl,[ren_aux]
		loop marcos_verticales_internos_aux2
	
	;imprime intersecciones internas
	posiciona_cursor 0,7
	imprime_caracter_color marcoCruceVerSup,cAmarillo,bgNegro
	posiciona_cursor 4,7
	imprime_caracter_color marcoCruceVerInf,cAmarillo,bgNegro
	posiciona_cursor 0,32
	imprime_caracter_color marcoCruceVerSup,cAmarillo,bgNegro
	posiciona_cursor 4,32
	imprime_caracter_color marcoCruceVerInf,cAmarillo,bgNegro
	posiciona_cursor 0,47
	imprime_caracter_color marcoCruceVerSup,cAmarillo,bgNegro
	posiciona_cursor 4,47
	imprime_caracter_color marcoCruceVerInf,cAmarillo,bgNegro
	posiciona_cursor 0,72
	imprime_caracter_color marcoCruceVerSup,cAmarillo,bgNegro
	posiciona_cursor 4,72
	imprime_caracter_color marcoCruceVerInf,cAmarillo,bgNegro
	posiciona_cursor 4,0
	imprime_caracter_color marcoCruceHorIzq,cAmarillo,bgNegro
	posiciona_cursor 4,79
	imprime_caracter_color marcoCruceHorDer,cAmarillo,bgNegro
	
	;imprimir [X] para cerrar programa
	posiciona_cursor 0,76
	imprime_caracter_color '[',cAmarillo,bgNegro
	posiciona_cursor 0,77
	imprime_caracter_color 'X',cRojoClaro,bgNegro
	posiciona_cursor 0,78
	imprime_caracter_color ']',cAmarillo,bgNegro
	
	;imprimir título
	posiciona_cursor 0,38
	imprime_cadena_color [titulo],4,cBlanco,bgNegro
	call IMPRIME_DATOS_INICIALES

	ret
endp

IMPRIME_DATOS_INICIALES proc
	
	;inicializa la cadena del timer
	mov [tiempo_cadena],"2"
	mov [tiempo_cadena+1],":"
	mov [tiempo_cadena+2],"0"
	mov [tiempo_cadena+3],"0"
	
	;mov [tiempo_s],120 ;inicializa el número de segundos del timer 				QUIZA NO LO USAMOOS
	mov [p1_score],0 ;inicializa el score del player 1
	mov [p2_score],0 ;inicializa el score del player 2
	
	;Imprime el score del player 1, en la posición del col_aux
	;la posición de ren_aux está fija en IMPRIME_SCORE_BL
	mov [col_aux],4
	mov bl,[p1_score]
	call IMPRIME_SCORE_BL
	
	;Imprime el score del player 2, en la posición del col_aux
	;la posición de ren_aux está fija en IMPRIME_SCORE_BL
	mov [col_aux],76
	mov bl,[p2_score]
	call IMPRIME_SCORE_BL
	
	;imprime cadena 'Player 1'
	posiciona_cursor 2,9
	imprime_cadena_color player1,8,cBlanco,bgNegro
	
	;imprime cadena 'Player 2'
	posiciona_cursor 2,63
	imprime_cadena_color player2,8,cBlanco,bgNegro
	
	;imprime cadena de Timer
	posiciona_cursor 2,38
	imprime_cadena_color tiempo_cadena,4,cBlanco,bgNegro
	;imprime players

	;player 1
	;columna: p1_col, renglón: p1_ren
	mov al,[p1_col]
	mov ah,[p1_ren]
	mov [col_aux],al
	mov [ren_aux],ah
	call IMPRIME_PLAYER
	
	;player 2
	;columna: p2_col, renglón: p2_ren
	mov al,[p2_col]
	mov ah,[p2_ren]
	mov [col_aux],al
	mov [ren_aux],ah
	call IMPRIME_PLAYER
	
	;imprime bola
	;columna: 40, renglón: 14
	mov [col_bola], 40
	mov [ren_bola], 14
	call IMPRIME_BOLA
	
	;Botón Stop
	mov [boton_caracter],254d
	mov [boton_color],bgAmarillo
	mov [boton_renglon],1d
	mov [boton_columna],34d
	call IMPRIME_BOTON
	
	;Botón Start
	mov [boton_caracter],16d
	mov [boton_color],bgAmarillo
	mov [boton_renglon],1d
	mov [boton_columna],43d
	call IMPRIME_BOTON

	ret
endp

IMPRIME_SCORE_BL proc
	xor ah,ah
	mov al,bl
	mov [conta],0
	div10:
		xor dx,dx
		div [diez]
		push dx
		inc [conta]
		cmp ax,0
		ja div10
	imprime_digito:
		posiciona_cursor 2,[col_aux]
		pop dx
		or dl,30h
		imprime_caracter_color dl,cBlanco,bgNegro
		inc [col_aux]
		dec [conta]
		cmp [conta],0
		ja imprime_digito
	ret
endp

IMPRIME_PLAYER proc
	posiciona_cursor [ren_aux],[col_aux]
	imprime_caracter_color 219d,cBlanco,bgNegro
	dec [ren_aux]
	posiciona_cursor [ren_aux],[col_aux]
	imprime_caracter_color 219d,cBlanco,bgNegro
	dec [ren_aux]
	posiciona_cursor [ren_aux],[col_aux]
	imprime_caracter_color 219d,cBlanco,bgNegro
	add [ren_aux],3
	posiciona_cursor [ren_aux],[col_aux]
	imprime_caracter_color 219d,cBlanco,bgNegro
	inc [ren_aux]
	posiciona_cursor [ren_aux],[col_aux]
	imprime_caracter_color 219d,cBlanco,bgNegro
	ret
endp

IMPRIME_BOLA proc
	posiciona_cursor [ren_bola], [col_bola]
	imprime_caracter_color 2d,cCyanClaro,bgNegro
	ret
endp

IMPRIME_BOTON proc
	;La esquina superior izquierda se define en registro CX y define el inicio del botón
	;La esquina inferior derecha se define en registro DX y define el final del botón
	;utilizando opción 06h de int 10h
	;el color del botón se define en BH
	mov ax,0600h ;AH=06h (scroll up window) AL=00h (borrar)
	mov bh,cRojo ;Caracteres en color rojo dentro del botón, los 4 bits menos significativos de BH
	xor bh,[boton_color] ;Color de fondo en los 4 bits más significativos de BH
	mov ch,[boton_renglon] ;Renglón de la esquina superior izquierda donde inicia el boton
	mov cl,[boton_columna] ;Columna de la esquina superior izquierda donde inicia el boton
	mov dh,ch ;Copia el renglón de la esquina superior izquierda donde inicia el botón
	add dh,2 ;Incrementa el valor copiado por 2, para poner el renglón final
	mov dl,cl ;Copia la columna de la esquina superior izquierda donde inicia el botón
	add dl,2 ;Incrementa el valor copiado por 2, para poner la columna final
	int 10h

	;Se recupera los valores del renglón y columna del botón
	;para posicionar el cursor en el centro e imprimir el
	;carácter en el centro del botón
	mov [col_aux],dl
	mov [ren_aux],dh
	dec [col_aux]
	dec [ren_aux]
	posiciona_cursor [ren_aux],[col_aux]
	imprime_caracter_color [boton_caracter],cRojo,[boton_color]
	ret ;Regreso de llamada a procedimiento
endp

;====================================================================
;====================================================================

BORRAR_BOLA proc
	posiciona_cursor [ren_bola], [col_bola]
	imprime_caracter_color 2d, cNegro,bgNegro
	ret
endp

MOV_BOLA proc
	mov dx, [milisegundos]
	cmp dx, [mil_aux]
	je mov_bola_salida
	mov [mil_aux], dx

	colision_player_1:

		;primero comprobamos si se encuentra en la columna
		mov al, [p1_col]
		inc al

		cmp al, [col_bola]
		jne colision_player_2

		;comprobamos si se encuentra dentro del rango de renglones que ocupa el jugador
		mov ah, [p1_ren]

		; comprueba limite inferior
		add ah, 2d
		cmp [ren_bola], ah
		ja colision_player_2

		;comprueba limite superior
		sub ah, 4d
		cmp [ren_bola], ah
		jb colision_player_2

		; cambia la direccion a la derecha
		mov [dir_hor], 1d
		jmp mover_bola

	colision_player_2:

		;primero comprobamos si se encuentra en la columna
		mov al, [p2_col]
		dec al

		cmp al, [col_bola]
		jne lim_izquierdo

		;comprobamos si se encuentra dentro del rango de renglones que ocupa el jugador
		mov ah, [p2_ren]

		; comprueba limite inferior
		add ah, 2d
		cmp [ren_bola], ah
		ja lim_izquierdo

		;comprueba limite superior
		sub ah, 4d
		cmp [ren_bola], ah
		jb lim_izquierdo

		; cambia la direccion a la izquierda
		mov [dir_hor], -1d
		jmp mover_bola

	; Comprueba si se anota un gol en el lado izquierdo
	lim_izquierdo:
		cmp [col_bola], 2d
		jae lim_derecho
		
		; cambia la direccion horizontal en direccion opuesta
		mov [dir_hor], 1d

		; aumenta el score para el jugador 2
		inc p2_score
		call SCORE_P2
		call BOLA_ORIGEN
		jmp mov_bola_salida

	; Comprueba si se anota un gol en el lado derecho
	lim_derecho:
		cmp [col_bola], 77d
		jbe lim_superior

		; cambia la direccion horizontal en direccion opuesta
		mov [dir_hor], -1d

		; aumenta el score para el jugador 1
		inc p1_score
		call SCORE_P1
		call BOLA_ORIGEN
		jmp mov_bola_salida

	;Comprueba si se toco el limite superior
	lim_superior:
		cmp [ren_bola], 6d ;[renbola] 5, 4 ,3 <= 6
		jae lim_inferior
		mov [dir_ver], 1d
		jmp mover_bola

	;Comprueba si se toco el limite inferior
	lim_inferior:
		cmp [ren_bola], 22d ;limite
		jbe mover_bola
		mov [dir_ver], -1d

	mover_bola:

		call BORRAR_BOLA

		; se obtiene la direccion (1 o -1) (derecha o izquierda)
		mov al, [dir_hor]

		add [col_bola], al
		
		; se obtiene la direccion veretical (1 o -1) (abajo o arriba)
		mov al, [dir_ver]
		add [ren_bola], al
		
		call IMPRIME_BOLA

	mov_bola_salida:

	ret
endp

BARRAS proc
	mov ah, 01h
	int 16h
	jz barras_salida

	mov ah, 00h
	int 16h

	call MOVJ1
	call MOVJ2

	barras_salida:

		ret
endp

MOVJ1 proc
	cmp al, "w"
	je arriba
	cmp al, "W"
	je arriba

	cmp al, "s"
	je abajo
	cmp al, "S"
	je abajo
	jmp movj1_salida

	arriba:
		cmp [p1_ren],7
		je movj1_salida
		mov al,[p1_col]
		mov ah,[p1_ren]
		mov [col_aux],al
		mov [ren_aux],ah
		call BORRAR_PLAYER
		dec [ p1_ren ]
		mov al,[p1_col]
		mov ah,[p1_ren]
		mov [col_aux],al
		mov [ren_aux],ah
		call IMPRIME_PLAYER
		jmp movj1_salida

	abajo:
		cmp [p1_ren],21
		je movj1_salida
		mov al,[p1_col]
		mov ah,[p1_ren]
		mov [col_aux],al
		mov [ren_aux],ah
		call BORRAR_PLAYER
		inc [ p1_ren ]
		mov al,[p1_col]
		mov ah,[p1_ren]
		mov [col_aux],al
		mov [ren_aux],ah
		call IMPRIME_PLAYER

	movj1_salida:

		ret

endp

MOVJ2 proc
	cmp al, "o"
	je arriba2
	cmp al, "O"
	je arriba2

	cmp al, "l"
	je abajo2
	cmp al, "L"
	je abajo2

	jmp movj2_salida

	arriba2:
		cmp [p2_ren],7
		je movj2_salida
		mov al,[p2_col]
		mov ah,[p2_ren]
		mov [col_aux],al
		mov [ren_aux],ah
		call BORRAR_PLAYER
		dec [ p2_ren ]
		mov al,[p2_col]
		mov ah,[p2_ren]
		mov [col_aux],al
		mov [ren_aux],ah
		call IMPRIME_PLAYER
		jmp movj2_salida

	abajo2:
		cmp [p2_ren],21
		je movj2_salida
		mov al,[p2_col]
		mov ah,[p2_ren]
		mov [col_aux],al
		mov [ren_aux],ah
		call BORRAR_PLAYER
		inc [ p2_ren ]
		mov al,[p2_col]
		mov ah,[p2_ren]
		mov [col_aux],al
		mov [ren_aux],ah
		call IMPRIME_PLAYER

	movj2_salida:
		ret
endp

BORRAR_PLAYER proc
	posiciona_cursor [ren_aux],[col_aux]
	imprime_caracter_color 219d,cNegro,bgNegro
	dec [ren_aux]
	posiciona_cursor [ren_aux],[col_aux]
	imprime_caracter_color 219d,cNegro,bgNegro
	dec [ren_aux]
	posiciona_cursor [ren_aux],[col_aux]
	imprime_caracter_color 219d,cNegro,bgNegro
	add [ren_aux],3
	posiciona_cursor [ren_aux],[col_aux]
	imprime_caracter_color 219d,cNegro,bgNegro
	inc [ren_aux]
	posiciona_cursor [ren_aux],[col_aux]
	imprime_caracter_color 219d,cNegro,bgNegro
	ret
endp

CRONO proc
    MOV AH, 0Dh
    INT 21H

	;Se vuelve a leer el contador de ticks
	;Se lee para saber cuántos ticks pasaron entre la lectura inicial y ésta
	;De esa forma, se obtiene la diferencia de ticks
	;por cada incremento en el contador de ticks, transcurrieron 55 ms
	mov ah,00h
	int 1Ah

	;Se recupera el valor de los ticks iniciales para poder hacer la diferencia entre
	;el valor inicial y el último recuperado
	mov ax,[t_inicial]		;AX = parte baja de t_inicial
	mov bx,[t_inicial+2]	;BX = parte alta de t_inicial
	
	;Se hace la resta de los valores para obtener la diferencia
	sub dx,ax  				;DX = DX - AX = t_final - t_inicial, DX guarda la parte baja del contador de ticks
	sbb cx,bx 				;CX = CX - BX - C = t_final - t_inicial - C, CX guarda la parte alta del contador de ticks y se resta el acarreo si hubo en la resta anterior

	;Se asume que el valor de CX es cronómetro
	;Significaría que la diferencia de ticks no es mayor a 65535d
	;Si la diferencia está entre 0d y 65535d, significa que hay un máximo de 65535 * 55ms =  3,604,425 milisegundos
	mov ax,dx

	;Se multiplica la diferencia de ticks por 55ms para obtener 
	;la diferencia en milisegundos
	mul [tick_ms]

	;El valor anterior se divide entre 1000 para calcular la cantidad de segundos 
	;y la cantidad de milisegundos del cronómetro (0d - 999d)
	div [mil]
	mov [milisegundos],dx
	;El valor de AX de la división anterior se divide entre 60
	;Segundos a minutos
	div [sesenta]
	;Al final de la división, AH tiene el valor de los segundos (0 -59d) 
	;y AL los minutos (>=0)
	;Nota: ambos valores están en hexadecimal
	
	;Se guardan los segundos en una variable
	mov [segundos],ah

	;Se calcula el número de minutos para el cronómetro dividiendo nuevamente entre 60
	;Esto dará el número de horas, pero en este caso se ignorará
	xor ah,ah
	div [sesenta]

	;Se guarda la cantidad de minutos en una variable
	mov [minutos],ah
    
    mov dl, [minutos]
    sub [max_time_min], dl


    mov al, [segundos]
    mov dl, 59d
    sub dl, al
    mov [max_time_sec], dl

	;A continuación, se tomarán los valores de las variables minutos, segundos y milisegundos
	;y se imprimirán en formato de cronómetro MM:SS.mmm
	;Imprime minutos
	xor ah,ah
	mov al, [max_time_min]
	aam
	or ax,3030h
	mov cl,al
	;decenas
	;mov dl,ah
	;mov ah,02h
	;int 21h
	;unidades
	;mov dl,cl
	;int 21h
	
	mov [tiempo_cadena], cl		;unidades
	mov [tiempo_cadena+1],":"

	;Imprime segundos
	xor ah,ah
	mov al,[max_time_sec]
	aam
	or ax,3030h
	mov cl,al
	;decenas
	;mov dl,ah
	;mov ah,02h
	;int 21h
	;unidades
	;mov dl,cl
	;int 21h

	mov [tiempo_cadena+2], ah
	mov [tiempo_cadena+3], cl

	posiciona_cursor 2,38
	imprime_cadena_color tiempo_cadena,4,cBlanco,bgNegro

	ret
crono endp

SCORE_P1 proc
	mov [col_aux], 4
	mov bl, [p1_score]
	call IMPRIME_SCORE_BL

	ret
endp

SCORE_P2 proc
	mov [col_aux],76
	mov bl,[p2_score]
	call IMPRIME_SCORE_BL

	ret
endp

BOLA_ORIGEN proc
	cmp [col_bola], 76d
	je borrar_rastro
	cmp [col_bola], 3d
	je borrar_rastro
	borrar_rastro:
		call BORRAR_BOLA

	mov [col_bola], 40
	mov [ren_bola], 14
	call IMPRIME_BOLA

	ret
endp

IMPRIME_GANADOR proc
	posiciona_cursor 7d, 35d 

	mov al, [p1_score]
	mov ah, [p2_score]

	cmp al, ah
	ja imprime_1
	jb imprime_2
	je imprime_empate

	imprime_1:
		imprime_cadena_color p1_win,12,cBlanco,bgAzul
		mov [ganador],1d
		jmp imprime_ganador_salir

	imprime_2:
		imprime_cadena_color p2_win,12,cBlanco,bgAzul
		mov [ganador],2d
		jmp imprime_ganador_salir

	imprime_empate:	
		imprime_cadena_color empate,6,cBlanco,bgAzul
		mov [ganador],3d

	imprime_ganador_salir:
	ret
endp

LIMPIA_GANADOR proc 

	posiciona_cursor 7d, 35d 
	cmp [ganador],1d
	je borraG1
	cmp [ganador],2d 
	je borraG2
	jmp borraG3

	borraG1:
		imprime_cadena_color p1_win,12,cNegro,bgNegro

	borraG2:
		imprime_cadena_color p2_win,12,cNegro,bgNegro

	borraG3:
		imprime_cadena_color empate,6,cNegro,bgNegro

	ret 
endp

end inicio