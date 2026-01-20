;*************************************************;
;'*                                             *';
;'*    by JogaSoft                              *';
;'*    Modified by MamSoft                      *';
;'*                                             *';
;'*        VERSION OF TETRIS CALLED TOTRUS      *';
;'*                                             *';
;'*    If you want to send me $1,000,000 for    *';
;'*    this program , please inform at least    *';
;'*    two weeks earlier by TELEX               *';
;'*                          173237 MEDIC SU    *';
;'*                     (to avoid conflicts)    *';
;'*                                             *';
;*************************************************;

; Algse TOTRUSe on JUKU 8080 Assemblerisse portinud
; Märt Põder ja porditud versiooni lähtekood on
; avaldatud GPL-3 litsentsi alusel.
;
; Aluseks on võetud Mart Palmase (põhiautor,
; 1988-1990) ja Tarmo Mamersi (täiendused, 1990)
; avaldatud lähtekood:
;
; * https://martpalmas.ee/TOTRUS.ASM
;
; Tõlgendan "avaliku koodiga vabavara" nii, et
; võin täiendatud versiooni levitada GPL-3 all.
; Algversioonile võivad rakenduda muud piirangud.

; TODO
;
; * k6ik ajav6tuga seotud kysimused
;   (levelid, kiirus ja selle kasv,
;   eemaldatud TICK vajab s3ttimist,
;   PROMPTiga ja ilma kiiruse v6rdlus)
;
; * m3ngu l6pu kerimine sujuvamaks
;   (nt jagada alles summa n-iks)
;
; * edetabel
;
; * h3kkeriv3rk
;

LEFT	EQU	16
RIGHT	EQU	LEFT+11
UP	EQU	0
DOWN	EQU	24
PROLX	EQU	21h
PROLY	EQU	06h
PROLOC	EQU	PROLX*100h+PROLY
BONSH	EQU	6	; x loc
BORDR	EQU	170
FILL	EQU	0
POL	EQU	0AAh
EXL	EQU	055h
SPACE	EQU	' '
ABO	EQU	0FFh
CR	EQU	0DH
LF	EQU	0AH
ESC	EQU	27
MHIGH	EQU	25
FORTY	EQU	40
;SCOREP	EQU	6*FORTY+13

;		**** SPEED CONSTANTS

SPDS	EQU	45
SPDN	EQU	30
SPDF	EQU	12
SPDX	EQU	5

;SPDI	EQU	0Fh
SPDI	EQU	1Fh

;****************************************

;ttcon	equ	0ffcdh	;Send message to console
tto	equ	0ffd9h	;Console output
ttstat	equ	0ffc7h	;Keyboard status
ttclk	equ	0d4bbh	;Keyboard "click" sound
ttrate	equ	0d4c4h	;General key delay
ttreps	equ	0d4c5h	;Stored repeat delay
cursw	equ	0d499h	;Switch cursor on/off
ttraw	equ	0d4bfh	;Active key per BIOS
intsrv	equ	0ff89h	;Interrupt serve
sndtog	equ	0d45ch	;Sound toggle counter
linelen	equ	0d4a7h	;Char width of screen
FTH	equ	0ddh	;Numbers at font table
FTL	equ	091h	;            at DD91h
NIL	equ	FTL-10
Z	equ	020h
X	equ	ESC
Y	equ	'='
PRINT	equ	tto

PROFF	equ	06h
PRON	equ	07h

;****************************************

INT8	EQU	4*8
GRSC	EQU	0B800h
MODE	EQU	10h
HEAD	EQU	1Ah
TAIL	EQU	1Ch

TOTTXT	EQU	3*40
GAMEF	EQU	25*40
MUL40T	EQU	GAMEF

	ORG	100H
	
TET:	JMP	TET1
USPEED	DW	0
PROMPT	DB	PROFF
PROM2	DB	0H
PONS	DB	NIL	;77h
BONCNT	DB	0
BONCNT2	DB	0
PREVFIG	DB	0
VIGUR	DB	0
OVIGUR	DB	0
CURPOS	DB	0,0
OCURPOS	DB	0,0
PADAVAI	DB	0
BONUSA	DB	0
BONUSB	DW	0
SEIS	DW	0
SEIS2	DW	0
OMODE	db	0
SCOREX	db	NIL,NIL,NIL,NIL	; not used
SCOREY	db	NIL,NIL,NIL,NIL
SCORE	db	FTL	; initial zero
STATS	DB	0
TMP	DW	0D53H
SPEED	DB	01FH
CHPN	DB	0
CHTB	DW	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	DB	'_________________________',CR,LF
	DB	'            ',CR,LF
MANG	DB	'written by:           ',CR,LF
	DB	'     MART PALMAS',CR,LF
	DB	'CHANGES BY TARMO MAMERS',CR,LF,LF
	DB	'JUKU E5104 demo by:     ',CR,LF
	DB	'       M\RT P`DER / J3K',CR,LF
	DB	CR,LF
	DB	26
EROL	DB	7
BEGIN	DB	0FFH
;=======================================
BONUZ	DB	0FFH
SOUND	DB	0FFH
;=======================================
STICK	DB	0
SAPOI	DW	SAUNUL
SCNT	DB	0
AUTOBON	DB	0

NEW8:	call	INCR
	lda	SCNT
	ora	a
	jnz	decra
	CALL	SAS
	jc	allnow
	mvi	a,2
decra:	dcr	a
	sta	SCNT
allnow:	RET

SAUBOOW	DW	0D68Dh,6B47h,0A0EAh,5075h,6B47h,35A3h,3C58h,10C3h,0D69h
;	DB	40H,20H,30H,18H,20H,10H,12H,5H,4H
	DW	0E3F6h,0AAF9h,71FBh,38FEh,1AD2h,141Dh,0D69h,0A0Fh
;	DB	044H,033H,022H,011H,8H,6H,4H,3H
SAUBONW	DW	0D68Dh,0A0EAh,35A3h,2186h,0A0EAh
;	DB	40H,30H,10H,0AH,30H
SAUKUKW	DW 	71FBh,38FEh,1AD2h,141Dh
SAUBACW	DW	0D69h,0A0Fh
;	DB	022H,011H,8H,6H,4H,3H
SAUNUL	DB	0
TXHISCO	DB	'* HIGH SCORES *'
TXMEN	DB	'you...   '
FNAME	DB	'HISCORES.TOT',0
HANDLE	DW	0

spdc	db	0fh

CLRSCR	db	ESC,'L',ESC,'4',0
mod40	db	ESC,'M0',0
mod53	db	ESC,'M1',0
mod64	db	ESC,'M2',0

keybst	db	0	; saved keyboard status
curst	db	0	; saved cursor status
curkey	db	0	; current key pressed
lastkey	db	0	; last key pressed

INT8J:
OLD8	DW	0
	DW	0

TET1:
;************** MAIN ROUTINE
MNPR:	lda	ttclk
	sta	keybst
	ori	80h
	sta	ttclk
	lda	cursw
	sta	curst
	ori	8h
	sta	cursw
	lxi	h,TF
	lxi	b,GAMEF-(TF-TS)
	mvi	e,0
eramem:	mov	m,e
	inx	h
	dcx	b
	mov	a,c
	ora	a
	jnz	eramem
	mov	a,b
	ora	a
	jnz	eramem
	lxi	d,TF-1
	lxi	b,TF-TS
	lxi	h,TS+TOTTXT+TF-TS-1
txtcpy:	ldax	d
	mov	m,a
	xra	a
	stax	d
	dcx	d
	dcx	h
	dcx	b
	mov	a,c
	ora	a
	jnz	txtcpy
	mov	a,b
	ora	a
	jnz	txtcpy
	lxi	d,TS
	lxi	b,GAME+GAMEF
nnn1:	ldax	d
	cpi	'~'
	jz	aacnv
	xra	a
	stax	d
	jmp	nnn
aacnv:	mvi	a,0aah
	stax	d
nnn:	inx	d
	dcx	b
	mov	a,c
	ora	a
	jnz	nnn1
	mov	a,b
	ora	a
	jnz	nnn1
	call	PUTMOD
	lxi	b,mod40
	call	ttcon
	CALL	ERASE
	CALL	RANDS
	mvi	a,0
	sta	PREVFIG
	CALL	COPYA	;INITIAL TEXT
	lxi	d,TITLES
	call	ESCTXT
	lxi	d,NEW8
	mvi	a,8
	call	intsrv
	call	VIDCRE
	;lxi	h,SAUBOOW
	;shld	SAPOI
	;CALL	SAON
	;CALL	COPYS
LOOPC:	CALL	ttstat
	CPI	0
	JZ	LOOPC
	CALL	ERASE
	lxi	d,TEXTS
	call	ESCTXT
MANN1:	CALL	MAIN
	CPI	27
	JNZ	MANN1
	CALL	GETMOD
	lxi	b,CLRSCR
	call	ttcon
	lda	keybst
	sta	ttclk
	lda	curst
	sta	cursw
	lxi	b,BYETXT7
	call	ttcon
	lxi	d,0
	mvi	a,8
	call	intsrv
ENDGAM:	JMP	0000h
;************** END OF MAIN (TET1)

LEVTXT	DB	ESC,27h,0
	DB	X,Y,Z+  6,LEFT+1 +Z,'  Select  ',0			;12
	DB	X,Y,Z+  7,LEFT+1 +Z,'  level:  ',0			;13
;	DB	'          ',0			;14
	DB	X,Y,Z+  9,LEFT+1 +Z,'(B)eginner',0			;15
	DB	X,Y,Z+ 10,LEFT+1 +Z,'(I)nter-  ',0			;16
	DB	X,Y,Z+ 11,LEFT+1 +Z,'   mediate',0			;17
	DB	X,Y,Z+ 12,LEFT+1 +Z,'(A)dvanced',0			;18
	DB	ESC,'(',0
	DB	0,0

TXTS	DB	X,Y,Z+ 11,RIGHT+4 + Z,'Slow game',0
TXTF	DB	X,Y,Z+ 11,RIGHT+4 + Z,'Fast game',0
TXTX	DB	X,Y,Z+ 11,RIGHT+4 + Z,'Very FAST',0

TITLES	DB	X,Y,Z+ 4,17 +Z,'TOTRUS',0
	DB	X,Y,Z+ 6,13 +Z,'(c) 1988-1990',0
	DB	X,Y,Z+ 7,11 +Z,'Jogasoft & MamSoft',0
	DB	X,Y,Z+ 11,12 +Z,'Demo version for',0
	DB	X,Y,Z+ 13,15 +Z,'JUKU E5104',0
	DB	X,Y,Z+ 18,9 +Z,'<<<<< Tartu 2025 >>>>>',0
	DB	X,Y,Z+ 21,9 +Z,'Hit any key to begin...',0
	DB	0,0

TEXTS	DB	X,Y,Z+ 1,2 +Z,'GAME TOTRUS',0
	DB	X,Y,Z+ 2,2 +Z,'By JogaSoft',0
	DB	X,Y,Z+ 3,2 +Z,'mod MamSoft',0
	DB	X,Y,Z+ 2,RIGHT+4 +Z,'Ver 4.0',0
	DB	X,Y,Z+ 5,3 +Z,'Score:  ',0
ESCSC	DB	X,Y,Z+ 6,5 +Z,'000000000',0
	DB	X,Y,Z+ 8,0 +Z, '  147zb - left',0
	DB	X,Y,Z+ 9,0 +Z, 'F8 25xn - turn',0
	DB	X,Y,Z+ 10,0 +Z,'  369cm - right',0
	DB	X,Y,Z+ 12,0 +Z,' SPC 08 - drop',0
	DB	X,Y,Z+ 15,2 +Z,'ESC - Boss is',0
	DB	X,Y,Z+ 16,8 +Z,'coming!',0
	DB	X,Y,Z+ 18,2 +Z,'  S - sound',0
	DB	X,Y,Z+ 19,8 +Z,'on/off',0
	DB	X,Y,Z+ 21,2 +Z,'  P - prompt',0
	DB	X,Y,Z+ 22,8 +Z,'on/off',0
;	DB	X,Y,Z+ 19,RIGHT+2 +Z,' Ported to',0
;	DB	X,Y,Z+ 20,RIGHT+2 +Z,'   JUKU by',0
	DB	X,Y,Z+ 19,RIGHT+2 +Z,'      JUKU',0
	DB	X,Y,Z+ 20,RIGHT+2 +Z,'   demo by',0
	DB	X,Y,Z+ 22,RIGHT+2 +Z,' Tramm/J3K',0
	DB	0,0
PUNK	DB	'.$'

BONTXT	DB	X,Y,Z+ 13,BONSH +Z,'+ - bonus',0
TXFREE	DB	X,Y,Z+ 13,BONSH +Z,'         ',0

BYETXT7	DB	'Data processing completed',CR,LF,LF,LF,0

POLYS	DB	0feh,   0,0ffh,   0,   0,   0,   1, 0	;*
	DB	   0,   2,   0,   1,   0,   0,   0,0ffh	;*
	DB	0feh,   0,0ffh,   0,   0,   0,   1, 0	;@
	DB	   0,   2,   0,   1,   0,   0,   0,0ffh	;*
;PULK
	DB	   0,   0,0ffh,   0,   1,   0,   0, 1	;
	DB	0ffh,   0,   0,   0,   0,0ffh,   0, 1	; *
	DB	   0,   0,0ffh,   0,   1,   0,   0,0ffh	;*@
	DB	   0,   0,   0,   1,   0,0ffh,   1, 0	; *
;T - TAHT
	DB	   0,   0,0ffh,   0,   0,   1,   1, 1
	DB	   0,   0,0ffh,   0,0ffh,   1,   0,0ffh	; *
	DB	   0,   0,0ffh,   0,   0,   1,   1, 1	;*@
	DB	   0,   0,0ffh,   0,0ffh,   1,   0,0ffh	;*
;
	DB	   0,   0,0ffh,   0,   0,0ffh,   1,0ffh
	DB	   0,   0,   0,0ffh,   1,   0,   1, 1	;*
	DB	   0,   0,0ffh,   0,   0,0ffh,   1,0ffh	;@*
	DB	   0,   0,   0,0ffh,   1,   0,   1, 1	; *
;
	DB	0ffh,   1,0ffh,   0,   0,   0,   1, 0	;@
	DB	0ffh,0ffh,   0,0ffh,   0,   0,   0, 1	;**
	DB	0ffh,   0,   0,   0,   1,   0,   1,0ffh
	DB	   0,   0,   0,0ffh,   0,   1,   1, 1	;*
;
	DB	0ffh,   0,   0,   0,   1,   0,   1, 1	; @
 	DB	0ffh,   1,   0,   1,   0,   0,   0,0ffh	; *
	DB	0ffh,0ffh,0ffh,   0,   0,   0,   1, 0
	DB	   0,0ffh,   1,0ffh,   0,   0,   0, 1	;**
;
	DB	   0,   0,   0,0ffh,   1,   0,   1,0ffh	;**
	DB	   0,   0,   0,0ffh,   1,   0,   1,0ffh	;@*
	DB	   0,   0,   0,0ffh,   1,   0,   1,0ffh
	DB	   0,   0,   0,0ffh,   1,   0,   1,0ffh

;************** SUBROUTINES

MAIN:	CALL	CLEAR
	CALL	COPYF
	CALL	COPYZ
	mvi	a,0
	sta	MANG
	mvi	a,SPDI
	sta	SPEED
	;CALL	CLEARA
	;MOV	DI,11*FORTY+RIGHT+4
	CALL	GETFIG

	jmp 	LEVELB	; ingore and jump to beginner

;	main menu
	CALL	COPYC

	lxi	d,LEVTXT
	call	ESCTXT
LEVEL1:	CALL	ttstat
	CPI	0
	JZ	LEVEL1
	cpi	ESC
	RZ

	ani	05FH
	
	cpi	'B'
	jz	LEVELB
	cpi	'I'
	jz	LEVELI
	cpi	'A'
	jnz	LEVEL1

	mvi	a,16
	add	a
	jmp	BONDON
LEVELI:	mvi	a,8
	add	a
	jmp	BONDON
LEVELB:	mvi	a,0
BONDON:	sta	BONUSA	; 0 | 16 | 32
	add	a
	cpi	0
	jz	LEVEL3
	; extra speed???
	
LEVEL3:	CALL	COPYF
	lda	BONUSA
	mov	l,a
	mvi	h,0
	dad	h
	dad	h
	dad	h
	dad	h
	dad	h
	dad	h
	dad	h
	shld	BONUSB
	mvi	a,0
	sta	MANG
	lda	USPEED	; user speed????
	cpi	2
	jz	LEVX
	cpi	0
	jz	OVR2
	jc	LEVELX
	lxi	b,TXTS
	JMP	LEVELY
LEVX:	lxi	B,TXTX
	JMP	LEVELY
LEVELX:	lxi	B,TXTF
LEVELY:	call	ttcon
OVR2:	mvi	a,0
	sta	AUTOBON
;
MAIN0:	mvi	a,0
	sta	STATS
	lxi	b,PROLOC
	lda	PREVFIG
	mvi	d,FILL
	CALL	PUT
	CALL	GETFIG
	sta	VIGUR
	lda	PROMPT
	CPI	PROFF
	JZ	NOPRO
	lxi	B,PROLOC
	lda	PREVFIG
	mvi	D,ABO
	CALL	PUT
NOPRO:	mvi	B,(RIGHT+LEFT)/2
	mvi	C,1
	mov	a,b
	sta	CURPOS
	mov	a,c
	sta	CURPOS+1
	lda	VIGUR
	CALL	MTEST
	JNC	MAINRN
	lda	AUTOBON
	inr	a
	sta	AUTOBON
	cpi	1
	jnz	NOAUBON
	CALL	BONKU
	CALL	KUKU
	JMP	NOPRO
NOAUBON:	
	JMP	MAINR
MAINRN:	mvi	a,0
	sta	AUTOBON
	lda	CURPOS
	mov	b,a
	lda	CURPOS+1
	mov	c,a
	mvi	D,ABO
	lda	VIGUR
	CALL	PUT ;PUT AT THE BEGINNING
	LDA	PONS	; bonus every +1000
	mov	b,a
	LDA	SCOREY+1
	cmp	b
	jz	MAINFA
	sta	PONS
	lda	BONUZ	; switched by installer
	ora	a
	jz	MAINFA
	call	BONTIM
MAINFA:	CALL	COPYP	; uus k3ik, uus laud/esimene plokk ekraanile
	mvi	a,0
	sta	PADAVAI
MAIN1:	lda	SPEED
	mov	c,a
MAIN2:	push	b
	lda	CURPOS
	mov	b,a
	sta	OCURPOS
	lda	CURPOS+1
	mov	c,a
	sta	OCURPOS+1
	lda	VIGUR
	sta	OVIGUR
	mvi	D,FILL
	CALL	PUT
	CALL	CHAR
	cpi	27
	JNZ	CRR0
	POP	b
	RET

CRR0:	ora	a
	jz	CRRX
	CPI	'0'
	JZ	CRR1A
	CPI	SPACE
	JNZ	CRR0A
CRR1A:	mvi	a,1
	sta	PADAVAI
	jmp	CRRX
CRR0A:	cpi	13
	JNZ	CRR1
	CALL	RAND
	DCR	A	; 1-255
	ANI	3
	sta	STICK
	jmp	CRR5	; stupid
CRR1:	cpi	'1'
	JNZ	CRR2
	lda	CURPOS
	dcr	a
	sta	CURPOS
	jmp	CRRX
CRR2:	cpi	'2'
	JNZ	CRR3
	lda	VIGUR
	ani	3
	lda	VIGUR
	jnz	KERI
	adi	3
	jmp	TUD1
KERI:	dcr	a
TUD1:	sta	VIGUR
	jmp	CRRX
CRR3:	cpi	'3'
	JNZ	CRR4
	lda	CURPOS
	inr	a
	sta	CURPOS
	jmp	CRRX
CRR4:	cpi	'P'
	JNZ	CRR5
	lda	PROMPT
	CPI	PRON
	JNZ	CRR4A
	mvi	a,PROFF
	sta	PROMPT
	JMP	CRRX
CRR4A:	mvi	a,PRON
	sta	PROMPT
CRR5:	cpi	13
	JZ	CRRBN
	cpi	'+'
	JZ	CRRBN
	cpi	3bh	; juku ext keyb special
	JNZ	CRRX
	
CRRBN:	CALL	BONKU

CRRX:	lda	PADAVAI
	mov	e,a
	mvi	d,0
	lhld	SEIS	; MOV	BX,SEIS
	dad	d	; ADD	BX,PADAVAI
	dad	d	; ADD	BX,PADAVAI
	dad	d	; ADD	BX,PADAVAI
	shld	SEIS	; MOV	SEIS,BX
	lda	CURPOS
	mov	b,a
	lda	CURPOS+1
	mov	c,a
	lda	PADAVAI
	add	c
	sta	CURPOS+1
	mov	c,a
	lda	VIGUR
	CALL	MTEST
	JC	MAIN4
	lda	CURPOS
	mov	b,a
	lda	CURPOS+1
	mov	c,a	
	lda	VIGUR
	mvi	D,ABO
	CALL	PUT
	CALL	COPYP	; paneb game[] ploki (tagasi)
	JMP	MAIN3
MAIN4:	lda	OCURPOS	;USER MOVE NOT SUPPORTED
	mov	b,a
	sta	CURPOS
	lda	OCURPOS+1
	mov	c,a
	sta	CURPOS+1
	lda	OVIGUR
	sta	VIGUR	
	mvi	D,ABO
	CALL	PUT
	CALL	COPYP
	mvi	a,0
	sta	PADAVAI
	JMP	MAIN3
MAIN2A:	JMP	MAIN2
MAIN3:	CALL	INCR
	POP	B	; speed???
	dcr	c
	jnz	MAIN2A
	lda	CURPOS
	mov	b,a
	sta	OCURPOS
	lda	CURPOS+1
	mov	c,a
	sta	OCURPOS+1
	lda	VIGUR
	sta	OVIGUR
	mvi	D,FILL
	CALL	PUT	; asendab ploki t3idisega puhvris
	lda	CURPOS
	mov	b,a
	lda	CURPOS+1
	inr	a	; DOWN
	mov	c,a
	sta	CURPOS+1
	lda	VIGUR
	CALL	MTEST	; tunneb end uuel kohal h3sti
	JC	MAINNO
	lda	CURPOS
	mov	b,a
	lda	CURPOS+1
	mov	c,a
	lda	VIGUR
	mvi	D,ABO
	CALL	PUT	; liigutab ploki allapoole puhvris
	mvi	a,0
	sta	STATS
	CALL	COPYP	; liigutab allapoole ploki ekraanil
	JMP	MAIN1
MAINNO:	lda	OCURPOS	;DENIED
	mov	b,a
	sta	CURPOS
	lda	OCURPOS+1
	mov	c,a
	sta	CURPOS+1
	lda	OVIGUR
	sta	VIGUR
	MVI	D,ABO
	CALL	PUT	; plokk j33b oma kohale
	CALL	COPYP	; ekraanil ka
	lda	STATS
	inr	a
	sta	STATS
	cpi	2
	JZ	MAINNP
	JMP	MAIN1
MAINNP:	lda	OCURPOS	; teisel p6hjatiksul puhvris
	mov	b,a
	lda	OCURPOS+1
	mov	c,a
	lda	OVIGUR
	mvi	D,POL
	CALL	PUT

	lda	OCURPOS+1	; STANDS
	mov	c,a
	mvi	b,0
	lhld	SEIS
	dad	b
	lda	BONUSA
	mov	c,a
	dad	b
	shld	SEIS

	CALL	BEES
	CALL	KUKU	;???
	lda	spdc
	mov	b,a
	ora	a
	jnz	notyet
	lda	SPEED
	ora	a
	jz	skipd
	dcr	a
	sta	SPEED
skipd:	mvi	b,0fh
notyet:	mov	a,b
	dcr	a
	sta	spdc
	JMP	MAIN0
MAINR:	lda	CURPOS	;END OF YOUR LIFE
	mov	b,a
	lda	CURPOS+1
	mov	c,a
	lda	VIGUR	
	mvi	D,ABO
	CALL	PUT
	mvi	a,0ffh
	sta	MANG
	mvi	c,10
	lhld	SEIS
	lxi	d,100	; MOV	AX,100
	dad	d	; ADD	AX,SEIS
	shld	SEIS	; MOV	SEIS,AX
FLASH:	PUSH	b
	mvi	c,5
p1r:	push	b
	lda	PROMPT
	dcr	a
	sta	PROM2
	call	INCR
	pop	b
	dcr	c
	jnz	p1r
	CALL	COPYB
	mvi	c,5
p2r:	push	b
	lda	PROMPT
	dcr	a
	sta	PROM2
	call	INCR
	pop	b
	dcr	c
	jnz	p2r
	CALL	COPYC
	POP	b
	dcr	c
	jnz	FLASH
MAINR1:	CALL	COPYP
	mvi	C,0ffH
MAINR2:	dcr	c
	jnz	MAINR2
	call	INCR
	ora	a
	jnz	MAINR1
	;CALL	COPYA
	CALL	COPYB
	;CALL	EDMA
	RET

; use bonus
;

BONKU:	lda	BONCNT
	cpi	0
	rz
	sta	BONCNT2
	lxi	h,SAUBACW
	shld	SAPOI
	call	SAON
	lxi	b,TXFREE
	call	ttcon
	mvi	a,0
	sta	BONCNT
	CALL	RANDS	; gives new rands
	RET

; activate bonus
;

BONTIM:	lda	BONCNT
	inr	a
	sta	BONCNT
	lxi	h,SAUBONW
	shld	SAPOI
	call	SAON
	lxi	b,BONTXT
	call	ttcon
	RET

; block fitness calcs
; H, L -- X,Y

ADCNOG:	push	b
	push	d
	mvi	b,0
	mov	c,h
	mvi	h,0
	dad	h
	lxi	d,GAME+MUL40T
	dad	d
	mov	e,m
	inx	h
	mov	d,m	; DE korrutatud
	xchg
	dad	b	; HL aadress
	pop	d
	pop	b
	RET

; m3nguv3lja aadressiga

ADCALC:	push	b
	push	d
	mvi	b,0
	mov	c,h
	mvi	h,0
	dad	h
	lxi	d,GAME+MUL40T
	dad	d
	mov	e,m
	inx	h
	mov	d,m	; DE korrutatud
	xchg
	dad	b	; HL aadress
	lxi	b,GAME
	dad	b
	pop	d
	pop	b
	RET

; copy everything to video

COPYA:	mvi	a,0
	sta	CHPN
	lxi	h,0d800h
	lxi	d,GAME
	mvi	b,MHIGH-1
nexro:	mvi	c,FORTY
	push	d
row0:	ldax	d
	mov	m,a
	inx	d
	inx	h
	dcr	c
	jnz	row0
	pop	d
	mvi	c,FORTY
	push	d
row1:	ldax	d
	cpi	0AAh
	jnz	row1m
	rrc
row1m:	mov	m,a
	inx	d
	inx	h
	dcr	c
	jnz	row1
	pop	d
	mvi	c,FORTY
	push	d
row2:	ldax	d
	mov	m,a
	inx	d
	inx	h
	dcr	c
	jnz	row2
	pop	d
	mvi	c,FORTY
	push	d
row3:	ldax	d
	cpi	0AAh
	jnz	row3m
	rrc
row3m:	mov	m,a
	inx	d
	inx	h
	dcr	c
	jnz	row3
	pop	d
	mvi	c,FORTY
	push	d
row4:	ldax	d
	mov	m,a
	inx	d
	inx	h
	dcr	c
	jnz	row4
	pop	d
	mvi	c,FORTY
	push	d
row5:	ldax	d
	cpi	0AAh
	jnz	row5m
	rrc
row5m:	mov	m,a
	inx	d
	inx	h
	dcr	c
	jnz	row5
	pop	d
	mvi	c,FORTY
	push	d
row6:	ldax	d
	mov	m,a
	inx	d
	inx	h
	dcr	c
	jnz	row6
	pop	d
	mvi	c,FORTY
	push	d
row7:	ldax	d
	cpi	0AAh
	jnz	row7m
	rrc
row7m:	mov	m,a
	inx	d
	inx	h
	dcr	c
	jnz	row7
	pop	d
	mvi	c,FORTY
	push	d
row8:	ldax	d
	mov	m,a
	inx	d
	inx	h
	dcr	c
	jnz	row8
	pop	d
	mvi	c,FORTY
rowx:	ldax	d
	cpi	0AAh
	jnz	rowxm
	rrc
rowxm:	mov	m,a
	inx	d
	inx	h
	dcr	c
	jnz	rowx
	dcr	b
	jnz	nexro
	mvi	c,FORTY
rowz:	ldax	d
	mov	m,a
	inx	d
	inx	h
	dcr	c
	jnz	rowz
	RET

; eelvaate ala tyhjendamine videos

COPYZ:	lxi	h,0d800h+(PROLX-2)+((PROLY-1)*40*10)
	lxi	b,FORTY-4
	mvi	e,30
	mvi	a,0
lin40:	mov	m,a
	inx	h
	mov	m,a
	inx	h
	mov	m,a
	inx	h
	mov	m,a
	inx	h
	dad	b
	dcr	e
	jnz	lin40
	ret

COPYT:	RET
	;CALL	WRITE	; alguses lauale
	;MOV	BP,WORD PTR COLBLUE
	;PUSH	DX
	lxi	h,0d800h+RIGHT+1
	lxi	d,GAME+RIGHT+1
	lxi	b,DOWN-UP
	JMP	COPYB1

; m3nguala sisu p88ratud v3rvidega
;

COPYC:	;CALL	TICK
	lxi	h,0ffeeh	;COPY INVERSE
	shld	crow0m
	shld	crow1m
	shld	crow2m
	shld	crow3m
	shld	crow4m
	shld	crow5m
	shld	crow6m
	shld	crow7m
	shld	crow8m
	shld	crowxm
	CALL	COPYB0
	lxi	h,0
	shld	crow0m
	shld	crow1m
	shld	crow2m
	shld	crow3m
	shld	crow4m
	shld	crow5m
	shld	crow6m
	shld	crow7m
	shld	crow8m
	shld	crowxm
	RET

; m3nguala sisu videosse
;

COPYF:	lxi	h,FORTY-(RIGHT-LEFT+1)
	shld	crow0f+1
	shld	crow1f+1
	shld	crow2f+1
	shld	crow3f+1
	shld	crow4f+1
	shld	crow5f+1
	shld	crow6f+1
	shld	crow7f+1
	shld	crow8f+1
	shld	crowxf+1
	lxi	h,0d800h+LEFT
	lxi	d,GAME+LEFT
	mvi	b,DOWN-UP+1
	mvi	a,RIGHT-LEFT+1
	sta	COPYB1+1
	sta	crow0c+1
	sta	crow1c+1
	sta	crow2c+1
	sta	crow3c+1
	sta	crow4c+1
	sta	crow5c+1
	sta	crow6c+1
	sta	crow7c+1
	sta	crow8c+1
	CALL	COPYB3
	mvi	a,RIGHT-LEFT-1
	sta	COPYB1+1
	sta	crow0c+1
	sta	crow1c+1
	sta	crow2c+1
	sta	crow3c+1
	sta	crow4c+1
	sta	crow5c+1
	sta	crow6c+1
	sta	crow7c+1
	sta	crow8c+1
	lxi	h,FORTY-(RIGHT-LEFT-1)
	shld	crow0f+1
	shld	crow1f+1
	shld	crow2f+1
	shld	crow3f+1
	shld	crow4f+1
	shld	crow5f+1
	shld	crow6f+1
	shld	crow7f+1
	shld	crow8f+1
	shld	crowxf+1
	RET

; m3nguplats piiretega videosse
; 

COPYB:	mvi	a,0	
	sta	CHPN
COPYB0:	lxi	h,0d800h+LEFT+1
	lxi	d,GAME+LEFT+1
	mvi	b,DOWN-UP
COPYB3:	push	h
	lxi	h,crow0f
	mvi	a,MHIGH
	cmp	b
	jnz	NOLOW
	lxi	h,lowco
NOLOW:	shld	drolow+1
	pop	h
COPYB1:	mvi	c,RIGHT-LEFT-1
	push	d
crow0:	ldax	d
crow0m:	nop
	nop
	mov	m,a
	inx	d
	inx	h
	dcr	c
	jnz	crow0
drolow:	jmp	crow0f
lowco:	mov	a,b
	ora	a
	jz	ecrow
crow0f:	lxi	d,FORTY-(RIGHT-LEFT-1)
	dad	d
	pop	d
crow0c:	mvi	c,RIGHT-LEFT-1
	push	d
crow1:	ldax	d
	cpi	0AAh
	jnz	crow1m
	rrc
crow1m:	nop
	nop
	mov	m,a
	inx	d
	inx	h
	dcr	c
	jnz	crow1
crow1f:	lxi	d,FORTY-(RIGHT-LEFT-1)
	dad	d
	pop	d
crow1c:	mvi	c,RIGHT-LEFT-1
	push	d
crow2:	ldax	d
crow2m:	nop
	nop
	mov	m,a
	inx	d
	inx	h
	dcr	c
	jnz	crow2
crow2f:	lxi	d,FORTY-(RIGHT-LEFT-1)
	dad	d
	pop	d
crow2c:	mvi	c,RIGHT-LEFT-1
	push	d
crow3:	ldax	d
	cpi	0AAh
	jnz	crow3m
	rrc
crow3m:	nop
	nop
	mov	m,a
	inx	d
	inx	h
	dcr	c
	jnz	crow3
crow3f:	lxi	d,FORTY-(RIGHT-LEFT-1)
	dad	d
	pop	d
crow3c:	mvi	c,RIGHT-LEFT-1
	push	d
crow4:	ldax	d
crow4m:	nop
	nop
	mov	m,a
	inx	d
	inx	h
	dcr	c
	jnz	crow4
crow4f:	lxi	d,FORTY-(RIGHT-LEFT-1)
	dad	d
	pop	d
crow4c:	mvi	c,RIGHT-LEFT-1
	push	d
crow5:	ldax	d
	cpi	0AAh
	jnz	crow5m
	rrc
crow5m:	nop
	nop
	mov	m,a
	inx	d
	inx	h
	dcr	c
	jnz	crow5
crow5f:	lxi	d,FORTY-(RIGHT-LEFT-1)
	dad	d
	pop	d
crow5c:	mvi	c,RIGHT-LEFT-1
	push	d
crow6:	ldax	d
crow6m:	nop
	nop
	mov	m,a
	inx	d
	inx	h
	dcr	c
	jnz	crow6
crow6f:	lxi	d,FORTY-(RIGHT-LEFT-1)
	dad	d
	pop	d
crow6c:	mvi	c,RIGHT-LEFT-1
	push	d
crow7:	ldax	d
	cpi	0AAh
	jnz	crow7m
	rrc
crow7m:	nop
	nop
	mov	m,a
	inx	d
	inx	h
	dcr	c
	jnz	crow7
crow7f:	lxi	d,FORTY-(RIGHT-LEFT-1)
	dad	d
	pop	d
crow7c:	mvi	c,RIGHT-LEFT-1
	push	d
crow8:	ldax	d
crow8m:	nop
	nop
	mov	m,a
	inx	d
	inx	h
	dcr	c
	jnz	crow8
crow8f:	lxi	d,FORTY-(RIGHT-LEFT-1)
	dad	d
	pop	d
crow8c:	mvi	c,RIGHT-LEFT-1
	push	d
crowx:	ldax	d
	cpi	0AAh
	jnz	crowxm
	rrc
crowxm:	nop
	nop
	mov	m,a
	inx	d
	inx	h
	dcr	c
	jnz	crowx
crowxf:	lxi	d,FORTY-(RIGHT-LEFT-1)
	dad	d
	pop	d
	mvi	c,FORTY
	mov	a,e
	add	c
	jnc	noupd1
	inr	d
noupd1:	mov	e,a
	dcr	b
	jnz	COPYB1
ecrow:	RET

; valitud puhver videosse
;

COPYP:	;CALL	TICK
	lda	CHPN
	CPI	0
	JZ	COPYAS
	LXI	H,CHTB
COPYP1:	mov	d,m
	inx	h
	mov	e,m
	inx	h
	CALL	COPY
	dcr	a
	JNZ	COPYP1
	sta	CHPN
COPYAS:	RET

; m3ngulaua DE aadress videosse
;

COPY:	push	psw
	push	h
	mov	h,d
	mov	l,e
	lxi	b,GAME
	dad	b
	mov	a,m	
	mov	h,d
	mov	l,e
	dad	h
vidm:	lxi	b,0
	dad	b
	lxi	b,FORTY
	mov	e,m
	inx	h
	mov	d,m
	xchg
	cpi	0AAh
	jz	RORO
	mov	m,a
	dad	b
	mov	m,a
	dad	b
	mov	m,a
	dad	b
	mov	m,a
	dad	b
	mov	m,a
	dad	b
	mov	m,a
	dad	b
	mov	m,a
	dad	b
	mov	m,a
	dad	b
	mov	m,a
	dad	b
	mov	m,a
	dad	b
	pop	h
	pop	psw
	RET
RORO:
	mov	m,a
	dad	b
	rrc
	mov	m,a
	dad	b
	rrc
	mov	m,a
	dad	b
	rrc
	mov	m,a
	dad	b
	rrc
	mov	m,a
	dad	b
	rrc
	mov	m,a
	dad	b
	rrc
	mov	m,a
	dad	b
	rrc
	mov	m,a
	dad	b
	rrc
	mov	m,a
	dad	b
	rrc
	mov	m,a
	dad	b
	pop	h
	pop	psw
	RET

; numbri joonistamine
;

DISPN:	mov	e,a
	mvi	d,FTH	; higher byte of num addr = 0ddH
	ldax	d
	mov	m,a
	dad	b
	inx	d
	ldax	d
	mov	m,a
	dad	b
	inx	d
	ldax	d
	mov	m,a
	dad	b
	inx	d
	ldax	d
	mov	m,a
	dad	b
	inx	d
	ldax	d
	mov	m,a
	dad	b
	inx	d
	ldax	d
	mov	m,a
	dad	b
	inx	d
	ldax	d
	mov	m,a
	dad	b
	inx	d
	ldax	d
	mov	m,a
	dad	b
	inx	d
;	ldax	d
;	mov	m,a
;	dad	b
;	inx	d
;	ldax	d
;	mov	m,a
;	dad	b
;	inx	d
	ret


LINF:	lxi	h,GAME
	dad	d
	mov	e,b
	mvi	b,0
replf:	mov	m,a
	dad	b
	dcr	e
	jnz	replf
	RET

CLEAR:	lxi	h,0
	shld	SEIS
	shld	SEIS2
	mvi	a,0
	sta	PROM2
	sta	BONCNT2
	;mvi	a,20
	sta	BONCNT
	mvi	a,NIL
	sta	PONS	; tuhandelised
	call	CLRSC
	lxi	d,FORTY*MHIGH
	inr	d
	lxi	h,GAME
	mvi	A,FILL
	;mvi	A,20H
clrg:	mov	m,a
	inx	h
	dcr	e
	jnz	clrg
	dcr	d
	jnz	clrg
	lxi	d,LEFT
	mvi	b,DOWN-UP+1
	mvi	c,FORTY
	;mvi	a,1
	mvi	a,0AAH
	CALL	LINF
	lxi	d,RIGHT
	mvi	b,DOWN-UP+1
	mvi	a,0AAH
	;mvi	a,80h
	CALL	LINF
	lxi	d,FORTY*DOWN+LEFT+1
	mvi	b,RIGHT-LEFT-1
	mvi	c,1
	mvi	a,0AAh
	CALL	LINF
	RET

CLRSC:	mvi	a,NIL
	sta	SCOREY
	sta	SCOREY+1
	sta	SCOREY+2
	sta	SCOREY+3
	mvi	a,FTL
	sta	SCORE
	lxi	b,ESCSC
	call	ttcon
	ret

ESCTXT:	;ldax	d
	;sta	0d49fh
	;inx	d
	;ldax	d
	;sta	0d49eh
	;inx	d
	mov	b,d
	mov	c,e
	call	ttcon
TT0:	ldax	d
	inx	d
	ora	a
	jnz	TT0
	mov	b,d
	mov	c,e
	ldax	d
	ora	a
	jnz	ESCTXT
	ret

; korruste eemaldamne
;

KUKU:	lda	BONCNT2
	ora	a
	jz	KUKU0P
	dcr	a
	sta	BONCNT2
	CALL	BONUS
;
KUKU0P:	mvi	b,DOWN-UP
	mvi	h,0
	lxi	d,GAME+LEFT+1
KUKU1:	push	b
	push	d
	mvi	c,RIGHT-LEFT-1
	mvi	l,0
KUKU3:	ldax	d
	cpi	0
	JNZ	KUKU2
	inr	l
KUKU2:	inx	d
	dcr	c
	jnz	KUKU3
	mvi	a,0
	cmp	l
	jnz	KUKU4
	mvi	c,RIGHT-LEFT-1
	mvi	a,EXL
	pop	d
	push	d
KUKU5:	stax	d	; m3rgistab korruse eemaldamiseks
	inx	d
	push	h
	lhld	SEIS
	inx	h	; INC	SEIS
	inx	h	; INC	SEIS
	inx	h	; INC	SEIS
	shld	SEIS
	lhld	BONUSB
	inx	h
	SHLD	BONUSB
	pop	h
	inr	h
	dcr	c
	jnz	KUKU5
KUKU4:	pop	d
	pop	b
	mvi	a,FORTY
	ADD	e
	mov	e,a
	jnc	nocar0
	inr	d
nocar0:	dcr	b
	jnz	KUKU1
	mvi	a,0
	cmp	h
	JZ	KUKU11
	CALL	COPYB
	
	lxi	h,SAUKUKW
	shld	SAPOI
	call	SAON

KUKUX:	mvi	c,RIGHT-LEFT-1	;10
	lxi	d,GAME+(FORTY*(DOWN-UP-1))+LEFT+1 ;LEFT-DOWN CORNER
KUKU6:	mov	h,d
	mov	l,e
	push	d
	mvi	b,DOWN-UP+1	; lisame yhe, et autobon t88taks
KUKU8:	ldax	d
	mov	m,a
	cpi	EXL
	jz	KUKU7	; m3rgistatud korrus kirjutatakse yle
	mov	a,l
	sui	FORTY
	mov	l,a
	jnc	KUKU7
	dcr	h
KUKU7:	mov	a,e
	sui	FORTY
	mov	e,a
	jnc	nocar1
	dcr	d
nocar1:	dcr	b
	jnz	KUKU8
KUKU10:	pop	d
	inx	d
	dcr	c
	JNZ	KUKU6

	CALL	COPYB

	lhld	BONUSB
	xra	a	; shift 7x right
	dad	h
	ral
	;mov	l,h	; ignore msb
	;mov	h,a
	
	;mov	a,l
	mov	a,h
	sta	BONUSA

	lda	BONCNT2
	ora	a
	jz	KUKU12
	JMP	KUKU
	
KUKU12:	
	; increase speed
KUKU11:	lda	BONCNT2
	ora	a
	jz	KUKU13
	JMP	KUKU
KUKU13:	RET

; A - vigur + p88re
; B - x, C - y

MTEST:	push	b
	stc
	cmc
	ral
	ral
	ral
	mvi	h,0
	mov	l,a
	lxi	d,POLYS
	dad	d
	xchg
	ldax	d	; 0
	inx	d
	add	b
	mov	h,a
	ldax	d
	inx	d
	add	c
	mov	l,a
	CALL	ADCALC
	mov	a,m
	cpi	FILL
	JNZ	MTEST2
	ldax	d	; 1
	inx	d
	add	b
	mov	h,a
	ldax	d
	inx	d
	add	c
	mov	l,a
	CALL	ADCALC
	mov	a,m
	cpi	FILL
	JNZ	MTEST2
	ldax	d	; 2
	inx	d
	add	b
	mov	h,a
	ldax	d
	inx	d
	add	c
	mov	l,a
	CALL	ADCALC
	mov	a,m
	cpi	FILL
	JNZ	MTEST2
	ldax	d	; 3
	inx	d
	add	b
	mov	h,a
	ldax	d
	inx	d
	add	c
	mov	l,a
	CALL	ADCALC
	mov	a,m
	cpi	FILL
	JNZ	MTEST2
	pop	b
	STC
	CMC
	RET
MTEST2:	pop	b
	STC
	RET

PUT:	push	b
	lxi	h,bltyp+1
	mov	m,d
	stc
	cmc
	ral
	ral
	ral
	mvi	h,0
	mov	l,a
	lxi	d,POLYS
	dad	d
	xchg
	ldax	d	; 0
	inx	d
	add	b
	mov	h,a
	ldax	d
	inx	d
	add	c
	mov	l,a
	CALL	ADCNOG
	CALL	PUTP
	ldax	d	; 1
	inx	d
	add	b
	mov	h,a
	ldax	d
	inx	d
	add	c
	mov	l,a
	CALL	ADCNOG
	CALL	PUTP
	ldax	d	; 2
	inx	d
	add	b
	mov	h,a
	ldax	d
	inx	d
	add	c
	mov	l,a
	CALL	ADCNOG
	CALL	PUTP
	ldax	d	; 3
	inx	d
	add	b
	mov	h,a
	ldax	d
	inx	d
	add	c
	mov	l,a
	CALL	ADCNOG
	CALL	PUTP
	pop	b
	RET

PUTP:	push	d
	lda	CHPN
	inr	a
	sta	CHPN
	dcr	a
	add	a
	lxi	d,CHTB
	add	e
	mov	e,a
	jnc	noinr
	inr	d
noinr:	mov	a,h
	stax	d
	inx	d
	mov	a,l
	stax	d
	lxi	d,GAME
	dad	d
bltyp:	mvi	a,FILL
	mov	m,a
	pop	d
	RET

; juhuarvude generaator
;
RAND:	push	b
rarv:	mvi	a,0a7h
	mov	b,a
r1:	mvi	c,1
l1:	stc
	cmc
	ral
	dcr	c
	jnz	l1
	xra	b
	mov	b,a
r2:	mvi	c,1
l2:	stc
	cmc
	rar
	dcr	c
	jnz	l2
	xra	b
	mov	b,a
r3:	mvi	c,2
l3:	stc
	cmc
	ral
	dcr	c
	jnz	l3
	xra	b
	sta	rarv+1
	pop	b
	ret

; juhuslikustaja
;
RANDS:	lda	0d463h
	stc
	cmc
	rar
	stc
	cmc
	rar
	stc
	cmc
	rar
	cpi	24
	jc	setsd
	stc
	cmc
	rar
setsd:	lxi	h,seeds
	cpi	0
	jz	nodec
	lxi	b,3
sloop:	dad	b
	dcr	a
	jnz	sloop
nodec:	mov	a,m
	sta	r1+1
	inx	h
	mov	a,m
	sta	r2+1
	inx	h
	mov	a,m
	sta	r3+1
	ret

; skoorile +1 ja kohe ekraanile
; A=0 kui yhtlustatud

INCR:	lda	SEIS
	lhld	SEIS2
	cmp	l
	jnz	INCR1
	lda	SEIS+1
	cmp	h
	mvi	a,0	; null kui valmis
	rz
INCR1:	lda	PROM2	; ettepoole?
	inr	a
	sta	PROM2
	mov	d,a
	lda	PROMPT
	cmp	d
	mvi	a,0ffh	; return code
	rnz
	inx	h
	shld	SEIS2
INC1A:	mvi	a,0
	sta	PROM2
	lxi	d,SCORE
	lxi	b,FORTY
	lxi	h,0d800h+(6*FORTY*10)+13
INCRR3:	ldax	d
	adi	9
	cpi	FTL-1	; NIL+1
	jz	INCR9
	cpi	FTL+(9*10)
	jnz	INCR4
	sui	9*10
	stax	d
	push	h
	push	d
	call	DISPN
	pop	d
	pop	h
	dcx	h
	dcx	d
	JMP	INCRR3
INCR9:	adi	10
	stax	d
	call	DISPN
	RET		; never zero
INCR4:	stax	d
	call	DISPN
	RET		; never zero

CHAR:	lda	curkey
	mov	b,a
	lda	ttraw
	cmp	b
	jz	keyin
	sta	curkey
	mvi	a,14
	sta	ttrate
	mvi	a,0
	sta	lastkey
	inr	a
	sta	ttreps
keyin:	call	ttstat
	ora	a
	rz
	mov	b,a
	lda	lastkey
	cmp	b
	jnz	storel
	mvi	a,0
	sta	ttrate
	inr	a
	sta	ttreps
storel:	mov	a,b
	sta	lastkey
	call	ISCHAR
	RET

ISCHAR:	CPI	'a'-1
	JC	CHARHI
	CPI	'z'+1
	JNC	CHARHI
	ANI	0DFH
CHARHI:	CPI	'S'
	JNZ	CHARP
	lda	SOUND
	xri	0FFH
	sta	SOUND
CHARP:	CPI	8
	jz	CHARL
	CPI	'Z'
	jz	CHARL
	CPI	'B'
	jz	CHARL
	CPI	'7'
	jz	CHARL
	CPI	'4'
	jz	CHARL
	CPI	11
	jz	CHART
	CPI	1Ah	; F8
	jz	CHART
	CPI	'X'
	jz	CHART
	CPI	'N'
	jz	CHART
	CPI	'5'
	jz	CHART
	CPI	12
	jz	CHARR
	CPI	'C'
	jz	CHARR
	CPI	'M'
	jz	CHARR
	CPI	'9'
	jz	CHARR
	CPI	'6'
	jz	CHARR
	CPI	' '
	jz	CHARD
	CPI	'8'
	jz	CHARD
	CPI	10
	jz	CHARD
	RET

CHARL:	MVI	A,'1'
	RET
CHART:	MVI	A,'2'
	RET
CHARR:	MVI	A,'3'
	RET
CHARD:	MVI	A,'0'
	RET

SAS:	lda	SOUND
	ora	a
	jz	SAOFF
	mvi	a,0b0h
	OUT	1bh
	lhld	SAPOI
	mov 	a,m
	ora	a
	jz	SAOFF
	OUT	19h
	inx	h
	mov 	a,m
	OUT	19h
	inx	h
	shld	SAPOI
	stc
	cmc
	RET

SAON:	lda	SOUND
	ora	a
	rz
	mvi	a,0b0h
	OUT	1bh
	lxi	h,0ffffh
	shld	sndtog
	RET

BEES:	lda	SOUND
	ora	a
	rz
	stc
	cmc
	mvi	e,4
	;mvi	d,18h
	mvi	d,3ch	;CLICK!
CLICK:	mov	a,d
	push	d
CLACK:	ral
	dcr	e
	jnz	CLACK
	mvi	a,0
	OUT	19h
	mov	a,d
	OUT	19h
	pop	d
	CALL	SAON
	;mvi	c,3eh
	mvi	c,1Ah
BEES1:	dcr	c
	jnz	BEES1
	dcr	e
	jnz	CLICK

SAOFF:	lda	SOUND
	ora	a
	rz
	IN	1bh
	ani	76h
	OUT	01bh
	lxi	h,0h
	shld	sndtog
	;in	4h
	;ani	0efh
	;out	4h
	stc
	RET

; t88tab ka ESC-koodidega
;

ttcon:	ldax	b
	ora	a
	rz
	call	tto
	inx	b
	jmp	ttcon

ERASE:	lxi	b,CLRSCR
	call	ttcon
	RET

GETFIG:	lda	PREVFIG
	mov	c,a
GETOF:	CALL	RAND
	ANI	11100b
	CPI	11100b
	JNC	GETOF
	mov	b,a
	lda	STICK
	dcr	a
	sta	STICK
	jz	KEEPIT
	mov	a,b
KEEPIT:	sta	PREVFIG
	mov	a,c
	RET

; find fillable holes
; 

BONUS:	lxi	d,GAME+(FORTY*(DOWN-UP-1))+LEFT+1	; all vasakul
	mvi	c,DOWN-UP-2
BONUS1:	push	d
	mvi	b,RIGHT-LEFT-1
	mvi	l,0
BONUS3:	ldax	d
	cpi	FILL
	jnz	NXBON
	inr	l
NXBON:	inx	d
	dcr	b
	jnz	BONUS3
	mov	a,l
	ora	a
	jz	NOBON
	call	RAND
	ani	0fh
RNDBON:	cmp	l
	jc	FNDBON
	sub	l
	jmp	RNDBON
FNDBON:	mov	l,a
	inr	l
	pop	d
	push	d
BONUS4:	ldax	d
	cpi	FILL
	jnz	WTBON
	dcr	l
	jz	ZAP
WTBON:	inx	d
	JMP	BONUS4
NOBON:	pop	d
	mov	a,e
	sbi	FORTY
	mov	e,a
	jnc	nocar2
	dcr	d
nocar2:	dcr	c
	jnz	BONUS1
	RET
	;JMP	MAINFA	; ???
ZAP:	mvi	a,POL
	stax	d
	pop	d
	CALL	COPYF
	lxi	h,SAUBOOW
	shld	SAPOI
	call	SAON
	RET

; videom3lu aadressid ja korrutustabel
;

VIDCRE:	lxi	h,0
	lxi	d,GAME+MUL40T
	mvi	c,MHIGH
nxwr1:	mov	a,l
	stax	d
	inx	d
	mov	a,h
	stax	d
	inx	d
	push	b
	lxi	b,FORTY
	dad	b
	pop	b
	dcr	c
	jnz	nxwr1
	xchg
	shld	vidm+1
	lxi	d,0d800h
	;lxi	h,vidm
	mvi	a,MHIGH
nx40:	mvi	c,FORTY
nxwr2:	mov	m,e
	inx	h
	mov	m,d
	inx	h
	inx	d
	dcr	c
	jnz	nxwr2
	lxi	b,FORTY*10-FORTY
	xchg
	dad	b
	xchg
	dcr	a
	jnz	nx40
	ret

PUTMOD:	lda	linelen
	sta	OMODE
	RET

GETMOD:	lda	linelen
	mov	b,a
	lda	OMODE
	cmp	b
	rz
	cpi	79
	jnz	mod1
	ret
mod1:	cpi	63
	lxi	b,mod64
	call	ttcon
	jnz	mod2
	ret
mod2:	cpi	52
	lxi	b,mod53
	call	ttcon
	ret
	jnz	mod3
mod3:	cpi	39
	lxi	b,mod40
	call	ttcon
	RET

seeds	db	1,1,2
	db	1,1,3
	db	1,7,3
	db	1,7,6
	db	1,7,7
	db	2,1,1
	db	2,5,5
	db	3,1,1
	db	3,1,5
	db	3,5,4
	db	3,5,5
	db	3,5,7
	db	3,7,1
	db	4,5,3
	db	5,1,3
	db	5,3,6
	db	5,3,7
	db	5,5,2
	db	5,5,3
	db	6,3,5
	db	6,7,1
	db	7,3,5
	db	7,5,3
	db	7,7,1

TS	DB	'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'	;4
GAME:	DB	'~~~~~~~                          ~~~~~~~'	;5
	DB	'~~~~~~~          TOTRUS          ~~~~~~~'	;6
	DB	'~~~~~~~                          ~~~~~~~'	;7
	DB	'~~~~~~~      (c) 1988-1990       ~~~~~~~'	;8
	DB	'~~~~~~~    Jogasoft & MamSoft    ~~~~~~~'	;9 
	DB	'~~~~~~~                          ~~~~~~~'	;10
	DB	'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'	;11
TF:

	end
