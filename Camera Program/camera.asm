;Carli Williams
;3410-002
;Assignment 1

.386

.MODEL FLAT

ExitProcess PROTO NEAR32 stdcall, dwExitCode:DWORD

INCLUDE debug.h
INCLUDE io.h
INCLUDE sqrt.h

.STACK  4096           

.DATA                   

; declare these first so that they are all on WORD boundaries
; Most of the variables I used, but some are just exist.

eye_x       WORD    ?
eye_y       WORD    ?
eye_z       WORD    ?
at_x        WORD    ?
at_y        WORD    ?
at_z        WORD    ?
up_x        WORD    ?
up_y        WORD    ?
up_z        WORD    ?
n_x         WORD    ?
n_y         WORD    ?
n_z         WORD    ?
v_x         WORD    ?
v_y         WORD    ?
v_z         WORD    ?
u_x         WORD    ?
u_y         WORD    ?
u_z         WORD    ?

eyexprompt      BYTE    "Enter the x-coordinate of the camera eyepoint:  ", 0
eyeyprompt      BYTE    "Enter the y-coordinate of the camera eyepoint:  ", 0
eyezprompt      BYTE    "Enter the z-coordinate of the camera eyepoint:  ", 0

atxprompt       BYTE    "Enter the x-coordinate of the camera look at point:  ", 0
atyprompt       BYTE    "Enter the y-coordinate of the camera look at point:  ", 0
atzprompt       BYTE    "Enter the z-coordinate of the camera look at point:  ", 0

upxprompt       BYTE    "Enter the x-coordinate of the camera up direction:  ", 0
upyprompt       BYTE    "Enter the y-coordinate of the camera up direction:  ", 0
upzprompt       BYTE    "Enter the z-coordinate of the camera up direction:  ", 0

display         		BYTE    50 DUP (?), 0 ; the text to display in (x, y, z) format
output_u        	BYTE    "u: ", 0
output_v        	BYTE    "v: ", 0
output_n        	BYTE    "n: ", 0

eol             		BYTE    CR, LF, 0     ; end of line

ndotn            WORD   ?
vupn             WORD   ?
length_n         WORD   ?
length_u         WORD   ?
length_v         WORD   ?


.CODE          

;Display macros
getCoord    MACRO   prompt, var
               inputW  prompt, var
               mov     var, ax         ; store the result in memory
               outputW ax
            ENDM


get_and_display MACRO prompt1, prompt2, prompt3, prompt4, x1, x2, x3
                  getCoord prompt1, x1
				  getCoord prompt2, x2
				  getCoord prompt3, x3
				  printPoint prompt4, x1, x2, x3  
                ENDM                            


printPoint  MACRO   point, xvar, yvar, zvar
               output eol
               mov     point, "("
               itoa    point + 1, xvar ; convert xvar to digits and place after the "("
               mov     point + 7, ","  ; insert the comma after the digits for xvar
			   itoa    point + 8, yvar
			   mov     point + 14, ","
			   itoa    point + 15, zvar
			   mov     point + 21, ")"
			   output point
			   output eol
            ENDM

printNormPoint  MACRO   point, xvar, yvar, zvar, len
               itoa point + 5, len
               itoa point + 16, len
               itoa point + 27, len

               output eol
               mov     point + 0, "("

               itoa    point + 1, xvar  
               mov     point + 7, "/"  
               mov     point + 11, ","
			   itoa    point + 12, yvar
			   mov     point + 18, "/"
			   mov     point + 22, ","
			   itoa    point + 23, zvar
			   mov     point + 29, "/"
			   mov     point + 33, ")"

               output  point
               output  eol
            ENDM

; computes the dot product of two vectors
dot_product MACRO   x1, y1, z1, x2, y2, z2
               mov ax, x1
               mov bx, x2
               imul bx        ; x1 * x2 is in ax  (actually dx::ax, high order bits dropped)
               mov cx, ax     ; the accumulating result will be in cx
			   mov ax, y1
			   mov bx, y2
			   imul bx
			   add cx, ax
			   mov ax, z1
			   mov bx, z2
			   imul bx
			   add cx, ax
            ENDM

; computes the cross product of two vectors
cross_product MACRO   x1, y1, z1, x2, y2, z2, x3, y3, z3
               mov ax, y1
               mov bx, z2
               mul bx         ; result in dx::ax
               mov cx, ax

               mov ax, z1     
               mov bx, y2
               mul bx         ; result in dx::ax
               neg ax

               add ax, cx
               mov x3, ax
			   
			   mov ax, z1
			   mov bx, x2
			   mul bx
			   mov cx, ax
			   
			   mov ax, x1
			   mov bx, z2
			   mul bx
			   neg ax
			   
			   add ax, cx
			   mov y3, ax
			   
			   mov ax, x1
			   mov bx, y2
			   mul bx
			   mov cx, ax
			   
			   mov ax, y1
			   mov bx, x2
			   mul bx
			   neg ax
			   
			   add ax, cx
			   mov z3, ax
			   
            ENDM

; performs point-point subtraction to obtain a vector
point_subtract MACRO x1, y1, z1, x2, y2, z2, vx, vy, vz
                  mov ax, x1
                  mov bx, x2
                  sub ax, bx
                  mov vx, ax
				  
				  mov ax, y1
				  mov bx, y2
				  sub ax, bx
				  mov vy, ax
				  
				  mov ax, z1
				  mov bx, z2
				  sub ax, bx
				  mov vz, ax

               ENDM

; performs point-vector addition to obtain a new point
point_vector_add MACRO x, y, z, vx, vy, vz, xn, yn, zn
                  mov ax, x
                  mov bx, vx
                  add ax, bx
                  mov xn, ax
				  
				  mov ax, y
				  mov bx, vy
				  add ax, bx
				  mov yn, ax
				  
				  mov ax, z
				  mov bx, vz
				  add ax, bx
				  mov zn, ax
				  ENDM


				  
				  
vector_length	MACRO x, y, z
                  dot_product x, y, z, x, y, z
				  sqrt cx
				   
                ENDM






_start:

          get_and_display eyexprompt, eyeyprompt, eyezprompt, display, eye_x, eye_y, eye_z
		  get_and_display atxprompt, atyprompt, atzprompt, display, at_x, at_y, at_z
		  get_and_display upxprompt, upyprompt, upzprompt, display, up_x, up_y, up_z
 


          point_subtract eye_x, eye_y, eye_z, at_x, at_y, at_z, n_x, n_y, n_z

          dot_product n_x, n_y, n_z, n_x, n_y, n_z
		  mov ndotn, cx
		  dot_product n_x, n_y, n_z, up_x, up_y, up_z
		  mov  vupn, cx

          mov ax, ndotn
		  mov bx, up_x
		  mul bx
		  mov cx, ax
		  mov ax, vupn
		  mov bx, n_x
		  neg ax
		  mul bx
		  add ax, cx
		  mov v_x, ax
		  
		  mov ax, ndotn
		  mov bx, up_y
		  mul bx
		  mov cx, ax
		  mov ax, vupn
		  mov bx, n_y
		  neg ax
		  mul bx
		  add ax, cx
		  mov v_y, ax
		  
		  mov ax, ndotn
		  mov bx, up_z
		  mul bx
		  mov cx, ax
		  mov ax, vupn
		  mov bx, n_z
		  neg ax
		  mul bx
		  add ax, cx
		  mov v_z, ax
		  
          cross_product v_x, v_y, v_z, n_x, n_y, n_z, u_x, u_y, u_z
		  vector_length u_x, u_y, u_z
		  mov length_u, ax
		  vector_length v_x, v_y, v_z
		  mov length_v, ax
		  vector_length n_x, n_y, n_z
		  mov length_n, ax
		  
          output eol
          output eol
          output output_u
          printNormPoint display, u_x, u_y, u_z, length_u
		  output output_v
		  printNormPoint display, v_x, v_y, v_z, length_v
		  output output_n
          printNormPoint display, n_x, n_y, n_z, length_n



        INVOKE  ExitProcess, 0  ; exit with return code 0

PUBLIC _start                   ; make entry point public

END                             ; end of source code