%{
#include <stdio.h>

void yyerror(char *c);
int yylex(void);

int primeiro = 0;
%}

%token NUMERO MULTI SOMA MENOS EOL 
%left SOMA
%left MENOS
%left MULTI

%%

PROGRAMA:
		PROGRAMA EXPRESSAO EOL{ printf("Resultado: %d\n", $2); }
		|
		;

EXPRESSAO:
		EXPRESSAO MULTI EXPRESSAO{
			$$ = $1 * $3;
			printf("%d * %d = %d\n", $1, $3, $$);
		}

		|NUMERO{
			$$ = $1;
		}

		| EXPRESSAO SOMA EXPRESSAO{
			$$ = $1 + $3;
			printf("%d + %d = %d\n", $1, $3, $$);
			if(primeiro){
				printf("MOV R1, #%d\nPUSH R1\nPOPALL\nADD R0, R0, R1\nPUSH R0\n",$3);
			}
			else {
				printf("MOV R0, #0\nMOV R1, #%d\nADD R0, R0, R1\nPUSH R0\nMOV R1, #%d\nPUSH R1\nPOPALL\nADD R0, R0, R1\nPUSH R0\n", $1, $2);
				primeiro = 1;
			}
		}

		| EXPRESSAO MENOS EXPRESSAO{
			$$ = $1 - $3;
			printf("MOV R1, #%d\nMOV R2, #%d\nSUB R0, R1, R2\n", $1, $3);
		}


%%

void yyerror(char *c){

	printf("meu erro foi: %s\n", c);
}

int main(){

	yyparse();
	return 0;
}