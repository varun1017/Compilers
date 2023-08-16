#ifndef SYMBTAB_HH
#define SYMBTAB_HH
#include<string>
#include<map>
#include<iostream>
using namespace std;

class SymbTabEntry;

class SymbTab
{
    public:
    map<string,SymbTabEntry> Entries;
    void printgst();
    void print();
    SymbTabEntry* search(string s);

};

class SymbTabEntry
{
    public:
    string varfun;
    string pos;
    int size;
    int offset;
    string stentyp;
    string type;
    SymbTab* symbtab;
};

#endif
