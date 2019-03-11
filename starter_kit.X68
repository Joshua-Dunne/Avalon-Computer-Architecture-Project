        org $1000

*-------------------------------------------------------
* Name: Joshua Dunne
* C00241588
* Date(s): 11/02/19
* Estimated Time Taken: 20 Hours
* Actual Time Taken: ~4 Hour(s)
* Known Bugs:
*------------------------------------------------------

*-------------------------------------------------------
*Choose to be a Worker or a God 
*https://www.avalon-rpg.com/
*-------------------------------------------------------

*-------------------------------------------------------
*Validation values to be used, modify as needed
*Add additional validation values as required
*-------------------------------------------------------
exit        EQU 0      used to exit assembly program
min_potions EQU 1      min number of potions
max_potions EQU 20     max number of potions
min_weapons EQU 1      min weapons
max_weapons EQU 15      max weapons
win_point   EQU 5      points accumilated on win
lose_point  EQU 8      points deducted on a loss
RED     EQU             $000000FF
CYAN    EQU             $00FFFF00
WHITE   EQU             $00FFFFFF
FONT    EQU             $01090000
health:     dc.w    100 Player's health
score:      dc.w    0 reserve space for score
gold:       dc.w    5000 gold player has (starts at 5000)
potion_count:    dc.w    0 potions player has (starts at 0)
weapon_count:    dc.w    5 number of weapons player has (starts at 5)
feed:       dc.w    0 amount of food for horse (starts at 0)


mine_loc    EQU 100    A location where a mine is found


*Start of Game
start:

    LEA score,A3
    LEA gold,A4
    LEA potion_count,A5
    LEA weapon_count,A6

    bsr     welcome    branch to the welcome subroutine
    bsr     input      branch to the input subroutine
    bsr     game       branch to the game subroutine
*Game loop
    org     $3000      the rest of the program is to be located from 3000 onwards

*-------------------------------------------------------
*-------------------Game Subroutine---------------------
*-------------------------------------------------------
game:
    bsr     gameloop   branch to gameloop subroutine
    rts                return from game: subroutine
          
end:
    simhalt

*-------------------------------------------------------
*-------------------Welcome Subroutine------------------
*-------------------------------------------------------
welcome:
    bsr     endl            branch to endl subroutine
    
    move.l #RED,D1
    move.l #FONT,D2
    move.b  #21,D0
    trap    #15
    
    clr     D1
    
    lea     welcome_msg,A1  assign message to address register A1
    move.b  #14,D0          move literal 14 to DO
    trap    #15             trap and interpret value in D0
    
    move.l #CYAN,D1
    move.l #FONT,D2
    move.b  #21,D0
    trap    #15

    clr     D1
    
    move.b  #4,D0           move literal 4 to D0
    trap    #15             trap and interpret value in D0 (get input from user)
    cmp     #exit,D1
    beq     end             if SR Z register contains 1 beq => Branch Equals
    bsr     endl            branch to endl subroutine
    
    move.b  #11,d0      clear screen
    move.w  #$ff00,d1
    trap    #15  
  
    
    move.l #WHITE,D1
    move.l #FONT,D2
    move.b  #21,D0
    trap    #15
    
    clr     D1
    
    lea     intro_msg,A1
    move.b  #14,D0
    trap    #15
    
    move.l   #600,D1     delay in 1/100th of seconds (2 seconds)
    moveq    #23,D0      23 -> Wait 1/100th of a second of the value in D1 
    trap     #15         trap and interpret value in D0
    
    rts                     return from welcome: subroutine

*-------------------------------------------------------
*---------Gameplay Input Values Subroutine--------------
*-------------------------------------------------------    
input:
    bsr     potions         branch to potion input subroutine
    bsr     weapons        branch to weaponss input subroutine
    rts

*-------------------------------------------------------
*----------------Gameloop (main loop)-------------------
*------------------------------------------------------- 
gameloop:
    bsr     update          branch to update game subroutine 
    bsr     clear_screen    clears the screen         
    bsr     draw            branch to draw screen subroutine
    bsr     clear_screen    clears the screen
    bsr     gameplay        branch to gameplay subroutine
    bsr     clear_screen    clears the screen
    bsr     hud             branch to display HUD subroutine
    bsr     clear_screen    clears the screen
    bsr     replay          branch to replay game subroutine
    bsr     clear_screen    clears the screen
    rts                     return from gameloop: subroutine

*-------------------------------------------------------
*----------------Update Quest Progress------------------
*  Complete Quest
*------------------------------------------------------- 
update:
    bsr     endl            print a CR and LF
    bsr     decorate        decorate with dots using a loop
    lea     update_msg,A1   
    move.b  #14,D0
    trap    #15
    bsr     decorate
    rts
*-------------------------------------------------------
*-----------------Draw Quest Updates--------------------
* Draw the game progress information, status regarding
* quest
*------------------------------------------------------- 
draw:
    bsr     endl
    bsr     decorate
    lea     draw_msg,A1
    move.b  #14,D0
    trap    #15
    bsr     decorate
    rts
*-------------------------------------------------------
*------------------------Potions------------------------
* Input the ingredients for each potion. Ingredients costs 
* money. For an advanced mark you need to manage this 
* resource
*------------------------------------------------------- 
potions:
    bsr     endl
    bsr     decorate
    lea     gold_msg,A1
    move.b  #14,D0
    trap    #15 display message saying how much gold user has
    
    move.w  (A4),D1
    move.b  #3,D0
    trap    #15 display the number of gold
    
    lea     empty_msg,A1
    move.b  #14,D0
    trap    #15 put in a line break
    
    lea     potions_msg,A1
    move.b  #14,D0
    trap    #15 display potion message
    
    move.b  #4,D0
    trap    #15 get input on how many potions user wants
    
    cmp     #min_potions,D1
    blt     potion_error_min compare less than minimum amount of potions allowed, branch if less
    
    cmp     #max_potions,D1
    bgt     potion_error_max compare more than minimum amount of potions allowed, branch if more
    
    clr     D2 clear d2 in case anything else has used it
    
    move.b  D1, D2 move the number of potions entered into data register 2
    mulu.w  #100, D2    multiply that number by 100 (to get the cost)
    
    move.w (A4),D3 temporarily move the amount of money they have into a data register
    
    cmp.w   D3,D2 compare the cost against the potions the user has
    
    bgt potion_error_money if they dont have enough, tell them
    
    add.w  D1, (A5) otherwise move the amount of potions they bought into number A5
    
    sub.w   D2,(A4) take away the cost
    
    lea     gold_msg,A1
    move.b  #14,D0
    trap    #15 display message saying how much gold user has
    
    move.w  (A4),D1
    move.b  #3,D0
    trap    #15 display the number of gold
    
    lea     empty_msg,A1
    move.b  #14,D0
    trap    #15 put in a line break
    
    lea     potion_msg,A1
    move.b  #14,D0
    trap    #15
    
    move.w  (A5),D1
    move.b  #3,D0
    trap    #15 display the number of potions
    
    lea     empty_msg,A1
    move.b  #14,D0
    trap    #15 put in a line break
    
    move.l   #500,D1     delay in 1/100th of seconds (2 seconds)
    moveq    #23,D0      23 -> Wait 1/100th of a second of the value in D1 
    trap     #15         trap and interpret value in D0

    bsr     decorate
    rts
    
potion_error_max:
    lea     potions_error_max,A1
    move.b  #14,D0
    trap    #15
    bra     potions

potion_error_min:
    lea     potions_error_min,A1
    move.b  #14,D0
    trap    #15
    bra     potions
    
potion_error_money:
    lea     error_money,A1
    move.b  #14,D0
    trap    #15
    bra     potions
    

*-------------------------------------------------------
*--------------------Potions Inventory------------------
* Number of potions to be used in a Quest 
*------------------------------------------------------- 
potionsremain:
    bsr     endl
    bsr     decorate
    lea     potion_msg,A1
    move.b  #14,D0
    trap    #15
    bsr     decorate
    
    move.b  #4,D0
    trap    #15 get input on how many weapons user wants
    
    rts

*-------------------------------------------------------
*-------------------------Weapons-----------------------
* Number of weapons
*-------------------------------------------------------   
weapons:
    bsr     endl
    bsr     decorate
    
    lea     gold_msg,A1
    move.b  #14,D0
    trap    #15 display message saying how much gold user has
    
    move.w  (A4),D1
    move.b  #3,D0
    trap    #15 display the number of gold
    
    lea     empty_msg,A1
    move.b  #14,D0
    trap    #15 put in a line break
    
    lea     weapons_msg,A1
    move.b  #14,D0
    trap    #15 display weapon shop message
    
    move.b  #4,D0
    trap    #15 get input on how many weapons user wants
    
    cmp     #min_weapons,D1
    blt     weapon_error_min compare less than minimum amount of weapons allowed, branch if less
    
    cmp     #max_weapons,D1
    bgt     weapon_error_max compare more than maximum amount of weapons allowed, branch if more
    
    clr     D2 clear d2 in case anything else has used it
    
    move.b  D1, D2      move the number of weapons entered into data register 2
    mulu.w  #250, D2    multiply that number by 250 (to get the cost)
    
    move.w (A4),D3 temporarily move the amount of money they have into a data register
    
    cmp.w   D3,D2 compare the cost against the money the user has
    bgt     weapon_error_money if they dont have enough, tell them
    
    clr     D3 we dont need the number in the register anymore if it goes through
    
    add.w  D1,(A6) otherwise move the amount of weapons they bought into number A6 
    
    sub.w   D2,(A4) take away the cost
    
    lea     gold_msg,A1
    move.b  #14,D0
    trap    #15 display message saying how much gold user has
    
    move.w  (A4),D1
    move.b  #3,D0
    trap    #15 display the number of gold
    
    lea     empty_msg,A1
    move.b  #14,D0
    trap    #15 put in a line break
    
    lea     weapon_msg,A1
    move.b  #14,D0
    trap    #15
    
    move.w  (A6),D1
    move.b  #3,D0
    trap    #15 display the number of weapons
    
    lea     empty_msg,A1
    move.b  #14,D0
    trap    #15 put in a line break
    
    move.l   #500,D1     delay in 1/100th of seconds (2 seconds)
    moveq    #23,D0      23 -> Wait 1/100th of a second of the value in D1 
    trap     #15         trap and interpret value in D0
 
    move.b  #11,d0      clear screen
    move.w  #$ff00,d1
    trap    #15 
 
    bsr     decorate
    rts
    
weapon_error_max:
    lea     weapons_error_max,A1
    move.b  #14,D0
    trap    #15
    bra     weapons

weapon_error_min:
    lea     weapons_error_min,A1
    move.b  #14,D0
    trap    #15
    bra     weapons
    
weapon_error_money:
    lea     error_money,A1
    move.b  #14,D0
    trap    #15
    clr     D3 reset this number for use later
    clr     D2 reset this number for use later
    bra     weapons

*-------------------------------------------------------
*---Game Play (Quest Progress)--------------------------
*------------------------------------------------------- 
gameplay:
    bsr     endl
    bsr     decorate
    lea     gameplay_msg,A1
    move.b  #14,D0
    trap    #15
    bsr     decorate
    
    move.b  #4,D0
    trap    #15 get input on how many weapons user wants
    
    bsr     collision
    rts

*-------------------------------------------------------
*-----------------Heads Up Display (Score)--------------
* Retrieves the score from memory location
*-------------------------------------------------------   
hud:

    bsr     endl
    bsr     decorate
    lea     hud_msg,A1
    move.b  #14,D0
    trap    #15
    move.w  (A3),D1     retrieve the value A3 point to and move to D1
    move.b  #3,D0       move literal 3 to D0
    trap    #15         intrepret value in D0, which 3 which displays D1
    bsr     decorate
    
    move.b  #4,D0
    trap    #15 wait for input to continue

    rts

*-------------------------------------------------------
*-----------------------Being Attacked------------------
* This could be used for collision detection
*-------------------------------------------------------
collision:
    move.b  #mine_loc,D1
    cmp     #100,D1 is( x == 100)?
    
    move.b  #4,D0
    trap    #15 get input on how many weapons user wants
    
	bne     collision_miss if x is not equal to 100, then not hit
collision_hit:
    *hit
    lea     hit_msg,A1
    move    #14,D0
    trap    #15
    
    move.b  #4,D0
    trap    #15 get input on how many weapons user wants
    
    rts
    
collision_miss:
    *miss
    lea     miss_msg,A1
    move    #14,D0
    trap    #15
    
    move.b  #4,D0
    trap    #15 get input on how many weapons user wants
    
    rts

*-------------------------------------------------------
*--------------------------Loop-------------------------
*-------------------------------------------------------
loop:
    move.b  #5, D3 loop counter D3=5
next:
    lea     loop_msg,A1
    move.b  #14,D0
    trap    #15
	sub     #1,D3   decrement loop counter
	
	move.b  #4,D0
    trap    #15 get input on how many weapons user wants
	
    bne     next    repeat until D0=0

*-------------------------------------------------------
*------------------Screen Decoration--------------------
*-------------------------------------------------------
decorate:
    move.b  #60, D3
    bsr     endl
out:
    lea     loop_msg,A1
    move.b  #14,D0
    trap    #15
	sub     #1,D3   decrement loop counter
    bne     out	    repeat until D0=0
    bsr     endl
    rts
    
clear_screen: 
    move.b  #11,D0      clear screen
    move.w  #$ff00,D1
    trap    #15
    rts
*-------------------------------------------------------
*------------------------Replay-------------------------
*-------------------------------------------------------
replay:
    bsr     endl
    lea     replay_msg,A1
    move.b  #14,D0
    trap    #15
    
    move.b  #4,D0
    trap    #15

    cmp     #exit,D1
    beq     end         if SR Z register contains 1 beq => Branch Equals
    bsr     gameloop

endl:
    movem.l D0/A1,-(A7)
    move    #14,D0
    lea     crlf,A1
    trap    #15
    movem.l (A7)+,D0/A1
    rts
    
*-------------------------------------------------------
*-------------------Data Delarations--------------------
*-------------------------------------------------------

crlf:                dc.b    $0D,$0A,0
welcome_msg:         dc.b    '************************************************************'
                     dc.b    $0D,$0A
                     dc.b    'Avalon: The Legend Lives'
                     dc.b    $0D,$0A
                     dc.b    '************************************************************'
                     dc.b    $0D,$0A
                     dc.b    'Enter 1 to Start, Enter 0 to Quit: ',0
intro_msg:           dc.b    $0D,$0A
                     dc.b    'You and your cavalry are given a quest to deliver '
                     dc.b    $0D,$0A
                     dc.b    'an ancient relic to the Kingdom of Noirheed.'
                     dc.b    $0D,$0A
                     dc.b    'Before you leave, the King who bestowed you this quest'
                     dc.b    $0D,$0A
                     dc.b    'gives you half the payment upfront -- 5000 gold.'
                     dc.b    $0D,$0A
                     dc.b    'With this, you must decide how best to spend your gold,'
                     dc.b    $0D,$0A
                     dc.b    'and how much you would like to keep for yourself.',0
potions_msg:         dc.b    'You walk into a nearby potion shop and decide how many potions you need. '
                     dc.b    $0D,$0A
                     dc.b    '"Each potion costs 100 gold, how many do ye want?":  ',0
potions_error_max    dc.b    'Even with your cavalry team, you would not be able to hold that many potions.'
                     dc.b    $0D,$0A,0
potions_error_min    dc.b    'You will need potions to go on this journey.'
                     dc.b    $0D,$0A,0
error_money          dc.b    'You do not have enough money.'
                     dc.b    $0D,$0A,0
                     
potion_msg:          dc.b    'Number of potions : ',0

weapon_msg:          dc.b    'Number of weapons : ',0

gold_msg             dc.b    'Amount of gold: ',0

weapons_msg:         dc.b    'You decide to buy some weapons for you and your cavalry.'
                     dc.b    $0D,$0A
                     dc.b    'Each fight will use at least 1 weapon and it`s 250 gold per weapon.'
                     dc.b    $0D,$0A
                     dc.b    'You already have 5 weapons, but more is always good.'
                     dc.b    $0D,$0A
                     dc.b    'With this knowledge, you decide to buy: ',0 
                 
weapons_error_max    dc.b    'As you already have weapons, that would be too many.'
                     dc.b    $0D,$0A,0
                     
weapons_error_min    dc.b    'You need more weapons than you already have.'
                     dc.b    $0D,$0A,0
                     
gameplay_msg:        dc.b    'Add Gameplay !',0
update_msg:          dc.b    'Update Gameplay !',0
draw_msg:            dc.b    'Draw Screen !',0
hit_msg:             dc.b    'Strike!',0
miss_msg:            dc.b    'Miss!',0
loop_msg:            dc.b    '.',0
replay_msg:          dc.b    'Enter 0 to Quit any other number to replay : ',0
hud_msg:             dc.b    'Score : ',0
empty_msg            dc.b    '',$0D,$0A,0



    end start











*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
