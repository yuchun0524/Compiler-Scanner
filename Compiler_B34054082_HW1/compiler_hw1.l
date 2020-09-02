/* Definition section */
%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>

    #define YY_NO_UNPUT
    #define YY_NO_INPUT
    
    int i, j, mark, count;
    int line_num = 0;
    int comment_num = 0;
    int line_record = -1;
    int comment_count = 0;
    char *str;

%}

/* Define regular expression label */
letter [a-zA-Z_]
digit [0-9]
id {letter}+({letter}|{digit})*
inumber {digit}+
fnumber ({digit}*\.{digit}+)
string  \"([^\\\"]|\\.)*\"

/* Rules section */
%%
	/* Delimiters */
"("	    { printf("%-8s \t %s\n", yytext, "LPAREN"); }
")"	    { printf("%-8s \t %s\n", yytext, "RPAREN"); }
"{"	    { printf("%-8s \t %s\n", yytext, "LBRACE"); }
"}"	    { printf("%-8s \t %s\n", yytext, "RBRACE"); }
"["	    { printf("%-8s \t %s\n", yytext, "LBRACK"); }
"]"	    { printf("%-8s \t %s\n", yytext, "RBRACK"); }
";"	    { printf("%-8s \t %s\n", yytext, "SEMICOLON"); }
","	    { printf("%-8s \t %s\n", yytext, "COMMA"); }
"\n"	    { printf("%-8s \t %s\n", " ", "NEWLINE");
	      line_num++;
 	    }

	/* Arithmetic operators */
"+"         { printf("%-8s \t %s\n", yytext, "ADD"); }
"-"         { printf("%-8s \t %s\n", yytext, "SUB"); }
"*"	    { printf("%-8s \t %s\n", yytext, "MUL"); }
"/"	    { printf("%-8s \t %s\n", yytext, "QUO"); }
"%"	    { printf("%-8s \t %s\n", yytext, "REM"); }
"++"        { printf("%-8s \t %s\n", yytext, "INC"); }
"--"	    { printf("%-8s \t %s\n", yytext, "DEC"); }


	/* Relational operators */
"<"	    { printf("%-8s \t %s\n", yytext, "LSS"); }
">"	    { printf("%-8s \t %s\n", yytext, "GTR"); }
"<="	    { printf("%-8s \t %s\n", yytext, "LEQ"); }
">="	    { printf("%-8s \t %s\n", yytext, "GEQ"); }
"=="	    { printf("%-8s \t %s\n", yytext, "EQL"); }
"!="	    { printf("%-8s \t %s\n", yytext, "NEQ"); }

	/* Assignment operators */
"="	    { printf("%-8s \t %s\n", yytext, "ASSIGN"); }
"+="	    { printf("%-8s \t %s\n", yytext, "ADD_ASSIGN"); }
"-="	    { printf("%-8s \t %s\n", yytext, "SUB_ASSIGN"); }
"*="	    { printf("%-8s \t %s\n", yytext, "MUL_ASSIGN"); }
"/="	    { printf("%-8s \t %s\n", yytext, "QUO_ASSIGN"); }
"%="	    { printf("%-8s \t %s\n", yytext, "REM_ASSIGN"); }

	/* Logical operators */
"&&"	    { printf("%-8s \t %s\n", yytext, "LAND"); }
"||"	    { printf("%-8s \t %s\n", yytext, "LOR"); }
"!"	    { printf("%-8s \t %s\n", yytext, "NOT"); }

	/* Keywords */
"int32"	    { printf("%-8s \t %s\n", yytext, "INT"); }
"float32"   { printf("%-8s \t %s\n", yytext, "FLOAT"); }
"bool"	    { printf("%-8s \t %s\n", yytext, "BOOL"); }
"string"    { printf("%-8s \t %s\n", yytext, "STRING"); }
"if"	    { printf("%-8s \t %s\n", yytext, "IF"); }
"else"	    { printf("%-8s \t %s\n", yytext, "ELSE"); }
"for"	    { printf("%-8s \t %s\n", yytext, "FOR"); }
"var"	    { printf("%-8s \t %s\n", yytext, "VAR"); }
"print"	    { printf("%-8s \t %s\n", yytext, "PRINT"); }
"println"   { printf("%-8s \t %s\n", yytext, "PRINTLN"); }
"true"	    { printf("%-8s \t %s\n", yytext, "TRUE"); }
"false"	    { printf("%-8s \t %s\n", yytext, "FALSE"); }

{inumber}   { printf("%-8s \t %s\n", yytext, "INT_LIT"); }
{fnumber}   { printf("%-8s \t %s\n", yytext, "FLOAT_LIT"); }
{id}        { printf("%-8s \t %s\n", yytext, "IDENT"); }
{string}    { 
		printf("%-8s \t %s\n", "\" ", "QUOTA");
		str = malloc(yyleng-2);		
		memcpy(str, yytext+1, yyleng-2);
		printf("%-8s \t %s\n", str,  "STRING");
		printf("%-8s \t %s\n", "\" ", "QUOTA");
		free(str); 
	    } 
"//"[^\n]*  { printf("%-8s \t %s\n", yytext, "C++ Comment");
	      if(line_record == line_num)
	          comment_count--;
	      comment_num++;
	    }
	/* <COMMENT><<EOF>> { printf("only comment%s\n", yytext); }*/
"/*"([^*]|\*+[^*/])*\*+"/\n" {
		    str = malloc(yyleng-1);      
                    memcpy(str, yytext, yyleng-1);
		    printf("%-11s \t %s\n", str, "C Comment");
		    printf("%-8s \t %s\n", " ", "NEWLINE");
		    free(str);
		    if(line_record == line_num)
			comment_count--;
		    line_num++;
		    comment_num++;
		}
"/*"([^*]|\*+[^*/])*\*+"/" {
		    count = 0;
		    mark = 0;
		    for (i = 0; i < yyleng; i++) {
                        if (yytext[i] == '\n')
			    break;
		    }
		    if(i == yyleng){
		    	printf("%-11s \t %s\n", yytext, "C Comment");
			if(line_record == line_num)
			    comment_count--;
			line_record = line_num;
			comment_num++;
		    } 
		    else{
	    	    for (i = 0; i < yyleng; i++) {
	    	        if (yytext[i] == '\n'){ 
			    str = malloc(i-mark+1);
			    memcpy(str, yytext+mark, i-mark+1);
			    printf("%s", str);
			    printf("%-7s \t %s", "", "C Comment");
			    free(str);          
			    if(i < yyleng-1){	
				mark = i;
				comment_num++;
				if(line_record == line_num)
				    comment_count--;
				line_num++;
			    }
			}
			}   		    	    
	    	   	str = malloc(i-mark+2);
                        memcpy(str, yytext+mark, i-mark+2);
			printf("%s", str);
                        printf("%-6s \t %s\n", "", "C Comment");
                        free(str);
			line_record = line_num;	
			comment_num++;
		}
}
<<EOF>>     { comment_num+= comment_count; line_num++; yyterminate(); }
.           {;}

%%

/*  C Code section */
int yywrap(void)
{
    return 1;
}

int main(int argc, char *argv[])
{
    if (argc == 2) {
        yyin = fopen(argv[1], "r");
    } else {
        yyin = stdin;
    }
    yylex();
    printf("\nFinish scanning,\n");
    printf("total line: %d\n", line_num);
    printf("comment line: %d\n", comment_num);
    fclose(yyin);
    return 0;
}
