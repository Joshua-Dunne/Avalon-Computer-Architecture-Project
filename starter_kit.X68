        org $1000

*-------------------------------------------------------
* Name: Joshua Dunne
* C00241588
* Date(s): 21/01/19, 11/02/19, 18/02/19, 25/02/19, 11/03/19, 19/03/19, 23/03/19
* Estimated Time Taken: 20 Hours
* Actual Time Taken: ~14 Hour(s)
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
gold:       dc.w    3000 gold player has (starts at 5000)
potion_count:    dc.w    0 potions player has (starts at 0)
weapon_count:    dc.w    5 number of weapons player has (starts at 5)
distance_travelled: dc.w    0 how far the player has gone (1000 to finish journey)


mine_loc    EQU 100    A location where a mine is found
noir_loc    EQU 800    Location of destination


*Start of Game
start:

    LEA distance_travelled, A2
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
    
    bsr clear_screen
  
    
    move.l #WHITE,D1
    move.l #FONT,D2
    move.b  #21,D0
    trap    #15
    
    clr     D1
    
    lea     intro_msg,A1
    move.b  #14,D0
    trap    #15
    
    move.l   #800,D1     delay in 1/100th of seconds (2 seconds)
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
    bsr     gameplay        branch to gameplay subroutine
    bsr     clear_screen    clears the screen
    bsr     hud             branch to display HUD subroutine
    bsr     clear_screen    clears the screen
    bsr     replay          branch to replay game subroutine
    bsr     clear_screen    clears the screen
    rts                     return from gameloop: subroutine
*-------------------------------------------------------
*------------------------Potions------------------------
* Buy some potions from a shop
* Each costs 100 in-game gold
*------------------------------------------------------- 
potions:
    bsr     endl
    bsr     decorate
    bsr     endl            print a CR and LF
    lea     gold_msg,A1
    move.b  #14,D0
    trap    #15 display message saying how much gold user has
    
    move.w  gold,D1
    move.b  #3,D0
    trap    #15 display the number of gold
    
    lea     empty_msg,A1
    move.b  #14,D0
    trap    #15 put in a line break
    
    move.w  gold,D3 temporarily move the amount of money they have into a data register
    
    cmp     #250, D3 check if the player has enough gold to buy 1 potion (which costs 100 gold)
    blt     potion_error_money_none
    
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
    
    cmp.w   D3,D2 compare the cost against the potions the user has given
    
    bgt potion_error_money if they dont have enough, tell them
    
    add.w  D1, potion_count otherwise move the amount of potions they bought into number A5
    
    sub.w   D2,gold take away the cost
    
    clr     D3           we dont need the number in the register anymore
    
    lea     gold_msg,A1
    move.b  #14,D0
    trap    #15 display message saying how much gold user has
    
    move.w  gold,D1
    move.b  #3,D0
    trap    #15 display the number of gold
    
    lea     empty_msg,A1
    move.b  #14,D0
    trap    #15 put in a line break
    
    lea     potion_msg,A1
    move.b  #14,D0
    trap    #15
    
    move.w  potion_count,D1
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
    bra     potions say they entered too many potions, then go back and let them enter again

potion_error_min:
    lea     potions_error_min,A1
    move.b  #14,D0
    trap    #15
    bra     potions say they entered too little potions, then go back and let them enter again
    
potion_error_money:
    lea     error_money,A1
    move.b  #14,D0
    trap    #15
    bra     potions say they dont have enough money to purchase the amount of potions they entered
    
potion_error_money_none:
    lea     error_money_none,A1
    move.b  #14,D0
    trap    #15 say they don't have enough money to enter the shop
    clr     D3 
    rts
    
*-------------------------------------------------------
*-------------------------Weapons-----------------------
* Number of weapons
*-------------------------------------------------------   
weapons:
    bsr     endl            print a CR and LF
    bsr     decorate
    bsr     endl
 
    lea     gold_msg,A1
    move.b  #14,D0
    trap    #15 display message saying how much gold user has
    
    move.w  gold,D1
    move.b  #3,D0
    trap    #15 display the number of gold
    
    move.w gold,D3 temporarily move the amount of money they have into a data register
    
    cmp     #250, D3 check if the player has enough gold to buy 1 weapon (which costs 250 gold)
    blt     weapon_error_money_none
    
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
    
    cmp.w   D3,D2 compare the cost against the money the user has
    bgt     weapon_error_money if they dont have enough, tell them
    
    clr     D3 we dont need the number in the register anymore if it goes through
    
    add.w  D1,weapon_count otherwise move the amount of weapons they bought into number A6 
    
    sub.w   D2, gold take away the cost
    
    lea     gold_msg,A1
    move.b  #14,D0
    trap    #15 display message saying how much gold user has
    
    move.w  gold,D1
    move.b  #3,D0
    trap    #15 display the number of gold
    
    lea     empty_msg,A1
    move.b  #14,D0
    trap    #15 put in a line break
    
    lea     weapon_msg,A1
    move.b  #14,D0
    trap    #15
    
    move.w  weapon_count,D1
    move.b  #3,D0
    trap    #15 display the number of weapons
    
    lea     empty_msg,A1
    move.b  #14,D0
    trap    #15 put in a line break
    
    move.l   #500,D1     delay in 1/100th of seconds (2 seconds)
    moveq    #23,D0      23 -> Wait 1/100th of a second of the value in D1 
    trap     #15         trap and interpret value in D0
 
    bsr clear_screen
    
    clr     D3           we dont need the number in the register anymore if it goes through
 
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
    
weapon_error_money_none:
    lea     error_money_none,A1
    move.b  #14,D0
    trap    #15
    clr     D3 reset this number for use later
    clr     D2 reset this number for use later
    rts

*-------------------------------------------------------
*---Game Play (Quest Progress)--------------------------
*------------------------------------------------------- 
gameplay:
    bsr     endl            print a CR and LF
    bsr     decorate
    bsr     endl
    lea     gameplay_msg,A1
    move.b  #14,D0
    trap    #15
    
    move.w  distance_travelled,D1
    move.b  #3,D0
    trap    #15 show how far the player has gone
    
    bsr     decorate
    
    move.b  #4,D0
    trap    #15 wait for input
    
    cmp     #100, health
    blt     ask_heal
    bge     continue_on

ask_heal:

    lea     heal_ask_msg,A1
    move.b  #14,D0
    trap    #15
    
    move.b  #4,D0
    trap    #15 check if user wants to heal
    
    cmp     #1, D1 
    bne     continue_on if they put in anything else, just continue
* if they put in one, heal them

    add.w   #50, health heal 50 health
    
    lea     heal_confirm_msg,A1
    move.b  #14,D0
    trap    #15
    
    bsr     endl
    
    cmp     #100, health
    bgt     fix_health if they have over 100 health, set it back to 100 (max)
    ble     continue_on otherwise if it's equal or less, continue
    
fix_health:
    move.w  #100, health
    

continue_on:
  
    bsr     collision
    rts
*-------------------------------------------------------
*-----------------Heads Up Display (Score)--------------
* Retrieves the score from memory location
*-------------------------------------------------------   
hud:
    bsr     endl            print a CR and LF
    bsr     decorate
    bsr     endl
    lea     hud_msg,A1
    move.b  #14,D0
    trap    #15
    move.w  score,D1     retrieve the value A3 point to and move to D1
    move.b  #3,D0       move literal 3 to D0
    trap    #15         intrepret value in D0, which 3 which displays D1
    bsr     decorate
    lea     gold_msg,A1
    move.b  #14,D0
    trap    #15 display message saying how much gold user has
    
    move.w  gold,D1
    move.b  #3,D0
    trap    #15 display the number of gold
    
    lea     empty_msg,A1
    move.b  #14,D0
    trap    #15 put in a line break
    
    bsr     decorate
    
    lea     potion_msg,A1
    move.b  #14,D0
    trap    #15
    
    move.w  potion_count,D1
    move.b  #3,D0
    trap    #15 display the number of potions
    
    lea     empty_msg,A1
    move.b  #14,D0
    trap    #15 put in a line break
    
    bsr     decorate

    lea     weapon_msg,A1
    move.b  #14,D0
    trap    #15
    
    move.w  weapon_count,D1
    move.b  #3,D0
    trap    #15 display the number of weapons
    
    lea     empty_msg,A1
    move.b  #14,D0
    trap    #15 put in a line break
    
    bsr     decorate
    
    lea     player_curr_health,A1
    move.b  #14,D0
    trap    #15
    
    move.w  health,D1
    move.b  #3,D0
    trap    #15 display the number of weapons
    
    lea     empty_msg,A1
    move.b  #14,D0
    trap    #15 put in a line break
    
    bsr     decorate
    
    
    
    move.b  #4,D0
    trap    #15 wait for input to continue
    
    bsr     clear_screen
    bra     gameloop

    rts

*-------------------------------------------------------
*-----------------------Event Collisions----------------
* Used to see if the Player is at an event
*-------------------------------------------------------
collision:
    add.w   #1,  score give the player 1 point since they advanced without dying
  
	cmp     #40, distance_travelled
	beq     potion_shop_event shop event when player moves 80 steps
	
	cmp     #80, distance_travelled
	beq     weapon_shop_event shop event when player moves 80 steps
	
	cmp     #100, distance_travelled
	beq     enemy_event first enemy encounter when player moves 100 steps
	
	cmp     #160, distance_travelled
	beq     potion_shop_event shop event when player moves 160 steps
	
	cmp     #200, distance_travelled
	beq     enemy_event first enemy encounter when player moves 200 steps	
		
	cmp     #220, distance_travelled
	beq     weapon_shop_event shop event when player moves 220 steps
	
	cmp     #260, distance_travelled
	beq     enemy_event first enemy encounter when player moves 260 steps	
	
	cmp     #300, distance_travelled
	beq     enemy_event first enemy encounter when player moves 300 steps
	
	cmp     #340, distance_travelled
	beq     potion_shop_event shop event when player moves 340 steps
	
	cmp     #360, distance_travelled
	beq     enemy_event first enemy encounter when player moves 360 steps
	
	cmp     #400, distance_travelled
	beq     enemy_event first enemy encounter when player moves 400 steps
	
	cmp     #440, distance_travelled
	beq     weapon_shop_event shop event when player moves 80 steps
	
	cmp     #500, distance_travelled
	beq     enemy_event first enemy encounter when player moves 360 steps
	
	cmp     #560, distance_travelled
	beq     enemy_event first enemy encounter when player moves 400 steps
	
	cmp     #660, distance_travelled
	beq     enemy_event first enemy encounter when player moves 360 steps
	
	cmp     #700, distance_travelled
	beq     enemy_event first enemy encounter when player moves 400 steps
	
	cmp     #720, distance_travelled
	beq     potion_shop_event shop event when player moves 80 steps
	
	cmp     #740, distance_travelled
	beq     weapon_shop_event shop event when player moves 80 steps
	
	cmp     #780, distance_travelled
	beq     boss_event

    	
	
	move.w  #noir_loc,D1 check to see if the player has won the game
    cmp     distance_travelled,D1 is( x == 1000)?  
	bne     collision_miss if x is not equal to 100, then not hit
	beq     collision_hit  if x is equal to 100, then game is done
	
	
collision_hit:
    *hit
    lea     hit_msg,A1
    move    #14,D0
    trap    #15 show a message saying they have reached their destination
    
    move.b  #4,D0 wait for player to press something before continuing
    trap    #15
    
    bra     replay
    
    rts
    
collision_miss:
    *miss
    lea     miss_msg,A1
    move    #14,D0
    trap    #15 show a message saying the player has not yet reached their end point, but have not encountered any other event
    
    add.w   #20, distance_travelled show that the player has advanced
    
    move.b  #4,D0
    trap    #15 wait for player to press enter to advance
    
    rts
    
potion_shop_event:
    lea     potion_event_start,A1
    move.b  #14,D0
    trap    #15 display a message saying a shop has appeared
    
    move.b  #4,D0 get input on if the user wants to go in or not
    trap    #15
    
    add.w   #20, distance_travelled show that the player has advanced
    
    cmp     #1, D1
    beq     entered_potion_shop
    
    rts
    
weapon_shop_event:
    lea     weapon_event_start,A1
    move.b  #14,D0
    trap    #15
    
    move.b  #4,D0
    trap    #15
    
    add.w   #20, distance_travelled show that the player has advanced
    
    cmp     #1, D1
    beq     entered_weapon_shop
    
    rts

enemy_event:
    lea     battle_start_msg,A1
    move.b  #14,D0
    trap    #15
    
    move.b  #4,D0
    trap    #15

    bsr     battle_start
    
    add.w   #20, distance_travelled  if they survived, move 20 steps
    
    rts


boss_event:
    lea     boss_battle_start_msg,A1
    move.b  #14,D0
    trap    #15
    
    move.b  #4,D0
    trap    #15

    bsr     boss_battle_start
    
    add.w   #20, distance_travelled  if they survived, move 20 steps
    
    rts
    
entered_potion_shop:
    bsr     potions
    rts
    
entered_weapon_shop:
    bsr     weapons
    rts  

*-------------------------------------------------------
*-----------------------Battle System----------------
* When fighting an Enemy, we go here.
*-------------------------------------------------------
battle_start:
    move.w health, D3 move the player's current health into D3
    move.w #60, D4     move enemy health into D4
    
    cmp     #0, weapon_count
    bgt     battle_weapon if they have at least 1 weapon, go into battle with it
    bra     battle_no_Weapon otherwise fight bare handed
    
boss_battle_start:
    move.w health, D3 move the player's current health into D3
    move.w #120, D4     move boss health into D4
    
    cmp     #0, weapon_count
    bgt     boss_battle_weapon if they have at least 1 weapon, go into boss battle with it
    bra     boss_battle_no_weapon otherwise fight vare handed
    
battle_no_weapon:


    sub.w #10, D3
    sub.w #10, D4
    
    lea     battle_player_nullWep_hit,A1 say that they have no weapons, so they deal less damage
    move.b  #14,D0
    trap    #15

    lea     battle_enemy_hit,A1 say how much the enemy hit you for
    move.b  #14,D0
    trap    #15
    
    lea     player_curr_health,A1 display player health message
    move.b  #14,D0
    trap    #15

    move.w  D3, D1
    move.b  #3, D0
    trap    #15 display player health
    
    lea     empty_msg,A1 carrage return
    move.b  #14,D0
    trap    #15
    
    lea     enemy_curr_health,A1 display enemy health message
    move.b  #14,D0
    trap    #15
    
    move.w  D4, D1
    move.b  #3, D0
    trap    #15 display enemy health
    
    lea     empty_msg,A1 carrage return
    move.b  #14,D0
    trap    #15
 
    cmp     #0, D3 if the player's health is less than or equal to 0
    ble     game_over they have lost the fight
    
    cmp     #0, D4 if the enemy's health is less than or equal to 0
    ble     battle_noWep_won they have won the fight (and didnt have any weapons)
    
    move.b  #4,D0
    trap    #15 if no one has lost, wait for input before continuing
    
    bra battle_no_weapon if no one has lost, just keep looping

    
    
battle_weapon: 
* same as battle no wep but player deals 20 damage instead of 10
    sub.w #10, D3
    sub.w #20, D4
    
    lea     battle_player_hit,A1
    move.b  #14,D0
    trap    #15

    lea     battle_enemy_hit,A1
    move.b  #14,D0
    trap    #15
    
    lea     player_curr_health,A1
    move.b  #14,D0
    trap    #15

    move.w  D3, D1
    move.b  #3, D0
    trap    #15
    
    lea     empty_msg,A1
    move.b  #14,D0
    trap    #15
    
    lea     enemy_curr_health,A1
    move.b  #14,D0
    trap    #15
    
    move.w  D4, D1
    move.b  #3, D0
    trap    #15
    
    lea     empty_msg,A1
    move.b  #14,D0
    trap    #15
 
    cmp     #0, D3 if the player's health is less than or equal to 0
    ble     game_over they have lost the fight
    
    cmp     #0, D4 if the enemy's health is less than or equal to 0
    ble     battle_won they have won the fight
    
    move.b  #4,D0
    trap    #15 if no one has lost, wait for input before continuing
    
    bra battle_weapon if no one has lost, just keep looping
    
boss_battle_no_weapon:

    sub.w #10, D3
    sub.w #5, D4
    
    lea     boss_battle_player_nullWep_hit,A1 say that they have no weapons, so they deal less damage
    move.b  #14,D0
    trap    #15

    lea     battle_enemy_hit,A1 say how much the enemy hit you for
    move.b  #14,D0
    trap    #15
    
    lea     player_curr_health,A1 display player health message
    move.b  #14,D0
    trap    #15

    move.w  D3, D1
    move.b  #3, D0
    trap    #15 display player health
    
    lea     empty_msg,A1 carrage return
    move.b  #14,D0
    trap    #15
    
    lea     enemy_curr_health,A1 display enemy health message
    move.b  #14,D0
    trap    #15
    
    move.w  D4, D1
    move.b  #3, D0
    trap    #15 display enemy health
    
    lea     empty_msg,A1 carrage return
    move.b  #14,D0
    trap    #15
 
    cmp     #0, D3 if the player's health is less than or equal to 0
    ble     game_over they have lost the fight
    
    cmp     #0, D4 if the enemy's health is less than or equal to 0
    ble     battle_noWep_won they have won the fight (and didnt have any weapons)
    
    move.b  #4,D0
    trap    #15 if no one has lost, wait for input before continuing
    
    bra boss_battle_no_weapon if no one has lost, just keep looping
    
boss_battle_weapon: 
* same as boss battle no wep but player deals 20 damage instead of 10
    sub.w #10, D3
    sub.w #20, D4
    
    lea     battle_player_hit,A1
    move.b  #14,D0
    trap    #15

    lea     battle_enemy_hit,A1
    move.b  #14,D0
    trap    #15
    
    lea     player_curr_health,A1
    move.b  #14,D0
    trap    #15

    move.w  D3, D1
    move.b  #3, D0
    trap    #15
    
    lea     empty_msg,A1
    move.b  #14,D0
    trap    #15
    
    lea     enemy_curr_health,A1
    move.b  #14,D0
    trap    #15
    
    move.w  D4, D1
    move.b  #3, D0
    trap    #15
    
    lea     empty_msg,A1
    move.b  #14,D0
    trap    #15
 
    cmp     #0, D3 if the player's health is less than or equal to 0
    ble     game_over they have lost the fight
    
    cmp     #0, D4 if the enemy's health is less than or equal to 0
    ble     battle_won they have won the fight
    
    move.b  #4,D0
    trap    #15 if no one has lost, wait for input before continuing
    
    bra boss_battle_weapon if no one has lost, just keep looping

    
game_over:
    lea     battle_lose_msg,A1
    move.b  #14,D0
    trap    #15
    
    move.b  #4,D0
    trap    #15 wait for input before replay
    
    bra     replay

battle_won:
    lea     battle_win,A1 say they won in message form
    move.b  #14,D0
    trap    #15
    
    move.b  #100, D1
    move.b  #3, D0 say they won 100 gold
    trap    #15

    lea     battle_win_two,A1
    move.b  #14,D0
    trap    #15
    
    lea     empty_msg,A1
    move.b  #14,D0
    trap    #15
    
    add.w   #100, gold give them 100 gold
    
    move.w  D3, health
    
    move.b  #4,D0
    trap    #15 wait for input before continuing
    
    sub.w   #1, weapon_count take away a weapon because a fight has occured
    
    rts
    
battle_noWep_won:
* same as battle_won but doesnt take away a weapon (cause they have none)
    lea     battle_win,A1
    move.b  #14,D0
    trap    #15
    
    move.b  #100, D1
    move.b  #3, D0 say they won 100 gold
    trap    #15

    lea     battle_win_two,A1
    move.b  #14,D0
    trap    #15
    
    lea     empty_msg,A1
    move.b  #14,D0
    trap    #15
    
    add.w   #100, gold
    
    move.w  D3, health
    
    move.b  #4,D0
    trap    #15 if no one has lost, wait for input before continuing
    
    rts
    
boss_battle_won
    lea     battle_win,A1 say they won in message form
    move.b  #14,D0
    trap    #15
    
    move.w  #500, D1
    move.b  #3, D0 say they won 100 gold
    trap    #15

    lea     battle_win_two,A1
    move.b  #14,D0
    trap    #15
    
    lea     empty_msg,A1
    move.b  #14,D0
    trap    #15
    
    add.w   #500, gold give them 500 gold
    
    move.w  D3, health
    
    move.b  #4,D0
    trap    #15 wait for input before continuing
    
    sub.w   #1, weapon_count take away a weapon because a fight has occured
    
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
    clr.w     D3
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
                     dc.b    'gives you half the payment upfront -- 3000 gold.'
                     dc.b    $0D,$0A
                     dc.b    'With this, you must decide how best to spend your gold,'
                     dc.b    $0D,$0A
                     dc.b    'and how much you would like to keep for yourself.',0

potion_event_start   dc.b    'Along your journey, you come across a Potion shop. Will you go in?'
                     dc.b    $0D,$0A
                     dc.b    '1 Enter, Anything else Leave: ',0
                     
weapon_event_start   dc.b    'Along your journey, you come across a Weapon shop. Will you go in?'
                     dc.b    $0D,$0A
                     dc.b    '1 Enter, Anything else Leave: ',0

potions_msg:         dc.b    'You walk into a nearby potion shop and decide how many potions you need. '
                     dc.b    $0D,$0A
                     dc.b    '"Each potion costs 100 gold, how many do ye want?":  ',0
                     
potions_error_max    dc.b    'Even with your cavalry team, you would not be able to hold that many potions.'
                     dc.b    $0D,$0A,0
                     
potions_error_min    dc.b    'You will need potions to go on this journey.'
                     dc.b    $0D,$0A,0
                     
error_money          dc.b    'You do not have enough money.'
                     dc.b    $0D,$0A,0
                     
error_money_none     dc.b    'You do not have enough money to buy anything from the shop,'
                     dc.b    $0D,$0A
                     dc.b    'So you decide to leave.'
                     dc.b    $0D,$0A,0
                     
potion_msg:          dc.b    'Number of potions : ',0

weapon_msg:          dc.b    'Number of weapons : ',0

gold_msg             dc.b    'Amount of gold: ',0

health_msg           dc.b    'Current health: ',0

heal_ask_msg         dc.b    'Would you like to use a Potion to heal? (A Potion will heal 50 HP)'
                     dc.b    $0D,$0A
                     dc.b    '1 Yes, Anything else No: ',0
                     
heal_confirm_msg     dc.b    'You healed 50 HP!',0

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
                     
battle_start_msg     dc.b    'Suddenly, an Enemy appears..!',0

boss_battle_start_msg     dc.b    'Suddenly, a Giant Boss appears!!',0

battle_no_weapons    dc.b    'You have no weapons, so you deal less damage!'
                     dc.b    $0D,$0A,0

battle_player_hit    dc.b    'You hit the Enemy for 20 damage with your weapon!'
                     dc.b    $0D,$0A,0
                     
battle_player_nullWep_hit    dc.b    'You hit the Enemy for 10 damage with your bare fists!'
                     dc.b    $0D,$0A,0
                     
boss_battle_player_nullWep_hit    dc.b    'You hit the Boss for 5 damage with your bare fists!'
                     dc.b    $0D,$0A,0
                     
battle_enemy_hit     dc.b    'You were hit and took 10 damage!'
                     dc.b    $0D,$0A,0
                     
battle_win           dc.b    'You won the battle! You found ',0
battle_win_two       dc.b    ' gold!',0

battle_lose_msg      dc.b    'You lost...',0

player_curr_health   dc.b    'Your Health: ',0
enemy_curr_health    dc.b    'Enemy Health: ',0
          
gameplay_msg:        dc.b    'Distance Travelled: ',0

update_msg:          dc.b    'Update Gameplay !',0
draw_msg:            dc.b    'Draw Screen !',0
hit_msg:             dc.b    'You made it!',0
miss_msg:            dc.b    'Nothing eventful happened.',0
loop_msg:            dc.b    '.',0
replay_msg:          dc.b    'Enter 0 to Quit any other number to replay : ',0
hud_msg:             dc.b    'Score : ',0
empty_msg            dc.b    '',$0D,$0A,0



    end start

















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
