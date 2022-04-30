%{
#include <stdio.h>
#include "y.tab.h"
%}

%option noyywrap
%option yylineno

%%

[ \r\n]* { continue; }

mvi return MVI;
mvr return MVR;
xcg return XCG;
ldr return LDR;
sti return STI;
str return STR;
add return ADD;
sub return SUB;
cmp return CMP;
mul return MUL;
inc return INC;
dec return DEC;
xor return XOR;
and return AND;
or return OR;
shl return SHL;
shr return SHR;
jmp return JMP;
jeq return JEQ;
jne return JNE;
jge return JGE;
jgt return JGT;
jle return JLE;
jlt return JLT;
jcf return JCF;
psi return PSI;
psh return PSH;
pop return POP;
hlt return HLT;

mov return MOV;

r0 return R0;
r1 return R1;
r2 return R2;
r3 return R3;
r4 return R4;
r5 return R5;
r6 return R6;
r7 return R7;

.offset return OFFSET;
.org return OFFSET;

[a-zA-Z_][a-zA-Z_0-9]* return WORD;
[0-9]+ { sscanf(yytext, "%d", &yylval); return NUM; }
0x[0-9A-Za-z]+ { sscanf(yytext, "%x", &yylval); return NUM; }
, return COMA;
: return COLON;
%%
