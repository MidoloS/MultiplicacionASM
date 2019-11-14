; Valores del display
UNIDAD equ 020h
DECENA equ 021h
CENTENA equ 022h
UMIL equ 023h

; Contadores para demoras
CONTADOR equ 026h
CONTADOR_DELAY equ 027h

; Valores a operar
N1U equ 028h
N2U equ 029h
N1D equ 030h
N2D equ 031h

; Manipulacion de datos temporales
AUX1 equ 024h
AUX2 equ 025h
AUX3 equ 032h
AUX4 equ 033h

	org 0
	bsf status,5
	clrf trisa
	clrf trisb
	bsf trisb,0	; Mostrar
	bsf trisa,4	; Reset
	bsf trisa,6	; G1 (Incrementar N1)
	bsf trisa,7	; G2 (Incrementar N2)
	bcf status,5


BOTONES
	call PANEL

    ; SELECCION DE LA OPCION
	btfsc portb,0
	goto MULTIPLICAR
	btfsc porta,4
	goto RESET
	btfsc porta,6
	goto INC_N1
	btfsc porta,7
	goto INC_N2
	goto BOTONES

COMRPOBAR_BOTONES
    ; EVITAR QUE LOS BOTONES SE MANTENGAN PRESIONADOS
	btfsc portb,0
	goto COMRPOBAR_BOTONES
	btfsc porta,4
	goto COMRPOBAR_BOTONES
	btfsc porta,6
	goto COMRPOBAR_BOTONES
	btfsc porta,7
	goto COMRPOBAR_BOTONES
	goto BOTONES

MOSTRAR DATOS
    ; Activar display's, mover informacion de variable, asignar valor de la tabla y mostrarla en puerto B.
	bsf porta,1
	movfw N1U
	call Tabla
	movwf portb
	call delay
	bcf porta,1

	bsf porta,0
	movfw N1D
	call Tabla
	movwf portb
	call delay
	bcf porta,0
	call delay

	bsf porta,2
	movfw N2U
	call Tabla
	movwf portb
	call delay
	bcf porta,2
	
	bsf porta,3
	movfw N2D
	call Tabla
	movwf portb
	call delay
	bcf porta,3
	return

RESET
	clrf N1U
	clrf N2U
	clrf N1D
	clrf N2D
    clrf UNIDAD 
    clrf DECENA
    clrf CENTENA
	goto COMRPOBAR_BOTONES

INC_N1
    ; ¿La unidad es mayor que 9?
    ; Si, incrementar 1 en decena
	movlw .9
	subwf N1U,W 
	btfsc status,c
	goto INC_DECENA
	incf N1U,f
	goto COMRPOBAR_BOTONES

INC_DECENA
	clrf N1U
	incf N1D,f
	goto COMRPOBAR_BOTONES

INC_N2
	movlw .9
	subwf N2U,W 
	btfsc status,c
	goto INC_MIL
	incf N2U,f
	goto COMRPOBAR_BOTONES

INC_MIL
	clrf N2U
	incf N2D,f
	goto COMRPOBAR_BOTONES

DELAY
    ; Demora para los displays
	movlw	.255
	movwf	CONTADOR_DELAY
	decfsz	CONTADOR_DELAY, f
	goto	$-1
	return

MULTIPLICAR
    ; Las multiplicaciones son sumas sucesivas de un mismo numero
    ; Los registros no permiten valores mayores a 255
    ; La solucion a este problema es operando de forma "individual" las partes UNIDAD, DECENA, CENTE, UNIDAD DE MIL.
    ; Las multiplicaciones implican procesos que para assembler son muy complejos de tratar.
    ; Encontre una forma de realizar multiplicaciones de forma "sencilla"
    ; 12 x 34 = 408
    ; 2x4 + 10*(1*4+3*2) + 100*(3*1) = 408
    ; El algoritmo siguiente realiza una operacion muy similar a la anterior.
	movfw N1U
	movwf CONTADOR
	incf CONTADOR,f
PARTE_1
	decfsz CONTADOR,f
	goto PARTE_2
	goto PARTE_3
PARTE_2	
    movfw N2U
	addwf AUX1,f
	movlw .10
	subwf AUX1,w
	btfss status,c
	goto parte1
	movwf AUX1
	incf AUX2,1
	goto PARTE_1
PARTE_3
	movfw AUX1
	movwf UNIDAD
	movfw AUX2
	movwf DECENA
	movfw N1U
	movwf CONTADOR
	incf CONTADOR,f
	clrf AUX1
PARTE_4
	decfsz CONTADOR,f
	goto parte5	
	goto wea	
PARTE_5	
    movfw N2D
	addwf AUX1,f
	movlw .10
	subwf AUX1,w
	btfss status,c
	goto PARTE_4
	movwf AUX1
	incf AUX2,1
	movfw AUX1
	movwf DECENA
	goto PARTE_4
PARTE_10
	movfw N1D
	movwf CONTADOR
	incf CONTADOR,f
PARTE_11
	decfsz CONTADOR,f
	goto PARTE_12
	goto PARTE_6
PARTE_12	movfw N2U
	addwf AUX4,f
	movlw .10
	subwf AUX4,w
	btfss status,c
	goto PARTE_11
	movwf AUX4
	incf AUX4,1
	goto PARTE_11
PARTE_6
	movfw AUX1
	addwf AUX4,w
	movwf DECENA
	movlw .10
	subwf DECENA,w
	btfsc status,c
	call corregir
	movfw AUX2
	addwf CENTENA,f
	movlw .10
	subwf CENTENA,w
	btfsc status,c
	call CORREGIR_2
	movfw N1D
	movwf CONTADOR
	incf CONTADOR,f
	clrf AUX1
	clrf AUX2
PARTE_7
	decfsz CONTADOR,f
	goto PARTE_8
	goto PARTE_9
PARTE_8	
    movfw N2D
	addwf AUX1,f
	movlw .10
	subwf AUX1,w
	btfss status,c
	goto PARTE_7
	movwf AUX1
	incf AUX2,1
	goto PARTE_7
PARTE_9
	movfw AUX1
	addwf CENTENA,f
	movfw AUX2
	addwf UMIL,f
	goto MOSTRADO
CORREGIR
	movwf DECENA
	incf CENTENA,1
	return
CORREGIR_2
	movwf CENTENA
	incf UMIL,1
	return

; FIN DEL ALGORITMO DE MULTIPLICACION AVANZADA
	
MOSTRADO
	clrf AUX1
	clrf AUX2
	call PANEL
	btfsc porta,4
	goto ResetBotones
	goto mostrado

PANEL
	bsf porta,1
	movfw UNIDAD
	call Tabla
	movwf portb
	call delay
	bcf porta,1

	bsf porta,0
	movfw DECENA
	call Tabla
	movwf portb
	call delay
	bcf porta,0
	call delay

	bsf porta,2
	movfw CENTENA
	call Tabla
	movwf portb
	call delay
	bcf porta,2
	
	bsf porta,3
	movfw UMIL
	call Tabla
	movwf portb
	call delay
	bcf porta,3
	return


Tabla
	addwf PCL,1
		; 01234567
	RETLW	b'01111111'	
	RETLW	b'00001101'
	RETLW	b'10110111'
	RETLW	b'10011111'
	RETLW	b'11001101'
	RETLW	b'11011011'
	RETLW	b'11111011'
	RETLW	b'00001111'
	RETLW	b'11111111'
	RETLW	b'11001111'
	end