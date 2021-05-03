#ifndef SYMBOLTABLE_H_INCLUDED
#define SYMBOLTABLE_H_INCLUDED

#include "ScopeTable.h"

class SymbolTable
{
private:
	ScopeTable* current_scopeTable;
	//num of buckets in each hashtable
	int n;

public:
	SymbolTable(int n);
	void Enter_Scope();
	void Exit_Scope();
	bool Insert(std::string symbol_name, std::string symbol_type);
	bool Insert(std::string symbol_name, std::string symbol_type, std::string symbol_var_type, std::string symbol_var_category);
	bool Insert(std::string symbol_name, std::string symbol_type, std::string symbol_var_type, int array_length);
	bool Insert(std::string symbol_name, std::string symbol_type, std::string symbol_var_type, std::vector<SymbolInfo*> parameter_list, bool defined);
	bool Remove(std::string symbol_name);
	SymbolInfo* Lookup(std::string symbol_name);
	std::string LookupScopeID(std::string symbol_name);	//returns the scope id of the scopeTable of a given variable

	std::string getCurrentScopeTableID();
	SymbolInfo** getCurrentScopeTableArray_symbolinfo();

	void Print_Current_ScopeTable();
	void Print_All_ScopeTable();

	~SymbolTable();
};

SymbolTable::SymbolTable(int n)
{
	this->n = n;
	current_scopeTable = NULL;
	Enter_Scope();
}

void SymbolTable::Enter_Scope()
{
	if(!current_scopeTable)
	{
		current_scopeTable = new ScopeTable(n);
		//current_scopeTable->setID(convert_scope_to_string(scope_level));
		current_scopeTable->setID("1");
		current_scopeTable->getParentScope() = NULL;

		//std::cout << "New ScopeTable with id " << current_scopeTable->getID() << " created\n";

		return;
	}

	ScopeTable* new_scopeTable = new ScopeTable(n);
	new_scopeTable->getParentScope() = current_scopeTable;
	new_scopeTable->setID(new_scopeTable->getParentScope()->getID() + "." + std::to_string(new_scopeTable->getParentScope()->getNumDeletedChildren() + 1));
	current_scopeTable = new_scopeTable;

	//std::cout << "\nNew ScopeTable with id " << current_scopeTable->getID() << " created\n";
	parserlog << "\tNew ScopeTable with id " << current_scopeTable->getID() << " created\n\n";
}

void SymbolTable::Exit_Scope()
{
	if(!current_scopeTable)
	{
		//std::cout << "No scope to exit from!\n";
		return;
	}

	ScopeTable* temp = current_scopeTable;
	current_scopeTable = current_scopeTable->getParentScope();
	//Increase the number of deleted children of the parent
	current_scopeTable->setNumDeletedChildren(current_scopeTable->getNumDeletedChildren() + 1);
	//std::cout << "Exited current scope!\n";

	//std::cout << "\nScopeTable with id " << temp->getID() << " removed\n";
	parserlog << "\tScopeTable with id " << temp->getID() << " removed\n\n";
}

bool SymbolTable::Insert(std::string symbol_name, std::string symbol_type)
{
	if(!current_scopeTable)
	{
		//std::cout << "No existing scope!\n";
		return false;
	}

	return current_scopeTable->Insert(symbol_name, symbol_type);
}

bool SymbolTable::Insert(std::string symbol_name, std::string symbol_type, std::string symbol_var_type, std::string symbol_var_category)
{
	if(!current_scopeTable)
	{
		//std::cout << "No existing scope!\n";
		return false;
	}

	return current_scopeTable->Insert(symbol_name, symbol_type, symbol_var_type, symbol_var_category);
}

bool SymbolTable::Insert(std::string symbol_name, std::string symbol_type, std::string symbol_var_type, int array_length)
{
	if(!current_scopeTable)
	{
		//std::cout << "No existing scope!\n";
		return false;
	}

	return current_scopeTable->Insert(symbol_name, symbol_type, symbol_var_type, array_length);
}

bool SymbolTable::Insert(std::string symbol_name, std::string symbol_type, std::string symbol_var_type, std::vector<SymbolInfo*> parameter_list, bool defined=false)
{
	if(!current_scopeTable)
	{
		//std::cout << "No existing scope!\n";
		return false;
	}

	return current_scopeTable->Insert(symbol_name, symbol_type, symbol_var_type, parameter_list, defined);
}

bool SymbolTable::Remove(std::string symbol_name)
{
	if(!current_scopeTable)
	{
		//std::cout << "No existing scope!\n";
		return false;
	}

	return current_scopeTable->Delete(symbol_name);
}

SymbolInfo* SymbolTable::Lookup(std::string symbol_name)
{
	if(!current_scopeTable)
	{
		//std::cout << "No existing scope!\n";
		return NULL;
	}

	ScopeTable* iter_scopetable = current_scopeTable;
	//assert(current_scopeTable->getParentScope() == NULL);

	while(iter_scopetable)
	{
	    //std::cout << "Inside symbol table lookup: searching in scope table " << iter_scopetable->getUid() << "\n";
		SymbolInfo* search_result = iter_scopetable->Lookup(symbol_name);

		if(search_result)
		{
			//std::cout << "Found in ScopeTable# " << iter_scopetable->getUid() << "\n";

			return search_result;
		}

		//std::cout << "Inside symbol table lookup: " << symbol_name << " not found in st " << iter_scopetable->getUid() << "\n";
		iter_scopetable = iter_scopetable->getParentScope();
	}

	//std::cout << "Found no result in any scope tables\n";
	//std::cout << symbol_name << " not found\n";
	return NULL;
}

std::string SymbolTable::LookupScopeID(std::string symbol_name)
{
	if(!current_scopeTable)
	{
		return NULL;
	}

	ScopeTable* iter_scopetable = current_scopeTable;

	while(iter_scopetable)
	{
		SymbolInfo* search_result = iter_scopetable->Lookup(symbol_name);

		if(search_result)
		{
			return iter_scopetable->getID();
		}

		iter_scopetable = iter_scopetable->getParentScope();
	}

	return "";
}

void SymbolTable::Print_Current_ScopeTable()
{
	current_scopeTable->Print();
}

void SymbolTable::Print_All_ScopeTable()
{
	ScopeTable* iter_scopetable = current_scopeTable;

	while(iter_scopetable)
	{
		iter_scopetable->Print();
		iter_scopetable = iter_scopetable->getParentScope();
		//std::cout << "\n";
		//logstream << "\n";
		parserlog << "\n";
	}
}

std::string SymbolTable::getCurrentScopeTableID()
{
	return current_scopeTable->getID();
}

SymbolInfo** SymbolTable::getCurrentScopeTableArray_symbolinfo()
{
	return current_scopeTable->getArray_symbolinfo();
}

SymbolTable::~SymbolTable()
{
	if(current_scopeTable)
		delete current_scopeTable;
}

#endif // SYMBOLTABLE_H_INCLUDED
