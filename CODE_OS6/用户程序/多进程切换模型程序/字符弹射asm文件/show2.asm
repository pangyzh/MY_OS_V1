START:
	mov ax,cs
	mov ds,ax
	mov ax,0b800h			; 文本窗口显存起始地址
	mov es,ax				; ES = B800h
	cmp byte[run],1
	jz BEGIN
	mov word[x],-1
	mov word[y],39
	mov byte[dir],Dn_Rt
	mov byte[cnt],2
	mov byte[color],1fh
	mov byte[count],0
	mov byte[run],1	
BEGIN:
	mov ax,0100h
	int 16h
	jnz ReadKey
	jmp NotRead
ReadKey:
	mov ax,0
	int 16h
	cmp al,'2'
	jz RETURN
NotRead:	
	inc byte[count]
	cmp byte[count],07fh
	jz RETURN
	jmp Direct
RETURN:
	mov ax,0
	mov es,ax
	mov word[es:602h],0
	mov byte[run],0
	ret
	
Direct:
	;确定方向	
	cmp byte[dir],1
	jz Down_Right
	cmp byte[dir],2
	jz Down_Left
	cmp byte[dir],3
	jz Up_Right
	cmp byte[dir],4
	jz Up_Left
	jmp START
	
;down and right	右下
Down_Right:
	mov byte[dir],Dn_Rt
	cmp word[y],79
	jz Down_Left
	cmp word[x],11
	jz Up_Right
	inc word[x]			;横坐标加1
	inc word[y]			;纵坐标加1
	jmp SHOW			;跳转到显示模块
;down and left 左下
Down_Left:
	mov byte[dir],Dn_Lt
	cmp word[y],40
	jz Down_Right
	cmp word[x],11
	jz Up_Left
	inc word[x]
	dec word[y]
	jmp SHOW
;up and left 左上
Up_Left:
	mov byte[dir],Up_Lt
	cmp word[y],40
	jz Up_Right
	cmp word[x],0
	jz Down_Left
	dec word[x]
	dec word[y]
	jmp SHOW
;up and right 右上
Up_Right:
	mov byte[dir],Up_Rt
	cmp word[y],79
	jz Up_Left
	cmp word[x],0
	jz Down_Right
	dec word[x]
	inc word[y]
	jmp SHOW
;show the char
SHOW:
	;calculate the color of char
	inc byte[cnt]
	cmp byte[cnt],0fh
	jz CHANGE
	jmp SHOWB
CHANGE:
	mov byte[cnt],2
	jmp SHOWB

SHOWB:
	;show the char 'B'
	mov ax,[x]
	mov cx,80
	mul cx
	add ax,[y]
	mov cx,2
	mul cx
	mov bx,ax	;显示字符的地址
	mov al,'A'	;al存要显示的字符
	mov ah,byte[cnt] ;ah存显示字符的颜色属性
	mov [es:bx],ax
	jmp SHOW_NAME
	jmp BEGIN
;show the name and id
SHOW_NAME: 
	;show the rectangle in the center, full of '*'
	mov word[xx],4;-----------------------------
	mov cx,4
L1:	
	push cx
	mov word[yy],50;----------------
	mov cx,24
L2:
	call CAL
	mov byte[es:bx],'*'
	mov al,[color]
	mov byte[es:bx+1],al
	inc word[yy]	
	loop L2
	pop cx
	inc word[xx]
	loop L1
	;show the first name
	mov word[xx],5;----------------
	mov word[yy],52;-------------
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
	mov word[xx],6;------------------
	mov word[yy],52;---------------
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
	cmp word [es:602h],1
	pop es
	jz FENSHI
	mov cx,0f0h
	call DELAY
	jmp BEGIN
FENSHI:
	mov cx,090h
	call DELAY
	ret	
;计算字符地址，利用(x*80+y)*2
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
    jmp $ 			; 停止画框，无限循环 
	
DEFINE:
    Dn_Rt equ 1                  ;D-Down,U-Up,R-right,L-Left
    Dn_Lt equ 2                  ;
    Up_Rt equ 3                  ;
    Up_Lt equ 4                  ;
;变量初始化--
	xx dw 0
	yy dw 0
	x dw 0
	y dw 0
	dir db Dn_Rt
	firstname db 'pangyezhan-16337192'
	secondname db 'pengsijie-16337193'
	cnt db 0
	color db 1fh
	count db 0
	run db 0	
	times 1022-($-$$) db 0
    db 0x55,0xaa	