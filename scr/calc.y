%{
#include <stdio.h>

void yyerror(char *c);
int yylex(void);

int primeiro = 0;
%}

%token NUMERO MULTI SOMA MENOS EOL OPARENT CPARENT
%left SOMA
%left MENOS
%left MULTI

%%

PROGRAMA:
		PROGRAMA EXPRESSAO EOL{ printf("Resultado: %d\n", $2); }
		|
		;

EXPRESSAO:
		NUMERO{
			$$ = $1;
		}
		| OPARENT EXPRESSAO CPARENT{
			$$ = $2;
			printf("Parênteses: %d", $2);
		}
		| EXPRESSAO MULTI EXPRESSAO{
			$$ = $1 * $3;
			printf("%d * %d = %d\n", $1, $3, $$);
		}

		| EXPRESSAO SOMA EXPRESSAO{
			$$ = $1 + $3;
			printf("%d + %d = %d\n", $1, $3, $$);
			if (primeiro){
				printf("MOV R1, #%d\nADD R0, R0, R1\n", $3);
			}
			else{
				primeiro = 1;
				printf("MOV R0, #0\nMOV R1, #%d\nADD R0,R0,R1\nMOV R1, #%d\nADD R0,R0,R1\n",$1,$3);
			}
		}

		| EXPRESSAO MENOS EXPRESSAO{
			$$ = $1 - $3;
			printf("%d - %d = %d\n", $1, $3, $$);
		}


%%

void yyerror(char *c){

	printf("meu erro foi: %s\n", c);
}

int main(){

	yyparse();
	return 0;
}