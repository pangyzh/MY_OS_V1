start:
	mov ax,cs
	mov ds,ax
	mov ax,0b800h			
	mov es,ax				; ES = B800h
	cmp byte[run],1
	jz BEGIN
	mov byte[count],0
	mov byte[run],1
	mov word[x],12
	mov word[y],-1
	mov byte[dir],Dn_Rt
BEGIN:
	mov ax,0100h
	int 16h
	jnz ReadKey
	jmp NotRead
ReadKey:
	mov ax,0
	int 16h
	cmp al,'3'
	jz RETURN
NotRead:
	inc byte[count]
	cmp byte[count],07fh
	jz RETURN
	jmp Direct
	
RETURN:
	mov ax,0
	mov es,ax
	mov word[es:604h],0
	mov byte[run],0
	ret
	
Direct:
	cmp byte[dir],1
	jz Down_Right
	cmp byte[dir],2
	jz Down_Left
	cmp byte[dir],3
	jz Up_Right
	cmp byte[dir],4
	jz Up_Left
	jmp start
	
;down and right	
Down_Right:
	mov byte[dir],Dn_Rt
	cmp word[y],39
	jz Down_Left
	cmp word[x],24
	jz Up_Right
	inc word[x]			
	inc word[y]		
	jmp SHOW			
;down and left 
Down_Left:
	mov byte[dir],Dn_Lt
	cmp word[y],0
	jz Down_Right
	cmp word[x],24
	jz Up_Left
	inc word[x]
	dec word[y]
	jmp SHOW
;up and left
Up_Left:
	mov byte[dir],Up_Lt
	cmp word[y],0
	jz Up_Right
	cmp word[x],13
	jz Down_Left
	dec word[x]
	dec word[y]
	jmp SHOW
;up and right 
Up_Right:
	mov byte[dir],Up_Rt
	cmp word[y],39
	jz Up_Left
	cmp word[x],13
	jz Down_Right
	dec word[x]
	inc word[y]
	jmp SHOW
	
SHOW:
	mov ax,[x]
	mov cx,80
	mul cx
	add ax,[y]
	mov cx,2
	mul cx
	mov bx,ax	
	mov al,'A'	
	mov ah,0Fh
	mov word[es:bx],ax	

	;show the char 'B',which opposite to the char 'A'
	mov ax,37
	sub ax,word[x]
	mov cx,80
	mul cx
	mov bx,39
	sub bx,[y]
	add ax,bx
	mov cx,2
	mul cx
	mov bx,ax
	mov al,'B'
	mov ah,0Fh
	mov [es:bx],ax
	jmp SHOW_NAME
	jmp BEGIN
;show the name and id
SHOW_NAME: 
	;show the rectangle in the center, full of '*'
	mov word[xx],16
	mov cx,4
L1:	
	push cx
	mov word[yy],10
	mov cx,24
L2:
	call CAL
	mov byte[es:bx],'*'
	mov al,0Fh
	mov byte[es:bx+1],al
	inc word[yy]	
	loop L2
	pop cx
	inc word[xx]
	loop L1
	;show the first name
	mov word[xx],17
	mov word[yy],12
	mov si,0
	mov cx,19
L3:
	call CAL
	mov al,byte[firstname+si]
	mov byte[es:bx],al
	inc word[yy]
	inc si
	loop L3
	;show the second name
	mov word[xx],18
	mov word[yy],12
	mov si,0
	mov cx,18
L4:
	call CAL
	mov al,byte[secondname+si]
	mov byte[es:bx],al
	inc word[yy]
	inc si
	loop L4
	push es
	mov ax,0
	mov es,ax
	cmp word [es:604h],1
	pop es
	jz FENSHI
	mov cx,0f0h
	call DELAY
	jmp BEGIN
FENSHI:
	mov cx,090h
	call DELAY
	ret	
;(x*80+y)*2
CAL:mov ax,word[xx]
	mov bx,80
	mul bx
	add ax,word[yy]
	mov bx,2
	mul bx
	mov bx,ax
	ret
DELAY:
DELAY1:
	push cx
	mov cx,05fffh
DELAY2:
	loop DELAY2
	pop cx
	loop DELAY1
	ret		
end:
    jmp $ 			

	
datadef:	
    Dn_Rt equ 1                  ;D-Down,U-Up,R-right,L-Left
    Up_Rt equ 3                  ;
    Up_Lt equ 4                  ;
    Dn_Lt equ 2                  ;
    dir db Dn_Rt         
    x    dw 0
    y    dw 0
    char db 'A'
	xx dw 0
	yy dw 0
	count db 0
	run db 0
	firstname db 'pangyezhan-16337192'
	secondname db 'pengsijie-16337193'
	times 1022-($-$$) db 0
    db 0x55,0xaa