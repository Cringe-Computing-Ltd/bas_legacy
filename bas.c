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

	codegen = codegen_create();
	if (!codegen)
		return 1;
	
	yyparse();


	codegen_gen(codegen, stdout);
	
	codegen_destroy(codegen);
}

void
yyerror(char *s)
{
	fprintf(stderr, "%s: %s (%d)\n", progname, s, yylineno);
}
