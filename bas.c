#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>

#include "codegen.h"
#include "y.tab.h"

char *progname;
extern int yylineno;

int
main(int argc, char **argv)
{
	progname = argv[0];

	codegen = malloc(sizeof(Codegen));
	if (!codegen)
		return 1;
	
	codegen_init(codegen);
	
	yyparse();


	codegen_gen(codegen, stdout);
	
	codegen_drop(codegen);
	free(codegen);
}

void
yyerror(char *s)
{
	fprintf(stderr, "%s: %s (%d)\n", progname, s, yylineno);
}
