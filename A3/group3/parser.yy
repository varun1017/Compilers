%skeleton "lalr1.cc"
%require  "3.0.1"

%defines 
%define api.namespace {IPL}
%define api.parser.class {Parser}

%define parse.trace

%code requires{
   #include "ast.hh"
   #include "location.hh"
   #include "symbtab.hh"
   namespace IPL {
      class Scanner;
   }

  // # ifndef YY_NULLPTR
  // #  if defined __cplusplus && 201103L <= __cplusplus
  // #   define YY_NULLPTR nullptr
  // #  else
  // #   define YY_NULLPTR 0
  // #  endif
  // # endif

}

%printer { std::cerr << $$; } VOID
%printer { std::cerr << $$; } INT
%printer { std::cerr << $$; } STRUCT
%printer { std::cerr << $$; } IF
%printer { std::cerr << $$; } ELSE
%printer { std::cerr << $$; } FOR
%printer { std::cerr << $$; } WHILE
%printer { std::cerr << $$; } RETURN
%printer { std::cerr << $$; } CONSTANT_INT
%printer { std::cerr << $$; } IDENTIFIER
%printer { std::cerr << $$; } CONSTANT_STR
%printer { std::cerr << $$; } OP_LT
%printer { std::cerr << $$; } OP_GT
%printer { std::cerr << $$; } OP_LTE
%printer { std::cerr << $$; } OP_GTE
%printer { std::cerr << $$; } OP_EQ
%printer { std::cerr << $$; } OP_NEQ
%printer { std::cerr << $$; } OP_INC
%printer { std::cerr << $$; } OP_PTR
%printer { std::cerr << $$; } OP_OR
%printer { std::cerr << $$; } OP_AND
%printer { std::cerr << $$; } LCB
%printer { std::cerr << $$; } RCB
%printer { std::cerr << $$; } LRB
%printer { std::cerr << $$; } RRB
%printer { std::cerr << $$; } LSB
%printer { std::cerr << $$; } RSB
%printer { std::cerr << $$; } OP_ADD
%printer { std::cerr << $$; } OP_SUB
%printer { std::cerr << $$; } OP_MUL
%printer { std::cerr << $$; } OP_DIV
%printer { std::cerr << $$; } OP_MEM
%printer { std::cerr << $$; } OP_NOT
%printer { std::cerr << $$; } OP_ADDR
%printer { std::cerr << $$; } OP_ASSIGN
%printer { std::cerr << $$; } MAIN
%printer { std::cerr << $$; } PRINTF
%printer { std::cerr << $$; } COMMA
%printer { std::cerr << $$; } EOS
%printer { std::cerr << $$; } OTHERS



%parse-param { Scanner  &scanner  }
%locations
%code{
   #include <bits/stdc++.h>
   #include "scanner.hh"
   using namespace std;


   string func_name,struct_name;
   string curfuntyp;
   map<string,abstract_astnode*> ast;
   int n_size;
   extern SymbTab gst;
   SymbTab* st;

   int y = 0;
   int lc_count = 0;
   int struct_size = 4;


#undef yylex
#define yylex IPL::Parser::scanner.yylex


}



%define api.value.type variant
%define parse.assert

%start program



%token '\n'
%token <std::string> VOID
%token <std::string> INT
%token <std::string> STRUCT
%token <std::string> IF
%token <std::string> ELSE
%token <std::string> FOR
%token <std::string> WHILE
%token <std::string> RETURN
%token <std::string> CONSTANT_INT
%token <std::string> IDENTIFIER
%token <std::string> CONSTANT_STR
%token <std::string> OP_LT
%token <std::string> OP_GT
%token <std::string> OP_LTE
%token <std::string> OP_GTE
%token <std::string> OP_EQ
%token <std::string> OP_NEQ
%token <std::string> OP_INC
%token <std::string> OP_PTR
%token <std::string> OP_OR
%token <std::string> OP_AND
%token <std::string> LCB
%token <std::string> RCB
%token <std::string> LRB
%token <std::string> RRB
%token <std::string> LSB
%token <std::string> RSB
%token <std::string> OP_ADD
%token <std::string> OP_SUB
%token <std::string> OP_MUL
%token <std::string> OP_DIV
%token <std::string> OP_MEM
%token <std::string> OP_NOT
%token <std::string> OP_ADDR
%token <std::string> OP_ASSIGN
%token <std::string> MAIN
%token <std::string> PRINTF
%token <std::string> COMMA
%token <std::string> EOS
%token <std::string> OTHERS

%nterm <abstract_astnode*> program;
%nterm <abstract_astnode*> main_definition;
%nterm <abstract_astnode*> translation_unit;
%nterm <abstract_astnode*> struct_specifier;
%nterm <abstract_astnode*> function_definition;
%nterm <abstract_astnode*> compound_statement;

%nterm <type_specifier_class*> type_specifier;
%nterm <declarator_class*> declarator_arr;
%nterm <declarator_class*> declarator;
%nterm <declaration_class*> declaration;
%nterm <declarator_list_class*> declarator_list;
%nterm <declaration_list_class*> declaration_list;
%nterm <fun_declarator_class*> fun_declarator;
%nterm <parameter_list_class*> parameter_list;
%nterm <parameter_declaration_class*> parameter_declaration;

%nterm <exp_astnode*> expression;
%nterm <exp_astnode*> logical_and_expression;
%nterm <exp_astnode*> equality_expression;
%nterm <exp_astnode*> relational_expression;
%nterm <exp_astnode*> additive_expression;
%nterm <exp_astnode*> multiplicative_expression;
%nterm <exp_astnode*> unary_expression;
%nterm <exp_astnode*> postfix_expression;
%nterm <exp_astnode*> primary_expression;

%nterm <seq_astnode*> statement_list;
%nterm <statement_astnode*> statement;
%nterm <statement_astnode*> selection_statement;
%nterm <statement_astnode*> iteration_statement;
%nterm <assignE_astnode*> assignment_expression;
%nterm <std::string> unary_operator;
%nterm <vector<exp_astnode*>> expression_list;
%nterm <proccall_astnode*> procedure_call;
%nterm <printfcall_astnode*> printf_call;


%%

program
  : main_definition // P1
  {
      ast[func_name] = $1;
  }
  | translation_unit main_definition 
  {
    ast["main"] = $2;
  }// P3

translation_unit
  : struct_specifier // P4
  | function_definition
  {
    ast[func_name] = $1;
  } // P3
  | translation_unit struct_specifier // P4
  | translation_unit function_definition
  {
    ast[func_name] = $2;
  } // P3

/* Struct Declaration */

struct_specifier
  : STRUCT IDENTIFIER LCB declaration_list RCB EOS
  {
    st = new SymbTab();
    vector<declaration_class*> vect = $4->children;
    int x = struct_size;
    for(int i=0;i<(int)vect.size();i++){
        string typ = vect[i]->type->type;
        declarator_list_class* decl_list = vect[i]->decl_list;
        vector<declarator_class*> vect2 = decl_list->children;
        for(int j=0;j<(int)vect2.size();j++){
          SymbTabEntry* se = new SymbTabEntry();
          se->stentyp = typ;
          se->size = 0;
          se->varfun = "var";
          string id = vect2[j]->identifier;
          int y;
          if(typ=="int"||typ=="void"){
              y = 4;
          } 
          if(typ.find("struct")!=string::npos){
              y = gst.Entries[typ].size;           
          } 
          se->offset = x;
          x = x + y;
          se->size = y;
          se->type = typ;   
          se->pos = "local";
          st->Entries.insert({id,*se});
        }
    }
    struct_name = "struct " + $2;
    SymbTabEntry* se2 = new SymbTabEntry();
    se2->stentyp = "-";
    se2->size = x;
    struct_size = struct_size + x;
    se2->pos = "global";
    se2->varfun = "struct";
    se2->symbtab = st;
    se2->offset = 0;
    gst.Entries.insert({struct_name,*se2});    
  } // P4


/* Function Definition */

function_definition
  : type_specifier IDENTIFIER LRB RRB
  {
    st = new SymbTab();
    string return_type = $1->type;
    curfuntyp = $1->type;
    func_name = $2;
    SymbTabEntry* se = new SymbTabEntry();
    se->stentyp = return_type;
    se->size = 0;
    se->varfun = "fun";
    se->pos = "global";
    se->symbtab = st;
    gst.Entries.insert({func_name,*se});
  } 
  compound_statement
  {
    $$ = $6;
  } // P3
  | type_specifier IDENTIFIER LRB parameter_list RRB
  {
    st = new SymbTab();
    string return_type = $1->type;
    curfuntyp = $1->type;
    func_name = $2;
    SymbTabEntry* se = new SymbTabEntry();
    se->stentyp = return_type;
    se->size = 0;
    se->varfun = "fun";
    se->pos = "global";
    se->symbtab = st;
    gst.Entries.insert({func_name,*se});
    int x = 8;
    vector<parameter_declaration_class*> vect = $4->children;
    for(int i=0;i<(int)vect.size();i++){
      SymbTabEntry* se2 = new SymbTabEntry();
      se2->stentyp = vect[i]->type->type;
      se2->type = vect[i]->type->type;
      se2->size = 0;
      se2->varfun = "var";
      string id = vect[i]->decl->identifier;
      int y;
      if(vect[i]->type->type == "int"||vect[i]->type->type == "void"){
          y=4;
      }
      if(vect[i]->type->type.find("struct")!=string::npos){
          y = gst.Entries[vect[i]->type->type].size;         
      }                            
      se2->offset = x;
      se2->size = y;
      x = x + y;
      se2->pos = "param";
      st->Entries.insert({id,*se2});
    }
    
  } 
  compound_statement
  {
    $$ = $7;
  } // P3

/* Main Function */

main_definition
  : INT MAIN LRB RRB 
    {
      func_name = "main";
      curfuntyp = "int";
      st = new SymbTab();
      SymbTabEntry* se = new SymbTabEntry();
      se->stentyp = "int";
      se->size = 0;
      se->varfun = "fun";
      se->pos = "global";
      se->symbtab = st;
      gst.Entries.insert({"main",*se});
  }
  compound_statement
  {
      $$ = $6;
  } 
  // P1


/* Type Specifier */

type_specifier
  : VOID
  {
    $$ = new type_specifier_class($1);
  } // P3
  | INT 
  {
      $$ = new type_specifier_class($1);
  } // P1
  | STRUCT IDENTIFIER
  {
    $$ = new type_specifier_class($1+" "+$2);
  } // P4

/* Declaration List */

declaration_list
  : declaration
  {
      $$ = new declaration_list_class();
      $$->children.push_back($1);
  } // P1
  | declaration_list declaration
  {
      $$ = $1;
      $$->children.push_back($2);
  } // P1

declaration
  : type_specifier declarator_list EOS
  {
      $$ = new declaration_class($1,$2);
  } // P1

declarator_list
  : declarator
  {
      $$ = new declarator_list_class();
      $$->pushback($1);
  } // P1
  | declarator_list COMMA declarator
  {
      $$ = $1;
      $$->children.push_back($3);
  } // P1

declarator
  : declarator_arr 
  {
      $$ = $1;
  } // P1
  | OP_MUL declarator // P5

declarator_arr
  : IDENTIFIER
  {
      $$ = new declarator_class($1);
  } // P1
  | declarator_arr LSB CONSTANT_INT RSB // P6

/* Parameter List */

parameter_list
  : parameter_declaration
  {
    $$ = new parameter_list_class();
    $$->children.push_back($1);
  } // P3
  | parameter_list COMMA parameter_declaration
  {
    $$ = $1;
    $$->children.push_back($3);
  } // P3

parameter_declaration
  : type_specifier declarator
  {
    $$ = new parameter_declaration_class($1,$2);
  } // P3

/* Statements */
compound_statement
  : LCB RCB
  {
    $$ = new seq_astnode();
  } // P1
  | LCB statement_list RCB
  {
      $$ = $2;
  } // P1
  | LCB declaration_list
  {
    vector<declaration_class*> vect = $2->children;
    int x = 0;                        
    for(int i=0;i<(int)vect.size();i++){
        string typ = vect[i]->type->type;
        declarator_list_class* decl_list = vect[i]->decl_list;
        vector<declarator_class*> vect2 = decl_list->children;
        for(int j=0;j<(int)vect2.size();j++){
            SymbTabEntry* se = new SymbTabEntry();
            se->stentyp = typ;
            se->size = 0;
            se->varfun = "var";
            string id = vect2[j]->identifier;
            int y;
            if(typ=="int"||typ=="void"){
                y = -4;
            }
            if(typ.find("struct")!=string::npos){
              y = -1*gst.Entries[typ].size;
            }  
            st->Entries.insert({id,*se});
            st->Entries[id].pos = "local";
            st->Entries[id].offset = x + y;
            x = x+y;
            st->Entries[id].size = -y;
            st->Entries[id].pos = "local";                  
            st->Entries[id].varfun = "var";
            st->Entries[id].stentyp = typ;
            st->Entries[id].type = typ;      
        }
    }
  } statement_list RCB
  {
      $$ = $4;
  } // P1

statement_list
  : statement
  {
      $$ = new seq_astnode();
      $$->pushback($1, curfuntyp);
  } // P1
  | statement_list statement
  {
      $$ = $1;
      $$->pushback($2, curfuntyp);
  } // P1

statement
  : EOS
  {
      $$ = new empty_astnode();
  } // P1
  | LCB statement_list RCB
  {
      $$ = $2;
  } // P1
  | assignment_expression EOS
  {
      $$ = new assignS_astnode($1->left,$1->right);
  } // P1
  | selection_statement
  {
    $$ = $1;
  } // P2
  | iteration_statement
  {
    $$ = $1;
  } // P2
  | procedure_call
  {
    $$ = $1;
  } // P3
  | printf_call
  {
      $$ = $1;
  } // P1
  | RETURN expression EOS
  {
      $$ = new return_astnode($2, func_name, curfuntyp);
      
  } // P1

/* Expressions */
assignment_expression
  : unary_expression OP_ASSIGN expression
  {
    $$ = new assignE_astnode($1,$3);
    if($1->reg_num == $3->reg_num){
      $$->reg_num = $1->reg_num + 1;
    }
    else if($1->reg_num > $3->reg_num){
      $$->reg_num = $1->reg_num;
    }
    else if($1->reg_num < $3->reg_num){
      $$->reg_num = $3->reg_num;
    };
  } // P1

expression
  : logical_and_expression
  {
      $$ = $1;
  } // P1
  | expression OP_OR logical_and_expression
  {
    $$ = new op_binary_astnode("OP_OR",$1,$3);    
    if($1->reg_num == $3->reg_num){
      $$->reg_num = $1->reg_num + 1;
    }
    else if($1->reg_num > $3->reg_num){
      $$->reg_num = $1->reg_num;
    }
    else if($1->reg_num < $3->reg_num){
      $$->reg_num = $3->reg_num;
    };
  } // P1

logical_and_expression
  : equality_expression
  {
      $$ = $1;
  } // P1
  | logical_and_expression OP_AND equality_expression
  {
      $$ = new op_binary_astnode("OP_AND",$1,$3);
      if($1->reg_num == $3->reg_num){
        $$->reg_num = $1->reg_num + 1;
      }
      else if($1->reg_num > $3->reg_num){
        $$->reg_num = $1->reg_num;
      }
      else if($1->reg_num < $3->reg_num){
        $$->reg_num = $3->reg_num;
      };
  } // P1

equality_expression
  : relational_expression
  {
      $$ = $1;
  } // P1
  | equality_expression OP_EQ relational_expression
  {
      $$ = new op_binary_astnode("OP_EQ",$1,$3);
      if($1->reg_num == $3->reg_num){
        $$->reg_num = $1->reg_num + 1;
      }
      else if($1->reg_num > $3->reg_num){
        $$->reg_num = $1->reg_num;
      }
      else if($1->reg_num < $3->reg_num){
        $$->reg_num = $3->reg_num;
      };
  } // P1
  | equality_expression OP_NEQ relational_expression
  {
      $$ = new op_binary_astnode("OP_NEQ",$1,$3);
      if($1->reg_num == $3->reg_num){
        $$->reg_num = $1->reg_num + 1;
      }
      else if($1->reg_num > $3->reg_num){
        $$->reg_num = $1->reg_num;
      }
      else if($1->reg_num < $3->reg_num){
        $$->reg_num = $3->reg_num;
      };
  } // P1

relational_expression
  : additive_expression
  {
      $$ = $1;
  }
  | relational_expression OP_LT additive_expression
  {
      $$ = new op_binary_astnode("OP_LT",$1,$3);   
      if($1->reg_num == $3->reg_num){
        $$->reg_num = $1->reg_num + 1;
      }
      else if($1->reg_num > $3->reg_num){
        $$->reg_num = $1->reg_num;
      }
      else if($1->reg_num < $3->reg_num){
        $$->reg_num = $3->reg_num;
      };   
  } // P1
  | relational_expression OP_GT additive_expression
  {
      $$ = new op_binary_astnode("OP_GT",$1,$3);
      if($1->reg_num == $3->reg_num){
        $$->reg_num = $1->reg_num + 1;
      }
      else if($1->reg_num > $3->reg_num){
        $$->reg_num = $1->reg_num;
      }
      else if($1->reg_num < $3->reg_num){
        $$->reg_num = $3->reg_num;
      };
  } // P1
  | relational_expression OP_LTE additive_expression
  {
      $$ = new op_binary_astnode("OP_LTE",$1,$3);
      if($1->reg_num == $3->reg_num){
        $$->reg_num = $1->reg_num + 1;
      }
      else if($1->reg_num > $3->reg_num){
        $$->reg_num = $1->reg_num;
      }
      else if($1->reg_num < $3->reg_num){
        $$->reg_num = $3->reg_num;
      };
  } // P1
  | relational_expression OP_GTE additive_expression
  {
      $$ = new op_binary_astnode("OP_GTE",$1,$3);
      if($1->reg_num == $3->reg_num){
        $$->reg_num = $1->reg_num + 1;
      }
      else if($1->reg_num > $3->reg_num){
        $$->reg_num = $1->reg_num;
      }
      else if($1->reg_num < $3->reg_num){
        $$->reg_num = $3->reg_num;
      };
  } // P1

additive_expression
  : multiplicative_expression
  {
      $$ = $1;
  } // P1
  | additive_expression OP_ADD multiplicative_expression
  {
      $$ = new op_binary_astnode("OP_ADD",$1,$3);
      if($1->reg_num == $3->reg_num){
        $$->reg_num = $1->reg_num + 1;
      }
      else if($1->reg_num > $3->reg_num){
        $$->reg_num = $1->reg_num;
      }
      else if($1->reg_num < $3->reg_num){
        $$->reg_num = $3->reg_num;
      };
  } // P1
  | additive_expression OP_SUB multiplicative_expression
  {
      $$ = new op_binary_astnode("OP_SUB",$1,$3);
      if($1->reg_num == $3->reg_num){
        $$->reg_num = $1->reg_num + 1;
      }
      else if($1->reg_num > $3->reg_num){
        $$->reg_num = $1->reg_num;
      }
      else if($1->reg_num < $3->reg_num){
        $$->reg_num = $3->reg_num;
      };
  } // P1

multiplicative_expression
  : unary_expression
  {
      $$ = $1;
  } // P1
  | multiplicative_expression OP_MUL unary_expression
  {
      $$ = new op_binary_astnode("OP_MUL",$1,$3);
      if($1->reg_num == $3->reg_num){
        $$->reg_num = $1->reg_num + 1;
      }
      else if($1->reg_num > $3->reg_num){
        $$->reg_num = $1->reg_num;
      }
      else if($1->reg_num < $3->reg_num){
        $$->reg_num = $3->reg_num;
      };
  } // P1
  | multiplicative_expression OP_DIV unary_expression
  {
      $$ = new op_binary_astnode("OP_DIV",$1,$3);
      if($1->reg_num == $3->reg_num){
        $$->reg_num = $1->reg_num + 1;
      }
      else if($1->reg_num > $3->reg_num){
        $$->reg_num = $1->reg_num;
      }
      else if($1->reg_num < $3->reg_num){
        $$->reg_num = $3->reg_num;
      };
  } // P1

unary_expression
  : postfix_expression
  {
      $$ = $1;
  } // P1
  | unary_operator unary_expression
  {
        $$ = new op_unary_astnode($1,$2);
        $$->reg_num = $2->reg_num;
  } // P1

postfix_expression
  : primary_expression
  {
        $$ = $1;
  } // P1
  | postfix_expression OP_INC
  {
      $$ = new op_unary_astnode("PP",$1);
      $$->reg_num = $1->reg_num;
  } // P1
  | IDENTIFIER LRB RRB
  {
    funcall_astnode * f = new funcall_astnode();
    f->setname($1, curfuntyp);
    $$ = f;
  } // P3
  | IDENTIFIER LRB expression_list RRB
  {
    funcall_astnode * f = new funcall_astnode();
    f->setname($1, curfuntyp);
    f->vect = $3;
    $$ = f;  
  } // P3
  | postfix_expression OP_MEM IDENTIFIER
  {
   
    $$ = new member_astnode($1,new identifier_astnode($3));
    SymbTabEntry* se = gst.search($1->name_bro);
    
    if(se==NULL){
        cout<<"Error: "<<endl;
    }
    SymbTab* se2 = se->symbtab;
    SymbTabEntry* se3 = se2->search($3);
    $$->offset = -se3->offset;
    $$->name_bro = se3->stentyp;
    
  } // P4
  | postfix_expression OP_PTR IDENTIFIER // P5
  | postfix_expression LSB expression RSB // P6

primary_expression
  : IDENTIFIER
  {
    $$ = new identifier_astnode($1);
    SymbTabEntry* se = st->search($1);
    if(se==NULL){
        cout<<"Error: "<<endl;
    }
    $$->offset = se->offset;
    $$->name_bro = se->stentyp; 
    $$->reg_num = 1;     
  } // P1
  | CONSTANT_INT
  {
    $$ = new intconst_astnode(stoi($1));
    $$->reg_num = 1;
  } // P1
  | LRB expression RRB
  {
      $$ = $2;
  } // P1

unary_operator
  : OP_SUB
  {
      $$ = $1;
  } // P1
  | OP_NOT
  {
      $$ = $1;
  } // P1
  | OP_ADDR // P5
  | OP_MUL // P5

/* Selection Statement */
selection_statement
  : IF LRB expression RRB statement ELSE statement
  {
    $$ = new if_astnode($3,$5,$7);
  } // P2

/* Iteration Statement */
iteration_statement
  : WHILE LRB expression RRB statement
  {
    $$ = new while_astnode($3,$5);
  } // P2
  | FOR LRB assignment_expression EOS expression EOS assignment_expression RRB statement
  {
    $$ = new for_astnode($3,$5,$7,$9);
  } // P2

/* Expression List */
expression_list
  : expression
  {
      $$.push_back($1);
  } // P1
  | expression_list COMMA expression
  {
      $$ = $1;
      $$.push_back($3);
  } // P1

/* Procedure Call */
procedure_call
  : IDENTIFIER LRB RRB EOS
  {
    $$ = new proccall_astnode(new identifier_astnode($1));
  } // P3
  | IDENTIFIER LRB expression_list RRB EOS
  {
    $$ = new proccall_astnode(new identifier_astnode($1));
    $$->vect = $3;
  } // P3

/* Printf Call */
printf_call
  : PRINTF LRB CONSTANT_STR RRB EOS
  {
      $$ = new printfcall_astnode(new stringconst_astnode($3));
      cout<<"\t.section\t.rodata"<<endl;
      cout<<".LC"<<lc_count<<":"<<endl;
      $$->lc_num = lc_count;
      lc_count++;
      cout<<"\t.string\t"<<$3<<endl;
  } // P1
  | PRINTF LRB CONSTANT_STR COMMA expression_list RRB EOS
  {
      $$ = new printfcall_astnode(new stringconst_astnode($3));
      $$->vect = $5;
      cout<<"\t.section\t.rodata"<<endl;
      cout<<".LC"<<lc_count<<":"<<endl;
      $$->lc_num = lc_count;
      lc_count++;
      cout<<"\t.string\t"<<$3<<endl;
  } // P1


               
%%
void IPL::Parser::error( const location_type &l, const std::string &err_message )
{
   std::cerr << "Error: " << err_message << " at " << l << "\n";
}


