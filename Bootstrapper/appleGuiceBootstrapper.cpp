//Copyright 2013 Tomer Shiri appleGuice@shiri.info
//
//Licensed under the Apache License, Version 2.0 (the "License");
//you may not use this file except in compliance with the License.
//You may obtain a copy of the License at
//
//http://www.apache.org/licenses/LICENSE-2.0
//
//Unless required by applicable law or agreed to in writing, software
//distributed under the License is distributed on an "AS IS" BASIS,
//WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//See the License for the specific language governing permissions and
//limitations under the License.

// NOTE(acm): Before gcc-4.7, __cplusplus is always defined to be 1, so we can't reliably
// detect C++11 support by exclusively checking the value of __cplusplus.  Additionaly, libc++,
// whether in C++11 or C++03 mode, doesn't use TR1 and drops things into std instead.
#if __cplusplus >= 201103L
#include <unordered_map>
#else
#include <tr1/unordered_map>
using namespace std::tr1;
#endif

#include <iostream>
#include <sstream>

#include <unistd.h>
#include <stdio.h>


#include <string>
#include <vector>
#include <set>

#include <algorithm>

using namespace std;

const static string protocolLabel = "@protocol";
const static string interfaceLabel = "@interface";
const static string NSObject = "NSObject";
const static string appleGuice = "AppleGuice";

template<class T>
bool contains(set<T> container, string key) {
	return container.find(key) != container.end();
}

template<class T, class N>
bool contains(unordered_map< T, N > container, string key) {
	return container.find(key) != container.end();
}

static string &ltrim(string &s) 
{
	s.erase(s.begin(), find_if(s.begin(), s.end(), not1(ptr_fun<int, int>(isspace))));
	return s;
}

// trim from end
static string &rtrim(string &s) 
{
	s.erase(find_if(s.rbegin(), s.rend(), not1(ptr_fun<int, int>(isspace))).base(), s.end());
	return s;
}

// trim from both ends
static string &trim(string &s) 
{
	return ltrim(rtrim(s));
}

bool isNSObject(string &str) 
{
	return str.compare(NSObject) == 0;
}

vector<string> split(const string  &theString, const string &theDelimiter)
{
	std::vector<string> theStringVector;
	size_t  start = 0, end = 0;
	while ( end != string::npos)
	{
		end = theString.find( theDelimiter, start);
		theStringVector.push_back( theString.substr(start, (end == string::npos) ? string::npos : end - start));
		start = ((end > (string::npos - theDelimiter.size())) ? string::npos : end + theDelimiter.size());
	}
	return theStringVector;
}

bool isPrefix(string const &s1, string const &s2)
{
	const char*p = s1.c_str();
	const char*q = s2.c_str();
	while (*p&&*q)
		if (*p++!=*q++)
			return false;
	return true;
}

set<string> parseProtocolListAsString(string &protocolListAsString) 
{
	protocolListAsString = trim(protocolListAsString);
	set<string> implementedProtocols;
	vector<string>implementedProtocolList = split(protocolListAsString, ",");

	for(vector<string>::const_iterator protocolImplementation = implementedProtocolList.begin(); protocolImplementation != implementedProtocolList.end(); protocolImplementation++ ) {
	  string protocolName = *protocolImplementation;
	  protocolName = trim(protocolName);
	  implementedProtocols.insert(protocolName);
	}

	return implementedProtocols;
}

void parseProtocolEntry(string &entry, unordered_map<string, set<string> > &protocolToSuperProtocols) 
{ //@protocol protocolName <p1, p2 , ... , pn> 
	
	//cout << "parsing line: " << entry << " ";

	int protocolLength = string(protocolLabel).length();
	
	size_t protocolNameEnd = entry.find('<');
	if (protocolNameEnd == string::npos) return; // bad entry syntax
	string protocolName = entry.substr(protocolLength + 1, protocolNameEnd - protocolLength - 1);
	protocolName = trim(protocolName);

	string protocolListAsString = entry.substr(protocolNameEnd + 1,entry.find('>') - protocolNameEnd - 1);

	set<string> implementedProtocols = parseProtocolListAsString(protocolListAsString);

	// 	set<string>::const_iterator implementedProtocolsIterator;
	// for( implementedProtocolsIterator = implementedProtocols.begin(); implementedProtocolsIterator != implementedProtocols.end(); implementedProtocolsIterator++ ) {
	// 	cout << "[" << *implementedProtocolsIterator << "] ";
	// }
	// cout << endl;

	protocolToSuperProtocols[protocolName] = implementedProtocols;
}

void parseInterfaceEntry(string &entry,unordered_map <string, string> &classToSuperClass, unordered_map <string, set<string> > &classToProtocols) 
{ //@interface className : superClass <p1, p2 , ... , pn> 
	
	//cout << "parsing line: " << entry << " ";
	
	int interfaceLength = string(interfaceLabel).length();

	size_t classNameEnd = entry.find(':');
	if (classNameEnd == string::npos) return; // bad entry syntax
	string className = entry.substr(interfaceLength + 1, classNameEnd - interfaceLength - 1);
	className = trim(className);

	bool hasProtocolList = true;
	size_t superClassEnd = entry.find('<'); //protocolList is optional

	if (superClassEnd == string::npos) {
		hasProtocolList = false;
		superClassEnd = entry.find('{'); //might be a variable list here!
		if (superClassEnd == string::npos) {
			superClassEnd = entry.length();
		}
	}

	string superClassName = entry.substr(classNameEnd + 1, superClassEnd - classNameEnd - 1);
	superClassName = trim(superClassName);

	//cout << "class name: " << className << " super: " << superClassName << " plist? " << (hasProtocolList ? "yes" : "no") << endl;

	classToSuperClass[className] = superClassName;

	if (!hasProtocolList) return;

	string protocolListAsString = entry.substr(superClassEnd + 1, entry.find('>') - superClassEnd - 1);

	//cout << "protocolListAsString=[" << protocolListAsString << "]" << endl;

	set<string> implementedProtocols = parseProtocolListAsString(protocolListAsString);

	// for(set<string>::const_iterator implementedProtocolsIterator = implementedProtocols.begin(); implementedProtocolsIterator != implementedProtocols.end(); implementedProtocolsIterator++ ) {
	// 	cout << " [ " << *implementedProtocolsIterator << " ] ";
	// }
	//cout << endl;
	classToProtocols[className] = implementedProtocols;
}

void parseLine(string &headerEntry, 
			   unordered_map<string, set<string> > &protocolToSuperProtocols, 
			   unordered_map <string, string> &classToSuperClass,
			   unordered_map <string, set<string> > &classToProtocols) 
{

	if (isPrefix(protocolLabel, headerEntry)) {
	  parseProtocolEntry(headerEntry, protocolToSuperProtocols);
	}
	else {
	  parseInterfaceEntry(headerEntry, classToSuperClass, classToProtocols);
	}
}

void addBindToResultList(string &className,
						 set<string> implementedProtocols,
						 unordered_map<string, set<string> > &protocolToSuperProtocols, 
						 unordered_map <string, set<string> > &protocolToImps) 
{

	for(set<string>::const_iterator protocolNameIterator = implementedProtocols.begin(); protocolNameIterator != implementedProtocols.end(); protocolNameIterator++ ) {
		
		string protocolName = *protocolNameIterator;
		
		//cout << "className: [" <<  className <<  "] protocolName: [" << protocolName << "]" << endl;

		if (!contains(protocolToImps, protocolName)) {
			set<string> protocolList;
			protocolToImps[protocolName] = protocolList;
		}

		protocolToImps[protocolName].insert(className);

		if (contains(protocolToSuperProtocols, protocolName)) {
			set<string> superProtocols = protocolToSuperProtocols[protocolName];
			addBindToResultList(className, superProtocols, protocolToSuperProtocols, protocolToImps);
		}
	}
}

void protocolsImplementedByClass(string &className,
				   unordered_map <string, string> &classToSuperClass,
			   unordered_map <string, set<string> > &classToProtocols,
			   set<string> &result) 
{

	if (contains(classToProtocols, className)) {
		set<string> implementedProtocols = classToProtocols[className];
		//must be a better way to union sets
		for(set<string>::const_iterator it = implementedProtocols.begin(); it != implementedProtocols.end(); it++ ) {
			string protocolName = *it;
			result.insert(protocolName);
		}
	}

	if (contains(classToSuperClass, className)) {
		string superClass = classToSuperClass[className];
		protocolsImplementedByClass(superClass, classToSuperClass, classToProtocols, result);
	}
}	

void travereOverClassHierarchAndAct(string &className, unordered_map<string, set<string> > &protocolToSuperProtocols, 
			   unordered_map <string, string> &classToSuperClass,
			   unordered_map <string, set<string> > &classToProtocols,
			   unordered_map <string, set<string> > &protocolToImps) 
{
	
	set<string> implementedProtocols;
	protocolsImplementedByClass(className, classToSuperClass, classToProtocols, implementedProtocols);
	
	addBindToResultList(className, implementedProtocols, protocolToSuperProtocols, protocolToImps);
	
	//cout << ">> " << className << " ";
	
	if (!contains(classToSuperClass, className)) {
		//cout << "||" << endl;
		return;
	}

	string superClass = classToSuperClass[className];
	travereOverClassHierarchAndAct(superClass, protocolToSuperProtocols, classToSuperClass, classToProtocols, protocolToImps);
}


void generateAppleGuiceCodeForEntry(string &protocolName, set<string> &implementingClasses, stringstream &stringBuilder) {
	const string classesDelimiter = ", ";

    stringBuilder << "[self.bindingService setImplementationsFromStrings:@[";

    int setSize = implementingClasses.size();
    for(set<string>::const_iterator implementedProtocolsIterator = implementingClasses.begin(); implementedProtocolsIterator != implementingClasses.end(); implementedProtocolsIterator++ ) {
		string implementationName = *implementedProtocolsIterator;
		stringBuilder << "@\"" << implementationName << "\"";
		--setSize;
		if (setSize > 0) {
			stringBuilder << classesDelimiter;
		}
	}
	stringBuilder << "] withProtocolAsString:@\"" << protocolName << "\" withBindingType:appleGuiceBindingTypeUserBinding];" << endl;
}

set<string> filterNonInjectableClasses(set<string> injectableClasses, set<string> &implementingClasses) {
	set<string> intersection;
	for(set<string>::const_iterator it = implementingClasses.begin(); it != implementingClasses.end(); it++ ) {
		string className = *it;
		if (contains(injectableClasses, className)) {
			intersection.insert(className);
		}
	}
	return intersection;
}

string generateAppleGuiceCode(unordered_map <string, set<string> > &protocolToImps) 
{
	const string appleGuiceInjectable = appleGuice + "Injectable";

	const string headerCode = "// DO NOT EDIT. This file is machine-generated and constantly overwritten.\n#import \"" + 
							  appleGuice + "BindingBootstrapper.h\"\n#import \"" + appleGuice + ".h\"\n@implementation " + 
							  appleGuice + "BindingBootstrapper\n@synthesize bindingService = _ioc_bindingService;\n\n-(void) bootstrap {\n";
	const string footerCode = "}\n@end";

	set<string> injectableClasses;
	if (contains(protocolToImps, appleGuiceInjectable)) {
		injectableClasses = protocolToImps[appleGuiceInjectable];
	}

	stringstream stringBuilder;
	
	stringBuilder << headerCode;

	for (unordered_map<string, set<string> >::const_iterator it = protocolToImps.begin(); it != protocolToImps.end(); ++it) {
    	
    	string protocolName = it->first;
    	set<string> implementingClasses = it->second;

    	if(isNSObject(protocolName)) continue;

    	set<string> filteredClasses = filterNonInjectableClasses(injectableClasses, implementingClasses);

    	if (filteredClasses.size() == 0) continue;

    	generateAppleGuiceCodeForEntry(protocolName, filteredClasses, stringBuilder);
    	
    }
    stringBuilder << footerCode << endl << endl;

	return stringBuilder.str();
}

string readFromStdin() {
	stringstream stringBuilder;
	for (string line; getline(cin, line);) {
        stringBuilder << line << endl;
    }
    return stringBuilder.str();
}

int main(int argc, char* argv[])
{

    if(isatty(fileno(stdin)))
    {
        fprintf(stderr, "You need to pipe in some data!\n");
        return 1;
    }
    
	string headerEntriesAsString = readFromStdin();

	headerEntriesAsString = trim(headerEntriesAsString);

	unordered_map<string, set<string> > protocolToSuperProtocols;
	unordered_map<string, set<string> > classToProtocols;
	unordered_map<string, string> classToSuperClass;

	unordered_map<string, set<string> > protocolToImps;
  
  	vector<string> headerEntries = split(headerEntriesAsString, "\n");

  	//parse 
  	for(vector<string>::const_iterator headerEntriesIterator = headerEntries.begin(); headerEntriesIterator != headerEntries.end(); headerEntriesIterator++ ) {
		string entry = *headerEntriesIterator;
		entry = trim(entry);
		parseLine(entry, protocolToSuperProtocols, classToSuperClass, classToProtocols);
  	}

  	//build dictionary
    for (unordered_map<string, string>::const_iterator it = classToSuperClass.begin(); it != classToSuperClass.end(); ++it) {
    	string className = it->first;
    	travereOverClassHierarchAndAct(className, protocolToSuperProtocols, classToSuperClass, classToProtocols, protocolToImps);
    }

    //generate code
    string generatedCode = generateAppleGuiceCode(protocolToImps);

    cout << generatedCode;
}
