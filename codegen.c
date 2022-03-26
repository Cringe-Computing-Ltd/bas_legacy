#include "codegen.h"
#include <stddef.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

Codegen *codegen = NULL;

void
bookmark_drop(Bookmark *bookmark)
{
	free(bookmark->name);
}

void
bookmark_destroy(Bookmark *bookmark)
{
	bookmark_drop(bookmark);
	free(bookmark);
}

void
instruction_drop(Instruction *instruction)
{
	if (instruction->has_imm == 2)
		free(instruction->bookmark_name);	
}

void
instruction_destroy(Instruction *instruction)
{
	instruction_drop(instruction);
	free(instruction);
}

void
codegen_init(Codegen *codegen)
{
	*codegen = (Codegen) {};
}

Codegen *
codegen_create()
{
	Codegen *codegen = malloc(sizeof(Codegen));
	if (!codegen)
		return NULL;

	codegen_init(codegen);

	return codegen;
}

void
codegen_drop(Codegen *codegen)
{
	codegen_instruction_destroy(codegen);
	codegen_bookmark_destroy(codegen);

	if (codegen->_word)
		free(codegen->_word);
}

void
codegen_destroy(Codegen *codegen)
{
	codegen_drop(codegen);
	free(codegen);
}

void
codegen_commit(Codegen *codegen)
{
	// Allocate instruction and copy bubble contents to it
	Instruction *instruction = malloc(sizeof(Instruction));
	if (!instruction)
		goto instruction_malloc_fail;

	codegen->ic++;
	if (codegen->bubble.has_imm)
		codegen->ic++;

	// Move bubble to it
	memcpy(instruction, &codegen->bubble, sizeof(Instruction));
	codegen->bubble = (Instruction) {};
	
	// Append the instruction to the instructions list
	codegen_instruction_append(codegen, instruction);

	return;	
 instruction_malloc_fail:
	return;
}

void
codegen_instruction_append(Codegen *codegen, Instruction *instruction)
{
	instruction->next = NULL;
	if (codegen->i_tail == NULL)
		codegen->i_head = codegen->i_tail = instruction;
	else {
		codegen->i_tail->next = instruction;
		codegen->i_tail = instruction;
	}
}

void
codegen_instruction_destroy(Codegen *codegen)
{
	Instruction *current = codegen->i_head, *tmp;
	while (current) {
		tmp = current;
		current = current->next;
		instruction_destroy(tmp);
	}
}

void
codegen_bookmark_append(Codegen *codegen, Bookmark *bookmark)
{       
	bookmark->next = codegen->b_head;
	codegen->b_head = bookmark;
}

Bookmark *codegen_bookmark_find(Codegen *codegen, char *name)
{
	Bookmark *current = codegen->b_head;
	
	while (current) {
		if (strcmp(current->name, name) == 0)
			return current;

		current = current->next;
	}

	return NULL;
}

void
codegen_bookmark_destroy(Codegen *codegen)
{
	Bookmark *current = codegen->b_head, *tmp;

	while (current) {
		tmp = current;
		current = current->next;
		bookmark_destroy(tmp);		
	}
}



char
codegen_gen(Codegen *codegen, FILE *file)
{
	Instruction *current = codegen->i_head;
	int fd = fileno(file);

	for (Instruction *current = codegen->i_head; current; current = current->next) {
		uint16_t code;
		code = current->opcode | current->dst << 6 | current->src << 11;
		write(fd, &code, sizeof(code));

		if (!current->has_imm)
			continue;

		uint16_t imm;
		if (current->has_imm == 2) {
			Bookmark *bookmark = codegen_bookmark_find(codegen, current->bookmark_name);
			if (!bookmark) {
				fprintf(stderr, "no such label %s\n", current->bookmark_name);
				exit(0);
			}
			imm = bookmark->ic + codegen->offset;
		} else
			imm = current->imm;

		write(fd, &imm, sizeof(imm));
	}
}
