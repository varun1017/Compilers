#ifndef AST_HH
#define AST_HH

#include <fstream>
#include <bits/stdc++.h>
using namespace std;

enum typeExp {
    Statement_astnode,
    Exp_astnode,
    Empty_astnode,
    Seq_astnode,
    AssignS_astnode,
    Return_astnode,
    If_astnode,
    While_astnode,
    For_astnode,
    Proccall_astnode,
    Printfcall_astnode,
    Ref_astnode,
    Identifier_astnode,
    Arrayref_astnode,
    Member_astnode,
    Arrow_astnode,
    Op_binary_astnode,
    Op_unary_astnode,
    AssignE_astnode,
    Funcall_astnode,
    Intconst_astnode,
    Floatconst_astnode,
    Stringconst_astnode
};

class abstract_astnode
{
public:
virtual void print(int blanks) = 0;
enum typeExp astnode_type;
};

class statement_astnode : public abstract_astnode
{
public:
statement_astnode();
virtual void print(int blanks) = 0;
int lc_num;
};

class exp_astnode : public abstract_astnode
{
public:
exp_astnode();
virtual void print(int blanks) = 0;
int reg_num;
int child;
int offset;
string name_bro;
// string id;
// string left;
// exp_astnode *middle;
// exp_astnode *right;
};

class stringconst_astnode : public exp_astnode
{
public:
string value;
stringconst_astnode(string s);
void print(int blanks);
};

class ref_astnode : public exp_astnode
{
public:
bool lvalue;
ref_astnode();
virtual void print(int blanks) = 0;
};

class empty_astnode : public statement_astnode
{
public:
empty_astnode();
void print(int blanks);
};

class seq_astnode : public statement_astnode
{
public:
seq_astnode();
vector<statement_astnode*> vect;
string function_type;
void pushback(statement_astnode *s, string s2);
void print(int blanks);
};

class assignS_astnode : public statement_astnode
{
public:
assignS_astnode(exp_astnode* e1,exp_astnode* e2);
void print(int blanks);
exp_astnode* left;
exp_astnode* right; 
};

class return_astnode : public statement_astnode
{
public:
exp_astnode *sing;
string function_name;
string function_type;
return_astnode(exp_astnode* e, string s1, string s2);
void print(int blanks);
};

class if_astnode : public statement_astnode
{
public:
exp_astnode *left;
statement_astnode *middle;
statement_astnode *right;
if_astnode(exp_astnode *e,statement_astnode *s1,statement_astnode *s2);
void print(int blanks);
};

class while_astnode : public statement_astnode
{
public:
exp_astnode *left;
statement_astnode *right;
while_astnode(exp_astnode *e, statement_astnode *s);
void print(int blanks);
};

class for_astnode : public statement_astnode
{
public:
exp_astnode *left;
exp_astnode *middle1;
exp_astnode *middle2;
statement_astnode *right;
for_astnode(exp_astnode *e1,exp_astnode *e2,exp_astnode *e3,statement_astnode *s);
void print(int blanks);
};

class identifier_astnode : public ref_astnode
{
public:
string id;
// int offset;
identifier_astnode(string s);
void print(int blanks);
};

class proccall_astnode : public statement_astnode
{
public:
identifier_astnode *funcname;
proccall_astnode();
proccall_astnode(identifier_astnode *child);
vector<exp_astnode*> vect;
void setname(string name);
void pushback(exp_astnode *e);
void print(int blanks);
};

class printfcall_astnode : public statement_astnode
{
public:
// string strval;
stringconst_astnode *strval;
printfcall_astnode();
printfcall_astnode(stringconst_astnode *s);
vector<exp_astnode*> vect;
// void setname(string name);
void pushback(exp_astnode *e);
void print(int blanks);
};


class op_binary_astnode : public exp_astnode
{
public:
string left;
exp_astnode *middle;
exp_astnode *right;
op_binary_astnode(string s,exp_astnode *e1,exp_astnode *e2);
void print(int blanks);
};

class op_unary_astnode : public exp_astnode
{
public:
string left;
exp_astnode *right;
op_unary_astnode(string s,exp_astnode *e);
void print(int blanks);
};

class assignE_astnode : public exp_astnode
{
public:
exp_astnode *left;
exp_astnode *right;
assignE_astnode(exp_astnode *e1,exp_astnode *e2);
void print(int blanks);
};

class funcall_astnode : public exp_astnode
{
public:
vector<exp_astnode*> vect;
identifier_astnode *funcname;
funcall_astnode();
funcall_astnode(identifier_astnode *child);
void setname(string name, string s);
void pushback(exp_astnode *e);
void print(int blanks);
string function_type;
};

class floatconst_astnode : public exp_astnode
{
public:
float value;
floatconst_astnode(float val);
void print(int blanks);
};

class intconst_astnode : public exp_astnode
{
public:
int value;
intconst_astnode(int val);
void print(int blanks);
};


class member_astnode : public ref_astnode
{
public:
exp_astnode *left;
identifier_astnode *right;
member_astnode(exp_astnode *e,identifier_astnode *i);
void print(int blanks);
};

class arrow_astnode : public ref_astnode
{
public:
exp_astnode *left;
identifier_astnode *right;
arrow_astnode(exp_astnode *e,identifier_astnode *i);
void print(int blanks);
};


class arrayref_astnode : public ref_astnode
{
public:
exp_astnode *left;
exp_astnode *right;
arrayref_astnode(exp_astnode *e1,exp_astnode *e2);
void print(int blanks);
};


//////////////////////////////////////////////////////////////////////////////////////

class type_specifier_class
{
    public:
    string type;
    string type2;
    type_specifier_class(string s);
    type_specifier_class(string s,string t);
};

class declarator_class
{
    public:
    string identifier;
    vector<int> index;
    declarator_class(string s);
    int star;
};

class parameter_declaration_class{
    public:
    type_specifier_class* type;
    declarator_class* decl;
    parameter_declaration_class(type_specifier_class* l,declarator_class* r);
};

class parameter_list_class
{
    public:
    vector<parameter_declaration_class*> children;
    parameter_list_class();
    void pushback(parameter_declaration_class* subtree);
};

class fun_declarator_class
{
    public:
    string identifier;
    parameter_list_class* right;
    fun_declarator_class(string s);
    fun_declarator_class(string s,parameter_list_class* r);
};

class declarator_list_class
{
    public:
    vector<declarator_class*> children;
    declarator_list_class();
    void pushback(declarator_class* subtree);
};

class declaration_class
{
    public:
    type_specifier_class* type;
    declarator_list_class* decl_list;
    declaration_class(type_specifier_class*l , declarator_list_class* r);
};

class declaration_list_class
{
    public:
    int offset;
    vector<declaration_class*> children;
    declaration_list_class();
    void pushback(declaration_class* subtree);
};


/////////////////////////////////////////////////////////////////////////////////// 



#endif

