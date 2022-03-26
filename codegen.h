#ifndef CODEGEN_H
#define CODEGEN_H

#include <stdint.h>
#include <stdio.h>


#define CG_RA 0
#define CG_RB 1
#define CG_RC 2
#define CG_RD 3
#define CG_RE 4
#define CG_RF 5
#define CG_RG 6
#define CG_RH 7

#define CG_LDI 0
#define CG_STR 1
#define CG_LDR 2
#define CG_ADD 3
#define CG_SUB 4
#define CG_MUL 5
#define CG_JMP 6
#define CG_JEQ 6
#define CG_JNE 6
#define CG_JGT 6
#define CG_JGE 6
#define CG_JLT 6
#define CG_JLE 6
#define CG_JCF 6
#define CG_XCG 7
#define CG_XOR 8
#define CG_AND 9
#define CG_OR  10
#define CG_CMP 11
#define CG_STI 12
#define CG_SHL 13
#define CG_SHR 14
#define CG_MOV 15
#define CG_INC 16
#define CG_DEC 17
#define CG_PSH 18
#define CG_PSHI 19
#define CG_POP 20
#define CG_DBG 21

typedef struct bookmark {
	char *name;
	uint16_t ic;

	struct bookmark *next;
} Bookmark;

void bookmark_drop(Bookmark *bookmark);
void bookmark_destroy(Bookmark *bookmark);

typedef struct instruction {
	uint16_t opcode;
	uint8_t dst;
	uint8_t src;

	struct instruction *next;
	
	char has_imm;
	union {
		uint16_t imm;
		char *bookmark_name;
	};
} Instruction;

void instruction_drop(Instruction *instruction);
void instruction_destroy(Instruction *instruction);

typedef struct codegen {
	uint16_t ic;
	uint16_t offset;

	uint8_t reg;
	
	uint8_t opcode;
	uint8_t dst;
	uint8_t src;

	Instruction bubble;

	Instruction *i_head;
	Instruction *i_tail;

	Bookmark *b_head;

	char *_word;
} Codegen;

void codegen_init(Codegen *codegen);
void codegen_drop(Codegen *codegen);

void codegen_commit(Codegen *codegen);

// Instructions management
void codegen_instruction_append(Codegen *codegen, Instruction *instruction);
void codegen_instruction_destroy(Codegen *codegen);

// Internal use
void codegen_bookmark_append(Codegen *codegen, Bookmark *bookmark);
Bookmark *codegen_bookmark_find(Codegen *codegen, char *name);
void codegen_bookmark_destroy(Codegen *codegen);

char codegen_gen(Codegen *codegen, FILE *file);


extern Codegen *codegen;

#endif
