;*****************************************************************
;* This stationery serves as the framework for a                 *
;* user application (single file, absolute assembly application) *
;* For a more comprehensive program that                         *
;* demonstrates the more advanced functionality of this          *
;* processor, please see the demonstration applications          *
;* located in the examples subdirectory of the                   *
;* Freescale CodeWarrior for the HC12 Program directory          *
;*****************************************************************

; export symbols
            XDEF Entry, _Startup            ; export 'Entry' symbol
            ABSENTRY Entry        ; for absolute assembly: mark this as application entry point



; Include derivative-specific definitions 
		INCLUDE 'derivative.inc' 

ROMStart    EQU  $4000  ; absolute address to place my code/constant data

; variable/data section

            ORG RAMStart
 ; Insert here your data definition.
Counter     DS.W 1
FiboRes     DS.W 1
  

; code section
            ORG   ROMStart


Entry:
_Startup:
            LDS   #RAMEnd+1         ; initialize the stack pointer

            CLI                     ; enable interrupts
mainLoop:
          
                      
                      
            
            
InitSPI:    ;initialize the SPI
        
            BSET MODRR,#$10         
            MOVB #$52,SPI0CR1
            MOVB #$10,SPI0CR2 
            MOVB #$00,SPI0BR 
            LDAB SPI0BR
            LDAB SPI0DR
            
            
            
            
InitLCD:    ;initialize the LCD        
            
            LDAA #%00110011           ;load two 4-bit sequences into A
            JSR  SENDINST             ;send instruction to SPI  
            
            LDAA #%00110010           ;load two 4-bit sequences into A
            JSR  SENDINST             ;send instruction to SPI     
            
            LDAA #%00101000           ;load two 4-bit sequences into A
            JSR  SENDINST             ;send instruction to SPI  
                                             
            LDAA #%00001000           ;load two 4-bit sequences into A
            JSR  SENDINST             ;send instruction to SPI  
            
            LDAA #%00000001           ;load two 4-bit sequences into A
            JSR  SENDINST             ;send instruction to SPI  
          
            LDAA #%00000110           ;load two 4-bit sequences into A
            JSR  SENDINST             ;send instruction to SPI  
            
            LDAA #$0F                 ;turn LCD display, cursor, blinking of cursor on   
            JSR SENDINST              ;send instruction to SPI
            
            
            
            
InitBuzz:   ;initialize the buzzer       
          
            MOVB #$01,DDRT       
            MOVB #$01,PTT             ;turning on the buzzer
            MOVB #$C7,MCCTL           ;initialize the MCCTL to prepare delay
            
            
            
                      
InitPB:     ;initializing push buttons SW1 and SW2
            
            MOVB  #$FC,DDRP           ;set bits 0 and 1, corresponding to SW1 and SW2, to 0 to set them as inputs
            MOVB  #$00,RDRP           ;set to 0 since pins are used as input
            MOVB  #$03,PERP           ;set bits 0 and 1 to 1 to enable pull device
            MOVB  #$00,PPSP           ;set bits 0 and 1 to 0 since push buttons are active low (pull-up device selected; falling edge selected) 
            
 
          
          
IntrPB:     ;push buttons interrupt
                                     
            MOVB  #$03,PIFP           ;interrupt flag is set to bits 0 and 1
            CLRA                      ;clear A
            LDAA  PTP                 ;load the status of port P into register A
            ANDA  #%00000011          ;clear bits 3->8 while preserving bits 1 and 2            
            CMPA  #%00000010          ;check if SW1 was pressed
            LBEQ   SONG1              ;play song 1
            CMPA  #%00000001          ;check if SW2 was pressed
            LBEQ  SONG2               ;play song 2
            BRA   IntrPB              ;branch back to repeat
            RTI                       ;return from interrupt
            

            
              
CHECK:      ;checks if push buttons were pressed during songs

            MOVB  #$03,PIFP           ;interrupt flag is set to bits 0 and 1
            CLRA                      ;clear A
            LDAA  PTP                 ;load the status of port P into register A
            ANDA  #%00000011          ;this will leave only the bits of the push button
            
            CMPA  #%00000010          ;check if SW1 was pressed
            BEQ   STARTS1             ;branch to start song 1
           
            
            CMPA  #%00000001          ;check if SW2 was pressed
            BEQ   STARTS2             ;branch to start song 2
            RTS                       ;return from subroutine
            
            
            
              
STARTS2:    ;play song 2

            LDAA  #%00000001          ;returns both display and cursor to the original position (first line / address 0)
            JSR   SENDINST            ;send instruction to SPI
            JMP   SONG2               ;play song 2
            RTS                       ;return from subroutine
          
          
STARTS1:    ;play song 1

            LDAA  #%00000001          ;returns both display and cursor to the original position (first line / address 0)
            JSR   SENDINST            ;send instruction to SPI
            JMP   SONG1               ;play song 1
            RTS                       ;return from subroutine
          
          
SONG1:      ;song 1 notes
          

            MOVW #238,MCCNT           ;moving 238 into the MCCNT corresponding to the Do frequency
          
            MOVB #$A0,DDRB            ;turning on LEDs 2 and 4, corresponding to Do
          
            LDAA  #'A'                ;load 'A' into register A
            JSR   SENDDATA            ;send character to SPI
            LDAA  #'u'                ;load 'u' into register A
            JSR   SENDDATA            ;send character to SPI
            
            JSR CHECK                 ;jump to check if push buttons have been pressed
          
            LDAA  #' '                ;load an empty character into register A
            JSR   SENDDATA            ;send character to SPI
            LDAA  #'c'                ;load 'c' into register A
            JSR   SENDDATA            ;send character to SPI
              
            MOVB #$00,DDRB            ;turning LEDs off
          
            MOVW #0,MCCNT             ;moving 0 into the MCCNT corresponding to zero frequency
            JSR DelayRest             ;jump to subroutine DelayRest
          
            JSR CHECK                 ;jump to check if push buttons have been pressed
          
          
          
            
            MOVW #238,MCCNT           ;moving 238 into the MCCNT corresponding to the Do frequency
          
            MOVB #$A0,DDRB            ;turning on LEDs 2 and 4, corresponding to Do
         
            LDAA  #'l'                ;load 'l' into register A
            JSR   SENDDATA            ;send character to SPI
            LDAA  #'a'                ;load 'a' into register A
            JSR   SENDDATA            ;send character to SPI
         
            JSR CHECK                 ;jump to check if push buttons have been pressed
                 
            LDAA  #'i'                ;load 'i' into register A
            JSR   SENDDATA            ;send character to SPI
            LDAA  #'r'                ;load 'r' into register A
            JSR   SENDDATA            ;send character to SPI
          
            MOVB #$00,DDRB            ;turning LEDs off
               
            MOVW #0,MCCNT             ;moving 0 into the MCCNT corresponding to zero frequency
            JSR DelayRest             ;jump to subroutine DelayRest
          
            JSR CHECK                 ;jump to check if push buttons have been pressed
           
          
 
 
            MOVW #238,MCCNT           ;moving 238 into the MCCNT corresponding to the Do frequency
          
            MOVB #$A0,DDRB            ;turning on LEDs 2 and 4, corresponding to Do
         
            LDAA #$C0                 ;position cursor at head of 2nd line
            JSR SENDINST              ;send instruction to SPI
            JSR LCD_DELAY             ;jump to LCD_DELAY to add a delay
            JSR LCD_DELAY             
        
            JSR CHECK                 ;jump to check if push buttons have been pressed
   
            LDAA  #'d'                ;load 'd' into register A
            JSR   SENDDATA            ;send character to SPI
            LDAA  #'e'                ;load 'e' into register A
            JSR   SENDDATA            ;send character to SPI
          
            MOVB #$00,DDRB            ;turning LEDs off
          
            JSR CHECK                 ;jump to check if push buttons have been pressed
         
          
          
          
            MOVW #212,MCCNT           ;moving 212 into the MCCNT corresponding to the Re frequency
          
          
            MOVB #$50,DDRB            ;turning on LEDs 1 and 3, corresponding to Re
          
            LDAA  #' '                ;load an empty character into register A
            JSR   SENDDATA            ;send character to SPI
            LDAA  #'l'                ;load 'l' into register A
            JSR   SENDDATA            ;send character to SPI
          
            JSR CHECK                 ;jump to check if push buttons have been pressed
          
            LDAA  #'a'                ;load 'a' into register A
            JSR   SENDDATA            ;send character to SPI
            JSR   LCD_DELAY           ;jump to LCD_DELAY to add a delay
            JSR   LCD_DELAY           
   
            MOVB #$00,DDRB            ;turning LEDs off
          
            JSR CHECK                 ;jump to check if push buttons have been pressed
          

          
          
            MOVW #190,MCCNT           ;moving 190 into the MCCNT corresponding to the Mi frequency
          
            MOVB #$90,DDRB            ;turning on LEDs 1 and 4, corresponding to Mi
          
            LDAA  #%00000001          ;returns both display and cursor to the original position (first line / address 0)
            JSR   SENDINST            ;send instruction to SPI
            LDAA  #'l'                ;load 'l' into register A
            JSR   SENDDATA            ;send character to SPI
            JSR   LCD_DELAY           ;jump to LCD_DELAY to add a delay
            JSR   LCD_DELAY           
            JSR   LCD_DELAY           
            JSR   LCD_DELAY           
 
            JSR CHECK                 ;jump to check if push buttons have been pressed
         
            LDAA  #'u'                ;load 'u' into register A
            JSR   SENDDATA            ;send character to SPI
            JSR   LCD_DELAY           ;jump to LCD_DELAY to add a delay
            JSR   LCD_DELAY           
            JSR   LCD_DELAY          
            JSR   LCD_DELAY           
            JSR   LCD_DELAY           
            JSR   LCD_DELAY           
                                      
            MOVB #$00,DDRB            ;turning LEDs off
   
            JSR CHECK                 ;jump to check if push buttons have been pressed
         
         
          
          
            MOVW #212,MCCNT           ;moving 212 into the MCCNT corresponding to the Re frequency
          
            MOVB #$50,DDRB            ;turning on LEDs 1 and 3, corresponding to Re
          
            LDAA  #'n'                ;load 'n' into register A
            JSR   SENDDATA            ;send character to SPI
            JSR   LCD_DELAY           ;jump to LCD_DELAY to add a delay
            JSR   LCD_DELAY
            JSR   LCD_DELAY
            JSR   LCD_DELAY
            JSR   LCD_DELAY
            JSR   LCD_DELAY
          
            JSR CHECK                 ;jump to check if push buttons have been pressed
           
            LDAA  #'e'                ;load 'e' into register A
            JSR   SENDDATA            ;send character to SPI
            JSR   LCD_DELAY           ;jump to LCD_DELAY to add a delay
            JSR   LCD_DELAY
            LDAA  #' '                ;load an empty character into register A
            JSR   SENDDATA            ;send character to SPI
            JSR   LCD_DELAY           ;jump to LCD_DELAY to add a delay
            JSR   LCD_DELAY

          
            MOVB #$00,DDRB            ;turning LEDs off
          
            JSR CHECK                 ;jump to check if push buttons have been pressed
          
          
          
          
            MOVW #238,MCCNT           ;moving 238 into the MCCNT corresponding to the Do frequency
          
            MOVB #$A0,DDRB            ;turning on LEDs 2 and 4, corresponding to Do
         
            LDAA  #'m'                ;load 'm' into register A
            JSR   SENDDATA            ;send character to SPI
            LDAA  #'o'                ;load 'o' into register A
            JSR   SENDDATA            ;send character to SPI
          
            JSR CHECK                 ;jump to check if push buttons have been pressed
          
            LDAA  #'n'                ;load 'n' into register A
            JSR   SENDDATA            ;send character to SPI
            JSR   LCD_DELAY           ;jump to LCD_DELAY to add a delay
            JSR   LCD_DELAY
              
            MOVB #$00,DDRB            ;turning LEDs off
           
            JSR CHECK                 ;jump to check if push buttons have been pressed
            
         

         
            MOVW #190,MCCNT           ;moving 190 into the MCCNT corresponding to the Mi frequency
             
            MOVB #$90,DDRB            ;turning on LEDs 1 and 4, corresponding to Mi
          
            LDAA  #$C0                ;position cursor at head of 2nd line
            JSR   SENDINST            ;send instruction to SPI
            LDAA  #'a'                ;load 'a' into register A
            JSR   SENDDATA            ;send character to SPI
          
            JSR CHECK                 ;jump to check if push buttons have been pressed
             
            JSR   LCD_DELAY           ;jump to LCD_DELAY to add a delay
            JSR   LCD_DELAY
            JSR   LCD_DELAY
            JSR   LCD_DELAY
          
            MOVB #$00,DDRB            ;turning LEDs off
          
            JSR CHECK                 ;jump to check if push buttons have been pressed
          
          
          
          
            MOVW #212,MCCNT           ;moving 212 into the MCCNT corresponding to the Re frequency

            MOVB #$50,DDRB            ;turning on LEDs 1 and 3, corresponding to Re
          
            LDAA  #'m'                ;load 'm' into register A
            JSR   SENDDATA            ;send character to SPI
            LDAA  #'i'                ;load 'i' into register A
            JSR   SENDDATA            ;send character to SPI
           
            JSR CHECK                 ;jump to check if push buttons have been pressed
          
            LDAA  #%00000001          ;returns both display and cursor to the original position (first line / address 0)
            JSR   SENDINST            ;send instruction to SPI
            JSR   LCD_DELAY           ;jump to LCD_DELAY to add a delay
            JSR   LCD_DELAY
            
            MOVB #$00,DDRB            ;turning LEDs off
          
            MOVW #0,MCCNT             ;moving 0 into the MCCNT corresponding to zero frequency
            JSR DelayRest             ;jump to subroutine DelayRest
          
            JSR CHECK                 ;jump to check if push buttons have been pressed
          
  
          
          
            MOVW #212,MCCNT           ;moving 212 into the MCCNT to get the Re frequency

            MOVB #$50,DDRB            ;turning on LEDs 1 and 3, corresponding to Re
          
            LDAA  #'P'                ;load 'P' into register A
            JSR   SENDDATA            ;send character to SPI
            LDAA  #'i'                ;load 'i' into register A
            JSR SENDDATA              ;send character to SPI
          
            JSR CHECK                 ;jump to check if push buttons have been pressed
            
            LDAA  #'e'                ;load 'e' into register A
            JSR   SENDDATA            ;send character to SPI
            LDAA  #'r'                ;load 'r' into register A
            JSR   SENDDATA            ;send character to SPI
          
            MOVB #$00,DDRB            ;turning LEDs off
                    
            JSR CHECK                 ;jump to check if push buttons have been pressed
          
        
          
          
            MOVW #238,MCCNT           ;moving 238 into the MCCNT corresponding to the Do frequency
          
            MOVB #$A0,DDRB            ;turning on LEDs 2 and 4, corresponding to Do
          
            LDAA  #'r'                ;load 'r' into register A
            JSR   SENDDATA            ;send character to SPI
            LDAA  #'o'                ;load 'o' into register A
            JSR   SENDDATA            ;send character to SPI
            LDAA  #'t'                ;load 't' into register A
            JSR   SENDDATA            ;send character to SPI
            JSR   LCD_DELAY           ;jump to LCD_DELAY to add a delay
            JSR   LCD_DELAY
            JSR   LCD_DELAY
            JSR   LCD_DELAY
            JSR   LCD_DELAY
            JSR   LCD_DELAY
            JSR   LCD_DELAY
            JSR   LCD_DELAY
            JSR   LCD_DELAY
            JSR   LCD_DELAY
         
            JSR   CHECK               ;jump to check if push buttons have been pressed
         
            JSR   LCD_DELAY           ;jump to LCD_DELAY to add a delay
            JSR   LCD_DELAY
            JSR   LCD_DELAY
            JSR   LCD_DELAY
            JSR   LCD_DELAY
            JSR   LCD_DELAY
            JSR   LCD_DELAY
            JSR   LCD_DELAY
            
            JSR   CHECK               ;jump to check if push buttons have been pressed
            
            JSR   LCD_DELAY           ;jump to LCD_DELAY to add a delay
            JSR   LCD_DELAY
            JSR   LCD_DELAY
            JSR   LCD_DELAY
            JSR   LCD_DELAY
            JSR   LCD_DELAY
            JSR   LCD_DELAY
            JSR   LCD_DELAY
          
            MOVB #$00,DDRB            ;turning LEDs off
          
            MOVW #0,MCCNT             ;moving 0 into the MCCNT corresponding to zero frequency
          
            LDAA  #%00000001          ;returns both display and cursor to the original position (first line / address 0)
            JSR   SENDINST            ;send instruction to SPI
          
            JMP IntrPB                ;jump back to repeat
          
          
          
          
SONG2:      ;song 2 notes   

            MOVW #160,MCCNT            ;moving 160 into the MCCNT corresponding to the Sol frequency
  
            MOVB #$C0,DDRB             ;turning on LEDs 3 and 4, corresponding to Sol
          
            LDAA  #'I'                 ;load 'I' into register A
            JSR   SENDDATA             ;send character to SPI
            JSR   LCD_DELAY            ;jump to LCD_DELAY to add a delay
            JSR   LCD_DELAY
          
            JSR CHECK                  ;jump to check if push buttons have been pressed
          
            LDAA  #' '                 ;load an empty character into register A
            JSR   SENDDATA             ;send character to SPI
            JSR   LCD_DELAY            ;jump to LCD_DELAY to add a delay
            JSR   LCD_DELAY
            JSR   LCD_DELAY
            JSR   LCD_DELAY
            JSR   LCD_DELAY
          
            MOVB #$00,DDRB             ;turning LEDs off
 
            JSR CHECK                  ;jump to check if push buttons have been pressed
          

          
            
            MOVW #190,MCCNT            ;moving 190 into the MCCNT corresponding to the Mi frequency
           
            MOVB #$90,DDRB             ;turning on LEDs 1 and 4, corresponding to Mi
          
            LDAA  #'l'                 ;load 'l' into register A
            JSR   SENDDATA             ;send character to SPI
            LDAA  #'o'                 ;load 'o' into register A
            JSR   SENDDATA             ;send character to SPI
         
            JSR CHECK                  ;jump to check if push buttons have been pressed
            
            LDAA  #'v'                 ;load 'v' into register A
            JSR   SENDDATA             ;send character to SPI
            LDAA  #'e'                 ;load 'e' into register A
            JSR   SENDDATA             ;send character to SPI
   
            MOVB #$00,DDRB             ;turning LEDs off
  
            JSR CHECK                  ;jump to check if push buttons have been pressed
           
    

          
            MOVW #160,MCCNT           ;moving 160 into the MCCNT corresponding to the Sol frequency
          
            MOVB #$C0,DDRB            ;turning on LEDs 3 and 4, corresponding to Sol
          
            LDAA #$C0                 ;position cursor at head of 2nd line
            JSR SENDINST              ;send instruction to SPI
            LDAA  #'y'                ;load 'y' into register A
            JSR   SENDDATA            ;send character to SPI
            JSR   LCD_DELAY           ;jump to LCD_DELAY to add a delay
            JSR   LCD_DELAY
            JSR   LCD_DELAY
            JSR   LCD_DELAY
          
            JSR CHECK                 ;jump to check if push buttons have been pressed
          
            LDAA  #'o'                ;load 'o' into register A
            JSR   SENDDATA            ;send character to SPI
            LDAA  #'u'                ;load 'u' into register A
            JSR   SENDDATA            ;send character to SPI
          
            LDAA  #%00000001          ;returns both display and cursor to the original position (first line / address 0)
            JSR   SENDINST            ;send instruction to SPI
            JSR   LCD_DELAY           ;jump to LCD_DELAY to add a delay
            JSR   LCD_DELAY
          
            MOVB #$00,DDRB            ;turning LEDs off
          
            MOVW #0,MCCNT             ;moving 0 into the MCCNT corresponding to zero frequency
            JSR DelayRest             ;jump to subroutine DelayRest
          
            JSR CHECK                 ;jump to check if push buttons have been pressed
         
         
         
          
            MOVW #160,MCCNT           ;moving 160 into the MCCNT corresponding to the Sol frequency
            
            MOVB #$C0,DDRB            ;turning on LEDs 3 and 4, corresponding to Sol
       
            LDAA  #'y'                ;load 'y' into register A
            JSR   SENDDATA            ;send character to SPI
            LDAA  #'o'                ;load 'o' into register A
            JSR   SENDDATA            ;send character to SPI
          
            JSR CHECK                 ;jump to check if push buttons have been pressed
          
            LDAA  #'u'                ;load 'u' into register A
            JSR   SENDDATA            ;send character to SPI
            LDAA  #' '                ;load an empty character into register A
            JSR   SENDDATA            ;send character to SPI
          
            MOVB #$00,DDRB            ;turning LEDs off
          
            JSR CHECK                 ;jump to check if push buttons have been pressed
          

          
            MOVW #190,MCCNT           ;moving 190 into the MCCNT corresponding to the Mi frequency
          
            MOVB #$90,DDRB            ;turning on LEDs 1 and 4, corresponding to Mi
          
            LDAA  #'l'                ;load 'l' into register A
            JSR   SENDDATA            ;send character to SPI
            LDAA  #'o'                ;load 'o' into register A
            JSR   SENDDATA            ;send character to SPI
          
            JSR CHECK                 ;jump to check if push buttons have been pressed
          
            LDAA  #'v'                ;load 'v' into register A
            JSR   SENDDATA            ;send character to SPI
            LDAA  #'e'                ;load 'e' into register A
            JSR   SENDDATA            ;send character to SPI
          
            MOVB #$00,DDRB            ;turning LEDs off
          
            JSR CHECK                 ;jump to check if push buttons have been pressed
          
         
         
         
            MOVW #160,MCCNT           ;moving 160 into the MCCNT corresponding to the Sol frequency
          
            MOVB #$C0,DDRB            ;turning on LEDs 3 and 4, corresponding to Sol
          
            LDAA #$C0                 ;position cursor at head of 2nd line
            JSR SENDINST              ;send instruction to SPI
            LDAA  #'m'                ;load 'm' into register A
            JSR   SENDDATA            ;send character to SPI
            JSR   LCD_DELAY           ;jump to LCD_DELAY to add a delay
            JSR   LCD_DELAY
            JSR   LCD_DELAY
            JSR   LCD_DELAY
          
            JSR CHECK                 ;jump to check if push buttons have been pressed

            LDAA  #'e'                ;load 'e' into register A
            JSR   SENDDATA            ;send character to SPI
            LDAA  #' '                ;load an empty character into register A
            JSR   SENDDATA            ;send character to SPI
            JSR   LCD_DELAY           ;jump to LCD_DELAY to add a delay
            JSR   LCD_DELAY
            JSR   LCD_DELAY
            JSR   LCD_DELAY
          
            MOVB #$00,DDRB            ;turning LEDs off
          
            JSR CHECK                 ;jump to check if push buttons have been pressed
          
          
          
          
            MOVW #142,MCCNT           ;moving 142 into the MCCNT corresponding to the La frequency
          
            MOVB #$30,DDRB            ;turning on LEDs 1 and 2, corresponding to La
          
            LDAA  #'w'                ;load 'w' into register A
            JSR   SENDDATA            ;send character to SPI
            LDAA  #'e'                ;load 'e' into register A
            JSR   SENDDATA            ;send character to SPI
    
            JSR CHECK                 ;jump to check if push buttons have been pressed
            JSR LCD_DELAY             ;jump to LCD_DELAY to add a delay
          
            LDAA  #'r'                ;load 'r' into register A
            JSR   SENDDATA            ;send character to SPI
            LDAA  #'e'                ;load 'e' into register A
            JSR   SENDDATA            ;send character to SPI
          
            MOVB #$00,DDRB            ;turning LEDs off
           
            JSR CHECK                 ;jump to check if push buttons have been pressed
          
        

         
            MOVW #160,MCCNT           ;moving 160 into the MCCNT corresponding to the Sol frequency
          
            MOVB #$C0,DDRB            ;turning on LEDs 3 and 4, corresponding to Sol

            LDAA  #%00000001          ;returns both display and cursor to the original position (first line / address 0)
            JSR   SENDINST            ;send instruction to SPI
            LDAA  #'a'                ;load 'a' into register A
            JSR   SENDDATA            ;send character to SPI
         
            JSR CHECK                 ;jump to check if push buttons have been pressed
   
            LDAA  #' '                ;load an empty character into register A
            JSR   SENDDATA            ;send character to SPI
            JSR   LCD_DELAY           ;jump to LCD_DELAY to add a delay
            JSR   LCD_DELAY
          
            MOVB #$00,DDRB            ;turning LEDs off

            JSR CHECK                 ;jump to check if push buttons have been pressed
          
          
          
          
            MOVW #178,MCCNT           ;moving 178 into the MCCNT corresponding to the Fa frequency
          
            MOVB #$60,DDRB            ;turning on LEDs 2 and 3, corresponding to Fa
          
            LDAA  #'h'                ;load 'h' into register A
            JSR   SENDDATA            ;send character to SPI
            JSR   LCD_DELAY           ;jump to LCD_DELAY to add a delay
            JSR   LCD_DELAY
          
            JSR CHECK                 ;jump to check if push buttons have been pressed
         
            LDAA  #'a'                ;load 'a' into register A
            JSR   SENDDATA            ;send character to SPI
            LDAA  #'p'                ;load 'p' into register A
            JSR   SENDDATA            ;send character to SPI
         
            MOVB #$00,DDRB            ;turning LEDs off
 
            JSR CHECK                 ;jump to check if push buttons have been pressed
          
         
   
          
            MOVW #190,MCCNT           ;moving 190 into the MCCNT corresponding to the Mi frequency
          
            MOVB #$90,DDRB            ;turning on LEDs 1 and 4, corresponding to Mi
            
            LDAA  #'p'                ;load 'p' into register A
            JSR   SENDDATA            ;send character to SPI
            JSR   LCD_DELAY           ;jump to LCD_DELAY to add a delay
            JSR   LCD_DELAY 
          
            JSR CHECK                 ;jump to check if push buttons have been pressed
          
            LDAA  #'y'                ;load 'y' into register A
            JSR   SENDDATA            ;send character to SPI
            JSR   LCD_DELAY           ;jump to LCD_DELAY to add a delay
            JSR   LCD_DELAY
          
            MOVB #$00,DDRB            ;turning LEDs off
             
            JSR CHECK                 ;jump to check if push buttons have been pressed
          
           
          
          
            MOVW #212,MCCNT           ;moving 239 into the MCCNT corresponding to the Re frequency
          
            MOVB #$50,DDRB            ;turning on LEDs 1 and 3, corresponding to Re
          
            LDAA #$C0                 ;position cursor at head of 2nd line
            JSR SENDINST              ;send instruction to SPI
            LDAA  #'f'                ;load 'f' into register A
            JSR   SENDDATA            ;send character to SPI
           
            JSR CHECK                 ;jump to check if push buttons have been pressed
          
            LDAA  #'a'                ;load 'a' into register A
            JSR   SENDDATA            ;send character to SPI
            LDAA  #'m'                ;load 'm' into register A
            JSR   SENDDATA            ;send character to SPI
          
            MOVB #$00,DDRB            ;turning LEDs off
          
            JSR CHECK                 ;jump to check if push buttons have been pressed
          
          
          
          
            MOVW #190,MCCNT           ;moving 190 into the MCCNT corresponding to the Mi frequency
         
            MOVB #$90,DDRB            ;turning on LEDs 1 and 4, corresponding to Mi
          
            LDAA  #'i'                ;load 'i' into register A
            JSR   SENDDATA            ;send character to SPI
            JSR   LCD_DELAY           ;jump to LCD_DELAY to add a delay
            JSR   LCD_DELAY
          
            JSR CHECK                 ;jump to check if push buttons have been pressed
           
            JSR   LCD_DELAY           ;jump to LCD_DELAY to add a delay
            JSR   LCD_DELAY
            JSR   LCD_DELAY
            JSR   LCD_DELAY
               
            MOVB #$00,DDRB            ;turning LEDs off
          
            JSR CHECK                 ;jump to check if push buttons have been pressed
            
            
             

            MOVW #178,MCCNT           ;moving 178 into the MCCNT corresponding to the Fa frequency
         
            MOVB #$60,DDRB            ;turning on LEDs 2 and 3, corresponding to Fa
         
            LDAA  #'l'                ;load 'l' into register A
            JSR   SENDDATA            ;send character to SPI
            JSR   LCD_DELAY           ;jump to LCD_DELAY to add a delay
            JSR   LCD_DELAY
          
            JSR CHECK                 ;jump to check if push buttons have been pressed
          
            LDAA  #'y'                ;load 'y' into register A
            JSR   SENDDATA            ;send character to SPI
            JSR   LCD_DELAY           ;jump to LCD_DELAY to add a delay
            
            JSR   CHECK               ;jump to check if push buttons have been pressed
            
            JSR   LCD_DELAY           ;jump to LCD_DELAY to add a delay
           
            MOVB #$00,DDRB            ;turning LEDs off
                    
            MOVW #0,MCCNT             ;moving 0 into the MCCNT corresponding to zero frequency
            
            LDAA  #%00000001          ;returns both display and cursor to the original position (first line / address 0)
            JSR   SENDINST            ;send instruction to SPI
          
            JMP   IntrPB              ;jump back to repeat
          
          
          
		      
DelayRest:  ;delay corresponding to the shift to 0 frequency

              LDY #5                    ;load 5 into register y
                                      
  Loop1:		  LDX #500                  ;load 500 into register x
  Loop2:		  DBNE X, Loop2             ;decrement X and branch to Loop 1 if not equal to 0
	      	    DBNE Y, Loop1             ;decrement Y and branch to Loop 1 if not equal to 0
		          RTS                       ;return to subroutine
		      



SENDINST:   ;sending instructions to the SPI

            PSHA                      ;save the existing value of A 
            PSHB                      ;save the exisiting value of B
            TAB                       ;transfer contents of A to B to preserve instruction     
            RORA                      ;rotate A to the right 4 times so that the 4 MSBs become the 4 LSBs
            RORA                    
            RORA
            RORA                   
            ANDA #%00001111           ;preserve the last 4 bits   
            ORAA #%10000000           ;set 7th bit to 1 to send bits to SPI  
                                      
            BSR  SPI                  ;branch to SPI to send bits   
            ANDA #%00001111           ;stops the writing of the instruction  
            BSR  SPI                  ;branch to SPI
            
            BSR LCD_DELAY             ;branch to LCD_DELAY   
                                      
            TBA                       ;transfer contents of B back to A    
            ANDA #%00001111           ;same process as above   
            ORAA #%10000000
            BSR  SPI
            ANDA #%00001111
            BSR  SPI
            BSR LCD_DELAY
            PULB
            PULA
            RTS
            
            
            
SENDDATA:   ;sending data to SPI

            PSHA                      ;save the existing value of A 
            PSHB                      ;save the exisiting value of B
            TAB                       ;transfer contents of A to B to preserve instruction   
            RORA                      ;rotate A to the right 4 times so that the 4 MSBs become the 4 LSBs
            RORA
            RORA
            RORA   
            ANDA #%00001111           ;preserve the last 4 bits 
            ORAA #%11000000           ;6th bit is set to 1 to signal that we're writing/sending data  
            
            BSR  SPI                  ;branch to SPI to send bits
            ANDA #%00001111           ;stops the writing of the instruction  
            ORAA #%01000000
            BSR  SPI
            
            BSR LCD_DELAY             ;branch to LCD_DELAY
            
            TBA                       ;transfer contents of B back to A    
            ANDA #%00001111           ;same process as above   
            ORAA #%11000000
            BSR  SPI
            ANDA #%00001111
            ORAA #%01000000
            BSR  SPI
            BSR LCD_DELAY
            PULB
            PULA
            RTS
            
            
            
LCD_DELAY:  ;LCD Delay

            LDY #$AAAA                ;load AAAA into Y
            DBNE Y,*                  ;decrement Y and branch to Loop 1 if not equal to 0
            RTS                       ;return from subroutine
            
            
            
            
SPI:        ;sending a byte through the SPI


            STAA SPI0DR                
            BRCLR SPI0SR,#%00100000,*  
            LDX SPI0DR
            LDX SPI0SR
            RTS
                      



IntrBuzz:		;buzzer interrupt      
		        
		        LDAA PTT                    ;load the status of port P into register A
		        EORA #$01                   ;XOR A with 1
		        STAA PTT                    ;store into A the status of port P
    		    MOVB #$FF,MCFLG             ;move FF into MCFLG

		        RTI                         ;return from interrupt
                                        
            
            

;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ;Reset Vector
            ORG   $FF8E           ;push buttons interrupt vector address
            DC.W  IntrPB          ;push button interrupt
            ORG   $FFCA           ;buzzer interrupt vector address
            DC.W  IntrBuzz        ;buzzer interrupt
            