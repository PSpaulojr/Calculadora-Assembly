%{
#include <stdio.h>
void yyerror(char *c);
int yylex(void);
int primeiro = 0;
int multiplicou = 0;
%}

%token NUMERO MULTI SOMA MENOS EOL OPARENT CPARENT
%left SOMA MENOS
%left MULTI
%left OPARENT
%left CPARENT


%%

PROGRAMA:
		PROGRAMA EXPRESSAO EOL{ 
			printf("LDR R0, [SP], #-4\n");
			printf("end\n");
			multiplicou = 0;
			primeiro = 0;
			}
		|
		;

EXPRESSAO:
		MENOS NUMERO{
			$$ = -$2;
			if (primeiro){
				printf("MOV R1, #%d\nSTR R1,[SP,#4]!\n", $$);
			}
			else{
				primeiro = 1;
				printf("MOV SP, #0XFF000000\nMOV R1, #%d\nSTR R1,[SP,#4]!\n", $$);
			}
		}

		|NUMERO{
			$$ = $1;
			if (primeiro){
				printf("MOV R1, #%d\nSTR R1,[SP,#4]!\n", $$);
			}
			else{
				primeiro = 1;
				printf("MOV SP, #0XFF000000\nMOV R1, #%d\nSTR R1,[SP,#4]!\n", $$);
			}
		}

		| OPARENT EXPRESSAO CPARENT{
			$$ = $2;
		}

		| EXPRESSAO MULTI EXPRESSAO{
			$$ = $1 * $3;

			if(multiplicou){
				printf("LDR R1, [SP], #-4\nLDR R2, [SP], #-4\nCMP R1, #0\nBEQ ZERO%d\nB NZERO%d\nZERO%d BL ZERRO\nNZERO%d MOV R3, #0X80000000\nAND R3, R3, R1\nCMP R3, #0X80000000\nBEQ NEGATIVO1%d\nB SOMA1%d\nNEGATIVO1%d BL NEGATIVOA1\nSOMA1%d BL SOMA\n\n", multiplicou+1, multiplicou+1, multiplicou+1, multiplicou+1, multiplicou+1, multiplicou+1, multiplicou+1, multiplicou+1);
			}
			else{
				printf("LDR R1, [SP], #-4\nLDR R2, [SP], #-4\nCMP R1, #0\nBEQ ZERO\nB NZERO\nZERO BL ZERRO\nNZERO MOV R3, #0X80000000\nAND R3, R3, R1\nCMP R3, #0X80000000\nBEQ NEGATIVO1\nB SOMA2\nNEGATIVO1 BL NEGATIVOA1\nSOMA2 BL SOMA\nB fim\n\nNEGATIVOA1 MOV R3, #0X80000000\nAND R3, R3, R2\nCMP R3, #0X80000000\nBEQ NEGATIVO2\nBNE NEGATIVOAB1\nRETORNE MOV PC,LR\nNEGATIVO2 B NEGATIVO22\n\nNEGATIVOAB1 MOV R3, R1\nMOV R1, R2\nMOV R2, R3\nMOV R3, #0\nB RETORNE\n\nNEGATIVO22 MVN R1, R1\nADD R1, R1, #1\nMVN R2, R2\nADD R2, R2, #1\nMOV R3, #0\nB RETORNE\n\nZERRO MOV R1, #1\nMOV R2, #0\nMOV PC, LR\n\nSOMA ADD R3,R3,R2\nSUB R1, R1, #1\nCMP R1, #0\nBNE SOMA\nSTR R3,[SP, #4]!\nMOV PC,LR\nfim\n\n");
			}
				multiplicou ++;
		}

		| EXPRESSAO SOMA EXPRESSAO{
			$$ = $1 + $3;
			printf("LDR R1, [SP], #-4\nLDR R2, [SP], #-4\nADD R0, R1, R2\nSTR R0,[SP, #4]!\n");
		}

		| EXPRESSAO MENOS EXPRESSAO{
			$$ = $1 - $3;
			printf("LDR R1, [SP], #-4\nLDR R2, [SP], #-4\nSUB R0, R2, R1\nSTR R0,[SP, #4]!\n");
		}


%%

void yyerror(char *c){

	printf("meu erro foi: %s\n", c);
}

int main(){

	yyparse();
	return 0;
}