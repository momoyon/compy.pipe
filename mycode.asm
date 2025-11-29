include emu8086.inc

org 100h

.data
	filename db "FILE.txt", 0
	filehandle dw 0

	text db "Hello, World", 10, 13
	textlen dw $ - text

	l1 db "1.Attack", 10, 13, 24h
	l2 db "2.Defend", 10, 13, 24h
	l3 db "3.Magic", 10, 13, 24h
	l4 db "4.Use Item", 10, 13, 24h
	l5 db 10, 13, 24h
	l6 db "What is your actions?[1,2,3,4]: ", 24h


	create_file_msg_s db "File created successfully!", 10, 13, 24h
	create_file_msg_e db "Failed to create file!", 10, 13, 24h

	write_to_file_msg_s db "Wrote to file successfully!", 10, 13, 24h
	write_to_file_msg_e db "Failed to write to file!", 10, 13, 24h

	open_file_msg_s db "Opened successfully!", 10, 13, 24h
	open_file_msg_e db "Failed to open file!", 10, 13, 24h

	close_file_msg_s db "Closed file successfully!", 10, 13, 24h
	close_file_msg_e db "Failed to close file!", 10, 13, 24h

	input_out_of_range_msg db "ERROR: Input should be in range 1-4!", 10, 13, 24h

	input db ?

.code
start:
	; INT 10h / AH = 0 - set video mode.
	mov ax, 0 ; TEXT MODE 40x25, 16 colors 8 pages
	int 10h


loop:
	call CLEAR_SCREEN

	; Create file/Clear file
	mov dx, offset filename
	call create_file
	
	; Print prompt
	mov dx, offset l1
	call print_line 
	mov dx, offset l2
	call print_line 
	mov dx, offset l3
	call print_line 
	mov dx, offset l4
	call print_line 
	mov dx, offset l5
	call print_line 
	mov dx, offset l6
	call print_line 
	
	; Get user input
	call get_user_input

	jmp loop

	ret


; filename in ds:dx (ASCIIZ)

; RET:
; CF set if error
; BX stores the file handle
create_file proc
	
	push cx
	push ax

	mov ah, 3Ch
	mov cx, 0
	int 21h

	jc .create_file_error

	push dx

.create_file_success:
	mov dx, offset create_file_msg_s
	call print_line
	mov bx, ax
	jmp .create_file_end
.create_file_error:
	mov dx, offset create_file_msg_e
	call print_line

	ret
.create_file_end:

	; INT 21h / AH= 3Dh - open existing file.
	pop dx
	mov al, 2
	mov ah, 3dh
	int 21h
	jc .open_file_error
	mov [filehandle], ax

.open_file_success:
	mov dx, offset open_file_msg_s
	call print_line
	mov bx, ax
	jmp .open_file_end
.open_file_error:
	mov dx, offset open_file_msg_e
	call print_line

	ret
.open_file_end:

	pop ax
	pop cx

	ret
create_file endp


; - filehandle - BX
; - num bytes  - CX
; - data       - DX

; RET:
; CF set if error
; AX is error code if CF else bytes written
write_to_file proc
	clc
	;INT 21h / AH= 40h - write to file. 
	mov ah, 40h
	int 21h

.write_file_success:
	mov dx, offset write_to_file_msg_s
	call print_line
	jmp .write_file_done
.write_file_error:
	mov dx, offset write_to_file_msg_e
	call print_line
	ret
.write_file_done:

; 	clc
; 	; INT 21h / AH= 3Eh - close file.
; 	mov ah, 3eh
; 	int 21h
;
; .close_file_success:
; 	mov dx, offset close_file_msg_s
; 	call print_line
; 	jmp .close_file_done
; .close_file_error:
; 	mov dx, offset close_file_msg_e
; 	call print_line
; 	CALL PRINT_NUM
; 	int 20h ; Exit 
; .close_file_done:
	
	ret
write_to_file endp


; - DS:DX - string (ASCIIZ)
print_line proc
	mov ah, 9
	int 21h
	ret
print_line endp



get_user_input proc
	push cx

	call SCAN_NUM

	; Check if number in range
	cmp cx, 4
	ja .number_out_of_range

	jmp .done

.number_out_of_range:
	mov dx, offset input_out_of_range_msg
	call print_line

	ret
.done:
	clc

	add cl, 48
	mov [input], cl

	; Write input to file
	mov bx, [filehandle]
	mov cx, 1
	mov dx, offset input
	call write_to_file 

	pop cx
	ret
get_user_input endp


DEFINE_SCAN_NUM
DEFINE_CLEAR_SCREEN
DEFINE_PRINT_NUM
DEFINE_PRINT_NUM_UNS
end
