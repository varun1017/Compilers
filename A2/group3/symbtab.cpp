#include "symbtab.hh"
#include <iostream>
using namespace std;

void SymbTab::printgst(){
    cout<<"[\n";
    for(auto it = Entries.begin();it != Entries.end(); ++it){
        cout<<"[\n";
        cout<<"\""<<it->first<<"\",";
        cout<<"\""<<it->second.varfun<<"\",";
        cout<<"\""<<it->second.pos<<"\",";
        cout<<it->second.size<<",";
        if(it->second.varfun != "fun" && it->second.pos == "global"){
            cout<<"\"-\""<<",";
        }
        else{
            cout<<it->second.offset<<",";
        }
        cout<<"\""<<it->second.stentyp<<"\""<<"]\n";
        if(next(it,1) != Entries.end()){
            cout<<","<<endl;
        }
    }
    cout<<"]\n";
}

void SymbTab::print(){
    printgst();
}

SymbTabEntry* SymbTab::search(string s){
    return &Entries[s];
}



