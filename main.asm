;
;	Cuando hice este codigo solo Dios y yo sabiamos como funcionaba
;	Ahora solo Dios lo sabe
;

UNIDAD equ 020h
DECENA equ 021h
CENTENA equ 022h
UMIL equ 023h
AUX1 equ 024h
AUX2 equ 025h
CONTADOR equ 026h
CONTADOR_DELAY equ 027h
N1U equ 028h
N2U equ 029h
N1D equ 030h
N2D equ 031h
AUX3 equ 033h
AUX4 equ 034h

	org 0
Config
	bsf status,5
	clrf trisa
	clrf trisb
	bsf trisb,0	; Mostrar
	bsf trisa,4	; Reset
	bsf trisa,6	; G1 (Incrementar N1)
	bsf trisa,7	; G2 (Incrementar N2)
	bcf status,5


Botones
	call mostrarDatosIngresados

	btfsc portb,0
	goto multiplicar
	btfsc porta,4
	goto resetearDatos
	btfsc porta,6
	goto IncPrimerNumero
	btfsc porta,7
	goto IncSegundoNumero
	goto Botones

ResetBotones
	btfsc portb,0
	goto ResetBotones
	btfsc porta,4
	goto ResetBotones
	btfsc porta,6
	goto ResetBotones
	btfsc porta,7
	goto ResetBotones
	goto Botones

mostrarDatosIngresados
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

resetearDatos
	clrf N1U
	clrf N2U
	clrf N1D
	clrf N2D
	goto ResetBotones

IncPrimerNumero
	movlw .9
	subwf N1U,W 
	btfsc status,c
	goto IncDecena
	incf N1U,f
	goto ResetBotones

IncDecena
	clrf N1U
	incf N1D,f
	goto ResetBotones

IncSegundoNumero
	movlw .9
	subwf N2U,W 
	btfsc status,c
	goto IncMil
	incf N2U,f
	goto ResetBotones
IncMil
	clrf N2U
	incf N2D,f
	goto ResetBotones

delay
	movlw	.255
	movwf	CONTADOR_DELAY
	decfsz	CONTADOR_DELAY, f
	goto	$-1
	return

multiplicar
	movfw N1U	; MULTIPLICACION LINEAL
	movwf CONTADOR
	incf CONTADOR,f
parte1
	decfsz CONTADOR,f
	goto parte2
	goto parte3
parte2	movfw N2U
	addwf AUX1,f
	movlw .10
	subwf AUX1,w
	btfss status,c
	goto parte1
	movwf AUX1
	incf AUX2,1
	goto parte1
parte3
	; MOVER VALORES A RESULTADOS TEMPORALES
	movfw AUX1
	movwf UNIDAD
	movfw AUX2
	movwf DECENA
	movfw N1U
	movwf CONTADOR
	; PREPARANDO MULTIPLICACION CRUZADA
	incf CONTADOR,f
	clrf AUX1
parte4
	
	decfsz CONTADOR,f
	goto parte5	; CONTINUA MULTIPLICANDO
	goto wea	; TERMINO LA MULTIPLICACION
parte5	movfw N2D
	addwf AUX1,f
	movlw .10
	subwf AUX1,w
	btfss status,c
	goto parte4
	movwf AUX1
	incf AUX2,1
	movfw AUX1
	movwf DECENA
	goto parte4





wea
	; MOVER VALORES A RESULTADOS TEMPORALES
	movfw N1D
	movwf CONTADOR
	; PREPARANDO MULTIPLICACION CRUZADA
	incf CONTADOR,f
wea1
	decfsz CONTADOR,f
	goto wea2	; CONTINUA MULTIPLICANDO
	goto parte6	; TERMINO LA MULTIPLICACION
wea2	movfw N2U
	addwf AUX4,f
	movlw .10
	subwf AUX4,w
	btfss status,c
	goto wea1
	movwf AUX4
	incf AUX4,1
	goto wea1




parte6
	movfw AUX1
	addwf AUX4,w ; DECENA + AUX
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
	call corregir2
	

	movfw N1D	; MULTIPLICACION LINEAL
	movwf CONTADOR
	incf CONTADOR,f
	clrf AUX1
	clrf AUX2
parte7
	decfsz CONTADOR,f
	goto parte8
	goto parte9	; fin
parte8	movfw N2D
	addwf AUX1,f
	movlw .10
	subwf AUX1,w
	btfss status,c
	goto parte7
	movwf AUX1
	incf AUX2,1
	goto parte7
parte9
	movfw AUX1
	addwf CENTENA,f
	movfw AUX2
	addwf UMIL,f
	goto mostrado
	
	
	
corregir
	movwf DECENA
	incf CENTENA,1
	return
corregir2
	movwf CENTENA
	incf UMIL,1
	return
	

	

mostrado
	clrf AUX1
	clrf AUX2
	call mostrarDatosResultado
	btfsc porta,4
	goto ResetBotones
	goto mostrado

mostrarDatosResultado
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
	