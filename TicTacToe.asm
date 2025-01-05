.MODEL SMALL
.STACK 100H

.DATA  
    game_draw db "_|_|_", 13, 10
              db "_|_|_", 13, 10
              db "_|_|_", 13, 10, "$"     
    game_pointer db 9 DUP(?)
    win_flag db 0  
    game_over_message db "GAME OVER!!", 13, 10, "$"
    player dw '0'
    player_message db "PLAYER $"
    type_message db "TYPE A POSITION (1-9): $"
    new_line db 13, 10, "$"   
    firstwin db 'First Player Wins!', 13, 10, "$"
    secondwin db 'Second Player Wins!', 13, 10, "$"  
    firstplayer db 'First Player:$'   
    secondplayer db 'Second Player:$'  
    drawprint db 'Game ended as DRAW!', 13, 10, "$"
    invalid_message db "INVALID, please choose another position.", 13, 10, "$" 
    congratulations db ", congratulations to you!$"
  

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    CALL set_game_pointer

game_function:   
    LEA SI, player
    CMP DS:[SI], "0"
    JE firstplayerturn 
    LEA DX, secondplayer
    CALL print
    CALL print_newline
    LEA DX, game_draw
    CALL print
    CALL print_newline
    LEA DX, type_message
    CALL print
    CALL key_pressed
    SUB AL, '1'
    MOV BH, 0
    MOV BL, AL 
    CALL print_newline 
    CALL update_draw 
    CALL check
    CMP win_flag, 1
    JE game_over
    CMP win_flag, 2
    JE draw_print
    CALL change_player
    JMP game_function 
    
firstplayerturn:
    LEA DX, firstplayer
    CALL print 
    CALL print_newline 
    LEA DX, game_draw
    CALL print
    CALL print_newline                            
    LEA DX, type_message
    CALL print
    CALL key_pressed
    SUB AL, '1'
    MOV BH, 0
    MOV BL, AL  
    CALL print_newline
    CALL update_draw 
    CALL check
    CMP win_flag, 1
    JE game_over
    CALL change_player
    JMP game_function

draw_print:
    CALL print_newline 
    LEA DX, game_draw
    CALL print 
    CALL print_newline
    LEA DX, game_over_message
    CALL print
    CALL print_newline
    LEA DX, drawprint
    CALL print
    MOV AH, 4CH
    INT 21H 
    
game_over:
    CALL print_newline 
    LEA DX, game_draw
    CALL print 
    CALL print_newline 
    LEA DX, game_over_message
    CALL print
    CALL print_newline
    LEA SI, player
    CMP DS:[SI], "0"
    JE print_player_win
    LEA DX, secondwin
    CALL print
  
    MOV AH, 4CH
    INT 21H

print_player_win:
    LEA DX, firstwin
    CALL print  

    MOV AH, 4CH
    INT 21H 

MAIN ENDP

set_game_pointer PROC
    LEA SI, game_draw
    LEA BX, game_pointer
    MOV CX, 9

set_loop:
    CMP CX, 3
    JE skip_space
    CMP CX, 6
    JE skip_space

add_position:
    MOV DS:[BX], SI
    ADD SI, 2
    INC BX
    LOOP set_loop
    RET

skip_space: 
    ADD SI, 1
    JMP add_position
set_game_pointer ENDP

key_pressed PROC 
    MOV AH, 1
    INT 21H
    RET
key_pressed ENDP

change_player PROC
    LEA SI, player
    CMP DS:[SI], "0"
    JE switch_to_player_1
    MOV DS:[SI], "0"
    RET

switch_to_player_1:
    MOV DS:[SI], "1"
    RET
change_player ENDP

update_draw PROC
    MOV BL, game_pointer[BX]
    MOV AL, DS:[BX]
    CMP AL, "_"  
    JNE invalid_position  
    LEA SI, player
    CMP DS:[SI], "0"
    JE draw_x
    MOV CL, "o"
    JMP update

draw_x:
    MOV CL, "x"

update:
    MOV DS:[BX], CL   
    RET 

invalid_position:
    CALL print_newline 
    LEA DX, invalid_message
    CALL print          
    CALL change_player
    CALL print_newline
    RET                
update_draw ENDP


check PROC
    CALL check_line
    CALL check_column
    CALL check_diagonal
    CMP win_flag, 1
    JE end_check
    CALL check_draw
end_check:
    RET
check ENDP


check_draw PROC
    MOV CX, 9   
    LEA SI, game_pointer
     
check_draw_loop:
    MOV BX, [SI]      
    MOV AL, DS:[BX]   
    CMP AL, "_"       
    JE not_draw        
    ADD SI, 2            
    LOOP check_draw_loop 
    MOV win_flag, 2     
    RET 
                   
not_draw:
    RET                   
check_draw ENDP


check_line PROC
    MOV CX, 0 
    
check_line_loop:
    CMP CX, 0
    JE first_line
    CMP CX, 1
    JE second_line
    CMP CX, 2
    JE third_line
    RET

first_line:
    MOV SI, 0
    JMP do_check_line

second_line:
    MOV SI, 3
    JMP do_check_line

third_line:
    MOV SI, 6
    JMP do_check_line

do_check_line:
    INC CX
    MOV BH, 0
    MOV BL, game_pointer[SI]
    MOV AL, DS:[BX]
    CMP AL, "_"
    JE check_line_loop
    INC SI
    MOV BL, game_pointer[SI]
    CMP AL, DS:[BX]
    JNE check_line_loop
    INC SI
    MOV BL, game_pointer[SI]
    CMP AL, DS:[BX]
    JNE check_line_loop
    MOV win_flag, 1
    RET
check_line ENDP

check_column PROC
    MOV CX, 0
check_column_loop:
    CMP CX, 0
    JE first_column
    CMP CX, 1
    JE second_column
    CMP CX, 2
    JE third_column
    RET

first_column:
    MOV SI, 0
    JMP do_check_column

second_column:
    MOV SI, 1
    JMP do_check_column

third_column:
    MOV SI, 2
    JMP do_check_column

do_check_column:
    INC CX
    MOV BH, 0
    MOV BL, game_pointer[SI]
    MOV AL, DS:[BX]
    CMP AL, "_"
    JE check_column_loop
    ADD SI, 3
    MOV BL, game_pointer[SI]
    CMP AL, DS:[BX]
    JNE check_column_loop
    ADD SI, 3
    MOV BL, game_pointer[SI]
    CMP AL, DS:[BX]
    JNE check_column_loop
    MOV win_flag, 1
    RET
check_column ENDP

check_diagonal PROC
    MOV CX, 0 
    
check_diagonal_loop:
    CMP CX, 0
    JE first_diagonal
    CMP CX, 1
    JE second_diagonal
    RET

first_diagonal:
    MOV SI, 0
    MOV DX, 4
    JMP do_check_diagonal

second_diagonal:
    MOV SI, 2
    MOV DX, 2
    JMP do_check_diagonal

do_check_diagonal:
    INC CX
    MOV BH, 0
    MOV BL, game_pointer[SI]
    MOV AL, DS:[BX]
    CMP AL, "_"
    JE check_diagonal_loop
    ADD SI, DX
    MOV BL, game_pointer[SI]
    CMP AL, DS:[BX]
    JNE check_diagonal_loop
    ADD SI, DX
    MOV BL, game_pointer[SI]
    CMP AL, DS:[BX]
    JNE check_diagonal_loop
    MOV win_flag, 1
    RET
check_diagonal ENDP

print PROC
    MOV AH, 9
    INT 21H   
    RET
print ENDP

print_newline PROC
    MOV DX, 0
    LEA DX, new_line
    CALL print
    RET
print_newline ENDP


END MAIN