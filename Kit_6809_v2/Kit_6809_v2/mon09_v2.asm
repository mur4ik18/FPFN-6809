* Moniteur MPF1 pour MC6809 @ 4.9152 MHz
* Fred 2020 d'après un source C de Wichit Sirichote
* ACIA @ 19200bauds

			org $7C00
			
USER_X		fdb 	0		; définition des variables systèmes implantées à partir de $7C00
USER_Y		fdb 	0
USER_S		fdb 	0
USER_U		fdb 	0
SAVE_S		fdb 	0
SAVE_S1		fdb 	0
PC			fdb 	0
SAVE_PC		fdb 	0
USER_A		fcb 	0		; 7c0e
USER_B		fcb 	0
USER_P		fcb 	0
USER_DP		fcb 	0

BUFFER		fdb 	0,0,0
KEY			fcb 	0
KEY_CODE	fcb 	0
BRKPT		fcb 	0
BRK_VA		fcb 	0
BRK_AD		fdb 	0
FLAG		fcb 	0
VAR1		fcb 	0
STATE		fcb 	0
HIT			fcb 	0
N_REG		fcb 	0
NUM			fdb 	0
REG8		fcb 	0
REG16		fdb 	0
BUFFER1		fdb 	0,0,0
START		fdb 	0
END			fdb 	0
DESTI		fdb 	0
POSITIVE	fdb 	0
N_ERROR		fcb 	0
SFLAG		fcb 	0
FSTART		fdb 	0
FSTOP		fdb 	0
CHKSUM		fdb 	0
VARSH1		fcb 	0
VARSH2		fcb 	0
CHKSUMR		fdb 	0


IRQ_VECTOR	equ 	$7FF0		; vecteurs d'interruption du MCU
FIRQ_VECTOR	equ 	$7FF3
NMI_VECTOR	equ 	$7FF6
_KEY_USER	equ 	$7FF9
COUNT_VAR	equ	 	$7FFF

GPIO		equ		$8000		; définition des adresses des périphériques du kit
PORT0		equ		$8001
PORT1		equ		$8002
PORT2		equ		$8003

ACIA		equ		$8800
ACIA1		equ		$8801

LCD_cwr 	equ 	$9000
LCD_dwr 	equ 	$9001
LCD_crd 	equ 	$9002
LCD_drd 	equ 	$9003



			org $c000

main		
			lds #$7FE0			; début du programme principal
			sts SAVE_S
			ldx	#$7F00
			stx	USER_S
			ldx	#$7E00
			stx	USER_U
			ldx	#$200
			stx	PC
			stx SAVE_PC
			ldx #0
			stx USER_X
			stx USER_Y
			clr USER_A
			clr USER_B
			clr USER_DP
			tfr cc,a
			sta USER_P
			clr GPIO
			clr BRKPT
			clr HIT
			clr STATE
			lda #$FF
			sta FLAG

main0			
			lda #$7e
			sta IRQ_VECTOR       
			ldx #irq_serv
			stx IRQ_VECTOR+1

			lda #$3b
			sta FIRQ_VECTOR
			sta NMI_VECTOR
			lda #$39        	; store rts instruction
			sta _KEY_USER
   
			ldx #0
			stx FIRQ_VECTOR+1
			stx _KEY_USER+1
			clr COUNT_VAR
						
			jsr init_ACIA
			jsr init_LCD
			jsr cls_LCD
			
			jsr newline
			ldx #MESS1
			jsr pstring
			jsr newline
			ldx #MESS2
			jsr puts_LCD
			ldd #$0001
			jsr gotoxy
			ldx #MESS3
			jsr puts_LCD
			jsr intro
main1
			jsr	scan1			; boucle principale
			bra main1
	


irq_serv
			inc COUNT_VAR		; routine IRQ
			rti


swi_serv	
			sts USER_S
			lds SAVE_S
			lds USER_S	
			puls a				; routine SWI
			sta USER_P
			puls a
			sta USER_A
			puls a
			sta USER_B	
			puls a
			sta USER_DP
			puls x
			stx USER_X
			puls x
			stx USER_Y
			puls x
			stx USER_U
			puls x			
			stx SAVE_PC
			
			sts USER_S
			lds SAVE_S		; SWI_PC

			lda BRKPT
			cmpa #1
			bne swis1
			ldx SAVE_PC
			leax -1,x
			cmpx BRK_AD
			bne swis1
			stx SAVE_PC
			lda BRK_VA
			sta ,x
swis1						
			jmp key_PC
			
				
			
			
MESS1
			fcc "ENSIM - 6809 MICROPROCESSOR KIT 2022 - VERSION 10/01/23"
			fcb 00
			
MESS2
			fcc "6809 MICROPROCESSOR"
			fcb 0
MESS3
			fcc "32K RAM ACIA LCD"
			fcb 0
MESS4			
			fcc "Loading Motorola S-record"
			fcb 0
MESS5			
			fcc "] :"
			fcb 0			
MESS6			
			fcc "checksum errors!"
			fcb 0			
MESS7			
			fcc "0 error..."
			fcb 0			
		
init_ACIA
			lda #$03
			sta ACIA
			lda #$16
			sta ACIA
			nop
			lda ACIA1
			
			rts
		
		
clear_buffer
			pshs x				; vide le buffer d'affichage 7 seg
			ldx #BUFFER
			clra
clr_bf1			
			sta ,X+
			cmpx #BUFFER+6
			bne clr_bf1
			puls x
			rts

delay_intro
			pshs a				; tempo pour l'intro
			lda #$08
dl_intr1	
			pshs a
			jsr scan
			puls a
			deca
			bne dl_intr1
			puls a
			rts
			
intro
			bsr clear_buffer	; fait défiler 6809 sur l'afficheur
			lda #$AF
			sta BUFFER
			bsr delay_intro
			sta BUFFER+1
			lda #$BF
			sta BUFFER
			bsr delay_intro
			lda #$AF
			sta BUFFER+2
			lda #$BF
			sta BUFFER+1
			lda #$BD
			sta BUFFER
			bsr delay_intro
			lda #$AF
			sta BUFFER+3
			lda #$BF
			sta BUFFER+2
			lda #$BD
			sta BUFFER+1
			lda #$BE
			sta BUFFER
			bsr delay_intro
			lda #$AF
			sta BUFFER+4
			lda #$BF
			sta BUFFER+3
			lda #$BD
			sta BUFFER+2
			lda #$BE
			sta BUFFER+1
			clra
			sta BUFFER			
			bsr delay_intro
			lda #$AF
			sta BUFFER+5
			lda #$BF
			sta BUFFER+4
			lda #$BD
			sta BUFFER+3
			lda #$BE
			sta BUFFER+2
			clra
			sta BUFFER+1
			sta BUFFER			
			rts
			

delay_1ms		
			pshs x				; tempo 1ms
			ldx #$007f
delay_ms1
			nop
			nop
			leax -1,x
			bne delay_ms1
			puls x
			rts


scan1
			bsr scan			; assure la lecture du clavier et l'affichage
			cmpa #$ff			; puis appelle key_exe pour identifier les opérations
			bne scan1
			bsr delay_1ms
			bsr delay_1ms
			bsr delay_1ms
scan1a
			bsr scan
			cmpa #$ff
			beq scan1a
			bsr delay_1ms
			bsr delay_1ms
			bsr delay_1ms
			
			lda KEY
			jsr key_code	
			sta KEY_CODE

			jsr key_exe
			rts
			
		
			
scan
			clr PORT2			; lecture du clavier ($FF no key sinon [0..$25])
			lda #$ff
			sta KEY
			lda #$01
			sta VAR1
			ldb	#$01
			lda #$ff
			sta PORT1
			ldx #BUFFER
scan_1	
			lda ,x+			
			sta PORT2
			comb
			stb PORT1
			cmpa #$30
			bne scan_2
			cmpa #$38
			bne scan_2
			cmpa #$70
			bne scan_2
			bsr delay_1ms
scan_2
			bsr delay_1ms
			clr PORT2		
			bsr delay_1ms
		
			lda PORT0
			anda #$3F
			pshs a
			lda #$ff
			sta PORT1
			comb
			lslb
			cmpb #$40
			bne scan_1

scan_3		
			clrb
			puls a
			coma
scan_4
			bita #$01
			beq scan_5	
			pshs a
			lda VAR1
			sta KEY
			puls a
scan_5
			lsra
			incb
			inc VAR1
			cmpb #$06
			bne scan_4
			lda VAR1
			cmpa #$25
			bne scan_3	
			lda PORT0
			anda #$40
			bne scan_6
			lda #$25
			sta KEY
scan_6
			lda KEY
			rts

key_code
			ldx #tbl_kbcode		; convertit la valeur touche en key_code
			tfr a,b
			abx
			lda ,x
			rts
tbl_kbcode

			fcb 255,255,$16,$12,$17,$18,$1c,$15,$10,$11
			fcb $13,$19,$1d,0,4,8,12,$1b,$1e,1
			fcb 5,9,13,$1a,$1f,2,6,10,14,255
			fcb 255,3,7,11,15,255,255,$14,$20
			

dot_address
			pshs a,x				; place 4 dp sous l'adresse
			ldx #BUFFER
dotad1			
			lda ,x
			anda #$BF
			sta ,x+
			cpx #BUFFER+2
			bne dotad1
dotad2			
			lda ,x
			ora #$40
			sta ,x+
			cpx #BUFFER+6
			bne dotad2
			puls a,x
			rts
			

dot_reg
			pshs a,x				; place 2 dp sous les registres 8 bits
			ldx #BUFFER
dotreg1			
			lda ,x
			anda #$BF
			sta ,x+
			cmpx #BUFFER+2
			bne dotreg1
dotreg2
			lda ,x
			ora #$40
			sta ,x+
			cmpx #BUFFER+4
			bne dotreg2
dotreg3			
			lda ,x
			anda #$BF
			sta ,x+
			cmpx #BUFFER+6
			bne dotreg3
			puls a,x
			rts		

dot_data
			pshs a,x				; place 2 dp sous les data
			ldx #BUFFER
dotda1			
			lda ,x
			ora #$40			
			sta ,x+
			cpx #BUFFER+2
			bne dotda1
dotda2			
			lda ,x
			anda #$BF
			sta ,x+
			cpx #BUFFER+6
			bne dotda2
			puls a,x
			rts	
			
convert
			pshs x				; conv nb en chiffre pour 7 segments
			ldx #tb_conv
			abx
			ldb ,x
			puls x
			rts

tb_conv
			fcb $BD,$30,$9B,$BA,$36,$AE,$AF,$38
            fcb $BF,$BE,$3F,$A7,$8D,$B3,$8F,$0F
			
hex2seg
			tfr a,b					; affiche un nb hex sur l'aff 2 dig (droite)
			andb #$0f
			bsr convert
			stb BUFFER
			tfr a,b
			lsrb
			lsrb
			lsrb
			lsrb
			bsr convert
			stb BUFFER+1
			rts

hex2reg
			tfr a,b					; affiche un nb hex 2 dig  sur l'aff gauche
			andb #$0f
			bsr convert
			stb BUFFER+2
			tfr a,b
			lsrb
			lsrb
			lsrb
			lsrb
			bsr convert
			stb BUFFER+3
			clr BUFFER+4
			clr BUFFER+5
			rts
			
			
hex4seg
			pshs x				; affiche un nb hex sur l'aff 4 dig
			puls b
			tfr b,a
			andb #$0f
			bsr convert
			stb BUFFER+4
			tfr a,b
			lsrb
			lsrb
			lsrb
			lsrb
			bsr convert
			stb BUFFER+5
			puls b
			tfr b,a
			andb #$0f
			bsr convert
			stb BUFFER+2
			tfr a,b
			lsrb
			lsrb
			lsrb
			lsrb
			bsr convert
			stb BUFFER+3					
			rts		

address_display
			ldx PC				; affichage de l'adresse sur l'afficheur
			bra hex4seg

data_display
			ldx PC				; affichage de la donnée sur l'afficheur
			lda ,x
			bsr hex2seg
			jsr dot_data
			rts

read_memory
			bsr address_display	; mise à jour aff AAAA DD
			bsr data_display
			rts


key_ADDR
			lda #1				; touche ADDR
			sta STATE
			bsr read_memory
			jsr dot_address
			clr HIT
			rts


key_DATA
			lda STATE			; touche DATA
			cmpa #8
			beq keydat1
			cmpa #3
			beq keydat3
			
			jsr read_memory
			jsr dot_data
			clr HIT
			lda #2
			sta STATE
			rts	
keydat1		
			lda N_REG			; state=8
			cmpa #6
			blo keydat2
			cmpa #8
			blo keydat5		
			lda #3
			sta STATE
			ldx REG16
			jsr hex4seg
			rts
keydat2			
			lda #3
			sta STATE
			lda REG8
			jsr hex2reg
			rts	
keydat3
			lda N_REG			; state=3
			cmpa #6
			blo keydat4
			cmpa #8
			bhs keydat6
keydat5
			rts
keydat6
			lda #8
			sta STATE
			clr HIT
			jmp dot_address
keydat4		
			lda N_REG
			beq keydat5
			lda #8
			sta STATE
			clr HIT
			jmp dot_reg



key_PC
			ldx SAVE_PC			; touche PC
			stx PC
			jsr read_memory
			lda #2
			sta STATE
			rts
		
		
key_PLUS
			lda STATE			; touche PLUS
			cmpa #1
			beq keypp1
			cmpa #2
			bne keypp2
keypp1
			ldx PC
			leax 1,x
			stx PC
			jsr read_memory
			jsr key_DATA
			rts

keypp2
			cmpa #4
			bne keypp3
			ldd NUM
			std START
			lda #1
			sta POSITIVE
			clr HIT
			rts
keypp3			
			cmpa #5
			bne keypp4
			lda #6
			sta STATE
			ldd NUM
			std START
			clr HIT
			lda #$8f
			sta BUFFER
			rts
keypp4			
			cmpa #6
			bne keypp5
			lda #7
			sta STATE
			ldd NUM
			std END
			clr HIT
			lda #$b3
			sta BUFFER
			
			ldx END
			cpx START
			bhi keypp5
			bsr print_error
keypp5				
			rts			
			
print_error
			clr BUFFER
			clr BUFFER+1
			clr BUFFER+2
			lda #3
			sta BUFFER+3
			sta BUFFER+4
			lda #$8f
			sta BUFFER+5
			clr STATE
			rts

			

		
key_MINUS
			lda STATE			; touche MOINS
			cmpa #1
			beq keymm1
			cmpa #2
			beq keymm1
			cmpa #4
			bne keymm2
			ldd NUM
			std START
			clr POSITIVE
			clr HIT
keymm2
			rts		
keymm1
			ldx PC
			leax -1,x
			stx PC
			jsr read_memory
			jsr key_DATA
			rts


key_GO
			lda STATE
			cmpa #1
			beq keygo1
			cmpa #2
			bne keygo2
keygo1			
			lda BRKPT
			cmpa #1
			bne keygo1a
			ldx BRK_AD
			cmpx PC
			beq keygo1a
			lda ,x
			sta BRK_VA
			lda #$3F
			sta ,x
keygo1a				
			sts SAVE_S
			ldu USER_U
			lds USER_S
			leas 2,s
			ldd #sortie
			pshs d
			ldd PC
			pshs d
			lda USER_P
			tfr a,cc
			lda USER_DP
			tfr a,dp
	
			ldx USER_X
			ldy USER_Y
			lda USER_A
			ldb USER_B
		
			rts
sortie
			swi
			
keygo2			
			cmpa #4
			bne keygo5
			ldd NUM
			std DESTI
			lda POSITIVE
			bne keygo3
			ldd START
			subd DESTI
			std START
			bra keygo4
keygo3			
			ldd START
			addd DESTI
			std START
keygo4			
			ldx START
			jsr hex4seg
			clr HIT
			rts		
keygo5			
			cmpa #7
			bne keygo6
			ldd NUM
			std DESTI
			ldx START
			ldy DESTI
keygo5a			
			lda ,x+
			sta ,y+
			cpx END
			bne keygo5a
			lda ,x
			sta ,y
			ldx DESTI
			stx PC
			jsr read_memory
			jsr dot_data
			lda #2
			sta STATE
keygo6
			rts





key_exe
			ldb FLAG			; cette fonction identifie le keycode et
			bne keyex1			; oriente vers les fonctions	
			jsr beep
keyex1		
			lda KEY_CODE
			cmpa #$0F
			bls keyexb				
keyexa
			cmpa #$13			; Touche ADDR
			bne keyexa1
			jmp key_ADDR
keyexa1
			cmpa #$12			; Touche DATA
			bne	keyexa2
			jmp key_DATA
keyexa2		
			cmpa #$17			; Touche +
			bne keyexa3
			jmp key_PLUS
keyexa3	
			cmpa #$16			; Touche -
			bne keyexa4
			jmp key_MINUS
keyexa4				
			cmpa #$10			; Touche PC
			bne keyexa5
			jmp key_PC
keyexa5
			cmpa #$1b			; Touche GO
			bne keyexa6
			jmp key_GO
keyexa6		
			cmpa #$11			; Touche key_REG
			bne	keyexa7
			jmp key_REG
keyexa7
			cmpa #$18			; touche INS
			bne keyexa8
			jmp key_INS
keyexa8
			cmpa #$19			; touche DEL
			bne keyexa9
			jmp key_DEL
keyexa9		
			cmpa #$15			; touche SOUND ON/OFF
			bne keyexa10
			com FLAG
			rts
keyexa10
			cmpa #$1a			; Touche USER
			bne keyexa11
			jmp key_USER
keyexa11
			cmpa #$14			; Touche BRKPT
			bne keyexa12
			jmp key_SBR
keyexa12
			cmpa #$1d			; Touche CAL
			bne keyexa13
			jmp key_CAL
keyexa13
			cmpa #$1c			; Touche COPY
			bne keyexa14
			jmp key_COPY
keyexa14
			cmpa #$1e			; Touche DUMP
			bne keyexa15
			jmp key_DUMP
keyexa15
			cmpa #$1f			; Touche LOAD
			bne keyexa16
			jmp key_LOAD
keyexa16	
keyexa17			

keyexb
			ldb STATE			; aucune touche de fonction appuyée
			cmpb #1				; mais une touche hexanumérique est appuyée
			bne keyexb1			; (machine etat)
			jmp hex_address
keyexb1
			cmpb #2
			bne keyexb2
			jmp data_hex
keyexb2
			cmpb #3
			bne keyexb3
			jmp reg_display
keyexb3
			cmpb #8
			bne keyexb4
			jmp reg_mod
keyexb4					
			cmpb #4
			beq keyexb5
			cmpb #5
			beq keyexb5
			cmpb #6
			beq keyexb5
			cmpb #7
			beq keyexb5
			rts
keyexb5
			jmp enter_num


beep
			ldx #0040
			jsr tone1k
			rts
			
			
			
hex_address
			lda HIT				; modification de la zone address
			bne hexadd1
			clr PC
			clr PC+1
hexadd1
			lda #1
			sta HIT
			ldd PC
			lslb
			rola
			lslb
			rola
			lslb
			rola
			lslb
			rola
			orb KEY_CODE
			std PC
			jsr read_memory
			jsr dot_address
			rts

data_hex
			ldx PC				; modification de la zone data
			lda ,x
			ldb HIT
			bne datahx1
			clra
datahx1			
			ldb #1
			stb HIT
			lsla
			lsla
			lsla
			lsla
			ora KEY_CODE
			sta ,x
			jsr read_memory
			jsr dot_data
			rts
	
			
hex_8reg
			sta REG8
			lda HIT
			bne hex8reg1
			lda KEY_CODE
			bne hex8reg1
			clr REG8
hex8reg1			
			lda #1
			sta HIT
			lda REG8
			lsla
			lsla
			lsla
			lsla
			ora KEY_CODE
			sta REG8
			jsr hex2reg
			jsr dot_reg
			lda REG8
			rts


hex_16reg
			std REG16
			lda HIT
			bne hex16reg1
			lda KEY_CODE
			bne hex16reg1
			clr REG16
			clr REG16+1
hex16reg1			
			lda #1
			sta HIT
			ldd REG16
			lslb
			rola
			lslb
			rola
			lslb
			rola
			lslb
			rola
			orb KEY_CODE
			std REG16
			ldx REG16
			jsr hex4seg
			jsr dot_address
			ldd REG16
			rts
			
reg_mod
			lda N_REG
			cmpa #1
			bne regmod1			
			lda USER_A
			jsr hex_8reg
			sta USER_A
			rts
regmod1
			cmpa #2
			bne regmod2
			lda USER_B
			jsr hex_8reg
			sta USER_B
			rts			
regmod2
			cmpa #3
			bne regmod3
			lda USER_DP			
			jsr hex_8reg
			sta USER_DP
			rts			
regmod3
			
regmod5
		
regmod6
			cmpa #8
			bne regmod7
			ldd USER_S
			jsr hex_16reg
			std USER_S
			rts
regmod7			
			cmpa #9
			bne regmod8
			ldd USER_U
			jsr hex_16reg
			std USER_U
			rts	
regmod8

regmod9
			cmpa #11
			bne regmod10			
			ldd USER_A
			jsr hex_16reg
			std USER_A
			rts
regmod10
			cmpa #12
			bne regmod11
			ldd USER_X
			jsr hex_16reg
			std USER_X

regmod11
			cmpa #13
			bne regmod12
			ldd USER_Y
			jsr hex_16reg
			std USER_Y
regmod12			
			
			rts	


		

reg_display
			lda KEY_CODE
			cmpa #0
			lbeq acca
			cmpa #1
			lbeq accb		
			cmpa #2
			lbeq accd		
			cmpa #4
			lbeq hi_CC		
			cmpa #5
			lbeq low_CC			
			cmpa #6
			lbeq indX		
			cmpa #7
			lbeq indY		
			cmpa #8
			lbeq reg_DP		
			cmpa #9
			beq reg_U		
			cmpa #10
			beq reg_S	

			
			rts	
			
reg_S
			ldx USER_S
			stx REG16
			jsr hex4seg
			lda #8
			sta N_REG
			lda #$ae
			sta BUFFER
			clr BUFFER+1
			rts
			
reg_U			
			ldx USER_U
			stx REG16
			jsr hex4seg
			lda #9
			sta N_REG
			lda #$b5
			sta BUFFER
			clr BUFFER+1
			rts	
		
						
acca
			lda USER_A
			sta REG8
			jsr hex2reg
			lda #1
			sta N_REG
			lda #$3f
			sta BUFFER
			clr BUFFER+1
			rts

accb			
			lda USER_B
			sta REG8
			jsr hex2reg
			lda #2
			sta N_REG
			lda #$a7
			sta BUFFER
			clr BUFFER+1
			rts

accd
			ldx USER_A
			stx REG16
			jsr hex4seg
			lda #11
			sta N_REG
			lda #$a7
			sta BUFFER
			lda #$3f
			sta BUFFER+1
			rts			
			
			
indX
			ldx USER_X
			stx REG16
			jsr hex4seg
			lda #12
			sta N_REG
			lda #$13
			sta BUFFER
			clr BUFFER+1
			rts

indY			
			ldx USER_Y
			stx REG16
			jsr hex4seg
			lda #13
			sta N_REG
			lda #$b6
			sta BUFFER
			clr BUFFER+1
			rts
		
			
hi_CC
			ldb USER_P
			stb REG8
			lda #$30
			bitb #$10
			bne hi_CC2
			lda #$BD
hi_CC2
			sta BUFFER+2
			lda #$30
			bitb #$20
			bne hi_CC3
			lda #$BD
hi_CC3
			sta BUFFER+3			
			lda #$30
			bitb #$40
			bne hi_CC4
			lda #$BD
hi_CC4
			sta BUFFER+4
			lda #$30
			bitb #$80
			bne hi_CC5
			lda #$BD
hi_CC5
			sta BUFFER+5			
			lda #6
			sta N_REG
			lda #$8d
			sta BUFFER+1
			lda #$37
			sta BUFFER
			rts
			
			
			
low_CC			
			ldb USER_P
			stb REG8
low_CC1
			lda #$30
			bitb #$01
			bne low_CC2
			lda #$BD
low_CC2
			sta BUFFER+2
			lda #$30
			bitb #$02
			bne low_CC3
			lda #$BD
low_CC3
			sta BUFFER+3			
			lda #$30
			bitb #$04
			bne low_CC4
			lda #$BD
low_CC4
			sta BUFFER+4
			lda #$30
			bitb #$08
			bne low_CC5
			lda #$BD
low_CC5
			sta BUFFER+5			
			lda #7
			sta N_REG
			lda #$8d
			sta BUFFER+1
			lda #$85
			sta BUFFER			
			rts			
reg_DP
			lda USER_DP
			sta REG8
			jsr hex2reg
			lda #3
			sta N_REG
			lda #$1F
			sta BUFFER
			lda #$B3
			sta BUFFER+1
			rts			


			
enter_num
			lda HIT
			bne enternm1
			clr NUM
			clr NUM+1
enternm1	
			lda #1
			sta HIT
			ldd NUM
			lslb
			rola
			lslb
			rola
			lslb
			rola
			lslb
			rola
			orb KEY_CODE
			std NUM
			ldx NUM
			jsr hex4seg
			rts

			

key_USER
			jsr _KEY_USER		; Touche USER
			rts
			

key_REG
			clr BUFFER+7		; touche REG
			clr BUFFER+6
			clr BUFFER+2
			clr BUFFER+1
			clr BUFFER+0
			lda #3
			sta BUFFER+5
			lda #$8F
			sta BUFFER+4
			lda #$AD
			sta BUFFER+3

			lda #3
			sta STATE
			clr N_REG
			rts

key_INS
			lda STATE
			cmpa #1
			beq insert1
			cmpa #2
			beq insert1
			rts
			
insert1		
			ldd PC
			addd #$200
			tfr d,x
			tfr d,y
			leax -1,x	
insert2
			lda ,-x			
			sta ,-y
			cmpx PC			
			bne insert2
			clra
			sta ,x		
			jsr read_memory
			lda #2
			sta STATE
			rts
	
key_DEL
			lda STATE
			cmpa #1
			beq kdel1
			cmpa #2
			beq kdel1
			rts
			
kdel1		ldd PC
			addd #$1FF
			std REG16
			ldx PC
			pshs x
			puls y
			leay 1,y
kdel2
			lda ,y+
			sta ,x+
			cpx REG16
			bne kdel2
			jsr read_memory
			lda #2
			sta STATE
			rts
		
cpybuff
			ldx #BUFFER			; copie buffer vers buffer1
			ldy #BUFFER1
cpybuff1			
			lda ,x+
			sta ,y+
			cpx #BUFFER+6
			bne cpybuff1
			rts
		
cpyrbuff
			ldx #BUFFER			; copie buffer1 vers buffer
			ldy #BUFFER1
cpyrbuff1			
			lda ,y+
			sta ,x+
			cpx #BUFFER+6
			bne cpyrbuff1
			rts

			
setbrk
			bsr cpybuff			; message Set brkpt
			lda #$03
			sta BUFFER
			lda #$a7
			sta BUFFER+1
			clr BUFFER+2
			lda #$07
			sta BUFFER+3
			lda #$8f
			sta BUFFER+4
			lda #$ae
			sta BUFFER+5
			bsr scbrk
			bsr cpyrbuff
			rts
			
clrbrk
			bsr cpybuff			; message Clr brkpt
			lda #$03
			sta BUFFER
			lda #$a7
			sta BUFFER+1
			clr BUFFER+2
			lda #$03
			sta BUFFER+3
			lda #$05
			sta BUFFER+4
			lda #$8d
			sta BUFFER+5
			bsr scbrk
			bsr cpyrbuff		
			rts
			
scbrk
			ldb #$20
scbrk1
			pshs b
			jsr scan
			puls b
			decb
			bne scbrk1
			rts
			
key_SBR
			lda BRKPT
			cmpa #1
			bne keysbr1	
			ldx BRK_AD
			cmpx PC
			bne keysbr1	
			
			clr BRKPT
			ldx #$FFFF
			stx BRK_AD
			bra clrbrk
	
keysbr1			
			lda #1
			sta BRKPT
			ldx PC
			stx BRK_AD
			bra setbrk
			
key_COPY
			lda #5
			sta STATE
			clr HIT
			jsr clear_buffer
			lda #$bd
			sta BUFFER+2
			clr BUFFER+1
			lda #$ae
			sta BUFFER
			rts
			
	
			
key_CAL			
			lda #4
			sta STATE
			jsr clear_buffer
			lda #$bd
			sta BUFFER+2
			ldx #$0000
			stx START
			stx DESTI
			clr HIT
			rts
			

key_DUMP
			ldb #$10
kdump1		
			pshs b
			ldx PC	
			jsr newline
			pshs x
			pshs x
			jsr out4x
			puls x
			puls y
			
			lda #':'
			jsr cout
			ldb #$10
kdump2	
			pshs b
			lda ,x+
			jsr out2x
			lda #' '
			jsr cout
			puls b
			decb
			bne kdump2
			
			ldb #$10
kdump3			
			pshs b
			lda ,y+
			cmpa #$20
			blo kdump5
			cmpa #$80
			bhs kdump5
kdump4					
			jsr cout
			puls b
			decb
			bne kdump3
			stx PC
			jsr newline
			puls b
			decb
			bne kdump1	
			jmp key_ADDR
kdump5			
			lda #'.'
			bra kdump4

			
read_S
			clr N_ERROR
			clr SFLAG
rds0
			jsr cin
			cmpa #'S'
			bne rds0
			jsr cin
			cmpa #'0'
			beq rds0
			cmpa #'1'  
			bne rds3  
	  
			clr CHKSUM
			jsr gethex
			tfr a,b
			subb #$03
			bsr gethex16
rds1
			bsr gethex
			sta ,x+
			decb
			bne rds1
			lda CHKSUM
			coma
			sta CHKSUMR
			sta GPIO
			bsr gethex
			cmpa CHKSUMR
			beq rds2
			inc N_ERROR
rds2
			bra rds0
rds3
			cmpa #'9'  
			bne rds0
			leax -1,x		
			stx FSTOP
			clr GPIO
			rts
	
gethex
			bsr getchar1
			lsla
			lsla
			lsla
			lsla
			sta VARSH2
			bsr getchar1
			anda #$0f
			ora VARSH2
			pshs a
			adda CHKSUM
			sta CHKSUM
			puls a
			rts	
gethex16
			bsr gethex
			sta VARSH1
			bsr gethex
			sta VARSH2
			ldx VARSH1
			lda SFLAG
			bne gethex1a
			stx FSTART
			inc SFLAG
gethex1a
			rts
		
getchar1
			jsr cin
			cmpa #$40
			blt gtrs1
			suba #$07
gtrs1	
			suba #$30
			rts
	
			
			
			
key_LOAD
			jsr newline
			ldx #MESS4
			jsr pstring
			jsr newline
			jsr read_S
			jsr newline
			lda #'['
			jsr cout
			ldx FSTART
			jsr out4x
			lda #'-'
			jsr cout
			ldx FSTOP
			jsr out4x
			ldx #MESS5
			jsr pstring
			lda N_ERROR
			ldx #MESS7
			bne keyld1
			ldx #MESS6
keyld1
			jsr pstring
			jsr newline
			ldx FSTART
			stx SAVE_PC
			jmp key_ADDR

			

					

			org	$F000	 		; fonctions utiles pour le contrôle des périphèriques du kit

init_LCD
			pshs a	         	; initialise l'afficheur LCD du kit
			bsr	l_ready
			lda	#$38
			sta LCD_cwr
			bsr	l_ready
			lda	#$03
			sta LCD_cwr
			bsr	l_ready
			lda	#$0C
			sta LCD_cwr
			puls a
			rts

		
		
l_ready					
			pshs x         		; attend que l'afficheur soit prêt
			ldx	#$0090		
l_rdy1
			lda LCD_crd
			bita #$80
			beq l_rdy2
			leax -1,x
			bne l_rdy1	
l_rdy2
			puls x
			rts

cls_LCD						
			pshs a				; efface l'écran
			bsr l_ready
			lda	#$01
			sta	LCD_cwr
			puls a
			rts	
		
cursor
			pshs a				; active ou désactive le curseur
			bsr l_ready
			puls a		
			anda #$03
			ora	 #$0C
			sta LCD_cwr
			rts

putch_LCD
			pshs a				; affiche un caractère sur l'écran LCD
			bsr l_ready
			puls a
			sta	LCD_dwr
			rts	
	
puts_LCD
			pshs a				; affiche une chaîne de caractères sur l'écran LCD
puts1
			bsr l_ready
			lda ,x+
			cmpa #$00
			beq	puts2
			bsr putch_LCD
			bra puts1
puts2
			puls a
			rts

gotoxy				
			pshs x				; place le curseur en X,Y
			ldx	#xy_v
			andb #$03
			abx
			tfr a,b
			adda ,x
			tfr a,b
			bsr l_ready
			stb	LCD_cwr
			puls x
			rts
		
xy_v	fcb	$80,$c0,$94,$d4				
			

hex1
			anda #$0f			; affiche 1 car hexa
			cmpa #10
			bcc	hex1a
			adda #'0'
			bra putch_LCD
hex1a	
			suba #10
			adda #'A'
			bra putch_LCD
		
printhex
			pshs a				; affiche un nombre hexa (2 digits)
			lsra
			lsra
			lsra
			lsra
			bsr hex1
			puls a
			bsr	hex1
			rts
		
printhex4
			pshs a,b				; affiche un nombre hexa (4 digits)

			exg d,x
			bsr printhex
			tfr b,a
			bsr printhex
			puls a,b
			rts
	
printint
			pshs b				; affiche un nombre décimal (3 digits)
			clrb
prt1		cmpa #$64
			bcs prt2
			suba #$64
			incb
			bra prt1
prt2		pshs a		
			tfr b,a
			bsr lputn
			puls a
			clrb
prt3		cmpa #10
			bcs prt4
			suba #10
			incb
			bra prt3
prt4		pshs a		
			tfr b,a
			bsr lputn
			puls a
			bsr lputn
			puls b
			rts
		
lputn		adda #'0'
			jmp putch_LCD
 		
		
delay2
			pshs x				; delay env 0.2s
			ldx	#$9832
dly1		nop
			leax -1,x
			bne dly1
			puls x
			rts

		
delay5
			bsr delay2				; delay env 0.5s
			nop
			bsr delay2
			rts

ttone
			pshs x
			ldx	#$002E
ttone1
			leax -1,x
			bne ttone1
			puls x
			rts

		
tone1k
		
			pshs a				; son @1kHz
t1k1
			lda #$7f
			sta $8002
			bsr ttone
			bsr ttone
			lda #$ff
			sta $8002
			bsr ttone
			bsr ttone
			leax -1,x
			bne t1k1
			puls a
			rts
	
	
tone2k
			pshs a				; son @2kHz
t2k1
			lda #$7f
			sta $8002
			bsr ttone		
			lda #$ff
			sta $8002
			bsr ttone
			leax -1,x
			bne t2k1
			puls a
			rts		
		

				
cin
		lda $8800		; lecture d'un car sur la liaison série
		anda #$01
		beq cin
		lda $8801
		rts
		
		
cout	pshs a			; envoi 1 car sur la liaison série
cout1	lda	$8800
		anda #$02
		beq	cout1
		puls a
		sta $8801
		rts
		
newline				
		lda #13			; passe à la ligne suivante
		bsr cout
        lda #10
		bra cout

pstring
		pshs a			; envoi une chaîne de caractères au terminal
pstr1	lda ,x+
		cmpa #$00
		beq	pstr2
		bsr cout
		bra pstr1

pstr2	puls a
		rts	
	
out1x_	
		anda #$0f		; envoi 1 car hexa au terminal
		cmpa #10
		bcc	out1a_
		adda #'0'
		bra cout
out1a_	suba #10
		adda #'A'
		bra cout
	
	
out2x
		pshs a			; envoi un nombre hexa (2 digits) au terminal
		lsra
		lsra
		lsra
		lsra
		bsr out1x_
		puls a
		bra	out1x_

out4x
		pshs a,b		; envoi un nombre hexa (4 digits) au terminal
		pshs x
		puls a,b
		bsr out2x
		exg a,b
		bsr out2x
		puls a,b
		rts		
		
outint	
		pshs b			; affiche un nombre décimal au terminal (3 digits)
		clrb
outn1	cmpa #$64
		bcs outn2
		suba #$64
		incb
		bra outn1
outn2	pshs a		
		exg a,b
		bsr outn
		puls a
		clrb
outn3	cmpa #10
		bcs outn4
		suba #10
		incb
		bra outn3
outn4	pshs a		
		exg a,b
		bsr outn
		puls a
		bsr outn
		puls b
		rts
		
outn	adda #'0'
		bra cout
	
			
scankb
			clr PORT2		; lecture du clavier ($FF no key [0..$25])
			lda #$ff
			sta VARSH2
			lda #$01
			sta VARSH1
			ldb	#$01
rd_kb1		
			comb
			stb PORT1
			lda PORT0
			anda #$3F
			pshs a
			comb
			lslb
			cmpb #$40
			bne rd_kb1
rd_kb2		
			clrb
			puls a
			coma
rd_kb3
			bita #$01
			beq rd_kb4	
			pshs a
			lda VARSH1
			sta VARSH2
			puls a
rd_kb4
			lsra
			incb
			inc VARSH1
			cmpb #$06
			bne rd_kb3
		
			lda VARSH1
			cmpa #$25
			bne rd_kb2
		
			lda PORT0
			anda #$40
			bne rd_kb5
			lda #$25
			sta VARSH2
rd_kb5
			lda VARSH2
			bmi rd_kb6
			ldx #tbl_kb1
			tfr a,b
			abx
			lda ,x
rd_kb6		
			rts
		
tbl_kb1
			fcb 255,255,14,13,6,31,24,22,29,21,5,23,16,1,9,17,25,7,8,2,10
			fcb 18,26,15,0,3,11,19,27,255,255,4,12,20,28,255,255,30 



			
			org $F300				; fonctions extension 1 et 2
			

init_AY
		clra
initAY1		
		sta $b010
		clr $b011
		inca
		cmpa #$10
		bne initAY1		
		lda #$07
		sta $b010
		lda #$38
		sta $b011
		rts
		

mute_AY
		pshs a				; volume =0
		lda #$08
mute1		
		sta $b010
		clr $b011
		inca
		cmpa #$0b
		bne mute1
		puls a
		rts
		
		
volume
		pshs b			; définit le volume des 3 voies
		anda #$0f
		ldb #$08
volume1
		stb $b010
		sta $b011
		incb
		cmpb #$0b
		bne volume1
		puls b
		rts
		
		
play_A
		pshs a,b		; joue une fréquence sur la voie A
		lda #$01
play_1
		sta $b010
		pshs a
		pshs x
		puls a,b
		anda #$0f
		sta $b011
		puls a
		deca
		sta $b010
		stb $b011
		puls a,b
		rts
		
play_B
		pshs a,b		; joue une fréquence sur la voie B
		lda #$03
		bra play_1
		
play_C
		pshs a,b		; joue une fréquence sur la voie C
		lda #$05
		bra play_1		

		
conversion
		sta $B030		; lance une conversion A/N
		lda #$10
conv1	nop
		deca
		bne conv1
		lda $B030
		rts

		
modeIO
		pshs b			; définit le mode des IOs
		anda #$C0
		tfr a,b
		lda #$07
		sta $b010
		lda $b011
		anda #$3F
		bitb #$80
		beq modeIO1
		ora #$80
modeIO1
		bitb #$40
		beq modeIO2
		ora #$40
modeIO2
		sta $b011
		puls b
		rts

read_AY_A
		lda #$0f		; lecture Port IOA
		sta $b010	
		lda $B011
		rts

writeAY_A
		pshs a			; écriture Port IOA
		lda #$0f		
		sta $b010
		puls a
		sta $B011
		rts
		
read_AY_B
		lda #$0e		; lecture Port IOB		
		sta $b010	
		lda $B011
		rts
	
writeAY_B
		pshs a			; écriture Port IOB
		lda #$0e		
		sta $b010
		puls a
		sta $B011
		rts			

	
RomRD
		sta $b03a
		pshs x		; lecture de la ROM indirecte
		puls a
		sta $b039
		puls a
		sta $b038
		lda $b03b
		rts		


		
*
* lecteur MYM
*


FRAG    	equ     128     ; Fragment size
REGS    	equ     14      ; Number of PSG registers
FBITS   	equ     7       ; Bits needed to store fragment offset

*
*	A=N° du bloc de 8K en NVRAM [0..15] pour 128K
*	B=0 -> mym en RAM à partir de 3000h
*   B=1 -> mym en NVRAM
*   les données décompressées sont stockées à partir de 5000h
*


	
		org $F400
playmym		
		clr source		; data @ Y
		bra mym1
playmymR
		lda #7			; b=N° musique
		ldx #$ffc0
		abx
		jsr RomRD		; lecture N° bloc
		cmpa #$ff
		bne playmymR2
		rts
playmymR2
		sta Nbloc		; data en ROM
		lda #1
		sta source
		ldy #0			; data at $0000 (NVRAM)

mym1:			
		clr cad			; y = pointeur data
		jsr RD_ram
		tfr a,b
		jsr RD_ram
		std rows
		clr reg_Dp
		lda #1
		sta reg_Ep
		clr fin				
		ldx #uncomp
		stx dest1
		ldx #uncomp+256
		stx dest2
		stx psource 
		lda #FRAG
		sta played
		ldx #0
		stx prows
		jsr extract

* détourne les int		
		ldx #interrupt
		stx $7ff1
		lda #$7E	* jmp interrupt
		sta $7ff0
		andcc #$EF	* autorise int

mainloop
		jsr extract

waitvb		
		lda played
		bne waitvb
		ldx next_VBI
		stx psource
		lda #FRAG
		sta played
		lda fin
		beq mainloop
waitvb1		
		lda played
		bne waitvb1
quit
		orcc #$10	* désactive int
		lda #$3B	* rti
		sta $7FF0
		jmp mute_AY

extract
		clrb
regloop
		pshs b
		ldx #regbits
		abx
		lda ,x
		sta reg_D
		ldx #current
		abx
		lda ,x
		sta reg_E
		
		ldd dest1
		std dest3
		addd #512
		std dest1
			
		ldx dest2
		tfr x,d
		addd #512
		std dest2
		
		lda #FRAG
		sta reg_Ap
		ldb #1
		jsr readbits	
		bne compfrag
		
		ldb #FRAG
sweep
		lda reg_E
		sta ,x+
		pshs x
		ldx dest3
		sta ,x+
		stx dest3
		puls x	
		decb
		bne sweep
		lbra nextreg
		
compfrag
		ldb #1
		jsr readbits
		bne notprev
		lda reg_E
		sta ,x+
		pshs x
		ldx dest3
		sta ,x+
		stx dest3
		puls x	
		dec reg_Ap
		bra nextbit

notprev
		ldb #1
		jsr readbits
		beq packed
		ldb reg_D
		jsr readbits
		sta reg_E
		sta ,x+
		pshs x
		ldx dest3
		sta ,x+
		stx dest3
		puls x
		dec reg_Ap
		bra nextbit
		
packed
		ldb #FBITS
		jsr readbits
		sta reg_C
		ldb #FBITS
		jsr readbits
		sta reg_B
		
		pshs x
		tfr x,d
		subd #FRAG
		tfr d,x
		ldb reg_C		
		abx
		stx reg_IY
		ldb reg_B
		puls x		
		incb
		pshs y
		ldy reg_IY
copy
		lda ,y+
		sta reg_E		
		sta ,x+
		pshs x
		ldx dest3
		sta ,x+
		stx dest3
		puls x
		dec reg_Ap
		decb
		bne copy
		sty reg_IY
		puls y
		
nextbit
		lda reg_Ap
		lbne compfrag

		
nextreg
		puls b
		pshs x
		ldx #current
		abx
		lda reg_E
		sta ,x
		puls x
		incb
		cmpb #REGS
		lbne regloop
		
		tfr x,d
		subd #rows	
		bne nowrap

		ldx #uncomp
		stx dest1
		ldx #uncomp+256
		stx dest2
		ldx #uncomp+384
		stx reg_IY
		bra endext

nowrap
		ldx #uncomp+128
		stx dest1
		ldx #uncomp+384
		stx dest2
		ldx #uncomp+256
		stx reg_IY

endext
		ldd prows
		addd #FRAG
		std prows
		subd rows
		bcs noend
		
		lda #1
		sta fin
noend
		pshs x
		ldx reg_IY
		stx next_VBI
		puls x
		rts
	
* reads B bits from data, returns bits in A
readbits
		clr reg_Cp
onebit		
		lsl reg_Cp
		lsr reg_Ep
		bcc nonew
		lda #$80
		sta reg_Ep
		bsr RD_ram
		sta reg_Dp
nonew
		lda reg_Ep
		anda reg_Dp
		beq zero
		inc reg_Cp
zero
		decb
		bne onebit
		lda reg_Cp
		rts


interrupt
		pshs a,b,x
		lda cad
		eora #$ff
		sta cad
		beq endint
	
		ldx psource
		clrb
ploop
		stb $b010
		lda ,x+
		sta $b011
		incb
		pshs b
		tfr x,d
		addd #511
		tfr d,x
		puls b
		cmpb #REGS-1
		bne ploop
		
		lda ,x
		cmpa #$ff
		beq notrig
		ldb #13
		stb $b010
		sta $b011
		
notrig
		ldx psource
		leax 1,x
		stx psource
		lda played
		beq endint
		dec played
endint
		puls a,b,x
		rti

RD_ram
		lda source
		bne RD_DTROM
		lda ,y+
		rts
		
RD_DTROM
		pshs b
		tfr y,d
		clr reg_L
		
		stb $b038
		ldb Nbloc
		lslb
		lslb
		rol reg_L
		lslb
		rol reg_L
		lslb
		rol reg_L
		lslb
		rol reg_L
		stb reg_H
		adda reg_H
		sta $b039
		lda reg_L
		sta $b03a
		puls b		
		lda ,y+
		lda $b03b
		rts
	
		
* *** Program data
* Bits per PSG register
regbits 	fcb    8,4,8,4,8,4,5,8,5,5,5,8,8,8		


		org $F690
playSONGS
		clrb
playSONGS1	
		pshs b
		jsr playmymR
		puls b
		incb
		cmpb #$40
		bne playSONGS1
		rts




		org $5800
		
* VBI counter

played 		fcb     0
* Uncompress destination 1
dest1 	 	fdb     0   
* Uncompress destination 2    
dest2  		fdb     0       
dest3		fdb		0
* Playing offset for the VB-player
psource 	fdb    	0       
* Rows played so far
prows  		fdb     0       
next_VBI	fdb		0
fin			fcb		0
cad			fcb		0
source		fcb		0
Nbloc		fcb		0
reg_Ap		fcb		0
reg_D		fcb		0
reg_E		fcb		0
reg_Cp		fcb		0
reg_Dp		fcb		0
reg_Ep		fcb		0
reg_IY		fdb		0
reg_B		fcb		0
reg_C		fcb		0
reg_L		fcb		0
reg_H		fcb		0


* Current values of PSG registers
current 	fcb    0,0,0,0,0,0,0,0,0,0,0,0,0,0

* Reserve room for uncompressed data
uncomp		rmb	4*FRAG*REGS	
rows		fdb 0
						

						
		org $F700		; fonction extension 3

init_I2C
		lda $b003
		anda #$fb
		sta $b003
		lda $b002
		anda #$7F
		sta $b002
		lda $b003
		anda #$c7
		ora #$34
		sta $b003
		lda $b001
		anda #$c7
		ora #$30
		sta $b001
		rts
		
sda_0
		lda $b003		; sda=0
		anda #$c7
		ora #$38
		sta $b003
		rts

sda_1
		lda $b003		; sda=1
		anda #$c7
		ora #$30
		sta $b003
		rts


scl_0
		lda $b001		; scl=0 $f93d
		anda #$c7
		ora #$38
		sta $b001
		rts

scl_1		
		lda $b001		; scl=1
		anda #$c7
		ora #$30
		sta $b001
		rts
		
clk_scl
		bsr scl_1
		bsr scl_0
		rts					
					

start_I2C	
		bsr scl_1
		nop
		bsr sda_0
		nop
		bsr scl_0
		rts

stop_I2C
		bsr sda_0
		bsr scl_1
		nop
		bsr sda_1
		rts
		

writei2c
		ldb	#$08
wri2c0		
		pshs a
		bita #$80		
		bne wri2c1		
		bsr sda_0
		bra wri2c2
wri2c1
		bsr sda_1
wri2c2
		bsr clk_scl
		puls a
		lsla
		decb
		bne wri2c0
		bsr sda_1
		bsr scl_1
		lda $b002
		bsr scl_0
		anda #$80
		rts
		
readi2c		
		bsr sda_1
		ldb	#$08
		clra
		pshs a
readi2c1		
		bsr scl_1
		lda $b002
		pshs a
		bsr scl_0
		puls a
		lsla
		puls a
		rola
		pshs a
		decb
		bne readi2c1
		puls a
		rts

RD_ack
		pshs a
		lbsr sda_0
		lbsr clk_scl
		puls a
		rts

RD_nack
		pshs a
		lbsr sda_1
		lbsr clk_scl
		puls a
		rts
		
		
WR_adr1
		pshs b			; START+1 octet
		pshs a
		bsr start_I2C
		puls a
		bsr writei2c
		puls a
		bsr writei2c
		rts
		
		
WR_adr2		
		pshs x			; START+2 octets
		pshs a
		bsr start_I2C
		puls a
		bsr writei2c
		puls a
		bsr writei2c
		puls a
		bsr writei2c
		rts
				

WRT_RTC
		lda #$a0		; écriture zone RTC depuis X (16 o)
		ldb #$00
		bsr WR_adr1
		bne	WRC2		; no response
		ldb #$10
WRC1
		lda ,x+
		pshs b
		lbsr writei2c
		puls b
		decb
		bne WRC1
WRC2		
		lbsr stop_I2C
		rts
						
		
RDT_RTC
		lda #$a0		; lecture zone RTC vers X (16 o)
		ldb #$00
		bsr WR_adr1
		bne	WRC2		; no response
		lbsr start_I2C
		lda #$a1
		lbsr writei2c
		ldb #$0f
RDC1
		pshs b
		lbsr readi2c
		bsr RD_ack
		sta ,x+
		puls b
		decb
		bne RDC1
		lbsr readi2c
		lbsr RD_nack
		sta ,x
RDC2		
		lbsr stop_I2C
		rts

	
WRM_RTC	
		lda #$a0		; écriture zone RTC depuis X
		ldb #$10
		bsr WR_adr1
		bne	WRC2		; no response
		ldb #$F0
		bra WRC1
		

RDM_RTC	
		lda #$a0		; lecture zone RTC vers X
		ldb #$10
		bsr WR_adr1
		bne	WRC2		; no response
		lbsr start_I2C
		lda #$a1
		lbsr writei2c
		ldb #$ef
		bra RDC1

WR_EE
		pshs a			; écriture 1 octet EEPROM @ X
		lda #$a8
		bsr WR_adr2
		puls a
		lbsr writei2c	
		lbsr stop_I2C
		rts	

RD_EE
		lda #$a8		; lecture 1 octet EEPROM @ X
		lbsr WR_adr2
		lbsr start_I2C
		lda #$a9
		lbsr writei2c
		lbsr readi2c
		lbsr RD_nack
		pshs a
RDEE1
		lbsr stop_I2C
		puls a
		rts	

WR_EEP
		pshs Y
		lda #$a8		; écriture page EEPROM depuis X
		lbsr WR_adr2
		bne	RDEE1		; no response
		puls X
		ldb #$80
		lbra WRC1

			
RD_EEP		
		pshs Y
		lda #$a8		; lecture page EEPROM depuis X
		lbsr WR_adr2
		lbsr start_I2C
		lda #$a9
		lbsr writei2c
		puls X
		ldb #$7f
		lbra RDC1

		
					
					
* Vecteurs d'interruption			
			

			org  $fffe			; RESET vector
			FDB  main

			org $fffc			; nmi vector
			fdb $7ff6
			
			org $fff6        	;firq vector
			fdb $7ff3
			
			org $fffa			; SWI vector
			fdb swi_serv
			
			org $fff8			; IRQ vector
			fdb $7FF0
			
			
	
