Start:
	mov ax,0b30h
	mov ds,ax
	mov es,ax
	;判断一个数是奇数还是偶数
	mov ah,0
	mov cx,3   ;这个数是3
	int 21h	
	mov ah,0
	mov cx,4	;这个数是4
	int 21h
	;在0ah行，20h列显示颜色为‘3f’的信息
	mov ah,1
	mov dx,0a20h
	mov cl,3fh
	int 21h
	;计算3+4
	mov ah,2
	mov cl,3
	mov ch,4
	int 21h
	;计算5+8
	mov ah,2
	mov cl,5
	mov ch,8
	int 21h	

;延时程序 DELAY 和 DELAY2构成一个双重循环，只是为了延时
	mov cx,0afffh
DELAY: 
	push cx;
	mov cx,0afffh
DELAY2:
	loop DELAY2
	pop cx
	loop DELAY

	ret
	
	times 510-($-$$) db 0
    db 0x55,0xaa
	
	
	
	