format PE console
entry start

; ����������� ���������, ��������� � �������� ASCII-������
; ������ ������ ������ ������������������ �� 5 ��������,
; ������ ������� ������� ������������ �� ������� "������ ���������������"

include 'win32ax.inc'

section '.data' data readable writable
        enter_string          db 'enter a string that only contains ascii symbols ', 0
        didNotFindStr         db 'could not find the necessary substring ', 0
        printChar             db '%c-', 0
        printInt              db '%d ', 0
        read_string           db '%s', 0
        notAsciiOutput        db 'You have entered a string that contains symbols outside the ascii table', 0
        stroka                rd 64
        firstElement          dd 0
        A                     dd 0
        B                     dd 0
        stringLength          dd 0

section '.code' code readable executable
start:
        mov     [A], 5
        mov     [B], 0
        push    enter_string
        call    [printf]
        add     esp, 4

        push    stroka
        push    read_string
        call    [scanf]
        add     esp, 8

        lea     edi, [stroka]       ; ������� ���������� ����� � edi
        call    GetStringLength     ; ������� ����� ������ � ������� eax
        mov     [stringLength], eax ; ��������� ����� ������

        call    FindSubstring              ;abcdefgfedcba


        cmp     edx, 0
        je      didNotFindSusbtring

        cmp     edx, 0
        jne     substringFoundPrint

GetStringLength:
        push    ecx       ; ��������� �������� ecx
        push    edi       ; ��������� �������� edi

        sub     ecx, ecx  ; �������� �������
        mov     ecx, -1   ; ������ ���� �������� (-1 -> 11111111..)
        sub     al, al
        cld
        repne   scasb     ; ����������� ������� ������ � ������ � 0 (al),
                          ; ���������, ���� <>
        neg     ecx       ; ������ ��� 0 �� 1 � ���������
        sub     ecx, 2    ; �������� 1, �� �� ������ � -1
        mov     eax, ecx  ; ��������� ������� ������� � eax

        pop     ecx       ; ��������������� �������� eax
        pop     edi       ; ��������������� �������� edi

        ret

FindSubstring:
        sub     ebx, ebx
        sub     ecx, ecx
        sub     edx, edx
        mov     ebx, [stringLength]
        ;mov     ecx, [stroka+ebx-1] ; last char

        mov     ecx, stroka
        add     ecx, ebx
        dec     ecx

findSubstringLoop:
        mov     [A], ecx
        mov     [B], edx
        cmp     edx, 5
        je      loopBreak


        cmp     ecx, stroka-1
        je      loopBreak

        mov     eax, [ecx-1]
        mov     ebx, [ecx]

        cmp     eax, ebx
        jg      greater

        cmp     eax, ebx
        jng     notGreater

notAscii:
        push notAsciiOutput
        call [printf]
        add esp, 4
        jmp exit

greater:
        cmp     edx, 0
        je      firstFound
        mov     edx, [B]
        inc     edx

        mov     ecx, [A]
        dec     ecx
        jmp     findSubstringLoop

notGreater:
        sub     edx, edx
        mov     edx, 0

        mov     ecx, [A]
        mov     [firstElement],0
        dec     ecx
        jmp     findSubstringLoop

firstFound:
        mov     edx, [B]
        mov     edx, 1
        mov     ecx, [A]
        mov     [firstElement],ecx
        jmp     findSubstringLoop

loopBreak:
        ret

didNotFindSusbtring:
        push    didNotFindStr
        call    [printf]
        add     esp, 4

        jmp     exit

substringFoundPrint:
        sub     ecx, ecx
        mov     ecx, 0
        mov     ebx, [firstElement]
printLoop:
        cmp     ecx, 5
        je      exit

        mov     [firstElement], ebx
        mov     [A], ecx

        sub     ebx, ecx
        mov     ecx, [ebx]
        push    ecx
        push    printChar
        call    [printf]
        add     esp, 8

        mov     ecx, [A]
        inc     ecx

        mov     ebx, [firstElement]
        jmp     printLoop

exit:
        call    [getch]
        push    0
        call    [ExitProcess]


section '.idata' import data readable
    library kernel, 'kernel32.dll',\
            msvcrt, 'msvcrt.dll',\
            user32,'USER32.DLL'

include 'api\user32.inc'
include 'api\kernel32.inc'
    import kernel,\
           ExitProcess, 'ExitProcess',\
           HeapCreate,'HeapCreate',\
           HeapAlloc,'HeapAlloc'
  include 'api\kernel32.inc'
    import msvcrt,\
           printf, 'printf',\
           scanf, 'scanf',\
           getch, '_getch'