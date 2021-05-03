#ifndef ICG_HELPER_H_INCLUDED
#define ICG_HELPER_H_INCLUDED

//ofstream asmic("code.asm");

string MODEL = ".MODEL SMALL\n";
string STACK = ".STACK 100H\n";
string DATA = ".DATA\n";
string CODE = ".CODE\n";

int tvc = -1;	//current temporary variable count, temporary variables temporarily store values in expression
int max_tvc = tvc;		//total amount of temporary variables - 1, needed to declare all temporary variables in DATA segment

int lc = 0;		//label count, whenver a label is used, this variable is incremented

string getAsmVar(string varName, string varCat="VARIABLE")  //returns the corresponding assembly variable in current scope
{
    //get the id of the current scope table
    //string id = table->getCurrentScopeTableID();
	string id = table->LookupScopeID(varName);

    //replaces the dots in the id with underscore to make var name compatible
    for(int i=0; i<id.size(); i++)
    {
        if(id[i] == '.')
            id[i] = '_';
    }

    if(varCat == "VARIABLE")
        return "var_" + id + "_" + varName;

    return "arr_" + id + "_" + varName;
}

string getAsmVar(char* varName)  //returns the corresponding assembly variable in current scope
{
    return getAsmVar(string(varName));
}

void DeclareVariablesAsm(bool declareTempVar = false)
{
    //declares the variables in the current scope table in the DATA segment
    SymbolInfo** arr = table->getCurrentScopeTableArray_symbolinfo();

    for(int i=0; i<30; i++)	//total 30 buckets
    {
        SymbolInfo* iter = arr[i];

        //print only non empty brackets
        if(!iter)
            continue;

        while(iter)
        {
            if(iter->getVar_category() == "VARIABLE")
                DATA = DATA + "\t" + getAsmVar(iter->getSymbol_name()) + "\tDW" + "\t?\n";
            else if(iter->getVar_category() == "ARRAY")
                DATA = DATA + "\t" + getAsmVar(iter->getSymbol_name(), "ARRAY") + "\tDW\t" + to_string(iter->getArray_length()) + "\tDUP\t(?)\n";

            iter = iter->getNext_symbol_info();
        }
    }

	//declares the temporary variables in the DATA segment, skips if no temporary variables were used
	if(declareTempVar && max_tvc != -1)
		for(int i=-1; i<max_tvc; i++)
			DATA = DATA + "\t" + "t" + to_string(i+1) + "\tDW" + "\t?\n";
}

string newLabel()
{
	return "L" + to_string(lc++);
}

void inc_tvc()
{
	tvc++;
	max_tvc = max(tvc, max_tvc);
}

string getConditionalJumpCommand(string relop)
{
	if(relop == "<=")
		return "JNLE";

	if(relop == "<")
		return "JNL";

	if(relop == ">=")
		return "JNGE";

	if(relop == ">")
		return "JNG";

	if(relop == "==")
		return "JNE";

	if(relop == "!=")
		return "JE";
}

string getTemp(char* type1, char* type2, char* var1, char* var2)
{
	if(string(type1) == "TEMP" && string(type2) == "TEMP")
	{
		tvc--;
		return "t" + to_string(tvc);
	}
	else if(string(type1) != "TEMP" && string(type2) != "TEMP")
	{
		inc_tvc();
		return "t" + to_string(tvc);
	}
	else if(string(type1) == "TEMP")
	{
		return string(var1);
	}
	else if(string(type2) == "TEMP")
	{
		return string(var2);
	}
}

void FinalizeAssemblyCode()
{
	ofstream asmic("code.asm");
    asmic << MODEL << STACK << DATA << CODE;
    asmic.close();
}

#endif // ICG_HELPER_H_INCLUDED
