%{
#include <stdio.h>
void yyerror(char *c);
int yylex(void);
int primeiro = 0;
int multiplicou = 0;
int negativo = 0;
%}

%token NUMERO MULTI SOMA MENOS EOL OPARENT CPARENT
%left SOMA MENOS
%left MULTI
%left CPARENT
%left OPARENT

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
			if( $1*$3 < 0 ){
				if( ($1 < 0) && ($3<0) ){
					$1 = $1*(-1);
					$3 = $3*(-1);
					$$ = $1 * $3;
				}
				else if( $1 > $3 ) {
					negativo++ ;
				}
			}
			
			if(multiplicou){
				if(negativo){
					printf("LDR R2, [SP], #-4\nLDR R1, [SP], #-4\nMOV R3, #0\nBL SOMA\n\n");
					negativo = 0;
				}
				else{
					if( $1*1 < 0){
						printf("LDR R1, [SP], #-4\nLDR R2, [SP], #-4\nMVN R2, R2\nADD R2, R2, #1\nMVN R1, R1\nADD R1, R1, #1\nMOV R3, #0\nBL SOMA\n\n");
					}
					else{
						printf("LDR R1, [SP], #-4\nLDR R2, [SP], #-4\nMOV R3, #0\nBL SOMA\n\n");
					}
				}
			}
			else{
				if(negativo){
					printf("LDR R2, [SP], #-4\nLDR R1, [SP], #-4\nBL SOMA\nB fim\n\nSOMA ADD R3,R3,R2\nSUB R1, R1, #1\nCMP R1, #0\nBNE SOMA\nSTR R3,[SP, #4]!\nMOV PC,LR\nfim\n\n");
					negativo = 0;
				}
				else{
					if( $1*1 < 0){
						printf("LDR R1, [SP], #-4\nLDR R2, [SP], #-4\nMVN R2, R2\nADD R2, R2, #1\nMVN R1, R1\nADD R1, R1, #1\nBL SOMA\nB fim\n\nSOMA ADD R3,R3,R2\nSUB R1, R1, #1\nCMP R1, #0\nBNE SOMA\nSTR R3,[SP, #4]!\nMOV PC,LR\nfim\n\n");
					}
					else{
						printf("LDR R1, [SP], #-4\nLDR R2, [SP], #-4\nBL SOMA\nB fim\n\nSOMA ADD R3,R3,R2\nSUB R1, R1, #1\nCMP R1, #0\nBNE SOMA\nSTR R3,[SP, #4]!\nMOV PC,LR\nfim\n\n");
					}
				}
				multiplicou ++;
			}
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