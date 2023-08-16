
#include "scanner.hh"
#include "parser.tab.hh"
#include "ast.hh"
#include <fstream>
using namespace std;


void printAst(const char *astname, const char *fmt...) // fmt is a format string that tells about the type of the arguments.
{   
	typedef vector<abstract_astnode *>* pv;
	va_list args;
	va_start(args, fmt);
	if ((astname != NULL) && (astname[0] != '\0'))
	{
		cout << "{ ";
		cout << "\"" << astname << "\"" << ": ";
	}
	cout << "{" << endl;
	while (*fmt != '\0')
	{
		if (*fmt == 'a')
		{
			char * field = va_arg(args, char *);
			abstract_astnode *a = va_arg(args, abstract_astnode *);
			cout << "\"" << field << "\": " << endl;
			
			a->print(0);
		}
		else if (*fmt == 's')
		{
			char * field = va_arg(args, char *);
			char *str = va_arg(args, char *);
			cout << "\"" << field << "\": ";

			cout << str << endl;
		}
		else if (*fmt == 'i')
		{
			char * field = va_arg(args, char *);
			int i = va_arg(args, int);
			cout << "\"" << field << "\": ";

			cout << i;
		}
		else if (*fmt == 'f')
		{
			char * field = va_arg(args, char *);
			double f = va_arg(args, double);
			cout << "\"" << field << "\": ";
			cout << f;
		}
		else if (*fmt == 'l')
		{
			char * field = va_arg(args, char *);
			pv f =  va_arg(args, pv);
			cout << "\"" << field << "\": ";
			cout << "[" << endl;
			for (int i = 0; i < (int)f->size(); ++i)
			{
				(*f)[i]->print(0);
				if (i < (int)f->size() - 1)
					cout << "," << endl;
				else
					cout << endl;
			}
			cout << endl;
			cout << "]" << endl;
		}
		++fmt;
		if (*fmt != '\0')
			cout << "," << endl;
	}
	cout << "}" << endl;
	if ((astname != NULL) && (astname[0] != '\0'))
		cout << "}" << endl;
	va_end(args);
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
	cout<<"\"empty\""<<endl;
}

///////////////////////////////////////////////////////



seq_astnode::seq_astnode() : statement_astnode(){
	astnode_type = Seq_astnode;
}

void seq_astnode::pushback(statement_astnode *s){
	vect.push_back(s);
}

void seq_astnode::print(int blanks){
	printAst("","l","seq",vect);
}

///////////////////////////////////////////////////////



assignS_astnode::assignS_astnode(exp_astnode *e1,exp_astnode *e2) : statement_astnode(){
	left = e1;
	right = e2;
	astnode_type = AssignS_astnode;
}

void assignS_astnode::print(int blanks){
	printAst("assignS","aa","left",left,"right",right);
}

////////////////////////////////////////////////////////

return_astnode::return_astnode(exp_astnode *e) :statement_astnode()
{
	sing = e;
	astnode_type = Return_astnode;
}

void return_astnode::print(int blanks){
	printAst("","a","return",sing);
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
	printAst("if","aaa","cond",left,"then",middle,"else",right);
}

//////////////////////////////////////////////////////////////

while_astnode::while_astnode(exp_astnode *e, statement_astnode *s) : statement_astnode()
{
	left = e;
	right = s;
	astnode_type = While_astnode;
}

void while_astnode::print(int blanks){
	printAst("while","aa","cond",left,"stmt",right);
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
	printAst("for","aaaa","init",left,"guard",middle1,"step",middle2,"body",right);
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
	printAst("proccall","al","fname",funcname,"params",vect);
}

//////////////////////////////////////////////////////////////////////////

op_binary_astnode::op_binary_astnode(string s,exp_astnode *e1,exp_astnode *e2) : exp_astnode()
{
	left = s;
	middle = e1;
	right = e2;
	astnode_type = Op_binary_astnode;
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

void funcall_astnode::setname(string name){
	funcname = new identifier_astnode(name);
}

void funcall_astnode::pushback(exp_astnode* e)
{
	vect.push_back(e);
}

void funcall_astnode::print(int blanks){
	printAst("funcall","al","fname",funcname,"params",vect);
}

////////////////////////////////////////////////////////////////////////////

floatconst_astnode::floatconst_astnode(float val) : exp_astnode()
{
	value = val;
	astnode_type = Floatconst_astnode;
}

void floatconst_astnode::print(int blanks){
	printAst("","f","floatconst",value);
}

/////////////////////////////////////////////////////////////////

intconst_astnode::intconst_astnode(int val) : exp_astnode()
{
	value = val;
	astnode_type = Intconst_astnode;
}

void intconst_astnode::print(int blanks){
	printAst("","i","intconst",value);
}

//////////////////////////////////////////////////////////////////////////////


stringconst_astnode::stringconst_astnode(string s) : exp_astnode()
{
	value = s;
	astnode_type = Stringconst_astnode;
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

bool isIntType(string s){
	return (s=="int");
}

bool isFloatType(string s){
	return (s=="float");
}


