#ifndef SCOPETABLE_H_INCLUDED
#define SCOPETABLE_H_INCLUDED
#define DEBUG true
#include "SymbolInfo.h"

class ScopeTable
{
private:
	//num of buckets and unique id
	int n;
	std::string id;
	//keeps track of total number of scopetables, necessary for assigning unique value
	SymbolInfo **array_symbolinfo;
	ScopeTable* parentScope;
	//keeps record of number of deleted children, necessary for new child's id
	int num_deleted_children;

	unsigned long hash_function(std::string key);

public:
	ScopeTable(int n);
	bool Insert(std::string symbol_name, std::string symbol_type);
	bool Insert(std::string symbol_name, std::string symbol_type, std::string symbol_var_type, std::string symbol_var_category);
	bool Insert(std::string symbol_name, std::string symbol_type, std::string symbol_var_type, int array_length);
	bool Insert(std::string symbol_name, std::string symbol_type, std::string symbol_var_type, std::vector<SymbolInfo*> parameter_list, bool defined);
	SymbolInfo* Lookup(std::string symbol_name);
	bool Delete(std::string symbol_name);
	void Print();
	ScopeTable*& getParentScope();

	std::string getID();
	void setID(std::string id);

	SymbolInfo ** getArray_symbolinfo();

	void setNumDeletedChildren(int n);
	int getNumDeletedChildren();
	~ScopeTable();
};

unsigned long ScopeTable::hash_function(std::string key)
{
    unsigned long hash_value = 0;

	for(int i=0; i<key.size(); i++)
		hash_value += key[i];

	return hash_value;
}

ScopeTable::ScopeTable(int n)
{
	this->n = n;
	this->id = id;
	array_symbolinfo = new SymbolInfo*[n];

	for(int i=0; i<n; i++)
    {
        array_symbolinfo[i] = NULL;
    }

	parentScope = NULL;
	num_deleted_children = 0;
}

bool ScopeTable::Insert(std::string symbol_name, std::string symbol_type)
{
    //if(DEBUG)   std::cout << "Entered Insert of scopetable.\n";

	if(Lookup(symbol_name))
	{
		//std::cout << symbol_name << " already exists in current ScopeTable\n";
		//logstream << symbol_name << " already exists in current ScopeTable\n";
		//parserlog << symbol_name << " already exists in current ScopeTable\n";
		return false;
	}

	//Symbol name does not exist, time for insertion
	int index = hash_function(symbol_name) % n;
	SymbolInfo* iter = array_symbolinfo[index];
	int chain_index = 0;

	//first entry for the particular hash value
	if(!iter || iter->getSymbol_name()=="")
	{
		SymbolInfo* new_symbolinfo = new SymbolInfo(symbol_name, symbol_type);

		array_symbolinfo[index] = new_symbolinfo;
		array_symbolinfo[index]->getNext_symbol_info() = NULL;

		//std::cout << "Inserted in ScopeTable# " << id << " at position " << index << ", " << chain_index << "\n";
		return true;
	}

	chain_index++;

	//iterate the chain to find the last element
	while(iter->getNext_symbol_info())
	{
		iter = iter->getNext_symbol_info();
		chain_index++;
	}

	//last entry in the chain found, time for insertion
	SymbolInfo* new_symbolinfo = new SymbolInfo(symbol_name, symbol_type);

	iter->getNext_symbol_info() = new_symbolinfo;
	new_symbolinfo->getNext_symbol_info() = NULL;

	//std::cout << "Inserted in ScopeTable# " << id << " at position " << index << ", " << chain_index << "\n";
	return true;
}

bool ScopeTable::Insert(std::string symbol_name, std::string symbol_type, std::string symbol_var_type, std::string symbol_var_category)
{
    //if(DEBUG)   std::cout << "Entered Insert of scopetable.\n";

	if(Lookup(symbol_name))
	{
		//std::cout << symbol_name << " already exists in current ScopeTable\n";
		//logstream << symbol_name << " already exists in current ScopeTable\n";
		//parserlog << symbol_name << " already exists in current ScopeTable\n";
		return false;
	}

	//Symbol name does not exist, time for insertion
	int index = hash_function(symbol_name) % n;
	SymbolInfo* iter = array_symbolinfo[index];
	int chain_index = 0;

	//first entry for the particular hash value
	if(!iter || iter->getSymbol_name()=="")
	{
		SymbolInfo* new_symbolinfo = new SymbolInfo(symbol_name, symbol_type, symbol_var_type, symbol_var_category);

		array_symbolinfo[index] = new_symbolinfo;
		array_symbolinfo[index]->getNext_symbol_info() = NULL;

		//std::cout << "Inserted in ScopeTable# " << id << " at position " << index << ", " << chain_index << "\n";
		return true;
	}

	chain_index++;

	//iterate the chain to find the last element
	while(iter->getNext_symbol_info())
	{
		iter = iter->getNext_symbol_info();
		chain_index++;
	}

	//last entry in the chain found, time for insertion
	SymbolInfo* new_symbolinfo = new SymbolInfo(symbol_name, symbol_type, symbol_var_type, symbol_var_category);

	iter->getNext_symbol_info() = new_symbolinfo;
	new_symbolinfo->getNext_symbol_info() = NULL;

	//std::cout << "Inserted in ScopeTable# " << id << " at position " << index << ", " << chain_index << "\n";
	return true;
}

bool ScopeTable::Insert(std::string symbol_name, std::string symbol_type, std::string symbol_var_type, int array_length)
{
    //if(DEBUG)   std::cout << "Entered Insert of scopetable.\n";

	if(Lookup(symbol_name))
	{
		//std::cout << symbol_name << " already exists in current ScopeTable\n";
		//logstream << symbol_name << " already exists in current ScopeTable\n";
		//parserlog << symbol_name << " already exists in current ScopeTable\n";
		return false;
	}

	//Symbol name does not exist, time for insertion
	int index = hash_function(symbol_name) % n;
	SymbolInfo* iter = array_symbolinfo[index];
	int chain_index = 0;

	//first entry for the particular hash value
	if(!iter || iter->getSymbol_name()=="")
	{
		SymbolInfo* new_symbolinfo = new SymbolInfo(symbol_name, symbol_type, symbol_var_type, array_length);

		array_symbolinfo[index] = new_symbolinfo;
		array_symbolinfo[index]->getNext_symbol_info() = NULL;

		//std::cout << "Inserted in ScopeTable# " << id << " at position " << index << ", " << chain_index << "\n";
		return true;
	}

	chain_index++;

	//iterate the chain to find the last element
	while(iter->getNext_symbol_info())
	{
		iter = iter->getNext_symbol_info();
		chain_index++;
	}

	//last entry in the chain found, time for insertion
	SymbolInfo* new_symbolinfo = new SymbolInfo(symbol_name, symbol_type, symbol_var_type, array_length);

	iter->getNext_symbol_info() = new_symbolinfo;
	new_symbolinfo->getNext_symbol_info() = NULL;

	//std::cout << "Inserted in ScopeTable# " << id << " at position " << index << ", " << chain_index << "\n";
	return true;
}

bool ScopeTable::Insert(std::string symbol_name, std::string symbol_type, std::string symbol_var_type, std::vector<SymbolInfo*> parameter_list, bool defined=false)
{
    //if(DEBUG)   std::cout << "Entered Insert of scopetable.\n";

	if(Lookup(symbol_name))
	{
		//std::cout << symbol_name << " already exists in current ScopeTable\n";
		//logstream << symbol_name << " already exists in current ScopeTable\n";
		//parserlog << symbol_name << " already exists in current ScopeTable\n";
		return false;
	}

	//Symbol name does not exist, time for insertion
	int index = hash_function(symbol_name) % n;
	SymbolInfo* iter = array_symbolinfo[index];
	int chain_index = 0;

	//first entry for the particular hash value
	if(!iter || iter->getSymbol_name()=="")
	{
		SymbolInfo* new_symbolinfo = new SymbolInfo(symbol_name, symbol_type, symbol_var_type, parameter_list, defined);

		array_symbolinfo[index] = new_symbolinfo;
		array_symbolinfo[index]->getNext_symbol_info() = NULL;

		//std::cout << "Inserted in ScopeTable# " << id << " at position " << index << ", " << chain_index << "\n";
		return true;
	}

	chain_index++;

	//iterate the chain to find the last element
	while(iter->getNext_symbol_info())
	{
		iter = iter->getNext_symbol_info();
		chain_index++;
	}

	//last entry in the chain found, time for insertion
	SymbolInfo* new_symbolinfo = new SymbolInfo(symbol_name, symbol_type, symbol_var_type, parameter_list, defined);

	iter->getNext_symbol_info() = new_symbolinfo;
	new_symbolinfo->getNext_symbol_info() = NULL;

	//std::cout << "Inserted in ScopeTable# " << id << " at position " << index << ", " << chain_index << "\n";
	return true;
}


SymbolInfo* ScopeTable::Lookup(std::string symbol_name)
{
	int index = hash_function(symbol_name) % n;

	SymbolInfo* iter = array_symbolinfo[index];
	//find the position of search element in the chain
	int chain_index = 0;

	//if(DEBUG)   std::cout << "Entered Lookup of scopetable.\n";

	while(iter)
	{
	    //if(iter)    std::cout << "Entered loop of Lookup of scopetable.\n";

		if(iter->getSymbol_name() == symbol_name)
		{
			//std::cout << "Found in ScopeTable# " << id << " at position " << index << ", " << chain_index << "\n";
			return iter;
		}

		iter = iter->getNext_symbol_info();
		chain_index++;
	}

	//std::cout << "Found no match in scope table " << id << " for " << symbol_name << "\n";
	return iter;
}

bool ScopeTable::Delete(std::string symbol_name)
{
	if(!Lookup(symbol_name))
	{
		//std::cout << symbol_name << " not found! Deletion aborted.\n";
		return false;
	}

	//Symbol name exists, time for deletion
	int index = hash_function(symbol_name) % n;

	//prev is the previous item of the item to be deleted
	SymbolInfo* prev = NULL;
	SymbolInfo* iter = array_symbolinfo[index];

	//iterate the chain to find the element to be deleted
	while(iter)
	{
		if(iter->getSymbol_name() == symbol_name)
		{
			//std::cout << "Deleting " << symbol_name << "\n";

			//In case the item to be deleted is the first one in the chain
			if(!prev)
			{
				//In case iter is the only element in the chain
				if(iter->getNext_symbol_info() == NULL)
				{
					array_symbolinfo[index] = NULL;
				}

				//Replace the iter with the next element on the chain
				else
				{
					array_symbolinfo[index] = iter->getNext_symbol_info();
				}

				//std::cout << "Deletion successful!\n";

				//this->Print();
                //std::cout << "Printed scope table inside st " << id << "\n";
				return true;
			}

			prev->getNext_symbol_info() = iter->getNext_symbol_info();

			//std::cout << "Deletion successful!\n";

			//std::cout << "Printed scope table inside st " << id << "\n";
			return true;
		}

		prev = iter;
		iter = iter->getNext_symbol_info();
	}

	//std::cout << "Deletion failed!\n";
	return false;
}

void ScopeTable::Print()
{
	if(!array_symbolinfo)
	{
		//std::cout << "array_symbolinfo is NULL!\n";
		return;
	}

	//std::cout << "ScopeTable # " << id << "\n";
	//logstream << "ScopeTable # " << id << "\n";
	parserlog << "ScopeTable # " << id << "\n";

	for(int i=0; i<n; i++)
		{
			SymbolInfo* iter = array_symbolinfo[i];

			//print only non empty brackets
			if(!iter)
				continue;

			//std::cout << " " << i << " --> ";
			//logstream << " " << i << " --> ";
			parserlog << " " << i << " --> ";

			while(iter)
			{
				//std::cout << "< " << iter->getSymbol_name() << " : " << iter->getSymbol_type() << ">";
				//logstream << "< " << iter->getSymbol_name() << " : " << iter->getSymbol_type() << ">";
				parserlog << "< " << iter->getSymbol_name() << " , " << iter->getSymbol_type() << " >";

				//if(iter->getNext_symbol_info())
				{
					//std::cout << " ";
					//logstream << " ";
					parserlog << " ";
				}

				iter = iter->getNext_symbol_info();
			}

			//std::cout << "\n";
			//logstream << "\n";
			parserlog << "\n";
		}
}

ScopeTable*& ScopeTable::getParentScope()
{
	return parentScope;
}

std::string ScopeTable::getID()
{
	return id;
}

int ScopeTable::getNumDeletedChildren()
{
	return num_deleted_children;
}

void ScopeTable::setNumDeletedChildren(int n)
{
	num_deleted_children = n;
}

void ScopeTable::setID(std::string id)
{
	this->id = id;
}

SymbolInfo ** ScopeTable::getArray_symbolinfo()
{
	return array_symbolinfo;
}

ScopeTable::~ScopeTable()
{
	if(parentScope)
		delete parentScope;

	if(array_symbolinfo)
	{
		for(int i=0; i<n; i++)
			if(array_symbolinfo[i])
				delete array_symbolinfo[i];
	}
}

#endif // SCOPETABLE_H_INCLUDED
