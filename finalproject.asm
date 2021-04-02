TITLE Example of ASM              (helloword.ASM)

INCLUDE Irvine32.inc
main          EQU start@0

.stack 4096
;宣告function
print		PROTO, source:PTR BYTE, sLength:DWORD
color		PROTO, source:PTR BYTE, sLength:DWORD
drawLine	PROTO
drawData	PROTO
drawTitle	PROTO
input		PROTO
drawOwin	PROTO
drawxwin	PROTO
drawBE      PROTO
drawScore	PROTO
transportox	PROTO
checkHorLine	PROTO
checkVerLine	PROTO
checkDiaLineL	PROTO
checkDiaLineR	PROTO
whoWins PROTO
;初始位置
x0 = 10
y0 = 7
;變數
.data
;初始畫面
blank BYTE "?"
mark1 BYTE "o"
mark2 BYTE "x"
line0 BYTE "  ABC   DEF   GHI"
line1 BYTE "1 ", 3 DUP(" "), " | ", 3 DUP(" "), " | ", 3 DUP(" ")
line2 BYTE " -", 3 DUP("-"), "-+-", 3 DUP("-"), "-+-", 3 DUP("-")
;輸入畫面
inputMsg	BYTE "Input position to put o,x(Ex.F5):", 0
errorMsg	BYTE " Error input!", 0
clearMsg	BYTE 50 DUP(" "), 0
scoreMsg1	BYTE "o's Score:", 0
scoreMsg2	BYTE "x's Score:", 0
;各自分數
oScore	BYTE 0 ;o的分數
xScore	BYTE 0 ;x的分數

PlayerCount BYTE 0 ;判斷輸入o或x
index DWORD 0 ;輸入位置
Same BYTE 0 ;判斷輸入位置是否一樣

data BYTE 81 DUP("?") ;九宮格
attribute WORD 81 DUP(0F9h)
buffer BYTE 2 DUP(?), 0 ;輸入值
counter BYTE 0

outputHandle DWORD 0
bytesWritten DWORD 0
count DWORD 0
xyPosition COORD <x0, y0>

; 標題畫面
titlePic0   BYTE "■■■　　　　　■■■　　　■■■■　■■■■　■　　　■　■　　　■"
titlePic1   BYTE "■　■　■　■　■　■　　　■　　■　■　　■　　■　■　　　■　■　";　;
titlePic2   BYTE "■■■　　■　　■■■　　　■　　■　■　　■　　　■　　　　　■　　"
titlePic3   BYTE "　　■　■　■　　　■　　　■　　■　■　　■　　■　■　　　■　■　"
titlePic4   BYTE "■■■　　　　　■■■　　　■■■■　■■■■　■　　　■　■　　　■"
titlePic5   BYTE "　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　"
titlePic6   BYTE "■■■　■　■■■　　■■■　　■　　■■■　　■■■　■■■　■■■"
titlePic7   BYTE "　■　　■　■　　　　　■　　■　■　■　　　　　■　　■　■　■"
titlePic8   BYTE "　■　　■　■　　　　　■　　■■■　■　　　　　■　　■　■　■■■"
titlePic9   BYTE "　■　　■　■　　　　　■　　■　■　■　　　　　■　　■　■　■"
titlePic10  BYTE "　■　　■　■■■　　　■　　■　■　■■■　　　■　　■■■　■■■"
titleMsg1 BYTE "[1] START"
titleMsg2 BYTE "[0] EXIT"

; 結束畫面，若o贏                             
oWinPic0  BYTE "■■■■　　　■　　　　　■　■　■■■■　■■■■　■"
oWinPic1  BYTE "■　　■　　　■　　■　　■　■　■　　■　■　　　　■"
oWinPic2  BYTE "■　　■　　　■　　■　　■　■　■　　■　■■■■　■"
oWinPic3  BYTE "■　　■　　　■　■　■　■　■　■　　■　　　　■"
oWinPic4  BYTE "■■■■　　　　■　　　■　　■　■　　■　■■■■　■"

; 結束畫面，若x贏
xWinPic0  BYTE "■　　　■　　　■　　　　　■　■　■■■■　■■■■　■"
xWinPic1  BYTE "　■　■　　　　■　　■　　■　■　■　　■　■　　　　■"
xWinPic2  BYTE "　　■　　　　　■　　■　　■　■　■　　■　■■■■　■"
xWinPic3  BYTE "　■　■　　　　■　■　■　■　■　■　　■　　　　■"
xWinPic4  BYTE "■　　　■　　　　■　　　■　　■　■　　■　■■■■　■"

; 結束畫面，若平手
BEline0 BYTE "■■■■　■　　■　■■■■　■■■■"
BEline1 BYTE "■　　　　■　　■　■　　　　■　　■"
BEline2 BYTE "■■■■　■　　■　■■■■　■　　■"
BEline3 BYTE "■　　　　■　　■　■　　　　■　　■"
BEline4 BYTE "■■■■　　■■　　■■■■　■　　■"

;程式
.code

main PROC
	INVOKE GetStdHandle, STD_OUTPUT_HANDLE ; Get the console ouput handle
	mov outputHandle, eax ; save console handle
	mov eax , black + ( white*16 )    ; 黑字白底
    call SetTextColor
 
TitleDisplay:
	call Clrscr ; 清空螢幕
	INVOKE drawTitle
	add xyPosition.x, 28
	add xyPosition.y, 3
	INVOKE print, OFFSET titleMsg1, LENGTHOF titleMsg1
	add xyPosition.y, 1
	INVOKE print, OFFSET titleMsg2, LENGTHOF titleMsg2
	call ReadChar
	cmp al, '1'
	je Start
	cmp al, '0'
	je EndGame
	jmp TitleDisplay
 
Start:
	call Clrscr ; 清空螢幕
	; 畫背景
	INVOKE drawLine		; 畫格子
	INVOKE drawData		; 畫內容
	
reInput:
	INVOKE drawScore	; 畫分數
	INVOKE input		; 輸入
	INVOKE transportox
	cmp Same, 1
	je reInput
	INVOKE drawData
	INVOKE checkHorLine 
	INVOKE checkVerLine 
	INVOKE checkDiaLineL 
	INVOKE checkDiaLineR 
	cmp counter,81
	jne reInput
	INVOKE whoWins
	call crlf
	call WaitMsg
	
EndGame:
	call Clrscr ; 清空螢幕
	exit
main ENDP

;=============================================
drawLine PROC USES ecx esi
	call Clrscr ; 清空螢幕

	; 座標設置原點
	mov xyPosition.x, x0-1
	mov xyPosition.y, y0-1
 
	; 重設標示1~9
	mov line1, '1'
 
	; 畫線
	INVOKE print, ADDR line0, LENGTHOF line0
	inc xyPosition.y
	mov ecx, 2
	
L2:
	push ecx
	mov ecx, 3
	
L1:
	push ecx
	INVOKE print, ADDR line1, LENGTHOF line1
	inc line1
	inc xyPosition.y
	pop ecx
	LOOP L1
	INVOKE print, ADDR line2, LENGTHOF line2
	inc xyPosition.y
	pop ecx
	LOOP L2
	mov ecx, 3
	
L3:
	push ecx
	INVOKE print, ADDR line1, LENGTHOF line1
	inc line1
	inc xyPosition.y
	pop ecx
	LOOP L3
	ret
drawLine ENDP
;=============================================
drawData PROC USES ecx esi eax edi
	; 座標設置原點
	mov xyPosition.x, x0+1
	mov xyPosition.y, y0 
	; 設置讀取data位置
	mov esi, OFFSET data[0]
	mov edi, OFFSET attribute[0]
	mov ecx, 3
	
L1:
	push ecx
	mov ecx, 3
	
L2:
	push ecx
	mov ecx, 3
	
L3:
	push ecx
	INVOKE print, esi, 3
	INVOKE color, edi, 3
	add esi, 3
	add edi, 6
	inc xyPosition.y
	pop ecx
	LOOP L3
	add xyPosition.x, 6
	sub xyPosition.y, 3
	pop ecx
	LOOP L2
	mov xyPosition.x, x0+1
	add xyPosition.y, 4
	pop ecx
	LOOP L1
	ret
drawData ENDP
;=============================================
print PROC, source:PTR BYTE, sLength:DWORD
	INVOKE WriteConsoleOutputCharacter,
		   outputHandle,
		   source,
           sLength,
           xyPosition,
           ADDR count
	ret
print ENDP
;=============================================
color PROC, source:PTR BYTE, sLength:DWORD
	INVOKE WriteConsoleOutputAttribute,
		   outputHandle,
		   source,
           sLength,
           xyPosition,
           ADDR count
	ret
color ENDP
;=============================================
drawTitle PROC USES ecx
	; 座標設置原點
	mov xyPosition.x, 10
	mov xyPosition.y, 5
	; 設置讀取data位置
	INVOKE print, OFFSET titlePic0, LENGTHOF titlePic0
	inc xyPosition.y
	INVOKE print, OFFSET titlePic1, LENGTHOF titlePic1
	inc xyPosition.y
	INVOKE print, OFFSET titlePic2, LENGTHOF titlePic2
	inc xyPosition.y
	INVOKE print, OFFSET titlePic3, LENGTHOF titlePic3
	inc xyPosition.y
	INVOKE print, OFFSET titlePic4, LENGTHOF titlePic4
	inc xyPosition.y
	INVOKE print, OFFSET titlePic5, LENGTHOF titlePic5
	inc xyPosition.y
	INVOKE print, OFFSET titlePic6, LENGTHOF titlePic6
	inc xyPosition.y
	INVOKE print, OFFSET titlePic7, LENGTHOF titlePic7
	inc xyPosition.y
	INVOKE print, OFFSET titlePic8, LENGTHOF titlePic8
	inc xyPosition.y
	INVOKE print, OFFSET titlePic9, LENGTHOF titlePic9
	inc xyPosition.y
	INVOKE print, OFFSET titlePic10, LENGTHOF titlePic10
	ret
drawTitle ENDP
;=============================================
drawScore PROC uses eax
	; 清除分數
	mov dl, 0
    mov dh, 0
    call Gotoxy
	mov edx, OFFSET clearMsg
	call WriteString
	call crlf
	call WriteString
	mov dl, 0
    mov dh, 0
    call Gotoxy
	; 印出分數
	mov edx, OFFSET scoreMsg1
	call WriteString
	mov al, oScore
	call WriteDec
	call crlf
	mov edx, OFFSET scoreMsg2
	call WriteString
	mov al, xScore
	call WriteDec
	call crlf
	ret
drawScore ENDP
;=============================================
input PROC uses eax edx

LDraw:
	; 清除提示訊息
	mov dl, 0
    mov dh, 2
    call Gotoxy
	mov edx, OFFSET clearMsg
	call WriteString
	mov dl, 0
    mov dh, 2
    call Gotoxy
	; 提示輸入
	mov edx, OFFSET inputMsg
	call WriteString
	jmp Linput
	
Lerror:
	mov edx, OFFSET errorMsg
	call WriteString
	call ReadChar
	jmp LDraw
	
Linput:
	call ReadChar
	cmp al, 1bh     ; check for [ESC]
	je main
	cmp al, 'A'
	jb Lerror
	cmp al, 'I'
	ja Lerror
	mov buffer[0], al
	call WriteChar
	call ReadChar
	cmp al, '1'
	jb Lerror
	cmp al, '9'
	ja Lerror
	mov buffer[1], al
	call WriteChar
	call ReadChar
	ret
input ENDP
;=============================================
transportox PROC 
	mov bl, buffer[0] ;英文
	mov dl, buffer[1] ;數字
	mov Same, 0		  ;如果輸入一樣位置
	sub dl, '0'
	sub bl, 'A'
	;比較英文
	cmp bl, 3;A~C
	jb LCOM
	cmp bl, 3;D
	je LD
	cmp bl, 4;E
	je LE_
	cmp bl, 5;F
	je LF
	cmp bl, 6;G
	je LG
	cmp bl, 7;H
	je LH
	jmp LI;I
	
LD:
	mov bl, 9;初始值
	jmp LCOM
	
LE_:
	mov bl, 10
	jmp LCOM
	
LF:
	mov bl, 11
	jmp LCOM
	
LG:
	mov bl, 18
	jmp LCOM
	
LH:
	mov bl, 19
	jmp LCOM
	
LI: 
	mov bl, 20
	jmp LCOM 

;比較數字	
LCOM:
	cmp dl, 4;1~3
	jb L123
	cmp dl, 7;4~6
	jb L456
	jmp L789 ;7~9
	
L123:
	sub dl, 1;算差值再乘3
	mov al, 3
	mul dl
	add al, bl
	jmp Lx
	
L456:
	sub dl, 4;以數字1~3為基底
	mov al, 3
	mul dl
	add al, bl
	add al, 27;差27
	jmp Lx
	
L789:
	sub dl, 7;以數字1~3為基底
	mov al, 3
	mul dl
	add al, bl
	add al, 54;差54
	jmp Lx
	
Lx:
	cmp data[eax], "?";輸入是否一樣
	jne Lerror
	cmp PlayerCount,1;如果PlayerCount是0，則'o'
	jne Lo
	sub PlayerCount, 1
	mov data[eax], 'x'
	add counter,1 ;計算輸入次數
	jmp LR
	
Lo:
	add PlayerCount, 1
	mov data[eax], 'o'
	add counter,1 ;計算輸入次數
	jmp LR

Lerror:
	add Same, 1
	jmp LR
	
LR:
	mov index,eax;放位置
	ret
transportox ENDP
;=============================================
;是否連成水平線
checkHorLine PROC 

L1:
	mov esi,index
	mov edx,0
	mov eax,index
	mov ebx,3
	div ebx
	cmp edx,0
	je Lmod01 ;3n
	cmp edx,1
	je Lmod11 ;3n+1
	cmp edx,2
	je Lmod21 ;3n+2
;3n
Lmod01:
	mov al,data[esi]
	cmp al,data[esi+1]
	je Lmod02
	jmp L3
	
Lmod02:
	cmp al,data[esi+2]
	je L2
	jmp L3
	
;3n+1
Lmod11: 
	mov al,data[esi]
	cmp al,data[esi-1]
	je Lmod12
	jmp L3
	
Lmod12:
	cmp al,data[esi+1]
	je L2
	jmp L3
	
;3n+2
Lmod21: 
	mov al,data[esi]
	cmp al,data[esi-1]
	je Lmod22
	jmp L3
	
Lmod22:
	cmp al,data[esi-2]
	je L2
	jmp L3
;確認連成線者為o或x
L2:
	cmp PlayerCount,1 
	je Lo
	jmp Lx
;上加分數
Lo:
	add oScore,1
	jmp L3
	
Lx:
	add xScore,1
	jmp L3
	
L3:
	ret
checkHorLine ENDP
;=============================================
;是否連成鉛錘線
checkVerLine PROC 

L1:
	mov edx,0
	mov eax,index
	mov ebx,9
	div ebx
	cmp edx,0 
	je Lmod01 ;9n
	cmp edx,1
	je Lmod01 ;9n+1
	cmp edx,2
	je Lmod01 ;9n+2
	cmp edx,3
	je Lmod11 ;9n+3
	cmp edx,4
	je Lmod11 ;9n+4
	cmp edx,5
	je Lmod11 ;9n+5
	cmp edx,6
	je Lmod21 ;9n+6
	cmp edx,7
	je Lmod21 ;9n+7
	cmp edx,8
	je Lmod21 ;9n+8
	
;9n,9n+1,9n+2
Lmod01: 
	mov al,data[esi]
	cmp al,data[esi+3]
	je Lmod02
	jmp L3
	
Lmod02:
	cmp al,data[esi+6]
	je L2
	jmp L3
	
;9n+3,9n+4,9n+5
Lmod11: 
	mov al,data[esi]
	cmp al,data[esi-3]
	je Lmod12
	jmp L3
	
Lmod12:
	cmp al,data[esi+3]
	je L2
	jmp L3
	
;9n+6,9n+7,9n+8
Lmod21: 
	mov al,data[esi]
	cmp al,data[esi-3]
	je Lmod22
	jmp L3
	
Lmod22:
	cmp al,data[esi-6]
	je L2
	jmp L3
;確認連成線者為o或x	
L2:
	cmp PlayerCount,1
	je Lo
	jmp Lx
;上加分數	
Lo:
	add oScore,1
	jmp L3
	
Lx:
	add xScore,1
	jmp L3
	
L3:
	ret
checkVerLine ENDP
;=============================================
;是否連成左上到右下對角線
checkDiaLineL PROC 

L1:
	mov edx,0
	mov eax,index
	mov ebx,9
	div ebx
	cmp edx,0
	je Lmod01 ;9n
	cmp edx,4
	je Lmod11 ;9n+4
	cmp edx,8
	je Lmod21 ;9n+8
	jmp L3    ;其餘位置 
	
;9n
Lmod01: 
	mov al,data[esi]
	cmp al,data[esi+4]
	je Lmod02
	jne L3
	
Lmod02:
	cmp al,data[esi+8]
	je L2
	jne L3
	
;9n+4
Lmod11: 
	mov al,data[esi]
	cmp al,data[esi-4]
	je Lmod12
	jne L3
	
Lmod12:
	cmp al,data[esi+4]
	je L2
	jne L3
	
;9n+8
Lmod21: 
	mov al,data[esi]
	cmp al,data[esi-4]
	je Lmod22
	jne L3
	
Lmod22:
	cmp al,data[esi-8]
	je L2
	jne L3
;確認連成線者為o或x	
L2:
	cmp PlayerCount,1
	je Lo
	jne Lx
;上加分數	
Lo:
	add oScore,1
	jmp L3
	
Lx:
	add xScore,1
	jmp L3
	
L3:
	ret
checkDiaLineL ENDP
;=============================================
;是否連成右上到左下對角線
checkDiaLineR PROC 

L1:
	mov edx,0
	mov eax,index
	mov ebx,9
	div ebx
	cmp edx,2
	je Lmod01 ;9n+2
	cmp edx,4
	je Lmod11 ;9n+4
	cmp edx,6
	je Lmod21 ;9n+6
	jmp L3    ;其餘位置
	
;9n+2
Lmod01: 
	mov al,data[esi]
	cmp al,data[esi+2]
	je Lmod02
	jne L3
	
Lmod02:
	cmp al,data[esi+4]
	je L2
	jne L3
	
;9n+4
Lmod11: 
	mov al,data[esi]
	cmp al,data[esi-2]
	je Lmod12
	jne L3
	
Lmod12:
	cmp al,data[esi+2]
	je L2
	jne L3
	
;9n+6
Lmod21: 
	mov al,data[esi]
	cmp al,data[esi-2]
	je Lmod22
	jne L3
	
Lmod22:
	cmp al,data[esi-4]
	je L2
	jne L3
;確認連成線者為o或x		
L2:
	cmp PlayerCount,1
	je Lo
	jne Lx
;上加分數	
Lo:
	add oScore,1
	jmp L3
	
Lx:
	add xScore,1
	jmp L3
	
L3:
	ret
checkDiaLineR ENDP
;=============================================
;o贏的畫面
drawOwin PROC USES ecx
	; 座標設置原點
	mov xyPosition.x, x0
	mov xyPosition.y, y0
	; 設置讀取data位置
	INVOKE print, OFFSET oWinPic0, LENGTHOF oWinPic0
	inc xyPosition.y
	INVOKE print, OFFSET oWinPic1, LENGTHOF oWinPic1
	inc xyPosition.y
	INVOKE print, OFFSET oWinPic2, LENGTHOF oWinPic2
	inc xyPosition.y
	INVOKE print, OFFSET oWinPic3, LENGTHOF oWinPic3
	inc xyPosition.y
	INVOKE print, OFFSET oWinPic4, LENGTHOF oWinPic4
	ret
drawOwin ENDP
;=============================================
;x贏的畫面
drawxwin PROC USES ecx
	; 座標設置原點
	mov xyPosition.x, x0
	mov xyPosition.y, y0
	; 設置讀取data位置
	INVOKE print, OFFSET xWinPic0, LENGTHOF xWinPic0
	inc xyPosition.y
	INVOKE print, OFFSET xWinPic1, LENGTHOF xWinPic1
	inc xyPosition.y
	INVOKE print, OFFSET xWinPic2, LENGTHOF xWinPic2
	inc xyPosition.y
	INVOKE print, OFFSET xWinPic3, LENGTHOF xWinPic3
	inc xyPosition.y
	INVOKE print, OFFSET xWinPic4, LENGTHOF xWinPic4
	ret
drawxwin ENDP
;=============================================
;平手的畫面
drawBE PROC USES ecx
	; 座標設置原點
	mov xyPosition.x, x0
	mov xyPosition.y, y0
	; 設置讀取data位置
	INVOKE print, OFFSET BEline0, LENGTHOF BEline0
	inc XyPosition.y
	INVOKE print, OFFSET BEline1, LENGTHOF BEline1
	inc XyPosition.y
	INVOKE print, OFFSET BEline2, LENGTHOF BEline2
	inc XyPosition.y
	INVOKE print, OFFSET BEline3, LENGTHOF BEline3
	inc XyPosition.y
	INVOKE print, OFFSET BEline4, LENGTHOF BEline4
	ret
drawBE ENDP
;=============================================
;確定贏家
whoWins PROC 
	mov al,oScore
	mov bl,xScore
	cmp al,bl
	je BreakEven
	jb XWins
	jmp OWins

BreakEven:
	call Clrscr
	INVOKE drawBE
	jmp ExitMsg

OWins:
	call Clrscr
	INVOKE drawOwin
	jmp ExitMsg

XWins:
	call Clrscr
	INVOKE drawXwin
	jmp ExitMsg

ExitMsg:
	CALL waitMsg
	ret
whoWins ENDP

END main