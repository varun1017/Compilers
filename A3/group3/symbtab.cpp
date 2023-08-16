#include "symbtab.hh"
#include <iostream>
using namespace std;

SymbTabEntry* SymbTab::search(string s){
    return &Entries[s];
}



