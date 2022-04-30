#ifndef CODEGEN_H
#define CODEGEN_H

#include <stdint.h>
#include <stdio.h>


#define CG_R0 0
#define CG_R1 1
#define CG_R2 2
#define CG_R3 3
#define CG_R4 4
#define CG_R5 5
#define CG_R6 6
#define CG_R7 7

#define CG_MVI 0
#define CG_MVR 1
#define CG_XCG 2
#define CG_LDR 3
#define CG_STI 4
#define CG_STR 5
#define CG_ADD 6
#define CG_SUB 7
#define CG_CMP 8
#define CG_MUL 9
#define CG_INC 10
#define CG_DEC 11
#define CG_XOR 12
#define CG_AND 13
#define CG_OR 14
#define CG_SHL 15
#define CG_SHR 16
#define CG_JMP 17
#define CG_PSI 18
#define CG_PSH 19
#define CG_POP 20
#define CG_HLT 21

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
Codegen *codegen_create(void);
void codegen_drop(Codegen *codegen);
void codegen_destroy(Codegen *codegen);

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
