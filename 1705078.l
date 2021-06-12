%option noyywrap yylineno

%x MULTILINE_COMMENT
%x SINGLELINE_COMMENT
%x CHARACTER
%x STRING

%{
#include<stdio.h>
#include<iostream>
#include<stdlib.h>
#include<string.h>
#include<fstream>
//extern std::ofstream logstream;
//extern std::ofstream parserlog;
//#include "SymbolTable.h"
#include "SymbolInfo.h"
//#define YYSTYPE SymbolInfo*
#include "y.tab.h"

using namespace std;

//extern YYSTYPE yylval;
//extern SymbolTable *table;
void yyerror(char *);
//void Enter_scope();
//void Exit_scope();
SymbolInfo* Lookup_Symbol(string name);

//extern int yylineno;
int comment_begin_line = 0;	//Tracks the line no where the comments begin
int error_count=0;

std::string comment_string;

std::string UPPER()
{
	std::string keyword_token_name = yytext;

	for(int i=0; i<strlen(yytext); i++)
	{
		keyword_token_name[i] = yytext[i] - 32;
	}

	return keyword_token_name;
}

void print_lines_and_errors()
{
	cout << "Total lines: " << yylineno << "\nTotal errors: " << error_count;
}

void shift_string(int index)
{
	//shifts the string to the space freed by the escaped character in index
	for(int j=index; j<comment_string.size()-1; j++)	{
		comment_string[j] = comment_string[j+1];
	}

	comment_string.pop_back();
}

%}

WHITESPACE [ \t\f\r\v]+ 
LETTER [a-zA-Z_]
DIGIT [0-9]
NEWLINE (\n)|(\r\n)

%%

{NEWLINE}	{}
{WHITESPACE}	{}

"if"		{return IF;}
"for"		{return FOR;}
"do"		{return DO;}
"int"		{return INT;}
"float"		{return FLOAT;}
"void"		{return VOID;}
"switch"	{return SWITCH;}
"default"	{return DEFAULT;}
"else"		{return ELSE;}
"while"		{return WHILE;}
"break"		{return BREAK;}
"char"		{return CHAR;}
"double" 	{return DOUBLE;}
"return"	{return RETURN;}
"case"		{return CASE;}
"continue"	{return CONTINUE;}
"println"	{return PRINTLN;}

"+"			|
"-"			{	
				SymbolInfo *s= new  SymbolInfo(yytext, "ADDOP");
				//yylval = (YYSTYPE)s;
				yylval.symbolinfo = s;
				return ADDOP;
			}

"*" 		|
"/"			|
"%"			{
				SymbolInfo *s= new  SymbolInfo(yytext, "MULOP");
				//yylval = (YYSTYPE)s;
				yylval.symbolinfo = s;
				return MULOP;
			}

"++" 		{return INCOP;}
"--"		{return DECOP;}

"<"			|
"<="		|
">"			|
">="		|
"=="		|
"!="		{
				SymbolInfo *s= new  SymbolInfo(yytext, "RELOP");
				//yylval = (YYSTYPE)s;
				yylval.symbolinfo = s;
				return RELOP;
			}

"="			{return ASSIGNOP;}

"&&"		|
"||"		{
				SymbolInfo *s= new  SymbolInfo(yytext, "LOGICOP");
				//yylval = (YYSTYPE)s;
				yylval.symbolinfo = s;
				return LOGICOP;
			}

"!"			{return NOT;}
","			{return COMMA;}
";"			{return SEMICOLON;}
"("			{return LPAREN;}
")"			{return RPAREN;}
"["			{return LTHIRD;}
"]"			{return RTHIRD;}
"{"			{return LCURL;}
"}"			{return RCURL;}
		
{DIGIT}+ 	{
				SymbolInfo *s= new  SymbolInfo(yytext, "CONST_INT");
				s->setVar_type("int");
				//yylval = (YYSTYPE)s;
				yylval.symbolinfo = s;
				return CONST_INT;
			}

({DIGIT}*\.?{DIGIT}+|{DIGIT}+\.)(E[-+]?{DIGIT}+)?	{	//matches floating point numbers
				SymbolInfo *s= new  SymbolInfo(yytext, "CONST_FLOAT");
				s->setVar_type("float");
				//yylval = (YYSTYPE)s;
				yylval.symbolinfo = s;
				return CONST_FLOAT; 
			}

({DIGIT}*\.?{DIGIT}+|{DIGIT}+\.)(E[-+]?{DIGIT}*\.{DIGIT}*)?	{	//handles cases like 10E2.8
			//cout << "Error at line no " << yylineno << ": Ill formed number "<< yytext <<"\n\n";
			yyerror("Ill formed number");
			error_count++;
		}

({DIGIT}*\.?{DIGIT}+|{DIGIT}+\.)(\.|{DIGIT})+	{	//handles cases like 1.2.3.4, 1.2.3 etc
			//cout << "Error at line no " << yylineno << ": Too many decimal points "<< yytext <<"\n\n";
			yyerror("Too many decimal points");
			error_count++;
		}

{DIGIT}+{LETTER}+({LETTER}|{DIGIT})*	{	//detects Invalid prefix on ID or invalid suffix on Number
			//cout << "Error at line no " << yylineno << ": Invalid prefix on ID or invalid suffix on Number "<< yytext <<"\n\n";
			yyerror("Invalid prefix on ID or invalid suffix on Number");
			error_count++;
		}

"\'"	{	//handles character literals
			comment_string.clear();
			comment_string = yytext;

			BEGIN CHARACTER;
		}

<CHARACTER>[^\'\n]*	{	//if the line doesn't end with single quote, just store those chars in comment_string variable
						//because we need to print those during errors
			comment_string += yytext;
		}

<CHARACTER>.*\'	{	//handles those cases where the character literal ends with single quote

			//handles Empty character constant error i.e. ''
			if(strlen(yytext) == 1){
				//cout << "Error at line no " << yylineno << ": Empty character constant error \'"<< yytext <<"\n\n";
				yytext = (char*)(string("\'") + string(yytext)).c_str();
				yyerror("Empty character constant error");
				error_count++;

				BEGIN INITIAL;
			}

			//handles multi character constant errors
			//yytext length includes the closing single quote
			if (strlen(yytext) >= 4 || (yytext[0] != '\\' && strlen(yytext) == 3))	{
				//cout << "Error at line no " << yylineno << ": Multi character constant error \'"<< yytext <<"\n\n";
				yytext = (char*)(string("\'") + string(yytext)).c_str();
				yyerror("Multi character constant error");
				error_count++;

				BEGIN INITIAL;
			}
			
			else if(yytext[0] == '\\' && strlen(yytext) == 2)	{	// '\\' is an unfinished char
				//cout << "Error at line no " << yylineno << ": Unterminated character \'"<< yytext <<"\n\n";
				yytext = (char*)(string("\'") + string(yytext)).c_str();
				yyerror("Unterminated character");
				error_count++;

				BEGIN INITIAL;
			}

			//handles escape characters like \n, \t, \a etc
			else if((yytext[0] == '\\' && strlen(yytext) == 3)){
				if(yytext[1] == 'n'){	//found '\n' or \n
					std::string prepend = "\'";	//prepend the single quote to yytext, necessary to insert in the symbol table
					prepend += yytext;

					SymbolInfo *s= new  SymbolInfo(prepend, "CONST_CHAR");
					//yylval = (YYSTYPE)s;
					yylval.symbolinfo = s;
					return CONST_CHAR;
				}

				else if(yytext[1] == 't'){	//found '\t' or \t
					std::string prepend = "\'";	//prepend the single quote to yytext, necessary to insert in the symbol table
					prepend += yytext;

					SymbolInfo *s= new  SymbolInfo(prepend, "CONST_CHAR");
					//yylval = (YYSTYPE)s;
					yylval.symbolinfo = s;
					return CONST_CHAR;
				}

				else if(yytext[1] == 'b'){	//found '\b' or \b
					std::string prepend = "\'";	//prepend the single quote to yytext, necessary to insert in the symbol table
					prepend += yytext;

					SymbolInfo *s= new  SymbolInfo(prepend, "CONST_CHAR");
					//yylval = (YYSTYPE)s;
					yylval.symbolinfo = s;
					return CONST_CHAR;
				}

				else if(yytext[1] == 'a'){	//found '\a' or \a
					std::string prepend = "\'";	//prepend the single quote to yytext, necessary to insert in the symbol table
					prepend += yytext;

					SymbolInfo *s= new  SymbolInfo(prepend, "CONST_CHAR");
					//yylval = (YYSTYPE)s;
					yylval.symbolinfo = s;
					return CONST_CHAR;
				}

				else if(yytext[1] == '\''){	//found '\'' or '
					std::string prepend = "\'";	//prepend the single quote to yytext, necessary to insert in the symbol table
					prepend += yytext;

					SymbolInfo *s= new  SymbolInfo(prepend, "CONST_CHAR");
					//yylval = (YYSTYPE)s;
					yylval.symbolinfo = s;
					return CONST_CHAR;
				}

				else if(yytext[1] == 'f'){	//found '\f' or \f
					std::string prepend = "\'";	//prepend the single quote to yytext, necessary to insert in the symbol table
					prepend += yytext;

					SymbolInfo *s= new  SymbolInfo(prepend, "CONST_CHAR");
					//yylval = (YYSTYPE)s;
					yylval.symbolinfo = s;
					return CONST_CHAR;
				}

				else if(yytext[1] == 'r'){	//found '\r' or \r
					std::string prepend = "\'";	//prepend the single quote to yytext, necessary to insert in the symbol table
					prepend += yytext;

					SymbolInfo *s= new  SymbolInfo(prepend, "CONST_CHAR");
					//yylval = (YYSTYPE)s;
					yylval.symbolinfo = s;
					return CONST_CHAR;
				}

				else if(yytext[1] == 'v'){	//found '\v' or \v
					std::string prepend = "\'";	//prepend the single quote to yytext, necessary to insert in the symbol table
					prepend += yytext;

					SymbolInfo *s= new  SymbolInfo(prepend, "CONST_CHAR");
					//yylval = (YYSTYPE)s;
					yylval.symbolinfo = s;
					return CONST_CHAR;
				}

				else if(yytext[1] == '0'){	//found '\0' or \0
					std::string prepend = "\'";	//prepend the single quote to yytext, necessary to insert in the symbol table
					prepend += yytext;

					SymbolInfo *s= new  SymbolInfo(prepend, "CONST_CHAR");
					//yylval = (YYSTYPE)s;
					yylval.symbolinfo = s;
					return CONST_CHAR;
				}

				else if(yytext[1] == '\\')	{	//found '\\' or backslash 
					std::string prepend = "\'";	//prepend the single quote to yytext, necessary to insert in the symbol table
					prepend += yytext;

					SymbolInfo *s= new  SymbolInfo(prepend, "CONST_CHAR");
					//yylval = (YYSTYPE)s;
					yylval.symbolinfo = s;
					return CONST_CHAR;
				}

				else{	//invalid character
					//cout << "Error at line no " << yylineno << ": Invalid escape character \'"<< yytext <<"\n\n";
					yytext = (char*)(string("\'") + string(yytext)).c_str();
					yyerror("Invalid escape character");
					error_count++;
				}

				BEGIN INITIAL;
			}

			else if(strlen(yytext) == 2){	//we found a valid character like 'a', 'b' etc
				std::string prepend = "\'";	//prepend the single quote to yytext, necessary to insert in the symbol table
				prepend += yytext;

				SymbolInfo *s= new  SymbolInfo(prepend, "CONST_CHAR");
				//yylval = (YYSTYPE)s;
				yylval.symbolinfo = s;
				return CONST_CHAR;
				BEGIN INITIAL;
			}
		}

<CHARACTER>{NEWLINE}	{	//unfinished character literal
			//cout << "Error at line no " << yylineno-1 << ": Unterminated character "<< comment_string <<"\n\n";
			yyerror("Unterminated character");
			error_count++;

			BEGIN INITIAL;
		}	

<CHARACTER><<EOF>>	{	//unfinished character literal
			//cout << "Error at line no " << yylineno << ": Unterminated character "<< comment_string <<"\n\n";
			yyerror("Unterminated character");
			error_count++;
			yyterminate();
		}

"/*"	{	//matches multi-line comment

			comment_begin_line = yylineno;	//saving the line where the comment began
			comment_string = yytext;
			BEGIN MULTILINE_COMMENT;	
		}

<MULTILINE_COMMENT>([^*]|{NEWLINE})+|.	{	
			//match everything until terminating */ is found
			//excludes * so that it can be matched by the terminator */
			//newline just makes matching faster because bigger chunks can be matched

			comment_string += yytext;
		}

<MULTILINE_COMMENT>"*/"	{	//multiline comment ended here
			comment_string += yytext;
			cout << "Line no " << comment_begin_line << ": Token <COMMENT> Lexeme "<< comment_string <<" found\n\n";

			BEGIN INITIAL;
		}

<MULTILINE_COMMENT><<EOF>>	{
			//cout << "Error at line no " << comment_begin_line << ": Unterminated Comment "<< comment_string <<"\n\n";
			yyerror("Unterminated Comment");
			error_count++;
			yyterminate();
		}	

"//"	{	//matches comments beginning with double forward slashes

			comment_begin_line = yylineno;	//saving the line where the comment began
			comment_string.clear();
			comment_string = yytext;

			BEGIN SINGLELINE_COMMENT;	
		}

<SINGLELINE_COMMENT>(.*\\{NEWLINE})*	{	//append lines ending with \ to the comment text		
			comment_string += yytext;
		}

<SINGLELINE_COMMENT>[^\r\n]*	{	//this is the last line of the comment, keeping appending until newline or EOF	
			comment_string += yytext;
			cout << "Line no " << comment_begin_line << ": Token <COMMENT> Lexeme "<< comment_string <<" found\n\n";

			BEGIN INITIAL;
		}

<SINGLELINE_COMMENT>{NEWLINE}	{	//Single line comment finished
			cout << "Line no " << comment_begin_line << ": Token <COMMENT> Lexeme "<< comment_string <<" found\n\n";

			yyterminate();
		}

<SINGLELINE_COMMENT><<EOF>>	{	//Single line comment finished
			cout << "Line no " << comment_begin_line << ": Token <COMMENT> Lexeme "<< comment_string <<" found\n\n";
			yyterminate();
		}

"\""	{	//matches string literals

			comment_begin_line = yylineno;	//saving the line where the string began
			comment_string.clear();
			comment_string = yytext;

			BEGIN STRING;	
		}

<STRING>([^"\\\r\n]|\\({NEWLINE}|.))*\"	{	
			//matches those multi-line strings which end properly with an unescaped double quote (")
			//[^"\\\r\n] deals with normal characters i.e. those not preceded by backslash or newline
			//\\({NEWLINE}|.) ensures escaped characters are not same as unescaped characters, because
			//\" is not a valid string terminator, only " is, however \\" is a valid string terminator since
			//the backslash is properly escaped
			//\\({NEWLINE}|.) is also necessary for multiline strings since multilines strings are extended by
			//appending backslash at the end of a line

			comment_string += yytext;
			cout << "Line no " << comment_begin_line << ": Token <STRING> Lexeme "<< comment_string <<" found";

			//gotta print the escaped string in the token file, so gotta handle escape characters
			for(int i=0; i<comment_string.size()-1; i++)	{
				if(comment_string[i] == '\\' && comment_string[i+1] == 't')	{	//escapes tab
					comment_string[i] = '\t';
					shift_string(i+1);
				}

				else if(comment_string[i] == '\\' && comment_string[i+1] == 'n')	{	//escapes newline
					comment_string[i] = '\n';
					shift_string(i+1);
				}

				else if(comment_string[i] == '\\' && comment_string[i+1] == '\"')	{	//escapes double quote
					comment_string[i] = '\"';
					shift_string(i+1);
				}

				else if(comment_string[i] == '\\' && comment_string[i+1] == '\'')	{	//escapes single quote
					comment_string[i] = '\'';
					shift_string(i+1);
				}

				else if(comment_string[i] == '\\' && comment_string[i+1] == '\\')	{	//escapes backslash
					comment_string[i] = '\\';
					shift_string(i+1);
				}

				else if(comment_string[i] == '\\' && comment_string[i+1] == '\n')	{	//for multiline characters, backslash followed by newline removed
					//strings are made multi-lined by adding a backslash at the end of the line
					//so in case of a backslash followed by a newline, we need to remove both
					//so two shift_comment call is necessary
					shift_string(i+1);
					shift_string(i);
					//current index of the string has changed, so decrementing i to make sure we
					//iterate the same position during next iteration
					i--;
				}

				else if((i+2) < comment_string.size() && comment_string[i] == '\\' && comment_string[i+1] == '\r' && comment_string[i+2] == '\n')	{	//same as the previous condition, just handling CRLF
					shift_string(i+2);
					shift_string(i+1);
					shift_string(i);
					//current index of the string has changed, so decrementing i to make sure we
					//iterate the same position during next iteration
					i--;
					i--;
				}

				else if(comment_string[i] == '\\' && comment_string[i+1] == 'a')	{	//escapes \a
					comment_string[i] = '\a';
					shift_string(i+1);
				}

				else if(comment_string[i] == '\\' && comment_string[i+1] == 'f')	{	//escapes \f
					comment_string[i] = '\f';
					shift_string(i+1);
				}

				else if(comment_string[i] == '\\' && comment_string[i+1] == 'r')	{	//escapes \r
					comment_string[i] = '\r';
					shift_string(i+1);
				}

				else if(comment_string[i] == '\\' && comment_string[i+1] == 'b')	{	//escapes \b
					comment_string[i] = '\b';
					shift_string(i+1);
				}
			}

			//fprintf(tokenout,"<STRING, %s> ",comment_string.c_str());
			cout << " --> <STRING, " << comment_string << "> \n\n";

			SymbolInfo *s= new SymbolInfo(comment_string, "STRING");
			//yylval = (YYSTYPE)s;
			yylval.symbolinfo = s;
			return STRING;

			BEGIN INITIAL;
		}

<STRING>([^"\\\r\n]|\\({NEWLINE}|.))*	{
			//this rule does not match any valid string, but
			//necessary for detecting unterminated multi-line strings, because in case the string does not terminate,
			//we need to print the part of the string matched so far

			comment_string += yytext;
		}

<STRING>{NEWLINE}	{	//newline without preceded by a backslash found, so report an error
			//cout << "Error at line no " << comment_begin_line << ": Unterminated String "<< comment_string <<"\n\n";
			yyerror("Unterminated String");
			error_count++;
			
			BEGIN INITIAL;
		}

<STRING><<EOF>>	{	//string literal ended without " (double quote), so report the error
			//cout << "Error at line no " << comment_begin_line << ": Unterminated String "<< comment_string <<"\n\n";
			yyerror("Unterminated String");
			error_count++;
			yyterminate();
		}

{LETTER}+({LETTER}|{DIGIT})*	{
				SymbolInfo *s = new SymbolInfo(yytext, "ID");
				//SymbolInfo *s = Lookup_Symbol(yytext);

				//if(!s)	s = new SymbolInfo(yytext, "ID");

				//yylval = (YYSTYPE)s;
				yylval.symbolinfo = s;
				return ID;
		}
			
.		{
			//cout << "Error at line no " << yylineno << ": Unrecognized character "<< yytext <<"\n\n";
			yyerror("Unrecognized character");
			error_count++;
		}
