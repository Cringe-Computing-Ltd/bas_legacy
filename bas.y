%{
#include <stdio.h>
#include <stdlib.h>
#include "codegen.h"
#include <string.h>

	extern char *yytext;
	int yylex();
	void yyerror(const char *s);
%}

%locations
%token WORD NUM COMA COLON
%token R0 R1 R2 R3 R4 R5 R6 R7
%token MVI MVR XCG LDR STI STR ADD SUB CMP MUL INC DEC XOR AND OR SHL SHR JMP JEQ JNE JGE JGT JLE JLT JCF PSI PSH POP HLT MOV

%token OFFSET

%%

code
: instructions
;

reg
: R0 { codegen->reg = CG_R0; }
| R1 { codegen->reg = CG_R1; }
| R2 { codegen->reg = CG_R2; }
| R3 { codegen->reg = CG_R3; }
| R4 { codegen->reg = CG_R4; }
| R5 { codegen->reg = CG_R5; }
| R6 { codegen->reg = CG_R6; }
| R7 { codegen->reg = CG_R7; }
;

dst
: reg { codegen->bubble.dst = codegen->reg; }
;

src
: reg { codegen->bubble.src = codegen->reg; }
;

dimm
: NUM {
	codegen->bubble.src = yyval;
 }
;

imm
: NUM {
	codegen->bubble.has_imm = 1;
	codegen->bubble.imm = yyval;
 }
| WORD {
	codegen->bubble.has_imm = 2;
	char *s = malloc(strlen(yytext) + 1);
	if (!s) {
		// TODO: error
	}
	strcpy(s, yytext);
	codegen->bubble.bookmark_name = s;
 }
;

jmpdst
: dst {
	codegen->bubble.src = 0;
 }
| imm {
	codegen->bubble.src = 1 << 4;
 }
;

instructions
: instruction instructions
| instruction
;

jmpinsts
: JMP jmpdst {}
| JEQ jmpdst {
	codegen->bubble.src |= 14;
 }
| JNE jmpdst {
	codegen->bubble.src |= 15;
 }
| JGT jmpdst {
	codegen->bubble.src |= 8;
 }
| JGE jmpdst {
	codegen->bubble.src |= 9;
 }
| JLT jmpdst {
	codegen->bubble.src |= 4;
 }
| JLE jmpdst {
	codegen->bubble.src |= 5;
 }
| JCF jmpdst {
	codegen->bubble.src |= 1;
 }
;

instruction0
: MVI dst COMA imm {
	codegen->bubble.opcode = CG_MVI;
 }
| MVR dst COMA src {
	codegen->bubble.opcode = CG_MVR;
 }
| MOV dst COMA src {
	codegen->bubble.opcode = CG_MVR;
 }
| MOV dst COMA imm {
	codegen->bubble.opcode = CG_MVI;
 }
| XCG dst COMA src {
	codegen->bubble.opcode = CG_XCG;
 }
| LDR dst COMA src {
	codegen->bubble.opcode = CG_LDR;
 }
| STI dst COMA imm {
	codegen->bubble.opcode = CG_STI;
 }
| STR dst COMA src {
	codegen->bubble.opcode = CG_STR;
 }
| ADD dst COMA src {
	codegen->bubble.opcode = CG_ADD;
 }
| SUB dst COMA src {
	codegen->bubble.opcode = CG_SUB;
 }
| CMP dst COMA src {
	codegen->bubble.opcode = CG_CMP;
 }
| MUL dst COMA src {
	codegen->bubble.opcode = CG_MUL;
 }
| INC dst {
	codegen->bubble.opcode = CG_INC;
 }
| DEC dst {
	codegen->bubble.opcode = CG_DEC;
 }
| XOR dst COMA src {
	codegen->bubble.opcode = CG_XOR;
 }
| AND  dst COMA src {
	codegen->bubble.opcode = CG_AND;
 }
| OR dst COMA src {
	codegen->bubble.opcode = CG_OR;
 }
| SHL dst COMA dimm {
	codegen->bubble.opcode = CG_SHL;
 }
| SHR dst COMA dimm {
	codegen->bubble.opcode = CG_SHR;
 }
| jmpinsts {
	codegen->bubble.opcode = CG_JMP;
 }
| PSI imm {
	codegen->bubble.opcode = CG_PSI;
 }
| PSH dst {
	codegen->bubble.opcode = CG_PSH;
 }
| PSH imm {
	codegen->bubble.opcode = CG_PSI;
 }
| POP dst {
	codegen->bubble.opcode = CG_POP;
 }
| HLT {
	codegen->bubble.opcode = CG_HLT;
 }
;

instruction
: instruction0 {
	codegen_commit(codegen);
 }
| label {
	Bookmark *bookmark = malloc(sizeof(Bookmark));
	if (!bookmark) {
		// TODO: error
	}
	
	*bookmark = (Bookmark) {
		.ic = codegen->ic + codegen->offset,
		.name = codegen->_word,
	};
	codegen->_word = NULL;

	codegen_bookmark_append(codegen, bookmark);
 }
| option
;

option
: OFFSET NUM {
	codegen->offset = atoi(yytext);
 }
;

label
: word COLON
;

word
: WORD {
	char *s = malloc(strlen(yytext) + 1);
	if (!s) {
		// TODO: error
	}
	strcpy(s, yytext);

	codegen->_word = s;
 }

%%
