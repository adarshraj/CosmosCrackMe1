.686
.model flat, stdcall
option casemap: none

include windows.inc
include user32.inc
include kernel32.inc
include comctl32.inc
include /masm32/macros/macros.asm
includelib user32.lib
includelib kernel32.lib
includelib comctl32.lib

WndProc	proto	:DWORD, :DWORD, :DWORD, :DWORD
CalculateSerial	proto	:HWND

.data
	szFormat		db	"%2d8-UI-%lX",0
	
.data?
	hInstance		HINSTANCE	?
	szName			db	40 dup(?)
	szSerial		db	60 dup(?)
	szTemp			db	60 dup(?)

.const
	IDD_CRACKME			equ	1001
	IDC_NAME			equ	1004
	IDC_SERIAL			equ	1006
	IDC_CHECK			equ	1007
	IDC_EXIT			equ	1008	

.code
Crackme:
	invoke GetModuleHandle, NULL
	mov hInstance, eax	
	invoke InitCommonControls
	invoke DialogBoxParam, hInstance, IDD_CRACKME, NULL, addr WndProc, NULL
	invoke ExitProcess,0
	
WndProc	proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
	.if uMsg == WM_COMMAND
		mov eax, wParam
		.if eax == IDC_CHECK
			invoke SendDlgItemMessage, hWnd, IDC_SERIAL,WM_GETTEXT,60,addr szSerial
			invoke SendDlgItemMessage, hWnd, IDC_NAME,WM_GETTEXT,32,addr szName
			.if eax != 0 && eax <32
				invoke CalculateSerial, hWnd
				invoke lstrcmp, addr szSerial, addr szTemp
				.if eax == 0
					invoke SendDlgItemMessage, hWnd, IDC_SERIAL,WM_SETTEXT,0,SADD("-={  Registered  }=-")
				.else
					invoke SendDlgItemMessage, hWnd, IDC_SERIAL,WM_SETTEXT,0,SADD("Sorry dear...Try again")
				.endif		
			.endif	
		.elseif eax == IDC_EXIT
			invoke SendMessage, hWnd,WM_CLOSE,0,0	
		.endif
	.elseif uMsg == WM_CLOSE
		invoke EndDialog, hWnd, 0
	.endif		
xor eax, eax
	Ret
WndProc EndP	

CalculateSerial proc hWnd:HWND
LOCAL nLen	:	DWORD
	invoke lstrlen, addr szName
	mov nLen, eax
	xor ecx, ecx
	xor edx, edx
	xor edi, edi
	mov edi, offset szName
Loop1:
		xor eax, eax
		mov al, byte ptr ds:[edi+ecx]
		add eax,4208h	
		mov ebx,93h
		mul ebx	
		sub eax, 3232
		xor eax, 83023444
		sar eax, 2
		add esi, eax
		inc ecx
		cmp ecx, nLen
		jnz Loop1
		invoke wsprintf, addr szTemp, addr szFormat, esi,esi

xor eax, eax
	Ret
CalculateSerial EndP
end Crackme