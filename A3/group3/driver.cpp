
#include "scanner.hh"
#include "parser.tab.hh"
#include "ast.hh"
#include "symbtab.hh"
#include <fstream>
using namespace std;

SymbTab gst, gstfun, gststruct; 
string filename;
extern std::map<string,abstract_astnode*> ast;
extern int n_size;

// std::map<std::string, datatype> predefined {
//             {"printf", createtype(VOID_TYPE)},
//             {"scanf", createtype(VOID_TYPE)},
//             {"mod", createtype(INT_TYPE)}
//         };


int main(int argc, char **argv)
{
	using namespace std;
	fstream in_file, out_file;
	

	in_file.open(argv[1], ios::in);

	IPL::Scanner scanner(in_file);

	IPL::Parser parser(scanner);

#ifdef YYDEBUG
	parser.set_debug_level(1);
#endif

// start .s printing

	cout<<"\t.file\t\""<<argv[1]<<"\""<<endl;
	cout<<"\t.text"<<endl;

parser.parse();
// create gstfun with function entries only

for (const auto &entry : gst.Entries)
{
	if (entry.second.varfun == "fun")
	gstfun.Entries.insert({entry.first, entry.second});
}
// create gststruct with struct entries only

for (const auto &entry : gst.Entries)
{
	if (entry.second.varfun == "struct")
	gststruct.Entries.insert({entry.first, entry.second});
}


// .s continue

	for (auto it = gstfun.Entries.begin(); it != gstfun.Entries.end(); ++it)
	{
		n_size = 0;
		for(auto it1 = it->second.symbtab->Entries.begin(); it1 != it->second.symbtab->Entries.end(); ++it1){
			if(it1->second.pos=="local"){
				n_size = n_size + it1->second.size;
			}
		}
		cout<<"\t.text\t"<<endl;
		cout<<"\t.globl\t"<<it->first<<endl;
		cout<<"\t.type\t"<<it->first<<", @function"<<endl;
		cout<<it->first<<":"<<endl;
		cout<<"\tpushl\t%ebp"<<endl;
		cout<<"\tmovl\t%esp, %ebp"<<endl;
		// if(it->first == "main"){
		cout<<"\tsubl\t$"<<n_size<<", %esp"<<endl;
		// }
		cout<<"\tpushl\t%ebx"<<endl;
		cout<<"\tpushl\t%edi"<<endl;
		cout<<"\tpushl\t%esi"<<endl;
		ast[it->first]->print(0);	
		cout<<"\t.size\t"<<it->first<<", .-"<<it->first<<endl;
		if(it->first == "main"){
			cout<<"\t.ident\t\"GCC: (Ubuntu 8.1.0-9ubuntu1~16.04.york1) 8.1.0\""<<endl;
			cout<<"\t.section\t.note.GNU-stack,\"\",@progbits"<<endl;	
		}else{
			cout<<"\t.section\t.rodata"<<endl;
		}
		
	}


	fclose(stdout);
}
