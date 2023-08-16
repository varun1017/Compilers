%{
// This part goes directly into the generated parser

#include "scanner.hh"
#include "parser.tab.hh"

// YY_DECL is bound to the type of the scanner. The default is 
// #define YY_DECL int Scanner::yylex()
// which is generated anyway.

//If you want the type of the generated scanner to be different, do this

#undef  YY_DECL
#define YY_DECL int IPL::Scanner::yylex( IPL::Parser::semantic_type * const lval, IPL::Parser::location_type *location )

//We want these to be the first action after a token is recognized. 

#define YY_USER_ACTION loc->step(); loc->columns(yyleng);

// token_type is a short hand for IPL::Parser::token

#define token_type  IPL::Parser::token

%}


/* %option debug */
%option nodefault
%option yyclass="Scanner"
%option noyywrap
%option c++

%%

%{ /** Code executed at the beginning of yylex **/

      yylval = lval;

%}

[ \t]                             //skip
[ \n]                             //skip
[ \r]                             //skip
"/*"([^\*]*(\*([^*/][^\*]*)?)*)"*/"  //skip                                                          
void          {   
       yylval->emplace< std::string >( YYText() );
       return token_type::VOID;
}
int                           {   
       yylval->emplace< std::string >( YYText() );
       return token_type::INT;
}
struct                         {
       yylval->emplace< std::string >( YYText() );
       return token_type::STRUCT;
}
if                         {
       yylval->emplace< std::string >( YYText() );
       return token_type::IF;
}
else                         {
       yylval->emplace< std::string >( YYText() );
       return token_type::ELSE;
}
for                         {
       yylval->emplace< std::string >( YYText() );
       return token_type::FOR;
}
while                         {
       yylval->emplace< std::string >( YYText() );
       return token_type::WHILE;
}
return                         {
       yylval->emplace< std::string >( YYText() );
       return token_type::RETURN;
}
main                          {
      yylval->emplace< std::string >( YYText() );
      return token_type::MAIN;
}
printf                        {
      yylval->emplace< std::string >( YYText() );
      return token_type::PRINTF;
}
[0-9][0-9]*                   {   
       yylval->emplace< std::string >( YYText() );
       return token_type::CONSTANT_INT;    
} 
[a-zA-Z_][a-zA-Z0-9_]*           {
      yylval->emplace< std::string >( YYText() );
      return token_type::IDENTIFIER;
}
\"(\\.|[^"\\])*\"        {
      yylval->emplace< std::string >( YYText() );
      return token_type::CONSTANT_STR;
}
"<="         {
      yylval->emplace< std::string >( YYText() );
      return token_type::OP_LTE;
}
">="         {
      yylval->emplace< std::string >( YYText() );
      return token_type::OP_GTE;
}
"=="         {
      yylval->emplace< std::string >( YYText() );
      return token_type::OP_EQ;
}
"!="         {
      yylval->emplace< std::string >( YYText() );
      return token_type::OP_NEQ;
}
"++"         {
      yylval->emplace< std::string >( YYText() );
      return token_type::OP_INC;
}
"->"         {
      yylval->emplace< std::string >( YYText() );
      return token_type::OP_PTR;
}
"||"          {
      yylval->emplace< std::string >( YYText() );
      return token_type::OP_OR;
}
"&&"         {
      yylval->emplace< std::string >( YYText() );
      return token_type::OP_AND;
}
"{"         {
      yylval->emplace< std::string >( YYText() );
      return token_type::LCB;
}
"}"         {
      yylval->emplace< std::string >( YYText() );
      return token_type::RCB;
}
";"         {
      yylval->emplace< std::string >( YYText() );
      return token_type::EOS;
}
"("         {
      yylval->emplace< std::string >( YYText() );
      return token_type::LRB;
}
")"         {
      yylval->emplace< std::string >( YYText() );
      return token_type::RRB;
}
","         {
      yylval->emplace< std::string >( YYText() );
      return token_type::COMMA;
}
"["         {
      yylval->emplace< std::string >( YYText() );
      return token_type::LSB;
}
"]"         {
      yylval->emplace< std::string >( YYText() );
      return token_type::RSB;
}
"+"         {
      yylval->emplace< std::string >( YYText() );
      return token_type::OP_ADD;
}
"-"         {
      yylval->emplace< std::string >( YYText() );
      return token_type::OP_SUB;
}
"*"         {
      yylval->emplace< std::string >( YYText() );
      return token_type::OP_MUL;
}
"/"         {
      yylval->emplace< std::string >( YYText() );
      return token_type::OP_DIV;
}
"."         {
      yylval->emplace< std::string >( YYText() );
      return token_type::OP_MEM;
}
"!"         {
      yylval->emplace< std::string >( YYText() );
      return token_type::OP_NOT;
}
"&"         {
      yylval->emplace< std::string >( YYText() );
      return token_type::OP_ADDR;
}
"="         {
      yylval->emplace< std::string >( YYText() );
      return token_type::OP_ASSIGN;
}
"<"         {
      yylval->emplace< std::string >( YYText() );
      return token_type::OP_LT;
}
">"         {
      yylval->emplace< std::string >( YYText() );
      return token_type::OP_GT;
}


<<EOF>>         yyterminate();
.         {
      yylval->emplace< std::string >( YYText() );
      return token_type::OTHERS;
}



%%

