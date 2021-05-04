#ifndef PARSER_HELPER_H_INCLUDED
#define PARSER_HELPER_H_INCLUDED


char* string_to_char_array(string s)
{
	int len = strlen(s.c_str());
	char* ch = new char[len+1];
	//char* ch = (char*)malloc(sizeof(char) * len);

	for(int i=0; i<len; i++)	
	{
		ch[i] = s.c_str()[i];			
	}
	ch[len] = '\0';

	return (char *)ch;
}

SymbolInfo* Copy_Symbol(SymbolInfo* s)
{
	//makes a copy of the SymbolInfo pointer passed as parameter

	string name = s->getSymbol_name();
	string type = s->getSymbol_type();

	if(s->getVar_category() == "VARIABLE")
	{
		return new SymbolInfo(name, type, s->getVar_type(), s->getVar_category());
	}

	if(s->getVar_category() == "ARRAY")
	{
		return new SymbolInfo(name, type, s->getVar_type(), s->getArray_length());
	}

	if(s->getVar_category() == "FUNCTION")
	{
		return new SymbolInfo(name, type, s->getVar_type(), s->getParameter_list());
	}

	return new SymbolInfo(name, type);
}

vector<SymbolInfo*> variables;	//keeps record of variables in the declaration_list
								// and parameters in the parameter_list

void save_variable(SymbolInfo* var, string var_category)
{
	var->setVar_category(var_category);
	variables.push_back(var);
}

void save_variable(SymbolInfo* var, string var_category, int array_size)
{
	var->setVar_category(var_category);
	var->setArray_length(array_size);
	variables.push_back(var);
}

void insert_variables_into_symbol_table(string data_type)
{
	for(int i=0; i<variables.size(); i++)
	{
		string name = variables[i]->getSymbol_name();
		string type = variables[i]->getSymbol_type();

		if(variables[i]->getVar_category() == "VARIABLE")
		{
			bool inserted = table->Insert(name, type, data_type, "VARIABLE");

			if(!inserted)
			{
				parserlog << "Error at line " << yylineno << " : variable \"" << name << "\" already exists in current scope table!\n\n";
				errorlog << "Error at line " << yylineno << " : variable \"" << name << "\" already exists in current scope table!\n\n";
				parser_error_count++;
			}
		}

		else if(variables[i]->getVar_category() == "ARRAY")
		{
			int length = variables[i]->getArray_length();

			bool inserted = table->Insert(name, type, data_type, length);

			if(!inserted)
			{
				parserlog << "Error at line " << yylineno << " : variable \"" << name << "\" already exists in current scope table!\n\n";
				errorlog << "Error at line " << yylineno << " : variable \"" << name << "\" already exists in current scope table!\n\n";
				parser_error_count++;
			}
		}
	}

	variables.clear();
}

void insert_function_into_symbol_table(string name, string return_type, bool defined=false)
{
	bool inserted = table->Insert(name, "ID", return_type, variables, defined);

	if(!inserted)
	{
		SymbolInfo* s = table->Lookup(name);

		if(s->getVar_category() == "ARRAY" || s->getVar_category() == "VARIABLE")
		{
			parserlog << "Error at line " << yylineno << " : global variable \"" << name << "\" already exists in the symbol table!\n\n";
			errorlog << "Error at line " << yylineno << " : global variable \"" << name << "\" already exists in the symbol table!\n\n";
			parser_error_count++;
		}

		else if(s->getVar_category() == "FUNCTION")
		{
			parserlog << "Error at line " << yylineno << " : function \"" << name << "\" already exists in the symbol table!\n\n";
			errorlog << "Error at line " << yylineno << " : function \"" << name << "\" already exists in the symbol table!\n\n";
			parser_error_count++;
		}
	}

	//check whether there are parameters with no name
	if(defined)
		for(int i=0; i<variables.size(); i++)
		{
			if(variables[i]->getSymbol_name() == "")	//when the parameter name is not given
			{
				parserlog << "Error at line " << yylineno << " : function \"" << name << "\" Name of Parameter " << i+1 << " is not given in function definition.\n\n";
				errorlog << "Error at line " << yylineno << " : function \"" << name << "\" Name of Parameter " << i+1 << " is not given in function definition.\n\n";
				parser_error_count++;
			}
		}

	//report errors due to multiple parameters having same name
	//if(variables.size() != 0)
	for(int i=0; i < int(variables.size()-1); i++)	//type casted to int since variables.size()-1 is an unsigned int
	{
		for(int j=i+1; j<variables.size(); j++)
		{
			if(variables[i]->getSymbol_name() != "" && (variables[j]->getSymbol_name() == variables[i]->getSymbol_name()))
			{
				parserlog << "Error at line " << yylineno << " : function \"" << name << "\" Parameter " << i+1 << " and Parameter " << j+1 << " have same name \"" << variables[j]->getSymbol_name() << "\"\n\n";
				errorlog << "Error at line " << yylineno << " : function \"" << name << "\" Parameter " << i+1 << " and Parameter " << j+1 << " have same name \"" << variables[j]->getSymbol_name() << "\"\n\n";
				parser_error_count++;
			}
		}
	}

	//variables.clear();

/*
	parserlog << "\tPrinting parameters:\n";
	
	SymbolInfo* func = table->Lookup(name);

	vector<SymbolInfo*> args = func->getParameter_list();

	for(int i=0; i<args.size(); i++)
	{
		parserlog << args[i]->getVar_type() << "\t" << args[i]->getSymbol_name() << "\n";
	}
*/
}

void match_function_definition_and_declaration(string return_type, string name)
{
	//Check whether the function was declared before definition
	SymbolInfo* s = table->Lookup(name);
	
	//the function was not declared before
	if(s == NULL)
	{
		insert_function_into_symbol_table(name, return_type, true);
		current_function = name;	//save the function name, we need it in procedures to determine whether we should replace parameters with [BP+n] or not in getAsmVar()
		ret_n = variables.size() * 2;	//how many addition bytes to return in RET opcode, necessary because we are saving parameters in the stack
		return;
	}

	//the function was declared before

	//check whether the function was defined before
	if(s->getDefined())
	{
		parserlog << "Error at line " << yylineno << " : function \"" << name << "\" has already been defined.\n\n";
		errorlog << "Error at line " << yylineno << " : function \"" << name << "\" has already been defined.\n\n";
		parser_error_count++;
		//variables.clear();		
		return;
	}

	//check whether the given id belongs to a variable
	if(s->getVar_category() != "FUNCTION")
	{
		parserlog << "Error at line " << yylineno << " : variable \"" << name << "\" already exists in current scope table.\n\n";
		errorlog << "Error at line " << yylineno << " : variable \"" << name << "\" already exists in current scope table.\n\n";
		parser_error_count++;
		//variables.clear();		
		return;
	}

	//given id belongs to a function
	//check return type
	if(s->getVar_type() != return_type)
	{
		parserlog << "Error at line " << yylineno << " : function \"" << name << "\" has return type \"" << s->getVar_type() << "\" in declaration but \"" << return_type << "\" in defintion!\n\n";
		errorlog << "Error at line " << yylineno << " : function \"" << name << "\" has return type \"" << s->getVar_type() << "\" in declaration but \"" << return_type << "\" in defintion!\n\n";
		parser_error_count++;
		//variables.clear();
		return;
	}

	//check number of parameters
	if(variables.size() != s->getParameter_list().size())
	{
		parserlog << "Error at line " << yylineno << " : function \"" << name << "\" has " << s->getParameter_list().size() << " parameters in declaration but " << variables.size() << " parameters in defintion!\n\n";
		errorlog << "Error at line " << yylineno << " : function \"" << name << "\" has " << s->getParameter_list().size() << " parameters in declaration but " << variables.size() << " parameters in defintion!\n\n";
		parser_error_count++;
		//variables.clear();		
		return;
	}

	std::vector<SymbolInfo*> declar_parameter_list = s->getParameter_list();

	int current_error_count = parser_error_count;	//to check whether the function is properly defined

	//check parameter sequence
	for(int i=0; i<variables.size(); i++)
	{
		//check datatype of i-th parameter
		if(variables[i]->getVar_type() != declar_parameter_list[i]->getVar_type())
		{
			parserlog << "Error at line " << yylineno << " : function \"" << name << "\" Parameter data type mismatch at parameter " << (i+1) << ": data type is \"" << declar_parameter_list[i]->getVar_type() << "\" in declaration but \"" << variables[i]->getVar_type() << "\" in defintion!\n\n";
			errorlog << "Error at line " << yylineno << " : function \"" << name << "\" Parameter data type mismatch at parameter " << (i+1) << ": data type is \"" << declar_parameter_list[i]->getVar_type() << "\" in declaration but \"" << variables[i]->getVar_type() << "\" in defintion!\n\n";
			parser_error_count++;
		}
		
		//check parameter name of i-th parameter
		if(declar_parameter_list[i]->getSymbol_name() != "" && variables[i]->getSymbol_name() != declar_parameter_list[i]->getSymbol_name())
		{
			parserlog << "Error at line " << yylineno << " : function \"" << name << "\" Parameter name mismatch at parameter " << (i+1) << ": parameter name is \"" << declar_parameter_list[i]->getSymbol_name() << "\" in declaration but \"" << variables[i]->getSymbol_name() << "\" in defintion!\n\n";
			errorlog << "Error at line " << yylineno << " : function \"" << name << "\" Parameter name mismatch at parameter " << (i+1) << ": parameter name is \"" << declar_parameter_list[i]->getSymbol_name() << "\" in declaration but \"" << variables[i]->getSymbol_name() << "\" in defintion!\n\n";
			parser_error_count++;
		}
	}

	if(current_error_count == parser_error_count)	//means the function was properly defined i.e. function definition is consistent with declaration
	{
		s->isDefined(true);
	}
/*	
	if(parser_error_count == 0)
		//since we are defining the function here, we have to insert the parameters into symbol table
		for(int i=0; i<variables.size(); i++)
		{
			table->Insert(variables[i]->getSymbol_name(), variables[i]->getSymbol_type(), variables[i]->getVar_type(), "VARIABLE");
		}
*/

	//variables.clear();

	current_function = name;	//save the function name, we need it in procedures to determine whether we should replace parameters with [BP+n] or not in getAsmVar()
	ret_n = declar_parameter_list.size() * 2;	//how many addition bytes to return in RET opcode, necessary because we are saving parameters in the stack
}

void Enter_scope()
{
	table->Enter_Scope();

	//insert new variables into the symbol tables, these are the arguments of functions
	for(int i=0; i<variables.size(); i++)
	{
		if(variables[i]->getSymbol_name() != "")	//when the parameter name is given
		{
			table->Insert(variables[i]->getSymbol_name(), variables[i]->getSymbol_type(), variables[i]->getVar_type(), "VARIABLE");
			SymbolInfo* s = table->Lookup(variables[i]->getSymbol_name());
			s->setIs_Parameter(true);
			s->setParameter_index(((variables.size()+1)-i)*2);	//multiplied by 2 since we are using word variables
		}
	}

	variables.clear();
}

void Exit_scope()
{
	//print the scope table just before exiting current scope as per instruction
	table->Print_All_ScopeTable();

	DeclareVariablesAsm();

	table->Exit_Scope();
}

SymbolInfo* Lookup_Symbol(string name)
{
	return table->Lookup(name);
}


#endif // PARSER_HELPER_H_INCLUDED
