%{
#include <stdio.h>
#include "y.tab.h"
%}

%option noyywrap
%option yylineno

%%

[ \r\n]* { continue; }

ldi return LDI;
str return STR;
ldr return LDR;
add return ADD;
sub return SUB;
mul return MUL;
jmp return JMP;
jeq return JEQ;
jne return JNE;
jgt return JGT;
jge return JGE;
jlt return JLT;
jle return JLE;
jcf return JCF;
xcg return XCG;
xor return XOR;
and return AND;
or  return OR;
cmp return CMP;
sti return STI;
shl return SHL;
shr return SHR;
mov return MOV;
inc return INC;
dec return DEC;
psh return PSH;
pop return POP;
dbg return DBG;
hlt return HLT;

ra return RA;
rb return RB;
rc return RC;
rd return RD;
re return RE;
rf return RF;
rg return RG;
rh return RH;

.offset return OFFSET;
.org return OFFSET;

[a-zA-Z_][a-zA-Z_0-9]* return WORD;
[0-9]+ { sscanf(yytext, "%d", &yylval); return NUM; }
0x[0-9A-Za-z]+ { sscanf(yytext, "%x", &yylval); return NUM; }
, return COMA;
: return COLON;
%%
