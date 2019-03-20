extrn _main:near
extrn _pos:near
extrn _cal_pos:near
extrn _x:near
extrn _y:near
extrn _offset_user:near
extrn _ch:near
extrn _isouch:near
extrn _cpaint:near
extrn _C_evenodd:near
extrn _number:near
extrn _sum:near
extrn _num1:near
extrn _num2:near
extrn _C_sum:near
extrn _CurrentProc:near
extrn _Scheduler:near

_TEXT segment byte public 'CODE'
DGROUP group _TEXT,_DATA,_BSS
	assume cs:_TEXT
	org 100h

start:
	mov ax,cs
	mov ds,ax
	mov es,ax
	mov ss,ax
	mov sp,100h
	
	;call set_clock_int
	;call set_int3456
	call int21h
	call near ptr _main
	jmp $

public _set	;移动光标位置
_set proc
	push ax
	push bx
	push dx
	mov ah,02h
	mov dh,byte ptr [_x]
	mov dl,byte ptr [_y]
	mov bh,0
	int 10h
	pop dx
	pop bx
	pop ax
	ret
_set endp


public _getChar  ;从键盘读入一个字符
_getChar proc
	push ax;进zhan
	call _set
	mov ax,0
	int 16h
	mov byte ptr [_ch],al ;都如入的字符存在ch中
	pop ax
	ret
_getChar endp

public _cls   ;清屏
_cls proc 
        push ax
        push bx
        push cx
        push dx		
		mov	ax, 600h	; AH = 6,  AL = 0
		mov	bx, 700h	; 黑底白字(BL = 7)
		mov	cx, 0		; 左上角: (0, 0)
		mov	dx, 184fh	; 右下角: (24, 79)
		int	10h		; 显示中断
		pop dx
		pop cx
		pop bx
		pop ax
		mov word ptr [_x],0
		mov word ptr [_y],0
        mov word ptr [_pos],0
		call _set
		ret
_cls endp

public _printChar  ;输出一个字符
_printChar proc 
	push ax
	push es
	push bp
	push bx
	
	call _set
	
    mov bp,sp
    mov ax,0b800h
	mov es,ax
	mov al,byte ptr [bp+2+2+2+2+2] ;ch\IP\bp\es\ax
	mov ah,00Fh
	
	mov bx,word ptr[_pos] ;将显示位置取出
	mov word ptr es:[bx],ax
	inc word ptr [_y];纵坐标加1
	
	call near ptr _cal_pos;重新计算坐标之后出栈
	
	pop bx
	pop bp
	pop es
	pop ax
	ret
_printChar endp



Public	_printf  ;输出一个字符串
_printf proc 
	push	bp         ;sp+2
	push	es         ;sp+2+2
	push    ax         ;sp+2+2+2
    mov ax,0b800h
	mov es,ax
	mov	bp, sp

	mov	si, word ptr [bp + 2+2+2+2]	; pszInfo\IP\bp\es\ax，取出首字符地址
	mov	di, word ptr [_pos]	;取出显示位置

	.1:
	mov al,byte ptr [si]	;字符取出
	inc si	;地址加1变成下一字符
	;mov byte ptr [di],al	;此字符要显示的位置
	test	al, al	;检查是否是空字符
	jz	.2	;是空则跳转到.2
	cmp	al, 0Ah	; 是回车吗?
	jz	.3	;是就跳转到.3
	
	mov ah,0Fh;颜色
	mov word ptr es:[di],ax;显示
	inc byte ptr [_y];转到下一个字符进行显示
	call near ptr _cal_pos;重新计算坐标
	mov di,word ptr [_pos] ;位置存进di
	jmp	.1
	
	.3:	;换行的时候直接往下移动一格
	inc word ptr [_x]
	mov word ptr [_y],0;然后纵坐标设成从头开始
	call near ptr _cal_pos
	mov di,word ptr[_pos]
	jmp	.1

	.2:	;如果是空格的话，那么直接设置光标之后退出
	call _set
	pop ax
	pop es
	pop bp
	
	ret
_printf endp	

;load(offset_begin,num_shanqu,pos_shanqu,segment)
public _load2
_load2 proc
	push ax
	push bx
	push cx
	push dx
	push es
	push bp
	mov bp,sp
	mov ax,word ptr [bp+12+8]             
    mov es,ax                ;设置段地址
    mov bx,word ptr [bp+12+2]  ;偏移地址
    mov ah,2                 ; 功能号
    mov al,byte ptr [bp+12+4] ;扇区数
    mov dl,0                 ;驱动器号
    mov dh,0                 ;磁头号
    mov ch,0                 ;柱面号
    mov cl,byte ptr [bp+12+6];起始扇区号
    int 13H ;                
	pop bp
	pop es
	pop dx
	pop cx
	pop bx
	pop ax
	ret
_load2 endp

Public _load
_load proc
	push ax
	push bx
	push cx
	push dx
	push es
	push bp
	
	mov bp,sp
	mov ax,cs
	mov es,ax ;设置段地址
	mov bx,word ptr [bp+12+2] ;偏移地址
	mov ah,2;功能号
	mov al,byte ptr [bp+12+4] ;扇区数
	mov dx,00h
	mov ch,0
	mov cl,byte ptr [bp+12+6] ;起始扇区号
	int 13h ;13号中断磁盘io的调用
	
	pop bp
	pop es
	pop dx
	pop cx
	pop bx
	pop ax
	ret
_load endp

kernelsp dw 0
kernelss dw 0
;跳转到用户程序

public _jmp2
_jmp2 proc
	push ax
	push bx
	push cx
	push dx
	push es
	push ds

	mov word ptr [kernelss],ss
	mov word ptr [kernelsp],sp
	call SetTimer
	call set_clock_int
	;;;;;;;;;;;;;
	;手动模拟时钟中断从内核开始进行时间片轮转
	;时间片轮转期间 不轮转到内核 直到轮转结束
	mov ax,512  ;
	push ax     ;将flag压入栈
	push cs     ;将cs压入栈
	call Timer  ;利用call将ip压栈
	;;;;;;;;;;;;;
	mov ss,word ptr [kernelss]
	mov sp,word ptr [kernelsp]
	call re_clock_int

	pop ds
	pop es
	pop dx
	pop cx
	pop bx
	pop ax
	ret
_jmp2 endp	

public _jmp
_jmp proc
	push ds
	call word ptr [_offset_user] ;跳转到offset_user表示的地址运行
	pop ds
	ret
_jmp endp


;*********************************************************************
;*                   Save                                                                    *
;*********************************************************************
; 将当前进程的寄存器值保存到当前进程的PCB中
ds_save dw ?
ret_save dw ?
si_save dw ?

;中断现场保护
public save
save proc
	push ds
	push cs
	pop ds
	pop word ptr [ds_save]
	pop word ptr [ret_save]
	mov word ptr[si_save],si
	mov si,word ptr [_CurrentProc]
	add si,22
	pop word ptr [si]
	add si,2
	pop word ptr [si]
	add si,2
	pop word ptr [si]
	mov word ptr [si-6],sp
	mov word ptr [si-8], ss
	mov si,ds
	mov ss,si
	mov sp,word ptr [_CurrentProc]
	add sp,18
	push word ptr[ds_save]
	push es
	push bp
	push di
	push word ptr[si_save]
	push dx
	push cx
	push bx
	push ax
	mov sp,word ptr[kernelsp]
	mov ax,word ptr [ret_save]
	jmp ax
save endp
;**********************************************************************
;*                    Restart                                                              *
;**********************************************************************
; 从当前选择的进程的PCB中恢复寄存器值，并启动其运行	
lds_low dw ?
lds_high dw ?
restart  proc
	mov word ptr[kernelsp],sp
	mov sp,word ptr[_CurrentProc]
	pop ax
	pop bx
	pop cx
	pop dx
	pop si
	pop di
	pop bp
	pop es
	mov word ptr[lds_low],bx
	pop word ptr[lds_high]
	mov bx,sp
	mov bx,word ptr[bx]
	mov ss,bx
	mov bx,sp
	add bx,2
	mov sp,word ptr[bx]
	push word ptr[bx+6]
	push word ptr[bx+4]
	push word ptr[bx+2]
	lds bx,dword ptr[lds_low]
	push ax
	mov al,20h			; AL = EOI
	out 20h,al			; 发送EOI到主8529A
	out 0A0h,al			; 发送EOI到从8529A
	pop ax
	iret				; 从中断返回
restart  endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;设置计时器，时钟每秒20次中断（50ms一次）：
;***************************************************************************
;*                      SetTimer                                           *
;***************************************************************************
; 设置计时器函数
SetTimer proc
	cli
	push ax
	mov al,34h			; 设控制字值
	out 43h,al				; 写控制字到控制字寄存器
	mov ax,60000			; 约每秒20次中断（50ms一次）
	out 40h,al				; 写计数器0的低字节
	mov al,ah				; AL=AH
	out 40h,al				; 写计数器0的高字节
	pop ax
	sti
	ret
SetTimer endp
; ---------------------------------------------------------------
;时钟中断处理程序参考程序：
;***************************************************************************
;*                         Timer                                                                   *
;***************************************************************************
; 时钟中断处理程序
              ; 使用当前进程的栈
timer proc
	call save
	call near ptr _Scheduler   
	jmp restart
	
timer endp


	  

;输出一个指定位置的指定颜色的字符
;show_color_char(char,x,y,color)
public _show_color_char
_show_color_char proc
	push bp
	push es
	push ax
	push bx
	push dx
	push ds
	mov bp,sp

	mov ax,0b800h
	mov es,ax
	mov ax,word ptr [bp+4+6*2];x
	mov bx,80
	mul bx
	add ax,word ptr [bp+6+6*2];y
	mov bx,2
	mul bx
	mov bx,ax
	mov ax,word ptr [bp+2+6*2];char
	mov byte ptr es:[bx],al
	mov ax,word ptr [bp+8+6*2];color
	mov byte ptr es:[bx+1],al
	
	pop ds
	pop dx
	pop bx
	pop ax
	pop es
	pop bp
	ret
_show_color_char endp

clock_vector dw 0,0
;设置时钟中断 08h
set_clock_int proc
	cli
	push es
	push ax
	xor ax,ax
	mov es,ax
	;save the vector
	mov ax,word ptr es:[20h]
	mov word ptr [clock_vector],ax
	mov ax,word ptr es:[22h]
	mov word ptr [clock_vector+2],ax
	;fill the vector
	mov word ptr es:[20h],offset Timer
	mov ax,cs
	mov word ptr es:[22h],ax
	pop ax
	pop es
	sti
	ret
set_clock_int endp
;恢复时钟中断
re_clock_int proc
	cli
	push es
	push ax
	xor ax,ax
	mov es,ax
	mov ax,word ptr [clock_vector]
	mov word ptr es:[20h],ax
	mov ax,word ptr [clock_vector+2]
	mov word ptr es:[22h],ax
	pop ax
	pop es
	sti
	ret
re_clock_int endp
;系统调用21h，设置中断向量表
int21h proc 
	cli
	push ax
	push es
	xor ax,ax
	mov es,ax	
	add ax,800h	
	mov word ptr es:[84h],offset mysyscall
	;mov ax,cs
	mov word ptr es:[86h],ax
	pop es
	pop ax
	sti
	ret
int21h endp

;跳转分支表
mycall_vec dw vector0,vector1,vector2
;系统调用入口，根据ah来判断具体功能
;因为此处用到al,bx，所以al,bx不能作为系统调用的参数
mysyscall proc
	cli
	push es
	push si
	push di
	push ax
	push bx
	push cx
	push dx
	push bp
	push ds
	mov al,ah
	xor ah,ah
	shl ax,1;*2
	mov bx,offset mycall_vec
	add bx,ax
	;改段地址
	mov ax,cs
	mov es,ax
	mov ds,ax
	;调用对应系统调用
	call word ptr [bx]

	mov al,20h
	out 20h,al
	out 0a0h,al
	
	pop ds
	pop bp
	pop dx
	pop cx
	pop bx
	pop ax
	pop di
	pop si
	pop es
	sti
	iret
mysyscall endp

;系统调用0，ah=0
;判断一个数的奇偶性
vector0 proc
	push cx
	mov ax,cx
	mov word ptr [_number],ax
	call near ptr _C_evenodd
	pop cx
	ret
vector0 endp

syscall1_color db 5
information1 db '---16337192---'
information2 db '---16337193---'
;系统调用1，ah=1
;在指定dh行，dl列开始显示cl指定色调的个人信息
vector1 proc
	xor ax,ax
	mov al,dh
	mov bl,80
	mul bl
	xor dh,dh
	add ax,dx
	shl ax,1
	mov bx,ax
	mov byte ptr [syscall1_color],cl
	mov ax,0b800h
	mov es,ax
;显示info1	
	sub bx,480
	add bx,2
	push bx
	mov cx,14
	lea si,information1
loop1_1:
	mov al,byte ptr [si]
	mov byte ptr es:[bx],al
	inc bx
	inc bx
	inc si
	loop loop1_1
;显示info2	
	pop bx
	add bx,160
	mov cx,14
	lea si,information2
loop1_2:
	mov al,byte ptr [si]
	mov byte ptr es:[bx],al
	inc bx
	inc bx
	inc si
	loop loop1_2

	ret
vector1 endp
	;##############################################			

;系统调用2，ah=2
;两个只有个位的正数相加
vector2 proc
	push cx
	mov al,cl
	add al,ch
	mov byte ptr [_sum],al
	mov byte ptr [_num1],cl
	mov byte ptr [_num2],ch
	call near ptr _C_sum
	pop cx
	ret
vector2 endp


_TEXT ends

;************DATA segment*************
_DATA segment word public 'DATA'
_DATA ends
;*************BSS segment*************
_BSS	segment word public 'BSS'
_BSS ends
;**************end of file***********
end start