#include "pch.h"
#include <string>
#include <cstring>
#include <sstream>
#include <iostream>
#include <fstream>

extern "C"
{
	//--- Called by Engine on extension load 
	__declspec (dllexport) void __stdcall RVExtensionVersion(char* output, int outputSize);

	//--- STRING callExtension STRING
	__declspec (dllexport) void __stdcall RVExtension(char* output, int outputSize, const char* function);

	//--- STRING callExtension ARRAY
	__declspec (dllexport) int __stdcall RVExtensionArgs(char* output, int outputSize, const char* function, const char** argv, int argc);
}

void __stdcall RVExtensionVersion(char* output, int outputSize) {
	strncpy_s(output, outputSize, "make_descriptionExt v0.1", _TRUNCATE);
}

void __stdcall RVExtension(char* output, int outputSize, const char* filePath)
{
	strncpy_s(output, outputSize, "Syntax Error - Use format STRING callExtension ARRAY.", _TRUNCATE);
}

int __stdcall RVExtensionArgs(char* output, int outputSize, const char* function, const char** argv, int argc)
{
	// generate filepath string from input array
	std::stringstream sstream;
	for (int i = 0; i < argc; i++)
	{
		sstream << argv[i];
	}
	std::string filePath = sstream.str().substr(1, sstream.str().length() - 2);
	filePath.append("description.ext");
	
	// create file and insert content
	std::ofstream file(filePath);
	file << "respawnOnStart = -1;\n";
	file.close();

	strncpy_s(output, outputSize, filePath.c_str(), _TRUNCATE);
	return 0;
}
