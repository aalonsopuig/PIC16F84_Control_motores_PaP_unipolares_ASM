; Motor03
; Programa para control de motores paso a paso unipolares 
; Por: Alejandro Alonso
; Fecha: 29/12/2002
; Función: 
;
; Simplemente hace rotar el motor


	list 		p=16f84
	include	"P16F84a.INC"


	Contador	EQU	0x0C	;Contador multiuso
	Velocidad	EQU	0x0F	;Inverso de velocidad


	; Definiciones bits del registro RA

	Switch1	EQU	0	;RA0 - Switches que definen la...
	Switch2	EQU	1	;RA1 - velocidad del motor
	;Atención, RA4 en modo salida trabaja en colector abierto


	org	0
	goto	INICIO
	org	5		

	
; ---------------------------------------------------------------------------
INICIO		;Inicio del cuerpo del programa

	bsf	STATUS,RP0		;Apunta a banco 1
	movlw	b'11111111'		;Establece puerta A como ENTRADA
	movwf	TRISA			;
	movlw	b'00000000'		;Establece puerta B como SALIDA 
	movwf	TRISB			;
	movlw	b'10000011'		;Configuracion OPTION para TMR0
	movwf	OPTION_REG
	bcf	STATUS,RP0		;Apunta a banco 0

	movlw	b'00000000'		;Establece interrupciones
	movwf	INTCON		;anuladas

	clrf	PORTA



BUCLE	;Bucle principal del programa


	;Chequeamos switches para asignar velocidad
		
	btfss	PORTA,Switch1	;Vemos valor Switch1
	goto	Sw_0x			;Sw1=0
	btfss	PORTA,Switch2	;Sw1=1. Vemos valor Switch2
	goto	Sw_10			;Sw1=1, Sw2=0
	goto	Sw_11			;Sw1=1, Sw2=1
Sw_0x	btfss	PORTA,Switch2	;Sw1=0. Vemos valor Switch2
	goto	Sw_00			;Sw1=0, Sw2=0
	goto	Sw_01			;Sw1=0, Sw2=1

Sw_00	movlw	16
	goto	Sw_Ok
Sw_01	movlw	8
	goto	Sw_Ok
Sw_10	movlw	2
	goto	Sw_Ok
Sw_11	movlw	1
	goto	Sw_Ok

Sw_Ok	movwf	Velocidad		;Cargamos el valor seleccionado en Velocidad		


Ciclo	movlw	b'00001110'		; un paso del motor
	movwf	PORTB
	Movf	Velocidad,W		; valor inverso de velocidad...
	movwf	Contador		;...se carga en "contador"
	call	Retardo	
	

	movlw	b'00001011'		; un paso del motor
	movwf	PORTB
	Movf	Velocidad,W		; valor inverso de velocidad...
	movwf	Contador		;...se carga en "contador"
	call	Retardo	

	movlw	b'00001101'		; un paso del motor
	movwf	PORTB
	Movf	Velocidad,W		; valor inverso de velocidad...
	movwf	Contador		;...se carga en "contador"
	call	Retardo	

	movlw	b'00000111'		; un paso del motor
	movwf	PORTB
	Movf	Velocidad,W		; valor inverso de velocidad...
	movwf	Contador		;...se carga en "contador"
	call	Retardo	

	GOTO BUCLE




; ---------------------------------------------------------------------------
	

; Subrutinas


Retardo		;Provoca un retardo según el valor de "Contador"
Bucle1	movlw		00			;Inicializacion bucle interno
		movwf		TMR0
Bucle2	btfss		INTCON,T0IF		;¿Terminado bucle interno?
		goto		Bucle2		;No, continuar bucle interno
		bcf		INTCON,T0IF		;Si, bajar bandera
		decfsz	Contador,F		;Decrementar contador bucle externo
		goto		Bucle1		;y repetir bucle externo hasta fin
		RETURN


Fin
	END


