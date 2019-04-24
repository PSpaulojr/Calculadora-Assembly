%{
#include <stdio.h>
#include <string.h>


void yyerror(char *c);

#include "y.tab.h"

%}

%%

[-] { return MENOS; }

[(] { return OPARENT;}

[)] { return CPARENT; }

[*] { return MULTI; }

[+] { return SOMA; }

[0-9]+ {
	yylval = atoi(yytext);
	return NUMERO;
}


\n {return EOL; }

[ \t]+ ;

.     { yyerror("Token nao reconhecido!\n"); }

%%

int yywrap(){
	return 1;
}