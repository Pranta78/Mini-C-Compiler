#ifndef OPTIMIZER_HELPER_H_INCLUDED
#define OPTIMIZER_HELPER_H_INCLUDED

bool isInteger(string str)
{
	char *ptr;
	strtol(str.c_str(), &ptr, 10);
    return *ptr == 0;
}

int getInteger(string str)
{
	char *ptr;
	int x = strtol(str.c_str(), &ptr, 10);

    if(*ptr)
		return 0;

	return x;
}

int optimize ()
{
	ifstream file("code.asm");
	ofstream outfile("optimized_code.asm");
	string line;	//takes a line from input file as a string

	bool read_previous_string = false;	//when true, the code does not read a new line from file, rather\
										it reads the previous line, this is necessary because sometimes we may need\
										to read one additional line from file to match the criteria of an optimization\
										if the criteria fails, then that extra line should be scanned next

	while (true)
	{
		if(!read_previous_string)
		{
			if(!getline(file, line))	//continue until end of file
				break;

			//line = trim_string(line);	//trim each assembly code, easier to work with
			//cout << line << "\n";
		}

		//if(line.substr(0, 9) == "\tMOV AX, ")
		if(line.substr(0, 5) == "\tMOV ")
		{
			//string var = line.substr(9);	//get variable name
			string op1 = line.substr(5, line.find(",")-5);	//get destination operand of MOV operation
			string op2 = line.substr(line.find(",")+2);		//get source operand of MOV operation

			string prev_line = line;	//save current instruction bc we are gonna overwrite it with next line/instruction

			//read the next line and see whether it matches MOV VAR_NAME, AX
			if(!getline(file, line))
				break;

			if(op1 == "AX")	//handle optimizations related to MOV AX, VAR_NAME or MOV AX, CONSTANT
			{
				string var = op2;	//since AX is a register, the other operand must be a variable
				//check whether the current instruction is MOV AX, 0 or MOV AX, 1
				//if true then execute some optimizations
				if(isInteger(var))
				{
					//check for MOV AX, 1 followed by IMUL VAR_NAME instructions
					//replace two instructions with MOV AX, VAR_NAME instruction
					//algebraic optimization: a * 1 or 1 * a
					if(getInteger(var) == 1)
					{
						if(line.substr(0, 6) == "\tIMUL ")
						{
							var = line.substr(6);	//get variable name, operand of IMUL
							line = "\tMOV AX, " + var;	//optimize cases like a * 1 or 1 * a
							outfile << line << "\n";
							read_previous_string = false;
							continue;
						}
					}

					//check for MOV AX, 0 followed by ADD AX, VAR_NAME instructions
					//replace two instructions with MOV AX, VAR_NAME instruction
					//algebraic optimization: 0 + a
					if(getInteger(var) == 0)
					{
						if(line.substr(0, 9) == "\tADD AX, ")
						{
							var = line.substr(9);	//get variable name, second operand of ADD
							line = "\tMOV AX, " + var;	//optimize cases like 0 + a
							outfile << line << "\n";
							read_previous_string = false;
							continue;
						}
					}
				}

				//peephole optimization: check for redundant load instructions
				string match = "\tMOV " + var + ", AX";
				outfile << prev_line << "\n";

				if(line == match)
				{
					read_previous_string = false;	//if this variable is false, then in the next iteration, program fetches\
													new line from input file, thus the second mov instruction is omitted
					continue;
				}
				else
					read_previous_string = true;

				//peephole optimization: check for algebraic optimization like var + 0, var - 0
				match = "\tADD AX, 0";
				string match2 = "\tSUB AX, 0";

				if(line == match || line == match2)
				{
					read_previous_string = false;	//if this variable is false, then in the next iteration, program fetches\
													new line from input file, thus the add/sub with 0 instruction is omitted
					continue;
				}
				else
					read_previous_string = true;

				continue;
			}

			outfile << prev_line << "\n";

			//check for optimization if the next line is MOV instruction as well
			if(line.substr(0, 5) == "\tMOV ")
			{
				//peephole optimization: Handle cases like MOV VAR_NAME, AX followed by MOV AX, VAR_NAME
				//in this case, remove the second mov instruction
				string line2_op1 = line.substr(5, line.find(",")-5);	//get destination operand of MOV operation in the next line
				string line2_op2 = line.substr(line.find(",")+2);		//get source operand of MOV operation in the next line

				//outfile << prev_line << "\n";

				//peephole optimization: check for redundant load instructions
				if(op1 == line2_op2 && op2 == line2_op1)
				{
					//cout << "\nFound match: " << prev_line << "\nFound match: " << line << "\n\n";
					read_previous_string = false;	//if this variable is false, then in the next iteration, program fetches\
													new line from input file, thus the second mov instruction is omitted
					continue;
				}
				else
					read_previous_string = true;
			}

			//No optimization was possible, so resume the iteration using the current line variable\
			instead of reading new a line from input file
			read_previous_string = true;
		}

		outfile << line << "\n";
		read_previous_string = false;
	}

	file.close();
	outfile.close();
}

#endif // OPTIMIZER_HELPER_H_INCLUDED
