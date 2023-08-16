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
%printer { std::cerr << $$; } FLOAT
%printer { std::cerr << $$; } STRUCT
%printer { std::cerr << $$; } IF
%printer { std::cerr << $$; } ELSE
%printer { std::cerr << $$; } FOR
%printer { std::cerr << $$; } WHILE
%printer { std::cerr << $$; } RETURN
%printer { std::cerr << $$; } INT_CONSTANT
%printer { std::cerr << $$; } FLOAT_CONSTANT
%printer { std::cerr << $$; } IDENTIFIER
%printer { std::cerr << $$; } STRING_LITERAL
%printer { std::cerr << $$; } LE_OP
%printer { std::cerr << $$; } GE_OP
%printer { std::cerr << $$; } EQ_OP
%printer { std::cerr << $$; } NE_OP
%printer { std::cerr << $$; } INC_OP
%printer { std::cerr << $$; } DEC_OP
%printer { std::cerr << $$; } PTR_OP
%printer { std::cerr << $$; } OR_OP
%printer { std::cerr << $$; } AND_OP
%printer { std::cerr << $$; } OTHERS



%parse-param { Scanner  &scanner  }
%locations
%code{
   #include <bits/stdc++.h>
   #include "scanner.hh"
   using namespace std;


   string fname,sname;
   SymbTabEntry* currFunc;
   map<string,abstract_astnode*> ast;

   extern SymbTab gst;
   SymbTab* st;

   int y = 0;


#undef yylex
#define yylex IPL::Parser::scanner.yylex


}



%define api.value.type variant
%define parse.assert

%start translation_unit



%token '\n'
%token <std::string> VOID
%token <std::string> INT
%token <std::string> FLOAT
%token <std::string> STRUCT
%token <std::string> IF
%token <std::string> ELSE
%token <std::string> FOR
%token <std::string> WHILE
%token <std::string> RETURN
%token <std::string> INT_CONSTANT
%token <std::string> FLOAT_CONSTANT
%token <std::string> IDENTIFIER
%token <std::string> STRING_LITERAL
%token <std::string> LE_OP
%token <std::string> GE_OP
%token <std::string> EQ_OP
%token <std::string> NE_OP
%token <std::string> INC_OP
%token <std::string> DEC_OP
%token <std::string> PTR_OP
%token <std::string> OR_OP
%token <std::string> AND_OP
%token '{' '}' '(' ')' '[' ']' '+' '-' '*' '/' '!' '&' '<' '>' ',' ':' ';' '=' '.'
%token <std::string> OTHERS

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
%nterm <assignS_astnode*> assignment_statement;
%nterm <assignE_astnode*> assignment_expression;
%nterm <std::string> unary_operator;
%nterm <vector<exp_astnode*>> expression_list;
%nterm <proccall_astnode*> procedure_call;


%%

    translation_unit: 
                     struct_specifier
                    | function_definition
                    {
                       ast[fname]=$1;
                    }
                     | translation_unit struct_specifier
                    | translation_unit function_definition
                     {
                       ast[fname]=$2;
                    }

     struct_specifier: 
                     STRUCT IDENTIFIER '{' declaration_list '}' ';'
                     {
                        st = new SymbTab();
                        vector<declaration_class*> vect = $4->children;
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
                              if(typ=="int"){
                                 y = 4;
                                 for(int k=0;k<(int)(vect2[j]->index).size();k++){
                                    y = y*(vect2[j]->index[k]);
                                 }
                              }
                              if(typ=="float"){
                                 y = 4;
                                 for(int k=0;k<(int)(vect2[j]->index).size();k++){
                                    y = y*(vect2[j]->index[k]);
                                 }
                              }
                              if(typ=="char"){
                                 y = 4;
                                 for(int k=0;k<(int)(vect2[j]->index).size();k++){
                                    y = y*(vect2[j]->index[k]);
                                 }
                              }
                              if(typ=="void"){
                                 y = 4;
                                 for(int k=0;k<(int)(vect2[j]->index).size();k++){
                                    y = y*(vect2[j]->index[k]);
                                 }
                              } 
                              if(typ.find("struct")!=string::npos){
                                 if((vect2[j]->star)>0){
                                    y = 4;
                                 }
                                 else{
                                    y = gst.Entries[typ].size;
                                 }
                                 for(int k=0;k<(int)(vect2[j]->index).size();k++){
                                    y = y*(vect2[j]->index[k]);
                                 }
                              } 

                              se->offset = x;
                              x = x + y;
                              se->size = y;
                              se->type = typ;
                              for(int l=0;l<(int)(vect2[j]->star);l++){
                                 se->stentyp = se->stentyp + "*";
                              }     
                              for(int m=0;m<(int)vect2[j]->index.size();m++){
                                 se->stentyp = se->stentyp+"["+to_string(vect2[j]->index[m])+"]";
                              }    

                              se->pos = "local";
                              st->Entries.insert({id,*se});

                           }
                        }

                        sname = "struct " + $2;
                        fname = ""; 
                        SymbTabEntry* se2 = new SymbTabEntry();

                        se2->stentyp = "-";
                        se2->size = x;
                        se2->pos = "global";
                        se2->varfun = "struct";
                        se2->symbtab = st;
                        se2->offset = 0;


                        gst.Entries.insert({sname,*se2});

                     }
                     ;

   function_definition: 
                        type_specifier fun_declarator 
                        {
                           st = new SymbTab();
                           string return_type = $1->type;
                           sname = "";
                           fname = $2->identifier;

                           SymbTabEntry* se = new SymbTabEntry();
                           se->stentyp = return_type;
                           se->size = 0;
                           se->varfun = "fun";
                           se->pos = "global";
                           se->symbtab = st;

                           gst.Entries.insert({$2->identifier,*se});

                           int x = 12;
                           vector<parameter_declaration_class*> vect = $2->right->children;
                           int sz = (int)vect.size();
                           for(int i=0;i<sz;i++){
                              SymbTabEntry* se2 = new SymbTabEntry();
                              se2->stentyp = vect[sz-1-i]->type->type;
                              se2->type = vect[sz-1-i]->type->type;
                              se2->size = 0;
                              se2->varfun = "var";
                              string id = vect[sz-1-i]->decl->identifier;
                              int y;
                              if(vect[sz-1-i]->type->type == "int"){
                                 y=4;
                                 for(int k=0;k<(int)(vect[sz-1-i]->decl->index).size();k++){
                                    y = y * (vect[sz-1-i]->decl->index[k]);
                                 }
                              }
                              if(vect[sz-1-i]->type->type == "float"){
                                 y=4;
                                 for(int k=0;k<(int)(vect[sz-1-i]->decl->index).size();k++){
                                    y = y * (vect[sz-1-i]->decl->index[k]);
                                 }
                              }
                              if(vect[sz-1-i]->type->type == "char"){
                                 y=4;
                                 for(int k=0;k<(int)(vect[sz-1-i]->decl->index).size();k++){
                                    y = y * (vect[sz-1-i]->decl->index[k]);
                                 }
                              }
                              if(vect[sz-1-i]->type->type == "void"){
                                 y=4;
                                 for(int k=0;k<(int)(vect[sz-1-i]->decl->index).size();k++){
                                    y = y * (vect[sz-1-i]->decl->index[k]);
                                 }
                              }

                              if(vect[sz-1-i]->type->type.find("struct")!=string::npos){
                                 if(vect[sz-1-i]->decl->star>0){
                                    y = 4;
                                 }
                                 else{
                                    y = gst.Entries[vect[sz-1-i]->type->type].size;
                                 }
                                 for(int k=0;k<(int)(vect[sz-1-i]->decl->index).size();k++){
                                    y = y * (vect[sz-1-i]->decl->index[k]);
                                 }
                              }

                              for(int l=0;l<(int)(vect[i]->decl->star);l++){
                                 se2->stentyp = se2->stentyp + "*";
                              }     
                              for(int m=0;m<(int)vect[i]->decl->index.size();m++){
                                 se2->stentyp = se2->stentyp+"["+to_string(vect[i]->decl->index[m])+"]";
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
                           $$ = $4;
                        }
                        ;

     type_specifier: 
                    VOID
                    {
                       $$ = new type_specifier_class($1);
                    }
                   | INT
                   {
                      $$ = new type_specifier_class($1);
                   }
                   | FLOAT
                   {
                      $$ = new type_specifier_class($1);
                   }
                   | STRUCT IDENTIFIER
                   {
                      $$ = new type_specifier_class($1+" "+$2);
                   }
                   ;

    fun_declarator: 
                  IDENTIFIER '(' parameter_list ')'
                  {
                     fname = $1;
                     $$ = new fun_declarator_class($1,$3);
                  }
                  | IDENTIFIER '(' ')'
                  {
                     $$ = new fun_declarator_class($1);
                     $$->right = new parameter_list_class();
                  }

    parameter_list: 
                  parameter_declaration
                  {
                     $$ = new parameter_list_class();
                     $$->children.push_back($1);
                  }
                  | parameter_list ',' parameter_declaration
                  {
                     $$ = $1;
                     $$->children.push_back($3);
                  }
                  ;

    parameter_declaration: 
                        type_specifier declarator
                        {
                           $$ = new parameter_declaration_class($1,$2);
                        }
                        ;

    declarator_arr: 
                  IDENTIFIER
                  {
                     $$ = new declarator_class($1);
                  }
                  | declarator_arr '[' INT_CONSTANT ']'
                  {
                     $$ = $1;
                     $$->index.push_back(stoi($3));
                  }
                  ;

    declarator: 
               declarator_arr
               {
                  $$ = $1;
               }
              | '*' declarator
               {
                  $$ = $2;
                  $$->star = $$->star + 1;
               }
               ;

    compound_statement: 
                     '{' '}' {
                        $$ = new seq_astnode();
                     }
                      | '{' statement_list '}' {
                         $$ = $2;

                      }
                      | '{' declaration_list '}' {
                         $$ = new seq_astnode();
                         vector<declaration_class*> vect = $2->children;
                         int x = 0;
                         for(int i=0;i<(int)vect.size();i++){
                           string typ = vect[i]->type->type;
                           declarator_list_class* decl_list = vect[i]->decl_list;
                           vector<declarator_class*> vect2 = decl_list->children;

                           for(int j=0;j<(int)vect2.size();j++){
                              SymbTabEntry* se2 = new SymbTabEntry();
                              se2->stentyp = typ;
                              se2->size = 0;
                              se2->varfun = "var";
                              string id = vect2[j]->identifier;
                              int y;
                              if(typ=="int"){
                                 y = -4;
                                 for(int k=0;k<(int)(vect2[j]->index).size();k++){
                                    y = y*(vect2[j]->index[k]);
                                 }
                              }
                              if(typ=="float"){
                                 y = -4;
                                 for(int k=0;k<(int)(vect2[j]->index).size();k++){
                                    y = y*(vect2[j]->index[k]);
                                 }
                              }
                              if(typ=="char"){
                                 y = -4;
                                 for(int k=0;k<(int)(vect2[j]->index).size();k++){
                                    y = y*(vect2[j]->index[k]);
                                 }
                              }
                              if(typ=="void"){
                                 y = -4;
                                 for(int k=0;k<(int)(vect2[j]->index).size();k++){
                                    y = y*(vect2[j]->index[k]);
                                 }
                              } 
                              if(typ.find("struct")!=string::npos){
                                 if((vect2[j]->star)>0){
                                    y = -4;                                   
                                 }
                                 else{
                                    y = -1*gst.Entries[typ].size;
                                 }
                                 for(int k=0;k<(int)(vect2[j]->index).size();k++){
                                    y = y*(vect2[j]->index[k]);
                                 }
                              }
                              st->Entries.insert({id,*se2});
                              st->Entries[id].offset = x + y;
                              x = x+y;
                              st->Entries[id].size = -y;
                              st->Entries[id].pos = "local";
                              st->Entries[id].type = typ;
                              st->Entries[id].varfun = "var";
                              st->Entries[id].stentyp = typ;
                              st->Entries[id].type = typ;

                              for(int l=0;l<(int)(vect2[j]->star);l++){
                                 st->Entries[id].stentyp = st->Entries[id].stentyp + "*"; 
                              }     
                              for(int m=0;m<(int)vect2[j]->index.size();m++){
                                 st->Entries[id].stentyp = st->Entries[id].stentyp + "[" + to_string(vect2[j]->index[m])+"]";
                              }                               
                           }
                        }
                      }
                      | '{' declaration_list {

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
                              if(typ=="int"){
                                 y = -4;
                                 for(int k=0;k<(int)(vect2[j]->index).size();k++){
                                    y = y*(vect2[j]->index[k]);
                                 }
                              }
                              if(typ=="float"){
                                 y = -4;
                                 for(int k=0;k<(int)(vect2[j]->index).size();k++){
                                    y = y*(vect2[j]->index[k]);
                                 }
                              }
                              if(typ=="char"){
                                 y = -4;
                                 for(int k=0;k<(int)(vect2[j]->index).size();k++){
                                    y = y*(vect2[j]->index[k]);
                                 }
                              }
                              if(typ=="void"){
                                 y = -4;
                                 for(int k=0;k<(int)(vect2[j]->index).size();k++){
                                    y = y*(vect2[j]->index[k]);
                                 }
                              } 
                              if(typ.find("struct")!=string::npos){
                                 if((vect2[j]->star)>0){
                                    y = -4;                                   
                                 }
                                 else{
                                    y = -1*gst.Entries[typ].size;
                                 }
                                 for(int k=0;k<(int)(vect2[j]->index).size();k++){
                                    y = y*(vect2[j]->index[k]);
                                 }
                              } 

                              st->Entries.insert({id,*se});
                              st->Entries[id].pos = "local";
                              st->Entries[id].offset = x + y;
                              x = x+y;
                              st->Entries[id].size = -y;
                              st->Entries[id].pos = "local";                  
                              st->Entries[id].type = typ;
                              st->Entries[id].varfun = "var";
                              st->Entries[id].stentyp = typ;
                              st->Entries[id].type = typ;

                              for(int l=0;l<(int)(vect2[j]->star);l++){
                                 st->Entries[id].stentyp = st->Entries[id].stentyp + "*"; 
                              }     
                              for(int m=0;m<(int)vect2[j]->index.size();m++){
                                 st->Entries[id].stentyp = st->Entries[id].stentyp + "[" + to_string(vect2[j]->index[m])+"]";
                              } 

                           }
                        }
                        

                        }
                        statement_list '}' {
                           $$ = $4;
                        }
                        ;

    statement_list: 
                  statement {
                     $$ = new seq_astnode();

                     $$->pushback($1);

                  }
                  | statement_list statement {
                     $$ = $1;
                     $$->pushback($2);
                  }
                  ;

    statement: 
            ';' {
               $$ = new empty_astnode();

            }
             | '{' statement_list '}' {

                $$ = $2;


             }
             | selection_statement {
                $$ = $1;
                

             }
             | iteration_statement {
                $$ = $1;               

             }
             | assignment_statement {
                $$ = $1;

             }
             | procedure_call {
               $$ = $1;
             }
             | RETURN expression ';' {
                $$ = new return_astnode($2);

             }
             ;

    assignment_expression: 
                           unary_expression '=' expression {

                              if(isIntType($1->data_type)&&isFloatType($3->data_type)){
                                 $3 = new op_unary_astnode("TO_INT",$3);
                              }
                              if(isFloatType($1->data_type)&&isIntType($3->data_type)){
                                 $3 = new op_unary_astnode("TO_FLOAT",$3);
                              }                              
                              $$ = new assignE_astnode($1,$3);
                              $$->data_type = $1->data_type;
                           }
                           ;

    assignment_statement: 
                           assignment_expression ';' { 
                              $$ = new assignS_astnode($1->left,$1->right);
                           }                           
                           ;

    procedure_call: 
                  IDENTIFIER '(' ')' ';' {
                     $$ = new proccall_astnode(new identifier_astnode($1));
                  }
                  | IDENTIFIER '(' expression_list ')' ';' {
                     $$ = new proccall_astnode(new identifier_astnode($1));
                     $$->vect = $3;
                  }
                  ;

    expression: 
               logical_and_expression {
                  $$ = $1;
               }
              | expression OR_OP logical_and_expression {
                  $$ = new op_binary_astnode("OR_OP",$1,$3);
                  $$->data_type = "int";
              }
              ;

    logical_and_expression: 
                           equality_expression {
                              $$ = $1;
                           }
                          | logical_and_expression AND_OP equality_expression {
                              $$ = new op_binary_astnode("AND_OP",$1,$3);
                              $$->data_type = "int";
                          }
                          ;
   
    equality_expression: 
                        relational_expression {
                           $$ = $1;
                        }
                       | equality_expression EQ_OP relational_expression {
                          if(isFloatType($1->data_type) || isFloatType($3->data_type)){
                             if(isIntType($1->data_type)){
                                $1 = new op_unary_astnode("TO_FLOAT",$1);
                             }
                             if(isIntType($3->data_type)){
                                $1 = new op_unary_astnode("TO_FLOAT",$3);
                             }                             
                             $$ = new op_binary_astnode("EQ_OP_FLOAT",$1,$3);
                          }
                          else{
                             $$ = new op_binary_astnode("EQ_OP_INT",$1,$3);
                          }
                          $$->data_type = "int";

                       }
                       | equality_expression NE_OP relational_expression{
                          if(isFloatType($1->data_type) || isFloatType($3->data_type)){
                             if(isIntType($1->data_type)){
                                $1 = new op_unary_astnode("TO_FLOAT",$1);
                             }
                             if(isIntType($3->data_type)){
                                $1 = new op_unary_astnode("TO_FLOAT",$3);
                             }                             
                             $$ = new op_binary_astnode("NE_OP_FLOAT",$1,$3);
                          }
                          else{
                             $$ = new op_binary_astnode("NE_OP_INT",$1,$3);
                          }
                          $$->data_type = "int";                          
                       }
                       ;

    relational_expression: 
                          additive_expression {
                             $$ = $1;
                          }
                         | relational_expression '<' additive_expression {
                          if(isFloatType($1->data_type) || isFloatType($3->data_type)){
                             if(isIntType($1->data_type)){
                                $1 = new op_unary_astnode("TO_FLOAT",$1);
                             }
                             if(isIntType($3->data_type)){
                                $1 = new op_unary_astnode("TO_FLOAT",$3);
                             }                             
                             $$ = new op_binary_astnode("LT_OP_FLOAT",$1,$3);
                          }
                          else{
                             $$ = new op_binary_astnode("LT_OP_INT",$1,$3);
                          }
                          $$->data_type = "int";
                         }
                         | relational_expression '>' additive_expression {
                          if(isFloatType($1->data_type) || isFloatType($3->data_type)){
                             if(isIntType($1->data_type)){
                                $1 = new op_unary_astnode("TO_FLOAT",$1);
                             }
                             if(isIntType($3->data_type)){
                                $1 = new op_unary_astnode("TO_FLOAT",$3);
                             }                             
                             $$ = new op_binary_astnode("GT_OP_FLOAT",$1,$3);
                          }
                          else{
                             $$ = new op_binary_astnode("GT_OP_INT",$1,$3);
                          }
                          $$->data_type = "int";                           
                         }
                         | relational_expression LE_OP additive_expression {
                          if(isFloatType($1->data_type) || isFloatType($3->data_type)){
                             if(isIntType($1->data_type)){
                                $1 = new op_unary_astnode("TO_FLOAT",$1);
                             }
                             if(isIntType($3->data_type)){
                                $1 = new op_unary_astnode("TO_FLOAT",$3);
                             }                             
                             $$ = new op_binary_astnode("LE_OP_FLOAT",$1,$3);
                          }
                          else{
                             $$ = new op_binary_astnode("LE_OP_INT",$1,$3);
                          }
                          $$->data_type = "int";                           
                         }
                         | relational_expression GE_OP additive_expression {
                          if(isFloatType($1->data_type) || isFloatType($3->data_type)){
                             if(isIntType($1->data_type)){
                                $1 = new op_unary_astnode("TO_FLOAT",$1);
                             }
                             if(isIntType($3->data_type)){
                                $1 = new op_unary_astnode("TO_FLOAT",$3);
                             }                             
                             $$ = new op_binary_astnode("GE_OP_FLOAT",$1,$3);
                          }
                          else{
                             $$ = new op_binary_astnode("GE_OP_INT",$1,$3);
                          }
                          $$->data_type = "int";                           
                         }
                         ;

    additive_expression: 
                        multiplicative_expression {
                           $$ = $1;
                        }
                       | additive_expression '+' multiplicative_expression {
                          if(isFloatType($1->data_type) || isFloatType($3->data_type)){
                             if(isIntType($1->data_type)){
                                $1 = new op_unary_astnode("TO_FLOAT",$1);
                             }
                             if(isIntType($3->data_type)){
                                $1 = new op_unary_astnode("TO_FLOAT",$3);
                             }                             
                             $$ = new op_binary_astnode("PLUS_FLOAT",$1,$3);
                             $$->data_type = "float";
                          }
                          else{
                             $$ = new op_binary_astnode("PLUS_INT",$1,$3);
                             $$->data_type = "int";
                          }
                       }
                       | additive_expression '-' multiplicative_expression {
                          if(isFloatType($1->data_type) || isFloatType($3->data_type)){
                             if(isIntType($1->data_type)){
                                $1 = new op_unary_astnode("TO_FLOAT",$1);
                             }
                             if(isIntType($3->data_type)){
                                $1 = new op_unary_astnode("TO_FLOAT",$3);
                             }                             
                             $$ = new op_binary_astnode("MINUS_FLOAT",$1,$3);
                             $$->data_type = "float";
                          }
                          else{
                             $$ = new op_binary_astnode("MINUS_INT",$1,$3);
                             $$->data_type = "int";
                          }
                       }
                       ;

    unary_expression: 
                     postfix_expression {
                        $$ = $1;
                     }
                    | unary_operator unary_expression {
                       $$ = new op_unary_astnode($1,$2);
                       $$->data_type = $2->data_type;
                       if($1=="NOT"){
                          $$->data_type = "int";
                       }
                    }
                    ;

    multiplicative_expression: 
                              unary_expression {
                                 $$ = $1;
                              }
                             | multiplicative_expression '*' unary_expression {
                                 if(isFloatType($1->data_type) || isFloatType($3->data_type)){
                                    if(isIntType($1->data_type)){
                                       $1 = new op_unary_astnode("TO_FLOAT",$1);
                                    }
                                    if(isIntType($3->data_type)){
                                       $1 = new op_unary_astnode("TO_FLOAT",$3);
                                    }                             
                                    $$ = new op_binary_astnode("MULT_FLOAT",$1,$3);
                                    $$->data_type = "float";
                                 }
                                 else{
                                    $$ = new op_binary_astnode("MULT_INT",$1,$3);
                                    $$->data_type = "int";
                                 }                               
                             }
                             | multiplicative_expression '/' unary_expression {
                                 if(isFloatType($1->data_type) || isFloatType($3->data_type)){
                                    if(isIntType($1->data_type)){
                                       $1 = new op_unary_astnode("TO_FLOAT",$1);
                                    }
                                    if(isIntType($3->data_type)){
                                       $1 = new op_unary_astnode("TO_FLOAT",$3);
                                    }                             
                                    $$ = new op_binary_astnode("DIV_FLOAT",$1,$3);
                                    $$->data_type = "float";
                                 }
                                 else{
                                    $$ = new op_binary_astnode("DIV_INT",$1,$3);
                                    $$->data_type = "int";
                                 }                                
                             }
                             ;

    postfix_expression: 
                      primary_expression {
                         $$ = $1;
                      }
                      | postfix_expression '[' expression ']' {
                         $$ = new arrayref_astnode($1,$3);  
                         $$->data_type = $1->data_type;                       
                      }
                      | IDENTIFIER '(' ')' {
                         funcall_astnode * f = new funcall_astnode();
                         f->setname($1);
                         $$ = f;
                      }
                      | IDENTIFIER '(' expression_list ')' {
                         funcall_astnode * f = new funcall_astnode();
                         f->setname($1);
                         f->vect = $3;
                         $$ = f;                         
                      }
                      | postfix_expression '.' IDENTIFIER {
                         $$ = new member_astnode($1,new identifier_astnode($3));                         
                      }
                      | postfix_expression PTR_OP IDENTIFIER {
                         $$ = new arrow_astnode($1,new identifier_astnode($3));                            
                      }
                      | postfix_expression INC_OP {
                         $$ = new op_unary_astnode("PP",$1);
                      }
                      ;

    primary_expression: 
                        IDENTIFIER {
                           $$ = new identifier_astnode($1);
                           SymbTabEntry* se = st->search($1);
                           if(se==NULL){
                              cout<<"Error: "<<endl;
                           }
                           $$->data_type = se->type;
                        }
                      | INT_CONSTANT {
                         $$ = new intconst_astnode(stoi($1));
                         $$->data_type = "int";
                      }
                      | FLOAT_CONSTANT {
                         $$ = new floatconst_astnode(stof($1));
                         $$->data_type = "float";
                      }
                      | STRING_LITERAL {
                         $$ = new stringconst_astnode($1);
                         $$->data_type = "string";
                      }
                      | '(' expression ')' {
                         $$ = $2;
                      }
                      ;

    expression_list: 
                    expression {
                      $$.push_back($1);
                       
                    }
                   | expression_list ',' expression {
                      $$ = $1;
                      $$.push_back($3);
                   }
                   ;

    unary_operator: 
                  '-' {
                     $$ = "UMINUS";
                  }
                  | '!' {
                     $$ = "NOT";
                  }
                  | '&' {
                     $$ = "ADDRESS";
                  }
                  | '*' {
                     $$ = "DEREF";
                  }
                  ;

    selection_statement: 
                        IF '(' expression ')' statement ELSE statement {
                           exp_astnode *l = $3;
                           statement_astnode *m = $5;
                           statement_astnode *r = $7;
                           $$ = new if_astnode(l,m,r);                           
                        }
                        ;

    iteration_statement: 
                       WHILE '(' expression ')' statement {
                           exp_astnode *l = $3;
                           statement_astnode *r = $5;
                           $$ = new while_astnode(l,r);                          
                       }
                       | FOR '(' assignment_expression ';' expression ';' assignment_expression ')' statement {
                           exp_astnode *l = $3;
                           exp_astnode *m1 = $5;
                           exp_astnode *m2 = $7;
                           statement_astnode *r = $9;
                           $$ = new for_astnode(l,m1,m2,r);                          
                       }
                       ;

    declaration_list: 
                     declaration
                     {
                        $$ = new declaration_list_class();
                        $$->children.push_back($1);
                     }
                    | declaration_list declaration
                    {
                       $$ = $1;
                       $$->children.push_back($2);
                    }
                    ;

    declaration:
                type_specifier declarator_list ';'
                {
                   $$ = new declaration_class($1,$2);
                   
                }
                ;

    declarator_list: declarator
                     {
                        $$ = new declarator_list_class();
                        $$->pushback($1);
                     }
                     
                    | declarator_list ',' declarator
                    {
                     $$ = $1;
                     $$->children.push_back($3);
                    }
                    ;
               
%%
void IPL::Parser::error( const location_type &l, const std::string &err_message )
{
   std::cerr << "Error: " << err_message << " at " << l << "\n";
}


