#include "symbtab.hh"
#include "scanner.hh"
#include "parser.tab.hh"
#include "ast.hh"
#include <fstream>
using namespace std;

stack<string> regi;
int l_num = 2;
extern int n_size;
// extern SymbTab gstfun;

void intialize(){
	regi.push("%esi");
	regi.push("%edi");
	regi.push("%ebx");
	regi.push("%ecx");
	regi.push("%edx");
	regi.push("%eax");
}

int dummy = (intialize(), 0);

void printAst(const char *astname, const char *fmt...) // fmt is a format string that tells about the type of the arguments.
{   
	typedef vector<abstract_astnode *>* pv;
	va_list args;
	va_start(args, fmt);
	// if ((astname != NULL) && (astname[0] != '\0'))
	// {
	// 	// cout << "{ ";
	// 	// cout << "\"" << astname << "\"" << ": ";
	// }
	// cout << "{" << endl;
	while (*fmt != '\0')
	{
		if (*fmt == 'a')
		{
			char * field = va_arg(args, char *);
			abstract_astnode *a = va_arg(args, abstract_astnode *);
			// cout << "\"" << field << "\": " << endl;
			
			a->print(0);
		}
		else if (*fmt == 's')
		{
			char * field = va_arg(args, char *);
			char *str = va_arg(args, char *);
			// cout << "\"" << field << "\": ";

			// cout << str << endl;
		}
		else if (*fmt == 'i')
		{
			char * field = va_arg(args, char *);
			int i = va_arg(args, int);
			// cout << "\"" << field << "\": ";

			// cout << i;
		}
		else if (*fmt == 'f')
		{
			char * field = va_arg(args, char *);
			double f = va_arg(args, double);
			// cout << "\"" << field << "\": ";
			// cout << f;
		}
		else if (*fmt == 'l')
		{
			char * field = va_arg(args, char *);
			pv f =  va_arg(args, pv);
			// cout << "\"" << field << "\": ";
			// cout << "[" << endl;
			for (int i = 0; i < (int)f->size(); ++i)
			{
				(*f)[i]->print(0);
				// if (i < (int)f->size() - 1)
				// 	// cout << "," << endl;
				// else
				// 	// cout << endl;
			}
			// cout << endl;
			// cout << "]" << endl;
		}
		++fmt;
		// if (*fmt != '\0')
		// 	// cout << "," << endl;
	}
	// cout << "}" << endl;
	if ((astname != NULL) && (astname[0] != '\0'))
		// cout << "}" << endl;
	va_end(args);
}

////////////////////////////////////////////////////

void genCode(exp_astnode *e){
	if(e->reg_num <= regi.size()){
		if(e->astnode_type == Op_binary_astnode){
			op_binary_astnode *b = dynamic_cast<op_binary_astnode*>(e);
			if(b->left == "OP_DIV"){
				// cout<<"\tpushl\t%eax"<<endl;
				// cout<<"\tpushl\t%edx"<<endl;
				// cout<<"\tpushl\t%ecx"<<endl;
				if(regi.top() == "%eax"){
					cout<<"\tpushl\t%edx"<<endl;
					cout<<"\tpushl\t%ecx"<<endl;
				}else if(regi.top() == "%edx"){
					cout<<"\tpushl\t%eax"<<endl;
					cout<<"\tpushl\t%ecx"<<endl;
				}else if(regi.top() == "%ecx"){
					cout<<"\tpushl\t%eax"<<endl;
					cout<<"\tpushl\t%edx"<<endl;
				}else{
					cout<<"\tpushl\t%eax"<<endl;
					cout<<"\tpushl\t%edx"<<endl;
					cout<<"\tpushl\t%ecx"<<endl;
				} 
				regi.push("%ecx");
				regi.push("%eax");
				genCode(b->middle);
				string R;
				R = regi.top();
				regi.pop();
				genCode(b->right);
				cout<<"\tcltd"<<endl;
				cout<<"\tidivl\t"<<regi.top()<<endl;
				regi.pop();
				if(regi.top() == "%eax"){
					cout<<"\tpopl\t%ecx"<<endl;
					cout<<"\tpopl\t%edx"<<endl;
				}else if(regi.top() == "%edx"){
					cout<<"\tmovl\t"<<R<<", %edx"<<endl;
					cout<<"\tpopl\t%ecx"<<endl;
					cout<<"\tpopl\t%eax"<<endl;
				}else if(regi.top() == "%ecx"){
					cout<<"\tmovl\t"<<R<<", %ecx"<<endl;
					cout<<"\tpopl\t%edx"<<endl;
					cout<<"\tpopl\t%eax"<<endl;
				}else{
					cout<<"\tmovl\t"<<R<<", "<<regi.top()<<endl;
					cout<<"\tpopl\t%ecx"<<endl;
					cout<<"\tpopl\t%edx"<<endl;
					cout<<"\tpopl\t%eax"<<endl;
				} 
				
				// cout<<"\tmovl\t"<<R<<", "<<regi.top()<<endl;
				

			}
			else if(b->left == "OP_OR"){
				genCode(b->middle);
				string R;
				R = regi.top();
				regi.pop();
				genCode(b->right);
				cout<<"\tcmpl\t$0, "<<R<<endl;
				cout<<"\tjne\t.L"<<l_num<<endl;
				l_num++;
				cout<<"\tcmpl\t$0, "<<regi.top()<<endl;
				cout<<"\tje\t.L"<<l_num<<endl;
				l_num++;
				cout<<".L"<<l_num-2<<":"<<endl;
				cout<<"\tmovl\t$1, "<<R<<endl;
				cout<<"\tjmp\t.L"<<l_num<<endl;
				cout<<".L"<<l_num-1<<":"<<endl;
				cout<<"\tmovl\t$0, "<<R<<endl;
				cout<<"\tjmp\t.L"<<l_num<<endl;
				cout<<".L"<<l_num<<":"<<endl;
				l_num++;
				regi.push(R);
			}
			else if(b->left == "OP_AND"){
				genCode(b->middle);
				string R;
				R = regi.top();
				regi.pop();
				genCode(b->right);
				cout<<"\tcmpl\t$0, "<<R<<endl;
				cout<<"\tje\t.L"<<l_num<<endl;
				l_num++;
				cout<<"\tcmpl\t$0, "<<regi.top()<<endl;
				cout<<"\tjne\t.L"<<l_num<<endl;
				l_num++;
				cout<<".L"<<l_num-2<<":"<<endl;
				cout<<"\tmovl\t$0, "<<R<<endl;
				cout<<"\tjmp\t.L"<<l_num<<endl;
				cout<<".L"<<l_num-1<<":"<<endl;
				cout<<"\tmovl\t$1, "<<R<<endl;
				cout<<"\tjmp\t.L"<<l_num<<endl;
				cout<<".L"<<l_num<<":"<<endl;
				l_num++;
				regi.push(R);
			}
			else if(b->left == "OP_LT"){
				genCode(b->middle);
				string R;
				R = regi.top();
				regi.pop();
				genCode(b->right);
				cout<<"\tcmpl\t"<<regi.top()<<", "<<R<<endl;
				cout<<"\tjl\t.L"<<l_num<<endl;
				l_num++;
				cout<<"\tmovl\t$0, "<<R<<endl;
				cout<<"\tjmp\t.L"<<l_num<<endl;
				l_num++;
				cout<<".L"<<l_num-2<<":"<<endl;
				cout<<"\tmovl\t$1, "<<R<<endl;
				cout<<"\tjmp\t.L"<<l_num-1<<endl;
				cout<<".L"<<l_num-1<<":"<<endl;
				
				regi.push(R);
			}
			else if(b->left == "OP_GT"){
				genCode(b->middle);
				string R;
				R = regi.top();
				regi.pop();
				genCode(b->right);
				cout<<"\tcmpl\t"<<regi.top()<<", "<<R<<endl;
				cout<<"\tjg\t.L"<<l_num<<endl;
				l_num++;
				cout<<"\tmovl\t$0, "<<R<<endl;
				cout<<"\tjmp\t.L"<<l_num<<endl;
				l_num++;
				cout<<".L"<<l_num-2<<":"<<endl;
				cout<<"\tmovl\t$1, "<<R<<endl;
				cout<<"\tjmp\t.L"<<l_num-1<<endl;
				cout<<".L"<<l_num-1<<":"<<endl;
				
				regi.push(R);
			}
			else if(b->left == "OP_LTE"){
				genCode(b->middle);
				string R;
				R = regi.top();
				regi.pop();
				genCode(b->right);
				cout<<"\tcmpl\t"<<regi.top()<<", "<<R<<endl;
				cout<<"\tjle\t.L"<<l_num<<endl;
				l_num++;
				cout<<"\tmovl\t$0, "<<R<<endl;
				cout<<"\tjmp\t.L"<<l_num<<endl;
				l_num++;
				cout<<".L"<<l_num-2<<":"<<endl;
				cout<<"\tmovl\t$1, "<<R<<endl;
				cout<<"\tjmp\t.L"<<l_num-1<<endl;
				cout<<".L"<<l_num-1<<":"<<endl;
				
				regi.push(R);
			}
			else if(b->left == "OP_GTE"){
				genCode(b->middle);
				string R;
				R = regi.top();
				regi.pop();
				genCode(b->right);
				cout<<"\tcmpl\t"<<regi.top()<<", "<<R<<endl;
				cout<<"\tjge\t.L"<<l_num<<endl;
				l_num++;
				cout<<"\tmovl\t$0, "<<R<<endl;
				cout<<"\tjmp\t.L"<<l_num<<endl;
				l_num++;
				cout<<".L"<<l_num-2<<":"<<endl;
				cout<<"\tmovl\t$1, "<<R<<endl;
				cout<<"\tjmp\t.L"<<l_num-1<<endl;
				cout<<".L"<<l_num-1<<":"<<endl;
				
				regi.push(R);
			}
			else if(b->left == "OP_EQ"){
				genCode(b->middle);
				string R;
				R = regi.top();
				regi.pop();
				genCode(b->right);
				cout<<"\tcmpl\t"<<regi.top()<<", "<<R<<endl;
				cout<<"\tje\t.L"<<l_num<<endl;
				l_num++;
				cout<<"\tmovl\t$0, "<<R<<endl;
				cout<<"\tjmp\t.L"<<l_num<<endl;
				l_num++;
				cout<<".L"<<l_num-2<<":"<<endl;
				cout<<"\tmovl\t$1, "<<R<<endl;
				cout<<"\tjmp\t.L"<<l_num-1<<endl;
				cout<<".L"<<l_num-1<<":"<<endl;
				
				regi.push(R);
			}
			else if(b->left == "OP_NEQ"){
				genCode(b->middle);
				string R;
				R = regi.top();
				regi.pop();
				genCode(b->right);
				cout<<"\tcmpl\t"<<regi.top()<<", "<<R<<endl;
				cout<<"\tjne\t.L"<<l_num<<endl;
				l_num++;
				cout<<"\tmovl\t$0, "<<R<<endl;
				cout<<"\tjmp\t.L"<<l_num<<endl;
				l_num++;
				cout<<".L"<<l_num-2<<":"<<endl;
				cout<<"\tmovl\t$1, "<<R<<endl;
				cout<<"\tjmp\t.L"<<l_num-1<<endl;
				cout<<".L"<<l_num-1<<":"<<endl;
				
				regi.push(R);
			}
			else{
				genCode(b->middle);
				string R;
				R = regi.top();
				regi.pop();
				genCode(b->right);
				if(b->left == "OP_ADD"){
					cout<<"\taddl\t"<<regi.top()<<", "<<R<<endl;
				};
				if(b->left == "OP_SUB"){
					cout<<"\tsubl\t"<<regi.top()<<", "<<R<<endl;
				}
				if(b->left == "OP_MUL"){
					cout<<"\timull\t"<<regi.top()<<", "<<R<<endl;
				}
				regi.push(R);
			}
		}
		if(e->astnode_type == Identifier_astnode){
			identifier_astnode *I = dynamic_cast<identifier_astnode*>(e);
			cout<<"\tmovl\t"<<I->offset<<"(%ebp), "<<regi.top()<<endl;
		}
		if(e->astnode_type == Intconst_astnode){
			intconst_astnode *I = dynamic_cast<intconst_astnode*>(e);
			cout<<"\tmovl\t$"<<I->value<<", "<<regi.top()<<endl;
		}
		if(e->astnode_type == Op_unary_astnode){
			op_unary_astnode *I = dynamic_cast<op_unary_astnode*>(e);
			genCode(I->right);
			if(I->left == "-"){
				cout<<"\tnegl\t"<<regi.top()<<endl;
			}
			else if(I->left == "!"){
				cout<<"\tcmpl\t$0, "<<regi.top()<<endl;
				cout<<"\tje\t.L"<<l_num<<endl;
				l_num++;
				cout<<"\tmovl\t$0, "<<regi.top()<<endl;
				cout<<"\tjmp\t.L"<<l_num<<endl;
				cout<<".L"<<l_num-1<<":"<<endl;
				cout<<"\tmovl\t$1, "<<regi.top()<<endl;
				cout<<"\tjmp\t.L"<<l_num<<endl;
				cout<<".L"<<l_num<<":"<<endl;
				l_num++;
			}else if(I->left == "PP"){
				if(I->right->astnode_type == Identifier_astnode){
					identifier_astnode *I2 = dynamic_cast<identifier_astnode*>(I->right);
					cout<<"\taddl\t$1, "<<I2->offset<<"(%ebp)"<<endl;
				}else if(I->right->astnode_type == Member_astnode){
					member_astnode *I2 = dynamic_cast<member_astnode*>(I->right);
					cout<<"\taddl\t$1, "<<I2->offset<<"(%ebp)"<<endl;
				}
			}
		}	
		if(e->astnode_type == Funcall_astnode){
			funcall_astnode *I = dynamic_cast<funcall_astnode*>(e);
			int s = I->vect.size();
			if(regi.top() == "%eax"){
				cout<<"\tpushl\t%edx"<<endl;
				cout<<"\tpushl\t%ecx"<<endl;
			}else if(regi.top() == "%edx"){
				cout<<"\tpushl\t%eax"<<endl;
				cout<<"\tpushl\t%ecx"<<endl;
			}else if(regi.top() == "%ecx"){
				cout<<"\tpushl\t%eax"<<endl;
				cout<<"\tpushl\t%edx"<<endl;
			}else{
				cout<<"\tpushl\t%eax"<<endl;
				cout<<"\tpushl\t%edx"<<endl;
				cout<<"\tpushl\t%ecx"<<endl;
			} 

			for(int i=s-1;i>=0;i--){
				genCode(I->vect[i]);
				cout<<"\tpushl\t"<<regi.top()<<endl;
			}
			
			cout<<"\tcall\t"<<I->funcname->id<<endl;
			cout<<"\taddl\t$"<<s*4<<", %esp"<<endl;
			if(regi.top() == "%eax"){
				cout<<"\tpopl\t%ecx"<<endl;
				cout<<"\tpopl\t%edx"<<endl;
			}else if(regi.top() == "%edx"){
				cout<<"\tmovl\t%eax, %edx"<<endl;
				cout<<"\tpopl\t%ecx"<<endl;
				cout<<"\tpopl\t%eax"<<endl;
			}else if(regi.top() == "%ecx"){
				cout<<"\tmovl\t%eax, %ecx"<<endl;
				cout<<"\tpopl\t%edx"<<endl;
				cout<<"\tpopl\t%eax"<<endl;
			}else{
				cout<<"\tmovl\t%eax, "<<regi.top()<<endl;
				cout<<"\tpopl\t%ecx"<<endl;
				cout<<"\tpopl\t%edx"<<endl;
				cout<<"\tpopl\t%eax"<<endl;
			} 
		}
		if(e->astnode_type == Member_astnode){
			member_astnode *I = dynamic_cast<member_astnode*>(e);
			cout<<"\tmovl\t"<<I->offset<<"(%ebp), "<<regi.top()<<endl;
		}
	}
	// else{
	// 	int req_reg = e->reg_num - regi.size() + 2;
	// 	int off = -n_size;
	// 	for(int i=0;i<req_reg;i++){
	// 		string s = "(%ebp)";
	// 		off = off - 4;
	// 		s = to_string(off) + s;
	// 		cout<<"\tpushl\t"<<s<<endl;
	// 		regi.push(s);
	// 	};
	// 	genCode(e);
	// 	for(int i=0;i<req_reg;i++){
	// 		string s;
	// 		s = regi.top();
	// 		regi.pop();
	// 		cout<<"\tpopl\t"<<s<<endl;
	// 	};
	// }
}

////////////////////////////////////////////////////

statement_astnode::statement_astnode() : abstract_astnode(){
	astnode_type = Statement_astnode;
}

exp_astnode::exp_astnode() : abstract_astnode(){
	astnode_type = Exp_astnode;
}

ref_astnode::ref_astnode() : exp_astnode(){
	lvalue = true;
	astnode_type = Ref_astnode;
}

//////////////////////////////////////////////////////

empty_astnode::empty_astnode() : statement_astnode(){
	astnode_type = Empty_astnode;
}

void empty_astnode::print(int  blanks){
	// cout<<"\"empty\""<<endl;
}

///////////////////////////////////////////////////////



seq_astnode::seq_astnode() : statement_astnode(){
	astnode_type = Seq_astnode;
}

void seq_astnode::pushback(statement_astnode *s, string s2){
	vect.push_back(s);
	function_type = s2;
}

void seq_astnode::print(int blanks){
	printAst("","l","seq",vect);
	if(function_type == "void"){
		cout<<"\tpopl\t%esi"<<endl;
		cout<<"\tpopl\t%edi"<<endl;
		cout<<"\tpopl\t%ebx"<<endl;
		cout<<"\tnop"<<endl;
		// cout<<"\tpopl\t%ebp"<<endl;
		cout<<"\tleave"<<endl;
		cout<<"\tret"<<endl;
	}
}

///////////////////////////////////////////////////////



assignS_astnode::assignS_astnode(exp_astnode *e1,exp_astnode *e2) : statement_astnode(){
	left = e1;
	right = e2;
	astnode_type = AssignS_astnode;
}

void assignS_astnode::print(int blanks){
	if(right->astnode_type == Intconst_astnode){
		intconst_astnode *I = dynamic_cast<intconst_astnode*>(right);
		cout<<"\tmovl\t$"<<I->value<<", "<<left->offset<<"(%ebp)"<<endl;
		printAst("assignS","aa","left",left,"right",right);
	}else if(right->astnode_type == Funcall_astnode){
		genCode(right);
		funcall_astnode *I = dynamic_cast<funcall_astnode*>(right);
		if(I->function_type == "int"){
			cout<<"\tmovl\t"<<regi.top()<<", "<<left->offset<<"(%ebp)"<<endl;
		}
		// printAst("assignS","aa","left",left,"right",right);
	}else{
		genCode(right);
		cout<<"\tmovl\t"<<regi.top()<<", "<<left->offset<<"(%ebp)"<<endl;
		printAst("assignS","aa","left",left,"right",right);
	}
	
}

////////////////////////////////////////////////////////

return_astnode::return_astnode(exp_astnode *e, string s1, string s2) :statement_astnode()
{
	sing = e;
	function_name = s1;
	function_type = s2;
	astnode_type = Return_astnode;
}

void return_astnode::print(int blanks){
	genCode(sing);
	cout<<"\tmovl\t"<<regi.top()<<", %eax"<<endl;
	if(function_name == "main"){
		cout<<"\tpopl\t%esi"<<endl;
		cout<<"\tpopl\t%edi"<<endl;
		cout<<"\tpopl\t%ebx"<<endl;
		cout<<"\tleave"<<endl;
	}else{
		if(function_type == "int"){
			cout<<"\tpopl\t%esi"<<endl;
			cout<<"\tpopl\t%edi"<<endl;
			cout<<"\tpopl\t%ebx"<<endl;
			cout<<"\tleave"<<endl;
		}else if(function_type == "void"){
			cout<<"\tpopl\t%esi"<<endl;
			cout<<"\tpopl\t%edi"<<endl;
			cout<<"\tpopl\t%ebx"<<endl;
			cout<<"\tnop"<<endl;
			cout<<"\tleave"<<endl;
		}
		
	} 
	cout<<"\tret"<<endl;
	// printAst("","a","return",sing);
}

/////////////////////////////////////////////////////////

if_astnode::if_astnode(exp_astnode *e,statement_astnode *s1,statement_astnode *s2) : statement_astnode()
{
	left = e;
	middle = s1;
	right = s2;
	astnode_type = If_astnode;
}

void if_astnode::print(int blanks){
	genCode(left);
	cout<<"\tcmpl\t$0, "<<regi.top()<<endl;
	cout<<"\tje\t.L"<<l_num<<endl;
	int temp0 = l_num;
	l_num++;
	middle->print(0);
	cout<<"\tjmp\t.L"<<l_num<<endl;
	cout<<".L"<<temp0<<":"<<endl;
	int temp = l_num;
	l_num++;
	right->print(0);
	cout<<"\tjmp\t.L"<<temp<<endl;
	cout<<".L"<<temp<<":"<<endl;
	// printAst("if","aaa","cond",left,"then",middle,"else",right);
}

//////////////////////////////////////////////////////////////

while_astnode::while_astnode(exp_astnode *e, statement_astnode *s) : statement_astnode()
{
	left = e;
	right = s;
	astnode_type = While_astnode;
}

void while_astnode::print(int blanks){
	cout<<"\tjmp\t.L"<<l_num<<endl;
	int temp0 = l_num;
	l_num++;
	cout<<".L"<<l_num<<":"<<endl;
	int temp = l_num;
	l_num++;
	right->print(0);
	cout<<".L"<<temp0<<":"<<endl;
	genCode(left);
	cout<<"\tcmpl\t$0, "<<regi.top()<<endl;
	cout<<"\tjne\t.L"<<temp<<endl;
	// printAst("while","aa","cond",left,"stmt",right);
}

///////////////////////////////////////////////////////////////////

for_astnode::for_astnode(exp_astnode *e1,exp_astnode *e2,exp_astnode *e3,statement_astnode *s) : statement_astnode()
{
	left = e1;
	middle1 = e2;
	middle2 = e3;
	right = s;
	astnode_type = For_astnode;
}

void for_astnode::print(int blanks){
	assignE_astnode *L = dynamic_cast<assignE_astnode*>(left);
	assignE_astnode *M2 = dynamic_cast<assignE_astnode*>(middle2);
	if(L->right->astnode_type == Intconst_astnode){
		intconst_astnode *I = dynamic_cast<intconst_astnode*>(L->right);
		cout<<"\tmovl\t$"<<I->value<<", "<<L->left->offset<<"(%ebp)"<<endl;
	}else{
		genCode(L->right);
		cout<<"\tmovl\t"<<regi.top()<<", "<<L->left->offset<<"(%ebp)"<<endl;
	}
	cout<<"\tjmp\t.L"<<l_num<<endl;
	int temp0 = l_num;
	l_num++;
	cout<<".L"<<l_num<<":"<<endl;
	int temp = l_num;
	l_num++;
	right->print(0);
	if(M2->right->astnode_type == Intconst_astnode){
		intconst_astnode *I = dynamic_cast<intconst_astnode*>(M2->right);
		cout<<"\tmovl\t$"<<I->value<<", "<<M2->left->offset<<"(%ebp)"<<endl;
	}else{
		genCode(M2->right);
		cout<<"\tmovl\t"<<regi.top()<<", "<<M2->left->offset<<"(%ebp)"<<endl;
	}
	cout<<".L"<<temp0<<":"<<endl;
	genCode(middle1);
	cout<<"\tcmpl\t$0, "<<regi.top()<<endl;
	cout<<"\tjne\t.L"<<temp<<endl;
	// printAst("for","aaaa","init",left,"guard",middle1,"step",middle2,"body",right);
}

///////////////////////////////////////////////////////////////////////

proccall_astnode::proccall_astnode() : statement_astnode()
{
	astnode_type = Proccall_astnode;
}

proccall_astnode::proccall_astnode(identifier_astnode *child) : statement_astnode()
{
	funcname = child;
	astnode_type = Proccall_astnode;
}

void proccall_astnode::setname(string name){
	funcname = new identifier_astnode(name);
}

void proccall_astnode::pushback(exp_astnode* e)
{
	vect.push_back(e);
}

void proccall_astnode::print(int blanks){
	int s = vect.size();

	if(regi.top() == "%eax"){
		cout<<"\tpushl\t%edx"<<endl;
		cout<<"\tpushl\t%ecx"<<endl;
	}else if(regi.top() == "%edx"){
		cout<<"\tpushl\t%eax"<<endl;
		cout<<"\tpushl\t%ecx"<<endl;
	}else if(regi.top() == "%ecx"){
		cout<<"\tpushl\t%eax"<<endl;
		cout<<"\tpushl\t%edx"<<endl;
	}else{
		cout<<"\tpushl\t%eax"<<endl;
		cout<<"\tpushl\t%edx"<<endl;
		cout<<"\tpushl\t%ecx"<<endl;
	} 

	for(int i=s-1;i>=0;i--){
		genCode(vect[i]);
		cout<<"\tpushl\t"<<regi.top()<<endl;
	}
	cout<<"\tcall\t"<<funcname->id<<endl;
	cout<<"\taddl\t$"<<s*4<<", %esp"<<endl;

	if(regi.top() == "%eax"){
		cout<<"\tpopl\t%ecx"<<endl;
		cout<<"\tpopl\t%edx"<<endl;
	}else if(regi.top() == "%edx"){
		cout<<"\tmovl\t%eax, %edx"<<endl;
		cout<<"\tpopl\t%ecx"<<endl;
		cout<<"\tpopl\t%eax"<<endl;
	}else if(regi.top() == "%ecx"){
		cout<<"\tmovl\t%eax, %ecx"<<endl;
		cout<<"\tpopl\t%edx"<<endl;
		cout<<"\tpopl\t%eax"<<endl;
	}else{
		cout<<"\tmovl\t%eax, "<<regi.top()<<endl;
		cout<<"\tpopl\t%ecx"<<endl;
		cout<<"\tpopl\t%edx"<<endl;
		cout<<"\tpopl\t%eax"<<endl;
	} 

	// printAst("proccall","al","fname",funcname,"params",vect);
}

///////////////////////////////////////////////////////////////////////

printfcall_astnode::printfcall_astnode() : statement_astnode()
{
	astnode_type = Printfcall_astnode;
}

printfcall_astnode::printfcall_astnode(stringconst_astnode *s) : statement_astnode()
{
	strval = s;
	astnode_type = Printfcall_astnode;
}

// void printfall_astnode::setname(string name){
// 	strname = ;
// }

void printfcall_astnode::pushback(exp_astnode* e)
{
	vect.push_back(e);
}

void printfcall_astnode::print(int blanks){
	if(vect.empty()){
		cout<<"\tpushl\t$.LC"<<lc_num<<endl;
		cout<<"\tcall\tprintf"<<endl;
		cout<<"\taddl\t$4, %esp"<<endl;
	}else{
		int s = vect.size();
		
		for(int i=s-1;i>=0;i--){
			genCode(vect[i]);
			// cout<<i<<endl;
			cout<<"\tpushl\t"<<regi.top()<<endl;
		}
		cout<<"\tpushl\t$.LC"<<lc_num<<endl;
		cout<<"\tcall\tprintf"<<endl;
		cout<<"\taddl\t$"<<(4*(s+1))<<", %esp"<<endl;
	}
	// printAst("printfcall","al","stringval",strval,"params",vect);
}

//////////////////////////////////////////////////////////////////////////

op_binary_astnode::op_binary_astnode(string s,exp_astnode *e1,exp_astnode *e2) : exp_astnode()
{
	left = s;
	middle = e1;
	right = e2;
	astnode_type = Op_binary_astnode;
	// child = 0;
}

void op_binary_astnode::print(int blanks){
	string str = "\"" + left + "\"";
	char *str1 = const_cast<char *>(str.c_str());
	printAst("op_binary","saa","op",str1,"left",middle,"right",right);
}

///////////////////////////////////////////////////////////////////////////////

op_unary_astnode::op_unary_astnode(string s,exp_astnode *e) : exp_astnode()
{
	left = s;
	right = e;
	astnode_type = Op_unary_astnode;
	// child = 0;
}

void op_unary_astnode::print(int blanks){
	string str = "\"" + left + "\"";
	char *str1 = const_cast<char *>(str.c_str());
	printAst("op_unary","sa","op",str1,"child",right);
}

//////////////////////////////////////////////////////////////////////
assignE_astnode::assignE_astnode(exp_astnode *e1,exp_astnode *e2) : exp_astnode()
{
	left = e1;
	right = e2;
	astnode_type = AssignE_astnode;
	// child = 0;
}

void assignE_astnode::print(int blanks){
	printAst("assignE","aa","left",left,"right",right);
}

//////////////////////////////////////////////////////////////////////

funcall_astnode::funcall_astnode() : exp_astnode()
{
	astnode_type = Funcall_astnode;
}

funcall_astnode::funcall_astnode(identifier_astnode *child) : exp_astnode()
{
	funcname = child;
	astnode_type = Funcall_astnode;
}

void funcall_astnode::setname(string name, string s){
	funcname = new identifier_astnode(name);
	function_type = s;
}

void funcall_astnode::pushback(exp_astnode* e)
{
	vect.push_back(e);
}

void funcall_astnode::print(int blanks){
	int s = vect.size();
	for(int i=s-1;i>=0;i--){
		genCode(vect[i]);
		cout<<"\tpushl\t"<<regi.top()<<endl;
	}
	cout<<"\tcall\t"<<funcname->id<<endl;
	cout<<"\taddl\t$"<<s*4<<", %esp"<<endl;
	// printAst("funcall","al","fname",funcname,"params",vect);
}

////////////////////////////////////////////////////////////////////////////

// floatconst_astnode::floatconst_astnode(float val) : exp_astnode()
// {
// 	value = val;
// 	astnode_type = Floatconst_astnode;
// }

// void floatconst_astnode::print(int blanks){
// 	printAst("","f","floatconst",value);
// }

/////////////////////////////////////////////////////////////////

intconst_astnode::intconst_astnode(int val) : exp_astnode()
{
	value = val;
	astnode_type = Intconst_astnode;
	// child = 1;
}

void intconst_astnode::print(int blanks){
	printAst("","i","intconst",value);
}

//////////////////////////////////////////////////////////////////////////////


stringconst_astnode::stringconst_astnode(string s) : exp_astnode()
{
	value = s;
	astnode_type = Stringconst_astnode;
	// child = 1;
}

void stringconst_astnode::print(int blanks){
	string str = value;
	char *str1 = const_cast<char *>(str.c_str());
	printAst("","s","stringconst",str1);
}

///////////////////////////////////////////////////////////////////

member_astnode::member_astnode(exp_astnode *e,identifier_astnode *i) : ref_astnode()
{
	left = e;
	right = i;
	astnode_type = Member_astnode;
}

void member_astnode::print(int blanks){
	printAst("member","aa","struct",left,"field",right);
}

//////////////////////////////////////////////////////////////////////

arrow_astnode::arrow_astnode(exp_astnode *e,identifier_astnode *i) : ref_astnode()
{
	left = e;
	right = i;
	astnode_type = Arrow_astnode;
}

void arrow_astnode::print(int blanks){
	printAst("arrow","aa","pointer",left,"field",right);
}

////////////////////////////////////////////////////////////////////////////////

identifier_astnode::identifier_astnode(string s) : ref_astnode()
{
	id = s;
	astnode_type = Identifier_astnode;
}

void identifier_astnode::print(int blanks){
	string str = "\"" + id + "\"";
	char *str1 = const_cast<char *>(str.c_str());
	printAst("","s","identifier",str1);
}

////////////////////////////////////////////////////////////////////

arrayref_astnode::arrayref_astnode(exp_astnode *e1,exp_astnode *e2) : ref_astnode()
{
	left = e1;
	right = e2;
	astnode_type = Arrayref_astnode;
}

void arrayref_astnode::print(int blanks){
	printAst("arrayref","aa","array",left,"index",right);
}

//////////////////////////////////////////////////////////////////////////////

type_specifier_class::type_specifier_class(string s)
{
	type = s;
}

type_specifier_class::type_specifier_class(string s,string t)
{
	type = s;
	type2 = t;
}

///////////////////////////////////////////////////////////////////////////////

declarator_class::declarator_class(string s)
{
	identifier = s;
	star = 0;
}

//////////////////////////////////////////////////////////////////////////////////////////

parameter_declaration_class::parameter_declaration_class(type_specifier_class* l,declarator_class* r)
{
	type = l;
	decl = r;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////

parameter_list_class::parameter_list_class()
{

}

void parameter_list_class::pushback(parameter_declaration_class* subtree)
{
	children.push_back(subtree);
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

fun_declarator_class::fun_declarator_class(string s)
{
	identifier = s;
}

fun_declarator_class::fun_declarator_class(string s,parameter_list_class* r)
{
	identifier = s;
	right = r;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

declarator_list_class::declarator_list_class()
{

}

void declarator_list_class::pushback(declarator_class* subtree)
{
	children.push_back(subtree);
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////

declaration_class::declaration_class(type_specifier_class*l , declarator_list_class* r)
{
	type = l;
	decl_list = r;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////

declaration_list_class::declaration_list_class()
{

}

void declaration_list_class::pushback(declaration_class* subtree)
{
	children.push_back(subtree);
}

//////////////////////////////////////////////////////////////////////////////////////////////////




