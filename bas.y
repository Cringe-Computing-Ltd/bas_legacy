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
%token RA RB RC RD RE RF RG RH
%token LDI STR LDR ADD SUB MUL JMP JEQ JNE JGT JGE JLT JLE JCF XCG XOR AND OR CMP STI SHL SHR MOV INC DEC PSH POP DBG

%%

code
: instructions
;

reg
: RA { codegen->reg = CG_RA; }
| RB { codegen->reg = CG_RB; }
| RC { codegen->reg = CG_RC; }
| RD { codegen->reg = CG_RD; }
| RE { codegen->reg = CG_RE; }
| RF { codegen->reg = CG_RF; }
| RG { codegen->reg = CG_RG; }
| RH { codegen->reg = CG_RH; }
;

dst
: reg { codegen->bubble.dst = codegen->reg; }
;

src
: reg { codegen->bubble.src = codegen->reg; }
;

imm
: NUM {
	codegen->bubble.has_imm = 1;
	codegen->bubble.imm = atoi(yytext);
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
: LDI dst COMA imm {
	codegen->bubble.opcode = CG_LDI;
 }
| STR dst COMA src {
	codegen->bubble.opcode = CG_STR;
 }
| LDR dst COMA src {
	codegen->bubble.opcode = CG_LDR;
 }
| ADD dst COMA src {
	codegen->bubble.opcode = CG_ADD;
 }
| SUB dst COMA src {
	codegen->bubble.opcode = CG_SUB;
 }
| MUL dst COMA src {
	codegen->bubble.opcode = CG_MUL;
 }
| jmpinsts {
	codegen->bubble.opcode = CG_JMP;
 }
| XCG dst COMA src {
	codegen->bubble.opcode = CG_XCG;
 }
| XOR dst COMA src {
	codegen->bubble.opcode = CG_XOR;
 }
| AND dst COMA src {
	codegen->bubble.opcode = CG_AND;
 }
| OR  dst COMA src {
	codegen->bubble.opcode = CG_OR;
 }
| CMP dst COMA src {
	codegen->bubble.opcode = CG_CMP;
 }
| STI dst COMA imm {
	codegen->bubble.opcode = CG_STI;
 }
| SHL dst COMA src {
	codegen->bubble.opcode = CG_SHL;
 }
| SHR dst COMA src {
	codegen->bubble.opcode = CG_SHR;
 }
| MOV dst COMA src {
	codegen->bubble.opcode = CG_MOV;
 }
| INC dst {
	codegen->bubble.opcode = CG_INC;
 }
| DEC dst {
	codegen->bubble.opcode = CG_DEC;
 }
| PSH dst {
	codegen->bubble.opcode = CG_PSH;
 }
| PSH imm {
	codegen->bubble.opcode = CG_PSHI;
 }
| POP dst {
	codegen->bubble.opcode = CG_POP;
 }
| DBG {
	codegen->bubble.opcode = CG_DBG;
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
		.ic = codegen->ic,
		.name = codegen->_word,
	};
	codegen->_word = NULL;

	codegen_bookmark_append(codegen, bookmark);
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
