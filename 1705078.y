%{
#include<iostream>
#include<cstdlib>
#include<cstring>
#include<cmath>
#include<fstream>
//std::ofstream logstream("lexer_log.txt");
std::ofstream parserlog("log.txt");
std::ofstream errorlog("error.txt");
#include "SymbolTable.h"
//#define YYSTYPE SymbolInfo*

using namespace std;

extern int yylineno;
extern char* yytext;

int yyparse(void);
int yylex(void);
extern FILE *yyin;

FILE* fp;

SymbolTable *table = new SymbolTable(30);
int parser_error_count = 0;

#include "ICG_HELPER.h"
#include "PARSER_HELPER.h"

void yyerror(char *s)
{
	parserlog << "Error at line " << yylineno << ": " << s << " : \"" << yytext << "\"\n\n";
	errorlog << "Error at line " << yylineno << ": " << s << " : \"" << yytext << "\"\n\n";
	parser_error_count++;
}

%}

%union
{
	SymbolInfo* symbolinfo;
	char* name;
	char* code;				//assembly code, needed in function, loops and if-else

	struct non_expression_struct
	{
		char* name;
		char* code;			//assembly code, needed in function, loops and if-else
	}	non_expression_structure;

	struct expression_struct
	{
		SymbolInfo* symbolinfo;	//to store information about data type; for Semantic analysis
		char* name;			//to print the code i.e. matched text
		char* var;			//integer constant/variable/temporary variable holding the value of the expression
		char* type;			//"VAR", "ARR", "CONST" or "ARRVAR"
		char* index;			//needed in arrays, stores the integer constant/variable/temporary variable holding the index of the array
		char* code;		//assembly code, needed in function, loops and if-else
	}	expression_structure;
}

%token IF FOR DO INT FLOAT VOID SWITCH DEFAULT ELSE WHILE BREAK CHAR DOUBLE RETURN CASE CONTINUE MAIN PRINTLN
%token INCOP DECOP ASSIGNOP
%token NOT COMMA SEMICOLON LPAREN RPAREN LTHIRD RTHIRD LCURL RCURL

%token ADDOP MULOP RELOP LOGICOP
%token CONST_INT CONST_FLOAT CONST_CHAR
%token ID STRING

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%nonassoc PARAMETER_LIST_RULE_WITHOUT_ERROR
%nonassoc error

%type <symbolinfo> ID STRING ADDOP MULOP RELOP LOGICOP CONST_INT CONST_FLOAT CONST_CHAR
%type <non_expression_structure> declaration_list type_specifier var_declaration unit program start func_declaration parameter_list

%type <non_expression_structure> func_definition compound_statement statements statement expression_statement argument_list arguments

%type <expression_structure> expression logic_expression rel_expression term unary_expression factor simple_expression variable

//%error-verbose

%%

start : program
	{
		$$.name = string_to_char_array(string($1.name));
		parserlog << "Line " << yylineno-1 << ": start : program\n\n";
		//parserlog << $$.name << "\n\n";
	}
	;

program : program unit
	{
		$$.name = string_to_char_array(string($1.name) + "\n" + string($2.name));
		parserlog << "Line " << yylineno << ": program : program unit\n\n" << $$.name << "\n\n";
	}
	| unit
	{
		$$.name = string_to_char_array(string($1.name));
		parserlog << "Line " << yylineno << ": program : unit\n\n" << $$.name << "\n\n";
	}
	;
	
unit : var_declaration
		{
			$$.name = string_to_char_array(string($1.name));
			parserlog << "Line " << yylineno << ": unit : var_declaration\n\n" << $$.name << "\n\n";
		}
	| func_declaration
		{
			$$.name = string_to_char_array(string($1.name));
			parserlog << "Line " << yylineno << ": unit : func_declaration\n\n" << $$.name << "\n\n";
		}
	| func_definition
		{
			$$.name = string_to_char_array(string($1.name));
			parserlog << "Line " << yylineno << ": unit : func_definition\n\n" << $$.name << "\n\n";
		}
     ;

func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON
		{
			$$.name = string_to_char_array(string($1.name)+" "+$2->getSymbol_name()+"("+ string($4.name) +");");
			parserlog << "Line " << yylineno << ": func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON\n\n" << $$.name << "\n\n";
		
			//function found, time for insertion
			insert_function_into_symbol_table($2->getSymbol_name(), string($1.name));
			variables.clear();
		}
		| type_specifier ID LPAREN RPAREN SEMICOLON
		{
			$$.name = string_to_char_array(string($1.name)+" "+$2->getSymbol_name()+"();");
			parserlog << "Line " << yylineno << ": func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON\n\n" << $$.name << "\n\n";

			//function found, time for insertion
			insert_function_into_symbol_table($2->getSymbol_name(), string($1.name));
			variables.clear();
		}
		;

func_definition : type_specifier ID LPAREN parameter_list RPAREN {match_function_definition_and_declaration(string($1.name), $2->getSymbol_name());} compound_statement
		{
			$$.name = string_to_char_array(string($1.name)+" "+$2->getSymbol_name()+"("+string($4.name)+")"+string($7.name)+"\n");
			parserlog << "Line " << yylineno << ": func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement\n\n" << $$.name << "\n\n";

			//match_function_definition_and_declaration(string($1.name), $2->getSymbol_name());
		}
		| type_specifier ID LPAREN RPAREN {match_function_definition_and_declaration(string($1.name), $2->getSymbol_name());} compound_statement
		{
			$$.name = string_to_char_array(string($1.name)+" "+$2->getSymbol_name()+"()"+string($6.name)+"\n");
			parserlog << "Line " << yylineno << ": func_definition : type_specifier ID LPAREN RPAREN compound_statement\n\n" << $$.name << "\n\n";

			//match_function_definition_and_declaration(string($1.name), $2->getSymbol_name());
		}
 		;

parameter_list : parameter_list COMMA type_specifier ID
		{
			$$.name = string_to_char_array(string($1.name)+","+string($3.name)+" "+$4->getSymbol_name());
			parserlog << "Line " << yylineno << ": parameter_list : parameter_list COMMA type_specifier ID\n\n" << $$.name << "\n\n";

			$4->setVar_type(string($3.name));
			save_variable($4, "VARIABLE");
		}
		| parameter_list COMMA type_specifier
		{
			$$.name = string_to_char_array(string($1.name)+","+string($3.name));
			parserlog << "Line " << yylineno << ": parameter_list : parameter_list COMMA type_specifier\n\n" << $$.name << "\n\n";

			SymbolInfo* s = new SymbolInfo("", "ID");
			s->setVar_type(string($3.name));
			save_variable(s, "VARIABLE");
		}
 		| type_specifier ID %prec PARAMETER_LIST_RULE_WITHOUT_ERROR
		{
			$$.name = string_to_char_array(string($1.name)+" "+$2->getSymbol_name());
			parserlog << "Line " << yylineno << ": parameter_list : type_specifier ID\n\n" << $$.name << "\n\n";

			$2->setVar_type(string($1.name));
			save_variable($2, "VARIABLE");			
		}
		| type_specifier %prec PARAMETER_LIST_RULE_WITHOUT_ERROR
		{
			$$.name = string_to_char_array(string($1.name));
			parserlog << "Line " << yylineno << ": parameter_list : type_specifier\n\n" << $$.name << "\n\n";

			SymbolInfo* s = new SymbolInfo("", "ID");
			s->setVar_type(string($1.name));
			save_variable(s, "VARIABLE");
		}
		| parameter_list error COMMA type_specifier ID
		{
			yyerrok;
			$$.name = string_to_char_array(string($1.name)+","+string($4.name)+" "+$5->getSymbol_name());
			parserlog << "Line " << yylineno << ": parameter_list : parameter_list COMMA type_specifier ID\n\n" << $$.name << "\n\n";

			$5->setVar_type(string($4.name));
			save_variable($5, "VARIABLE");
		}
		| parameter_list error COMMA type_specifier
		{
			yyerrok;
			$$.name = string_to_char_array(string($1.name)+","+string($4.name));
			parserlog << "Line " << yylineno << ": parameter_list : parameter_list COMMA type_specifier\n\n" << $$.name << "\n\n";

			SymbolInfo* s = new SymbolInfo("", "ID");
			s->setVar_type(string($4.name));
			save_variable(s, "VARIABLE");
		}
 		| type_specifier ID error
		{
			yyclearin;
			yyerrok;
			$$.name = string_to_char_array(string($1.name)+" "+$2->getSymbol_name());
			parserlog << "Line " << yylineno << ": parameter_list : type_specifier ID\n\n" << $$.name << "\n\n";

			$2->setVar_type(string($1.name));
			save_variable($2, "VARIABLE");			
		}
		| type_specifier error
		{
			yyclearin;
			yyerrok;
			$$.name = string_to_char_array(string($1.name));
			parserlog << "Line " << yylineno << ": parameter_list : type_specifier\n\n" << $$.name << "\n\n";

			SymbolInfo* s = new SymbolInfo("", "ID");
			s->setVar_type(string($1.name));
			save_variable(s, "VARIABLE");
		}
 		;

compound_statement : LCURL {Enter_scope();} statements RCURL
			{
				$$.name = string_to_char_array("{\n" + string($3.name) + "\n}");
				parserlog << "Line " << yylineno << ": compound_statement : LCURL statements RCURL\n\n" << $$.name << "\n\n";

				Exit_scope();
			}
 		    | LCURL {Enter_scope();} RCURL
			{
				$$.name = string_to_char_array("{\n}");
				parserlog << "Line " << yylineno << ": compound_statement : LCURL RCURL\n\n" << $$.name << "\n\n";

				Exit_scope();
			}
 		    ;
 		    
var_declaration : type_specifier declaration_list SEMICOLON
		{
			$$.name = string_to_char_array(string($1.name)+" "+string($2.name)+";");
			parserlog << "Line " << yylineno << ": var_declaration : type_specifier declaration_list SEMICOLON\n\n" << $$.name << "\n\n";

			if(string($1.name) == "void")
			{
				parserlog << "Error at line " << yylineno << ": Variable type cannot be void." << "\n\n";
				errorlog << "Error at line " << yylineno << ": Variable type cannot be void." << "\n\n";
				parser_error_count++;

				variables.clear();
			}
			
			else
			//time to insert variables in the declaration list into the SymbolTable
				insert_variables_into_symbol_table(string($1.name));
		}
 		 ;
 		 
type_specifier : INT	{parserlog << "Line " << yylineno << ": type_specifier : INT\n\n" << "int" << "\n\n"; $$.name = "int";}
 		| FLOAT			{parserlog << "Line " << yylineno << ": type_specifier : FLOAT\n\n" << "float" << "\n\n"; $$.name = "float";}
 		| VOID			{parserlog << "Line " << yylineno << ": type_specifier : VOID\n\n" << "void" << "\n\n"; $$.name = "void";}
 		;
 		
declaration_list : declaration_list COMMA ID
		{
			$$.name = string_to_char_array(string($1.name)+","+$3->getSymbol_name());
			parserlog << "Line " << yylineno << ": declaration_list : declaration_list COMMA ID\n\n" << $$.name << "\n\n";

			save_variable($3, "VARIABLE");
		}
 		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD
		{
			$$.name = string_to_char_array(string($1.name)+","+$3->getSymbol_name()+"["+$5->getSymbol_name()+"]");
			parserlog << "Line " << yylineno << ": declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD\n\n" << $$.name << "\n\n";

			save_variable($3, "ARRAY", atoi($5->getSymbol_name().c_str()));
		}
 		  | ID
		{
			$$.name = string_to_char_array($1->getSymbol_name());
			parserlog << "Line " << yylineno << ": declaration_list : ID\n\n" << $$.name << "\n\n";

			save_variable($1, "VARIABLE");
		}
 		  | ID LTHIRD CONST_INT RTHIRD
		{
			$$.name= string_to_char_array($1->getSymbol_name()+"["+$3->getSymbol_name()+"]");
			parserlog << "Line " << yylineno << ": declaration_list : ID LTHIRD CONST_INT RTHIRD\n\n" << $$.name << "\n\n";

			save_variable($1, "ARRAY", atoi($3->getSymbol_name().c_str()));
		}
		  | declaration_list error COMMA ID
		{
			//yyclearin;
			yyerrok;

			$$.name = string_to_char_array(string($1.name)+","+$4->getSymbol_name());

			save_variable($4, "VARIABLE");
		}
 		  | declaration_list error COMMA ID LTHIRD CONST_INT RTHIRD
		{
			//yyclearin;
			yyerrok;

			$$.name = string_to_char_array(string($1.name)+","+$4->getSymbol_name()+"["+$6->getSymbol_name()+"]");

			save_variable($4, "ARRAY", atoi($6->getSymbol_name().c_str()));
		}
 		  | error COMMA ID
		{
			//yyclearin;
			yyerrok;

			$$.name = string_to_char_array($3->getSymbol_name());

			save_variable($3, "VARIABLE");
		}
 		  | error COMMA ID LTHIRD CONST_INT RTHIRD
		{
			//yyclearin;
			yyerrok;

			$$.name = string_to_char_array($3->getSymbol_name()+"["+$5->getSymbol_name()+"]");

			save_variable($3, "ARRAY", atoi($5->getSymbol_name().c_str()));
		}
 		;

statements : statement
		{
			$$.name = string_to_char_array(string($1.name));
			parserlog << "Line " << yylineno << ": statements : statement\n\n" << $$.name << "\n\n";
		}
	   | statements statement
		{
			$$.name = string_to_char_array(string($1.name) + "\n" + string($2.name));
			parserlog << "Line " << yylineno << ": statements : statements statement\n\n" << $$.name << "\n\n";
		}
	   ;
	   
statement : var_declaration
	{
		$$.name = string_to_char_array(string($1.name));
		parserlog << "Line " << yylineno << ": statement : var_declaration\n\n" << $$.name << "\n\n";
	}
	  | expression_statement
	{
		$$.name = string_to_char_array(string($1.name));
		parserlog << "Line " << yylineno << ": statement : expression_statement\n\n" << $$.name << "\n\n";
	}
	  | compound_statement
	{
		$$.name = string_to_char_array(string($1.name));
		parserlog << "Line " << yylineno << ": statement : compound_statement\n\n" << $$.name << "\n\n";
	}
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement
	{
		$$.name = string_to_char_array(string("for") + string("(") + string($3.name) + string($4.name) + string($5.name) + string(")") + string($7.name));
		parserlog << "Line " << yylineno << ": statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement\n\n" << $$.name << "\n\n";
	}
	  | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE
	{
		$$.name = string_to_char_array(string("if ") + string("(") + string($3.name) + string(")") + string($5.name));
		parserlog << "Line " << yylineno << ": statement : IF LPAREN expression RPAREN statement\n\n" << $$.name << "\n\n";
	}
	  | IF LPAREN expression RPAREN statement ELSE statement
	{
		$$.name = string_to_char_array(string("if ") + string("(") + string($3.name) + string(")") + string($5.name) + "\nelse\n" + string($7.name));
		parserlog << "Line " << yylineno << ": statement : IF LPAREN expression RPAREN statement ELSE statement\n\n" << $$.name << "\n\n";
	}
	  | WHILE LPAREN expression RPAREN statement
	{
		$$.name = string_to_char_array(string("while ") + string("(") + string($3.name) + string(")") + string($5.name));
		parserlog << "Line " << yylineno << ": statement : WHILE LPAREN expression RPAREN statement\n\n" << $$.name << "\n\n";
	}
	  | PRINTLN LPAREN ID RPAREN SEMICOLON
	{
		$$.name = string_to_char_array(string("printf") + string("(") + $3->getSymbol_name() + string(")") + string(";"));
		parserlog << "Line " << yylineno << ": statement : PRINTLN LPAREN ID RPAREN SEMICOLON\n\n" << $$.name << "\n\n";

		if(!table->Lookup($3->getSymbol_name()))
		{
			parserlog << "Error at line " << yylineno << ": variable \"" << $3->getSymbol_name() << "\" was not declared." << "\n\n";
			errorlog << "Error at line " << yylineno << ": variable \"" << $3->getSymbol_name() << "\" was not declared." << "\n\n";
			parser_error_count++;
		}
	}
	  | RETURN expression SEMICOLON
	{
		$$.name = string_to_char_array(string("return ") + string($2.name) + string(";"));
		parserlog << "Line " << yylineno << ": statement : RETURN expression SEMICOLON\n\n" << $$.name << "\n\n";
	}
	  ;
	  
expression_statement : SEMICOLON
	{
		$$.name = string_to_char_array(";");
		parserlog << "Line " << yylineno << ": expression_statement : SEMICOLON\n\n" << $$.name << "\n\n";

		//reset tvc
		tvc = -1;
		CODE += "\n";
	}			
	| expression SEMICOLON
	{
		$$.name = string_to_char_array(string($1.name) + ";");
		parserlog << "Line " << yylineno << ": expression_statement : expression SEMICOLON\n\n" << $$.name << "\n\n";
		
		//reset tvc
		tvc = -1;
		CODE += "\n";
	}
	| error SEMICOLON
	{
		yyclearin;
		yyerrok;

		$$.name = string_to_char_array(";");
	}			
	| expression error SEMICOLON
	{
		yyclearin;
		yyerrok;
		
		$$.name = string_to_char_array(string($1.name) + ";");
	}
	;
	  
variable : ID 
	{
		$$.symbolinfo = $1;
		$$.name = string_to_char_array($1->getSymbol_name());
		parserlog << "Line " << yylineno << ": variable : ID\n\n" << $$.name << "\n\n";

		SymbolInfo* s = table->Lookup($1->getSymbol_name());

		//print an error if the id is undeclared
		if(!s)
		{
			parserlog << "Error at line " << yylineno << ": variable \"" << $1->getSymbol_name() << "\" was not declared." << "\n\n";
			errorlog << "Error at line " << yylineno << ": variable \"" << $1->getSymbol_name() << "\" was not declared." << "\n\n";
			parser_error_count++;
		}

		else
		{
			//if the variable is declared then replace with the one in the symbol table
			$$.symbolinfo = s;

			//print an error if the id does not belong to a variable
			if(s->getVar_category() == "ARRAY")
			{
				parserlog << "Error at line " << yylineno << ": id \"" << s->getSymbol_name() << "\" is an array used without an index." << "\n\n";
				errorlog << "Error at line " << yylineno << ": id \"" << s->getSymbol_name() << "\" is an array used without an index." << "\n\n";
				parser_error_count++;
			}

			//print an error if the id does not belong to a variable
			if(s->getVar_category() == "FUNCTION")
			{
				parserlog << "Error at line " << yylineno << ": id \"" << s->getSymbol_name() << "\" is a function, not a variable." << "\n\n";
				errorlog << "Error at line " << yylineno << ": id \"" << s->getSymbol_name() << "\" is a function, not a variable." << "\n\n";
				parser_error_count++;
			}
		}
		
		if(s)
		{
			$$.var = string_to_char_array(getAsmVar(s->getSymbol_name(), s->getVar_category()));
			$$.type = string_to_char_array("VAR");
		}
	}
	 | ID LTHIRD expression RTHIRD
	{	
		$$.symbolinfo = $1;

		$$.name = string_to_char_array($1->getSymbol_name() + "[" + $3.name + "]");
		parserlog << "Line " << yylineno << ": variable : ID LTHIRD expression RTHIRD\n\n";
		parserlog << $$.name << "\n\n";

		SymbolInfo* s = table->Lookup($1->getSymbol_name());

		//print an error if the id is undeclared
		if(!s)
		{
			parserlog << "Error at line " << yylineno << ": array \"" << $1->getSymbol_name() << "\" was not declared." << "\n\n";
			errorlog << "Error at line " << yylineno << ": array \"" << $1->getSymbol_name() << "\" was not declared." << "\n\n";
			parser_error_count++;
		}

		else
		{
			//if the variable is declared then replace with the one in the symbol table
			$$.symbolinfo = s;

			//since an index was used, variable is not an array, rather a non array variable
			if(s->getVar_category() == "ARRAY")
			{
				$$.symbolinfo = Copy_Symbol(s);
				$$.symbolinfo->setVar_category("VARIABLE");
			}

			//print an error if the id does not belong to an array
			if(s->getVar_category() != "ARRAY")
			{
				parserlog << "Error at line " << yylineno << ": id \"" << s->getSymbol_name() << "\" is not an array.\n\n";
				errorlog << "Error at line " << yylineno << ": id \"" << s->getSymbol_name() << "\" is not an array.\n\n";
				//errorlog << "data type is " << s->getVar_category() << "\n\n";
				parser_error_count++;
			}

			if(s->getVar_category() == "ARRAY")
			{
				//print an error if array index is not an integer
				if($3.symbolinfo->getVar_type() != "int")
				{
					parserlog << "Error at line " << yylineno << ": array \"" << $1->getSymbol_name() << "\" has non integer index " << "\n\n";
					errorlog << "Error at line " << yylineno << ": array \"" << $1->getSymbol_name() << "\" has non integer index " << "\n\n";
					parser_error_count++;
				}
			}
		}

		if(s)
		{
			$$.var = string_to_char_array(getAsmVar($1->getSymbol_name(), $1->getVar_category()));
			$$.type = string_to_char_array("ARRVAR");
			$$.index = $3.var;
			//$$.index_type = $3.type;
		}
	}
	 ;
	 
expression : logic_expression
		{
			$$.symbolinfo = $1.symbolinfo;
			$$.name = string_to_char_array(string($1.name));

			parserlog << "Line " << yylineno << ": expression : logic_expression\n\n" << $$.name << "\n\n";

			$$.var = string_to_char_array(string($1.var));
			$$.type = string_to_char_array(string($1.type));
		}	
	   | variable ASSIGNOP logic_expression
		{
			$$.symbolinfo = $1.symbolinfo;
			$$.name = string_to_char_array(string($1.name) + "=" + string($3.name));

			parserlog << "Line " << yylineno << ": expression : variable ASSIGNOP logic_expression\n\n" << $$.name << "\n\n";

			//check whether the variable was declared, undeclared variables don't have any data type
			if(!table->Lookup($1.symbolinfo->getSymbol_name()))
			{
				//redundant error message, already handled in "variable -> ID" rule
				//parserlog << "Error at line " << yylineno << ": variable \"" << $1.symbolinfo->getSymbol_name() << "\" was not declared." << "\n\n";
				//errorlog << "Error at line " << yylineno << ": variable \"" << $1.symbolinfo->getSymbol_name() << "\" was not declared." << "\n\n";
				//parser_error_count++;
			}

			else
			{
				//assigning float value in an integer
				if($1.symbolinfo->getVar_type() == "int" && $3.symbolinfo->getVar_type() == "float")
				{
					parserlog << "Error at line " << yylineno << ": float value is being assigned to an integer." << "\n\n";
					errorlog << "Error at line " << yylineno << ": float value is being assigned to an integer." << "\n\n";
					parser_error_count++;
				}

				//assigning a non array value to an array
				if($1.symbolinfo->getVar_category() == "ARRAY" && $3.symbolinfo->getVar_category() != "ARRAY")
				{
					parserlog << "Error at line " << yylineno << ": Non array value assigned to array \"" << $1.symbolinfo->getSymbol_name() << "\"\n\n";
					errorlog << "Error at line " << yylineno << ": Non array value assigned to array \"" << $1.symbolinfo->getSymbol_name() << "\"\n\n";
					parser_error_count++;
				}

				//void return type cannot be part of an expression
				if($1.symbolinfo->getVar_type()=="void" || $3.symbolinfo->getVar_type()=="void")
				{
					parserlog << "Error at line " << yylineno << ": Void return type cannot be part of an expression." << "\n\n";
					errorlog << "Error at line " << yylineno << ": Void return type cannot be part of an expression." << "\n\n";
					parser_error_count++;
				}
			}

			//cout << "\n\t" << string($1.var) << "\t" << string($1.var)

			if(string($1.type) == "VAR")
			{
				if(string($3.type) == "CONST")
				{
					CODE = CODE + "\tMOV " + $1.var + ", " + $3.var + "\n";
				}

				else if(string($3.type) == "VAR" || string($3.type) == "TEMP")
				{
					CODE = CODE + "\
	PUSH AX\n\
	MOV AX, " + $3.var + "\n\
	MOV " + $1.var + ", AX\n\
	POP AX\n";
				}

				$$.var = $1.var;
				$$.type = $1.type;
			}

			else if(string($1.type) == "ARRVAR")
			{
				if(string($3.type) == "CONST")
				{
					CODE = CODE + "\
	PUSH BX\n\
	MOV BX, " + $1.index + "\n\
	SAL BX, 1\n\
	MOV " + $1.var + "[BX], " + $3.var + "\n\
	POP BX\n";
				}

				else if(string($3.type) == "VAR" || string($3.type) == "TEMP")
				{
					CODE = CODE + "\
	PUSH AX\n\
	PUSH BX\n\
	MOV BX, " + $1.index + "\n\
	SAL BX, 1\n\
	MOV AX, " + $3.var + "\n\
	MOV " + $1.var + "[BX], AX\n\
	POP BX\n\
	POP AX\n";
				}

				$$.var = $1.var;
				$$.type = $1.type;
			}

			if(string($3.type) == "TEMP")	//make the temp var free to use
			{
				tvc--;
			}
		} 	
	   ;
			
logic_expression : rel_expression
		{
			$$.symbolinfo = $1.symbolinfo;
			$$.name = string_to_char_array(string($1.name));

			parserlog << "Line " << yylineno << ": logic_expression : rel_expression\n\n" << $$.name << "\n\n";

			$$.var = string_to_char_array(string($1.var));
			$$.type = string_to_char_array(string($1.type));
		}
		 | rel_expression LOGICOP rel_expression
		{
			$$.symbolinfo = $1.symbolinfo;
			//the result of RELOP and LOGICOP operation should be an integer
			$$.symbolinfo->setVar_type("int");
			$$.name = string_to_char_array(string($1.name)+$2->getSymbol_name()+string($3.name));

			parserlog << "Line " << yylineno << ": logic_expression : rel_expression LOGICOP rel_expression\n\n" << $$.name << "\n\n";

			//void return type cannot be part of an expression
			if($1.symbolinfo->getVar_type()=="void" || $3.symbolinfo->getVar_type()=="void")
			{
				parserlog << "Error at line " << yylineno << ": Void return type cannot be part of an expression." << "\n\n";
				errorlog << "Error at line " << yylineno << ": Void return type cannot be part of an expression." << "\n\n";
				parser_error_count++;
			}
		}
		 ;
			
rel_expression : simple_expression
		{
			$$.symbolinfo = $1.symbolinfo;
			$$.name = string_to_char_array(string($1.name));

			parserlog << "Line " << yylineno << ": rel_expression : simple_expression\n\n" << $$.name << "\n\n";

			$$.var = string_to_char_array(string($1.var));
			$$.type = string_to_char_array(string($1.type));
		}
		| simple_expression RELOP simple_expression
		{
			$$.symbolinfo = $1.symbolinfo;
			//the result of RELOP and LOGICOP operation should be an integer
			$$.symbolinfo->setVar_type("int");
			$$.name = string_to_char_array(string($1.name)+$2->getSymbol_name()+string($3.name));

			parserlog << "Line " << yylineno << ": rel_expression : simple_expression RELOP simple_expression\n\n" << $$.name << "\n\n";

			//void return type cannot be part of an expression
			if($1.symbolinfo->getVar_type()=="void" || $3.symbolinfo->getVar_type()=="void")
			{
				parserlog << "Error at line " << yylineno << ": Void return type cannot be part of an expression." << "\n\n";
				errorlog << "Error at line " << yylineno << ": Void return type cannot be part of an expression." << "\n\n";
				parser_error_count++;
			}
		}
		;
				
simple_expression : term 
		{
			$$.symbolinfo = $1.symbolinfo;
			$$.name = string_to_char_array(string($1.name));

			parserlog << "Line " << yylineno << ": simple_expression : term\n\n" << $$.name << "\n\n";

			$$.var = string_to_char_array(string($1.var));
			$$.type = string_to_char_array(string($1.type));
		}
		  | simple_expression ADDOP term
		{
			$$.symbolinfo = $1.symbolinfo;
			$$.name = string_to_char_array(string($1.name)+$2->getSymbol_name()+string($3.name));

			parserlog << "Line " << yylineno << ": simple_expression : simple_expression ADDOP term\n\n" << $$.name << "\n\n";

			//void return type cannot be part of an expression
			if($1.symbolinfo->getVar_type()=="void" || $3.symbolinfo->getVar_type()=="void")
			{
				parserlog << "Error at line " << yylineno << ": Void return type cannot be part of an expression." << "\n\n";
				errorlog << "Error at line " << yylineno << ": Void return type cannot be part of an expression." << "\n\n";
				parser_error_count++;
			}

			//type casting
			if(($1.symbolinfo->getVar_type()=="float" && $3.symbolinfo->getVar_type()=="int"))
			{
				$$.symbolinfo = $1.symbolinfo;
			}

			if($3.symbolinfo->getVar_type()=="float" && $1.symbolinfo->getVar_type()=="int")
			{
				$$.symbolinfo = $3.symbolinfo;
			}

			CODE = CODE + "\
	PUSH AX\n\
	MOV AX, " + $1.var + "\n";

			if($2->getSymbol_name() == "+")
				CODE = CODE + "\
	ADD AX, " + $3.var + "\n";
			else if($2->getSymbol_name() == "-")
				CODE = CODE + "\
	SUB AX, " + $3.var + "\n";

			string temp;
			
			if(string($1.type) == "TEMP" && string($3.type) == "TEMP")
			{
				tvc--;
				temp = "t" + to_string(tvc);
			}
			else if(string($1.type) != "TEMP" && string($3.type) != "TEMP")
			{
				inc_tvc();
				temp = "t" + to_string(tvc);
			}
			else if(string($1.type) == "TEMP")
			{
				temp = string($1.var);
			}
			else if(string($3.type) == "TEMP")
			{
				temp = string($3.var);
			}
	
			CODE = CODE + "\
	MOV " + temp + ", AX\n\
	POP AX\n";

			$$.var = string_to_char_array(string(temp));
			$$.type = string_to_char_array(string("TEMP"));
		}
		  ;
					
term :	unary_expression
		{
			$$.symbolinfo = $1.symbolinfo;
			$$.name = string_to_char_array(string($1.name));

			parserlog << "Line " << yylineno << ": term : unary_expression\n\n" << $$.name << "\n\n";

			$$.var = string_to_char_array(string($1.var));
			$$.type = string_to_char_array(string($1.type));
		}
     |  term MULOP unary_expression
		{
			$$.symbolinfo = $1.symbolinfo;
			$$.name = string_to_char_array(string($1.name)+$2->getSymbol_name()+string($3.name));

			parserlog << "Line " << yylineno << ": term : term MULOP unary_expression\n\n" << $$.name << "\n\n";

			//both operands of modulus (%) should be integers
			if($2->getSymbol_name() == "%" && (($1.symbolinfo->getVar_type() != "int") || ($3.symbolinfo->getVar_type() != "int")))
			{
				parserlog << "Error at line " << yylineno << ": Both operands of the modulus (%) operator should be integers." << "\n\n";
				errorlog << "Error at line " << yylineno << ": Both operands of the modulus (%) operator should be integers." << "\n\n";
				parser_error_count++;
			}

			//Modulus by Zero
			if($2->getSymbol_name() == "%" && (($1.symbolinfo->getSymbol_type() == "CONST_INT" && atoi($1.symbolinfo->getSymbol_name().c_str())==0) || ($3.symbolinfo->getSymbol_type() == "CONST_INT" && atoi($3.symbolinfo->getSymbol_name().c_str())==0)))
			{
				parserlog << "Error at line " << yylineno << ": Modulus by Zero" << "\n\n";
				errorlog << "Error at line " << yylineno << ": Modulus by Zero" << "\n\n";
				parser_error_count++;
			}

			//void return type cannot be part of an expression
			if($1.symbolinfo->getVar_type()=="void" || $3.symbolinfo->getVar_type()=="void")
			{
				parserlog << "Error at line " << yylineno << ": Void return type cannot be part of an expression." << "\n\n";
				errorlog << "Error at line " << yylineno << ": Void return type cannot be part of an expression." << "\n\n";
				parser_error_count++;
			}

			//type casting during '*' or '/' operation
			if($2->getSymbol_name() != "%")
			{
				if(($1.symbolinfo->getVar_type()=="float" && $3.symbolinfo->getVar_type()=="int"))
				{
					$$.symbolinfo = $1.symbolinfo;
				}

				if($3.symbolinfo->getVar_type()=="float" && $1.symbolinfo->getVar_type()=="int")
				{
					$$.symbolinfo = $3.symbolinfo;
				}
			}

			if($2->getSymbol_name() == "*")
			{
				//Since the operand of IMUL/IDIV cannot be constant; we keep the variable as the operand of IMUL/IDIV
				if(string($1.type) == "VAR" || string($1.type) == "TEMP")
				{
					CODE += "\
	MOV AX, " + string($3.var) + "\n\
	IMUL " + string($1.var) + "\n";
				}

				else if(string($3.type) == "VAR" || string($3.type) == "TEMP")
				{
					CODE += "\
	MOV AX, " + string($1.var) + "\n\
	IMUL " + string($3.var) + "\n";
				}

				else if(string($3.type) == "CONST" || string($3.type) == "CONST")	//need two registers in this case
				{
					CODE += "\
	MOV AX, " + string($1.var) + "\n\
	MOV BX, " + string($3.var) + "\n\
	IMUL BX" + "\n";
				}
			}

			else
			//we cannot switch the operators during division, so keeping the first operator in AX
			{
				CODE += "\
	MOV AX, " + string($1.var) + "\n\
	CWD\n";
				if(string($3.type) == "VAR" || string($3.type) == "TEMP")	//can directly IDIV, no register is needed
					CODE += "\tIDIV " + string($3.var) + "\n";
				else
					CODE += "\
	MOV BX, " + string($3.var) + "\n\
	IDIV BX\n";
			}
			
			string temp;
			
			if(string($1.type) == "TEMP" && string($3.type) == "TEMP")
			{
				tvc--;
				temp = "t" + to_string(tvc);
			}
			else if(string($1.type) != "TEMP" && string($3.type) != "TEMP")
			{
				inc_tvc();
				temp = "t" + to_string(tvc);
			}
			else if(string($1.type) == "TEMP")
			{
				temp = string($1.var);
			}
			else if(string($3.type) == "TEMP")
			{
				temp = string($3.var);
			}

			if($2->getSymbol_name() == "%")		//DX keeps the remainder after division
				CODE += "\tMOV " + temp + ", DX\n";
			else
				CODE += "\tMOV " + temp + ", AX\n";

			$$.var = string_to_char_array(string(temp));
			$$.type = string_to_char_array(string("TEMP"));
		}
     ;

unary_expression : ADDOP unary_expression
		{
			$$.symbolinfo = $2.symbolinfo;
			$$.name = string_to_char_array($1->getSymbol_name() + string($2.name));

			parserlog << "Line " << yylineno << ": unary_expression : ADDOP unary_expression\n\n" << $$.name << "\n\n";

			string CUR_CODE = "";

			if($1->getSymbol_name() == "-")
			{
				if(string($2.type) == "CONST")
				{
					//converts the char array to int, then multiplies it by -1, converts it back to char array
					//this helps handle cases like --2 or +++3
					$$.var = string_to_char_array(to_string(atoi($2.var)*-1));
					$$.type = string_to_char_array("CONST");
				}

				else if(string($2.type) == "TEMP")
				{
					CUR_CODE = CUR_CODE + "\tNEG " + $2.var + "\n";	//negate the value

					$$.var = string_to_char_array(string($2.var));
					$$.type = string_to_char_array("TEMP");
				}

				else if(string($2.type) == "VAR")
				{
					inc_tvc();	//need new temp var to store this expression
					string temp = "t" + to_string(tvc);

					//since mem to mem operation is illegal, store the variable in register AX first, then move it to temp var
					CUR_CODE = CUR_CODE + "\tMOV AX, " + string($2.var) + "\n" + "\tMOV " + temp + ", AX\n";
					CUR_CODE = CUR_CODE + "\tNEG " + temp + "\n";	//negate the value

					$$.var = string_to_char_array(temp);
					$$.type = string_to_char_array("TEMP");
				}

				/*	since we replace a[n] with a temporary vairable, this case is no longer needed
				else if(string($2.type) == "ARRVAR")
				{
					inc_tvc();	//need new temp var to store this expression
					string temp = "t" + to_string(tvc);

					//get the value at the given index
					CUR_CODE = CUR_CODE + "\tMOV BX, " + string($2.index) + "\n";
					CUR_CODE = CUR_CODE + "\tSAL BX, 1\n";		//we are using word arrays, each word takes 2 bytes
					//since mem to mem operation is illegal, store the variable in register AX first, then move it to temp var
					CUR_CODE = CUR_CODE + "\tMOV AX, " + string($2.var) + "[BX]\n" + "\tMOV " + temp + ", AX\n";
					CUR_CODE = CUR_CODE + "\tNEG " + temp + "\n";	//negate the value

					$$.var = string_to_char_array(temp);
					$$.type = string_to_char_array("TEMP");
					$$.index = string_to_char_array(string($2.index));
					$$.index_type = string_to_char_array(string($2.index_type));
				}*/
			}

			$$.code = string_to_char_array(CUR_CODE);
		}  
		 | NOT unary_expression 
		{
			$$.symbolinfo = $2.symbolinfo;
			$$.name = string_to_char_array("!"+string($2.name));

			parserlog << "Line " << yylineno << ": unary_expression : NOT unary_expression\n\n" << $$.name << "\n\n";
		}
		 | factor
		{
			$$.symbolinfo = $1.symbolinfo;
			$$.name = string_to_char_array(string($1.name));

			parserlog << "Line " << yylineno << ": unary_expression : factor\n\n" << $$.name << "\n\n";

			$$.var = string_to_char_array(string($1.var));
			$$.type = string_to_char_array(string($1.type));

			/*if(string($1.type) == "ARRVAR")
			{
				$$.index = string_to_char_array(string($1.index));
				$$.index_type = string_to_char_array(string($1.index_type));
			}*/
		}
		 ;
	
factor : variable 
	{	//variable may be undeclared, handled in the rules of variable
		$$.symbolinfo = $1.symbolinfo;
		$$.name = string_to_char_array($1.name);

		parserlog << "Line " << yylineno << ": factor : variable\n\n" << $$.name << "\n\n";

		$$.var = string_to_char_array(string($1.var));
		$$.type = string_to_char_array(string($1.type));

		string CUR_CODE = "";

		//if the variable is variable of an array then put it in a temp var
		if(string($1.type) == "ARRVAR")
		{
			inc_tvc();
			string temp = "t" + to_string(tvc);

			CUR_CODE = CUR_CODE + "\tMOV BX, " + string($1.index) + "\n" + "\tSAL BX, 1\n";
			CUR_CODE = CUR_CODE + "\tMOV AX, " + string($1.var) + "[BX]\n" + "\tMOV " + temp + ", AX\n";
		
			$$.var = string_to_char_array(string(temp));
			$$.type = string_to_char_array(string("TEMP"));
		}

		$$.code = string_to_char_array(CUR_CODE);
	}
	| ID LPAREN argument_list RPAREN
	{
		$$.symbolinfo = $1;
		$$.name = string_to_char_array($1->getSymbol_name() + "(" + string($3.name) + ")");

		parserlog << "Line " << yylineno << ": factor : ID LPAREN argument_list RPAREN\n\n" << $$.name << "\n\n";

		SymbolInfo* s = table->Lookup($1->getSymbol_name());
		
		//function call
		//check whether the function was declared
		if(!s)
		{
			parserlog << "Error at line " << yylineno << ": Function \"" << $1->getSymbol_name() << "\" has to be declared before being called.\n\n";
			errorlog << "Error at line " << yylineno << ": Function \"" << $1->getSymbol_name() << "\" has to be declared before being called.\n\n";
			parser_error_count++;
			variables.clear();
		}
		
		//since the spec says a function should be declared OR defined before it is called, definition isn't must
/*
		//check whether the function was defined
		else if( ! s->getDefined() )
		{
			parserlog << "Error at line " << yylineno << ": Function \"" << s->getSymbol_name() << "\" was declared, but not defined.\n\n";
			errorlog << "Error at line " << yylineno << ": Function \"" << s->getSymbol_name() << "\" was declared, but not defined.\n\n";
			parser_error_count++;
			variables.clear();
		}
*/

		else
		{
			//if the variable is declared then replace with the one in the symbol table
			$$.symbolinfo = s;
			
			//check whether the given id is indeed a function
			if(s->getVar_category() != "FUNCTION")
			{
				parserlog << "Error at line " << yylineno << ": Variable \"" << s->getSymbol_name() << "\" is not a function.\n\n";
				errorlog << "Error at line " << yylineno << ": Variable \"" << s->getSymbol_name() << "\" is not a function.\n\n";
				parser_error_count++;
				variables.clear();
			}

			else
			{
/*
				if(s->getVar_type() == "void")
				{
					parserlog << "Error at line " << yylineno << ": Void return type cannot be part of an expression." << "\n\n";
					errorlog << "Error at line " << yylineno << ": Void return type cannot be part of an expression." << "\n\n";
					parser_error_count++;
				}
*/

				//check number of parameters
				if(variables.size() != s->getParameter_list().size())
				{
					parserlog << "Error at line " << yylineno << " : function \"" << s->getSymbol_name() << "\" has " << s->getParameter_list().size() << " parameters in declaration but " << variables.size() << " parameters in function call!\n\n";
					errorlog << "Error at line " << yylineno << " : function \"" << s->getSymbol_name() << "\" has " << s->getParameter_list().size() << " parameters in declaration but " << variables.size() << " parameters in function call!\n\n";
					parser_error_count++;
					variables.clear();
				}

				else
				{
					std::vector<SymbolInfo*> declar_parameter_list = s->getParameter_list();

					//check parameter sequence
					for(int i=0; i<variables.size(); i++)
					{
						//check datatype of i-th parameter
						if(variables[i]->getVar_type() != declar_parameter_list[i]->getVar_type())
						{
							if(variables[i]->getVar_type() == "")	//if the variable was not declared
							{
								parserlog << "Error at line " << yylineno << " : function \"" << s->getSymbol_name() << "\" Parameter " << (i+1) << ": variable is undeclared.\n\n";
							errorlog << "Error at line " << yylineno << " : function \"" << s->getSymbol_name() << "\" Parameter " << (i+1) << ": variable is undeclared.\n\n";
							parser_error_count++;
							}

							else if(variables[i]->getVar_type() == "int" && declar_parameter_list[i]->getVar_type() == "float")
							{
								//int to float type casting is allowed, so don't report an error
							}
							
							else
							{
								parserlog << "Error at line " << yylineno << " : function \"" << s->getSymbol_name() << "\" Parameter data type mismatch at parameter " << (i+1) << ": data type is \"" << declar_parameter_list[i]->getVar_type() << "\" in declaration but \"" << variables[i]->getVar_type() << "\" in function call!\n\n";
								errorlog << "Error at line " << yylineno << " : function \"" << s->getSymbol_name() << "\" Parameter data type mismatch at parameter " << (i+1) << ": data type is \"" << declar_parameter_list[i]->getVar_type() << "\" in declaration but \"" << variables[i]->getVar_type() << "\" in function call!\n\n";
								parser_error_count++;
							}
						}

						//check array non array mismatch of i-th parameter
						//since the grammer does not allow arrays as function parameters, no need to deal with arrays
						if( !((variables[i]->getVar_category() == "VARIABLE" && declar_parameter_list[i]->getVar_category() == "VARIABLE")))
						{
							parserlog << "Error at line " << yylineno << " : function \"" << s->getSymbol_name() << "\"  attempted to assign non-array to array or vice versa at parameter " << (i+1) << "\n\n";
							errorlog << "Error at line " << yylineno << " : function \"" << s->getSymbol_name() << "\"  attempted to assign non-array to array or vice versa at parameter " << (i+1) << "\n\n";
							parser_error_count++;
						}
					}

					variables.clear();
				}
			}
		}
	}
	| LPAREN expression RPAREN
	{
		$$.symbolinfo = $2.symbolinfo;
		$$.name = string_to_char_array("("+string($2.name)+")");

		parserlog << "Line " << yylineno << ": factor : LPAREN expression RPAREN\n\n" << $$.name << "\n\n";

		$$.var = string_to_char_array(string($2.var));
		$$.type = string_to_char_array(string($2.type));
	}
	| CONST_INT
	{
		$$.symbolinfo = $1;
		$$.name = string_to_char_array($1->getSymbol_name());

		parserlog << "Line " << yylineno << ": factor : CONST_INT\n\n" << $$.name << "\n\n";

		$$.var = string_to_char_array($1->getSymbol_name());
		$$.type = string_to_char_array("CONST");
	}
	| CONST_FLOAT
	{
		$$.symbolinfo = $1;
		$$.name = string_to_char_array($1->getSymbol_name());

		parserlog << "Line " << yylineno << ": factor : CONST_FLOAT\n\n" << $$.name << "\n\n";
	}
	| variable INCOP
	{
		$$.symbolinfo = $1.symbolinfo;
		$$.name = string_to_char_array(string($1.name)+"++");

		parserlog << "Line " << yylineno << ": factor : variable INCOP\n\n" << $$.name << "\n\n";

		inc_tvc();
		string temp = "t" + to_string(tvc);

		string CUR_CODE = "";

		if(string($1.type) == "VAR")
		{
			CUR_CODE += "\
	MOV AX, " + string($1.var) + "\n\
	MOV " + temp + ", AX\n\
	INC " + string($1.var) + "\n";
		}

		else if(string($1.type) == "ARRVAR")
		{
			CUR_CODE += "\
	MOV BX, " + string($1.index) + "\n\
	SAL BX, 1\n\
	MOV AX, " + string($1.var) + "[BX]\n\
	MOV " + temp + ", AX\n\
	INC " + string($1.var) + "[BX]\n";
		}

		$$.var = string_to_char_array(temp);
		$$.type = string_to_char_array(string("TEMP"));
		$$.code = string_to_char_array(CUR_CODE);
	}
	| variable DECOP 
	{
		$$.symbolinfo = $1.symbolinfo;
		$$.name = string_to_char_array(string($1.name)+"--");

		parserlog << "Line " << yylineno << ": factor : variable DECOP\n\n" << $$.name << "\n\n";

		inc_tvc();
		string temp = "t" + to_string(tvc);

		string CUR_CODE;

		if(string($1.type) == "VAR")
		{
			CUR_CODE = "\
	MOV AX, " + string($1.var) + "\n\
	MOV " + temp + ", AX\n\
	DEC " + string($1.var) + "\n";
		}

		else if(string($1.type) == "ARRVAR")
		{
			CUR_CODE = "\
	MOV BX, " + string($1.index) + "\n\
	SAL BX, 1\n\
	MOV AX, " + string($1.var) + "[BX]\n\
	MOV " + temp + ", AX\n\
	DEC " + string($1.var) + "[BX]\n";
		}

		$$.var = string_to_char_array(temp);
		$$.type = string_to_char_array(string("TEMP"));
		$$.code = string_to_char_array(CUR_CODE);
	}
	;
	
argument_list : arguments
		{
			$$.name = string_to_char_array(string($1.name));
			parserlog << "Line " << yylineno << ": argument_list : arguments\n\n" << $$.name << "\n\n";
		}
		|
		{
			$$.name = string_to_char_array("");
			parserlog << "Line " << yylineno << ": argument_list : \n\n" << $$.name << "\n\n";

			variables.clear();	//empty parameter list
		}
		;
	
arguments : arguments COMMA logic_expression
		{
			$$.name = string_to_char_array(string($1.name) + "," + string($3.name));
			parserlog << "Line " << yylineno << ": arguments : arguments COMMA logic_expression\n\n" << $$.name << "\n\n";

			//save the data type, we will need it in factor -> ID LPAREN argument_list RPAREN to compare function call
			//with function definition
			if($3.symbolinfo->getVar_category() == "ARRAY")
				save_variable($3.symbolinfo, "ARRAY", $3.symbolinfo->getArray_length());
			else
				save_variable($3.symbolinfo, "VARIABLE");
		}
	      | logic_expression
		{
			$$.name = string_to_char_array(string($1.name));
			parserlog << "Line " << yylineno << ": arguments : logic_expression\n\n" << $$.name << "\n\n";

			variables.clear();	//empty the variables vector

			//save the data type, we will need it in factor -> ID LPAREN argument_list RPAREN to compare function call
			//with function definition
			if($1.symbolinfo->getVar_category() == "ARRAY")
				save_variable($1.symbolinfo, "ARRAY", $1.symbolinfo->getArray_length());
			else
				save_variable($1.symbolinfo, "VARIABLE");
		}
	      ;

%%
int main(int argc,char *argv[])
{

	if((fp=fopen(argv[1],"r"))==NULL)
	{
		printf("Cannot Open Input File.\n");
		exit(1);
	}
	
	variables.clear();

	yyin=fp;
	yyparse();

	table->Print_All_ScopeTable();

	FinalizeAssemblyCode();

	parserlog << "Total Lines: " << yylineno-1 << "\nTotal Errors: " << parser_error_count;
	errorlog << "Total Errors: " << parser_error_count;

	fclose(fp);
	parserlog.close();
	errorlog.close();
	
	return 0;
}

