%{
#include <stdio.h>
#include <string.h>


void yyerror(char *c);

#include "y.tab.h"

%}

%%

[0-9]+ {
	yylval = atoi(yytext);
	return NUMERO;
}

[(] { return OPARENT;}

[)] { return CPARENT; }

[*] { return MULTI; }

[+] { return SOMA; }

[-] { return MENOS; }

\n {return EOL; }

[ \t]+ ;

.     { yyerror("Token nao reconhecido!\n"); }

%%

int yywrap(){
	return 1;
}