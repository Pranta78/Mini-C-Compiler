#ifndef SYMBOLINFO_H_INCLUDED
#define SYMBOLINFO_H_INCLUDED

#include <vector>

class SymbolInfo
{
private:
    std::string name, type;
	std::string var_type;	//type of variable(int, float) or return type of function(int, float, void)
	std::string var_category;	//variable, array or function
	int array_length;
	std::vector<SymbolInfo*> parameter_list;	//for functions only
	bool is_defined;	//necessary to see whether a function was defined before calling it
    SymbolInfo* next_symbol_info;

public:
    SymbolInfo()
	{
        next_symbol_info = NULL;
	}

	SymbolInfo(std::string symbol_name, std::string symbol_type)
	{
		this->name = symbol_name;
		this->type = symbol_type;
		next_symbol_info = NULL;
	}

	SymbolInfo(std::string symbol_name, std::string symbol_type, std::string symbol_var_type, std::string symbol_var_category)
	{
		this->name = symbol_name;
		this->type = symbol_type;
		this->var_type = symbol_var_type;
		this->var_category = symbol_var_category;
		next_symbol_info = NULL;
	}

	SymbolInfo(std::string symbol_name, std::string symbol_type, std::string symbol_var_type, int array_length)
	{
		this->name = symbol_name;
		this->type = symbol_type;
		this->var_type = symbol_var_type;
		this->var_category = "ARRAY";
		this->array_length = array_length;
		next_symbol_info = NULL;
	}

	SymbolInfo(std::string symbol_name, std::string symbol_type, std::string symbol_var_type, std::vector<SymbolInfo*> parameter_list, bool defined=false)
	{
		this->name = symbol_name;
		this->type = symbol_type;
		this->var_type = symbol_var_type;
		this->var_category = "FUNCTION";
		this->parameter_list = parameter_list;
		this->is_defined = defined;
		next_symbol_info = NULL;
	}

	std::string getSymbol_name()
	{
		return name;
	}

	std::string getSymbol_type()
	{
		return type;
	}

	std::string getVar_type()
	{
		return var_type;
	}

	std::string getVar_category()
	{
		return var_category;
	}

	int getArray_length()
	{
		return array_length;
	}

	std::vector<SymbolInfo*> getParameter_list()
	{
		return parameter_list;
	}

	bool getDefined()
	{
		return is_defined;
	}

	void setVar_type(std::string var_type)
	{
		this->var_type = var_type;
	}

	void setVar_category(std::string var_category)
	{
		this->var_category = var_category;
	}

	void setArray_length(int array_length)
	{
		this->array_length = array_length;
	}

	void setParameter_list(std::vector<SymbolInfo*> parameter_list)
	{
		this->parameter_list = parameter_list;
	}

	void isDefined(bool var)
	{
		this->is_defined = var;
	}

	SymbolInfo*& getNext_symbol_info()
	{
		return next_symbol_info;
	}

	~SymbolInfo()
	{
		if(next_symbol_info)
			delete next_symbol_info;
	}
};

#endif // SYMBOLINFO_H_INCLUDED
