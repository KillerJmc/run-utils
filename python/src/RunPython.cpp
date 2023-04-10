// RunLua.exe

#include <iostream>
#include <cstdlib>
#include <Windows.h>

std::string get_pwd()
{
	char exe_path[MAX_PATH];
	GetModuleFileNameA(NULL, exe_path, MAX_PATH);
	return std::string(exe_path).substr(0, std::string(exe_path).find_last_of('\\'));
}

std::string get_args_str(int argc, char* argv[])
{
	std::string args;
	for (int i = 1; i < argc; i++)
	{
		args += std::string(argv[i]) + " ";
	}
	return args;
}

std::string get_cmd(std::string pwd, std::string cmd_name, std::string args_str)
{
	return "\"" + pwd + "\\" + cmd_name + "\" " + args_str;
}

int main(int argc, char* argv[])
{
	auto pwd = get_pwd();
	auto args_str = get_args_str(argc, argv);
	auto cmd = get_cmd(pwd, "RunPython.cmd", args_str);

	system(cmd.c_str());
}
