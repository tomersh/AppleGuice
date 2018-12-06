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

const static string protocolLabelObjC = "@protocol";
const static string protocolLabelSwift = "protocol";
const static string interfaceLabelObjC = "@interface";
const static string classLabelSwift = "class";
const static string NSObject = "NSObject";
const static string appleGuice = "AppleGuice";
const static string appleGuiceModule = "AppleGuiceModule";

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

string moduleNameFromProtocolsList(set<string> protocols) {
    for (set<string>::const_iterator item = protocols.begin(); item != protocols.end(); item++ ) {
        string protocolName = *item;
        size_t protocolStart = protocolName.find(appleGuiceModule);
        if (protocolStart != string::npos) {
            return protocolName.substr(0, protocolStart);
        }
    }
    return "";
}

void addClassOrProtocolToTheModuleMapIfNeeded(string classOrProtocol, set<string> protocols, unordered_map <string, string> &classOrProtocolToModule) {
    string moduleNameForProtocol = moduleNameFromProtocolsList(protocols);
    if (moduleNameForProtocol.length() > 0) {
        classOrProtocolToModule[classOrProtocol] = moduleNameForProtocol;
    }
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

vector<string> parseSuperClassOrProtocolsListAsString(string &superClassOrProtocolListAsString) {
    superClassOrProtocolListAsString = trim(superClassOrProtocolListAsString);
    vector<string> implementedSuperClassOrProtocolList = split(superClassOrProtocolListAsString, ",");
    vector<string> implementedSuperClassOrProtocolTrimmedList;
    
    for (vector<string>::const_iterator item = implementedSuperClassOrProtocolList.begin(); item != implementedSuperClassOrProtocolList.end(); item++ ) {
        string itemName = *item;
        itemName = trim(itemName);
        implementedSuperClassOrProtocolTrimmedList.push_back(itemName);
    }
 
    return implementedSuperClassOrProtocolTrimmedList;
}

void parseProtocolEntry(string &entry, unordered_map<string, set<string> > &protocolToSuperProtocols, unordered_map <string, string> &classOrProtocolToModule, string protocolLabel, char endProtocolNameChar, char endProtocolListChar, bool shouldAddProtocolWithNoSuper) {
    //cout << "parsing line: " << entry << " ";
    size_t protocolStart = entry.find(protocolLabel);
    if (protocolStart == string::npos) {
        return;
    }
    unsigned long protocolLength = string(protocolLabel).length();
    
    size_t protocolNameEnd = entry.find(endProtocolNameChar);
    bool noSuperProtocols = false;
    if (protocolNameEnd == string::npos) {
        noSuperProtocols = true;
        
        protocolNameEnd = entry.find(endProtocolListChar);
        if (protocolNameEnd == string::npos) {
            protocolNameEnd = entry.length();
        }
    }
    size_t protocolNameStart = protocolStart + protocolLength + 1;
    string protocolName = entry.substr(protocolStart + protocolLength + 1, protocolNameEnd - protocolNameStart);
    protocolName = trim(protocolName);
    
    if (noSuperProtocols && shouldAddProtocolWithNoSuper) {
        set<string> emptyImplementedProtocols;
        protocolToSuperProtocols[protocolName] = emptyImplementedProtocols;
        return;
    }
    
    size_t relevantStringLengthToSearch = entry.find(endProtocolListChar) != string::npos ? entry.find(endProtocolListChar) : entry.length();
    string protocolListAsString = entry.substr(protocolNameEnd + 1, relevantStringLengthToSearch - protocolNameEnd - 1);
    
    set<string> implementedProtocols = parseProtocolListAsString(protocolListAsString);

    addClassOrProtocolToTheModuleMapIfNeeded(protocolName, implementedProtocols, classOrProtocolToModule);
    
    //     set<string>::const_iterator implementedProtocolsIterator;
    // for( implementedProtocolsIterator = implementedProtocols.begin(); implementedProtocolsIterator != implementedProtocols.end(); implementedProtocolsIterator++ ) {
    //     cout << "[" << *implementedProtocolsIterator << "] ";
    // }
    // cout << endl;
    
    protocolToSuperProtocols[protocolName] = implementedProtocols;
}

void parseProtocolEntryObjC(string &entry, unordered_map<string, set<string> > &protocolToSuperProtocols, unordered_map <string, string> &classOrProtocolToModule) {
    //@protocol protocolName <p1, p2 , ... , pn>
    parseProtocolEntry(entry, protocolToSuperProtocols, classOrProtocolToModule, protocolLabelObjC, '<', '>', false);
}

void parseProtocolEntrySwift(string &entry, unordered_map<string, set<string> > &protocolToSuperProtocols, unordered_map <string, string> &classOrProtocolToModule) {
    //protocol protocolName: p1, p2, p3
    parseProtocolEntry(entry, protocolToSuperProtocols, classOrProtocolToModule, protocolLabelSwift, ':', '{', true);
}

void parseInterfaceEntryObjC(string &entry,unordered_map <string, string> &classToSuperClass, unordered_map <string, set<string> > &classToProtocols, unordered_map <string, string> &classOrProtocolToModule)
{ //@interface className : superClass <p1, p2 , ... , pn> 
	
	//cout << "parsing line: " << entry << " ";
	
	unsigned long interfaceLength = string(interfaceLabelObjC).length();

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
    
    addClassOrProtocolToTheModuleMapIfNeeded(className, implementedProtocols, classOrProtocolToModule);
	// for(set<string>::const_iterator implementedProtocolsIterator = implementedProtocols.begin(); implementedProtocolsIterator != implementedProtocols.end(); implementedProtocolsIterator++ ) {
	// 	cout << " [ " << *implementedProtocolsIterator << " ] ";
	// }
	//cout << endl;
	classToProtocols[className] = implementedProtocols;
}

void parseClassEntrySwift(string &entry,unordered_map <string, string> &classToSuperClass, unordered_map <string, set<string> > &classToProtocols,
    unordered_map<string, string> &swiftClassToUknownSuperClassOrProtocol, unordered_map <string, string> &classOrProtocolToModule)
{ //class className : superClass, p1, p2 , ... , pn
    
    //cout << "parsing line: " << entry << " ";
    
    size_t classStart = entry.find(classLabelSwift);
    unsigned long classLength = string(classLabelSwift).length();
    
    size_t classNameEnd = entry.find(':');
    bool hasSuperClassOrProtocols = true;
    if (classNameEnd == string::npos) { // no super class or protocols
        hasSuperClassOrProtocols = false;
        
        classNameEnd = entry.find('{');
        if (classNameEnd == string::npos) {
            classNameEnd = entry.length();
        }
        
    }
    size_t classNameStart = classStart + classLength + 1;
    string className = entry.substr(classNameStart, classNameEnd - classNameStart);
    className = trim(className);
    
    if (hasSuperClassOrProtocols == false) {
        //cout << "class name: " << className << " super: no, plist? no" << endl;
        return;
    }
    
    size_t startOfSuperClassOrProtocols = classNameEnd + 1;
    size_t endOfSuperClassOrProtocols = entry.find('{') != string::npos ? entry.find('{') : entry.length() + 1;
    string superClassOrProtocolListAsString = entry.substr(startOfSuperClassOrProtocols, endOfSuperClassOrProtocols - 1 - startOfSuperClassOrProtocols);
    
    vector<string> superClassOrProtocolList = parseSuperClassOrProtocolsListAsString(superClassOrProtocolListAsString);
    
    if (superClassOrProtocolList.size() == 0) { //If we enter this if, means the statement is malformed
        return;
    }
    
    string superClassOrProtocol = superClassOrProtocolList.front();

    /*if we find AppleGuice as a substring of the first item - it means
       there is an attempt to inject a class that is not inheriting from NSObject - We don't support this case so we igonre this class.*/
    if (superClassOrProtocol.find(appleGuice) != string::npos) {
        return;
    }
    swiftClassToUknownSuperClassOrProtocol[className] = superClassOrProtocol;

    if (superClassOrProtocolList.size() > 1) { //We aren't sure if the first is class/protocol. The rest are definetly protocols!
        set<string> implementedProtocols(superClassOrProtocolList.begin() + 1, superClassOrProtocolList.end());
        
        addClassOrProtocolToTheModuleMapIfNeeded(className, implementedProtocols, classOrProtocolToModule);
        
        classToProtocols[className] = implementedProtocols;
    }
}

bool lineHasComponent(string &entry, string componentToFind) {
    vector<string> lineComponents = split(entry, " ");
    
    for(vector<string>::const_iterator component = lineComponents.begin(); component != lineComponents.end(); component++ ) {
        string componentName = *component;
        componentName = trim(componentName);
        if (componentName.compare(componentToFind) == 0) {
            return true;
        }
    }
    
    return false;
}

bool lineHasSwiftProtocol(string &entry) {
    return lineHasComponent(entry, protocolLabelSwift);
}

bool lineHasSwiftClass(string &entry) {
    return lineHasComponent(entry, classLabelSwift);
}

//TODO deal with extensions

void parseLine(string &headerEntry, 
			   unordered_map <string, set<string> > &protocolToSuperProtocols,
			   unordered_map <string, string> &classToSuperClass,
			   unordered_map <string, set<string> > &classToProtocols,
               unordered_map <string, string> &swiftClassToUknownSuperClassOrProtocol,
               unordered_map <string, string> &classOrProtocolToModule)
{

	if (isPrefix(protocolLabelObjC, headerEntry)) { //for Objective C
	  parseProtocolEntryObjC(headerEntry, protocolToSuperProtocols, classOrProtocolToModule);
	}
	else if (isPrefix(interfaceLabelObjC, headerEntry)) { //for Objective C
	  parseInterfaceEntryObjC(headerEntry, classToSuperClass, classToProtocols, classOrProtocolToModule);
	}
    else if (lineHasSwiftProtocol(headerEntry)) {
        parseProtocolEntrySwift(headerEntry, protocolToSuperProtocols, classOrProtocolToModule);
    }
    else if (lineHasSwiftClass(headerEntry)) {
        parseClassEntrySwift(headerEntry, classToSuperClass, classToProtocols, swiftClassToUknownSuperClassOrProtocol, classOrProtocolToModule);
    }
}

void resolveSwiftClassOrProtocolMap(unordered_map<string, set<string>>                          &protocolToSuperProtocols,
                                    unordered_map <string, string> &classToSuperClass,
                                    unordered_map <string, set<string> > &classToProtocols,
                                    unordered_map<string, string> &swiftClassToUknownSuperClassOrProtocol) {
    //build dictionary
    for (unordered_map<string, string>::const_iterator it = swiftClassToUknownSuperClassOrProtocol.begin(); it != swiftClassToUknownSuperClassOrProtocol.end(); ++it) {
        
        string className = it->first;
        string superClassOrProtocol = it->second;

        unordered_map<string, set<string>>::const_iterator protocolFindIterator = protocolToSuperProtocols.find(superClassOrProtocol);
        if (protocolFindIterator != protocolToSuperProtocols.end()) {
            //This is a protocol
            //Search in classToProtocols for key with className
            if (contains(classToProtocols, className)) {
                //If found add to set.
                set<string> implementedProtocols = classToProtocols[className];
                implementedProtocols.insert(superClassOrProtocol);
            }
            else {
                //If no - create a new set
                set<string> implementedProtocols;
                implementedProtocols.insert(superClassOrProtocol);
                classToProtocols[className] = implementedProtocols;
            }
        }
        else { //if it's not a protocol - it means it's a class!
            classToSuperClass[className] = superClassOrProtocol;
        }
    }
}

void addBindToResultList(string &className,
                         set<string> implementedProtocols,
                         unordered_map<string, set<string> > &protocolToSuperProtocols,
                         unordered_map <string, set<string> > &protocolToImps)
{
    
    while (implementedProtocols.size() > 0) {
        set<string> nextRoundImplementedProtocols;
        for(set<string>::const_iterator protocolNameIterator = implementedProtocols.begin(); protocolNameIterator != implementedProtocols.end(); protocolNameIterator++ ) {
            
            string protocolName = *protocolNameIterator;
            
            //cout << "className: [" <<  className <<  "] protocolName: [" << protocolName << "]" << endl;
            
            if (!contains(protocolToImps, protocolName)) {
                set<string> protocolList;
                protocolToImps[protocolName] = protocolList;
            }
            
            protocolToImps[protocolName].insert(className);
            
            if (protocolName.find(appleGuice) == string::npos && contains(protocolToSuperProtocols, protocolName)) {
                set<string> superProtocols = protocolToSuperProtocols[protocolName];
                if (contains(superProtocols, NSObject)) {
                    protocolToSuperProtocols[protocolName].erase(NSObject);
                }
                if (superProtocols.size() != 0) {
                    nextRoundImplementedProtocols.insert(superProtocols.begin(), superProtocols.end());
                }
            }
        }
        implementedProtocols = nextRoundImplementedProtocols;
    }
}

bool hasPrefixToIgnore(string className, set<string> prefixesToIgnore) {
    for(set<string>::const_iterator prefixesToIgnoreIterator = prefixesToIgnore.begin(); prefixesToIgnoreIterator != prefixesToIgnore.end(); prefixesToIgnoreIterator++ ) {
        if (isPrefix(*prefixesToIgnoreIterator, className)) {
            return true;
        }
    }
    return false;
}

void protocolsImplementedByClass(string &className,
                                 unordered_map <string, string> &classToSuperClass,
                                 unordered_map <string, set<string> > &classToProtocols,
                                 set<string> prefixesToIgnore,
                                 set<string> &result)
{
    
    string curClassName = className;
    
    while (true) {
        if (contains(classToProtocols, curClassName)) {
            set<string> implementedProtocols = classToProtocols[curClassName];
            result.insert(implementedProtocols.begin(), implementedProtocols.end());
        }
        
        if (contains(classToSuperClass, curClassName)) {
            string superClass = classToSuperClass[curClassName];
            if (!isNSObject(superClass) && !hasPrefixToIgnore(superClass, prefixesToIgnore)) {
                curClassName = superClass;
            }
            else {
                break;
            }
        }
        else {
            break;
        }
    }
}


void generateAppleGuiceCodeForEntry(string &protocolName, set<string> &implementingClasses, unordered_map<string, string> &classOrProtocolToModule, stringstream &stringBuilder) {
	const string classesDelimiter = ", ";

    stringBuilder << "[self.bindingService setImplementationsFromStrings:@[";

    unsigned long setSize = implementingClasses.size();
    for(set<string>::const_iterator implementedProtocolsIterator = implementingClasses.begin(); implementedProtocolsIterator != implementingClasses.end(); implementedProtocolsIterator++ ) {
		string implementationName = *implementedProtocolsIterator;
        if (contains(classOrProtocolToModule, implementationName)) {
            string moduleName = classOrProtocolToModule[implementationName];
            implementationName = moduleName + "." + implementationName;
        }
		stringBuilder << "@\"" << implementationName << "\"";
		--setSize;
		if (setSize > 0) {
			stringBuilder << classesDelimiter;
		}
	}
    if (contains(classOrProtocolToModule, protocolName)) {
        string moduleName = classOrProtocolToModule[protocolName];
        protocolName = moduleName + "." + protocolName;
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

string generateAppleGuiceCode(unordered_map <string, set<string> > &protocolToImps, unordered_map<string, string> &classOrProtocolToModule)
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
        
        //We want to disregard the module protocols
        if (protocolName.find(appleGuiceModule) != string::npos) {
            continue;
        }
        
    	set<string> implementingClasses = it->second;

    	if(isNSObject(protocolName)) continue;

    	set<string> filteredClasses = filterNonInjectableClasses(injectableClasses, implementingClasses);

    	if (filteredClasses.size() == 0) continue;

    	generateAppleGuiceCodeForEntry(protocolName, filteredClasses, classOrProtocolToModule, stringBuilder);
    	
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

unordered_map<string, set<string> > generateProtocolsToImpsMap(string headerEntriesAsString, set<string> prefixesToIgnore, unordered_map<string, string> &classOrProtocolToModule) {
	unordered_map<string, set<string> > protocolToSuperProtocols;
	unordered_map<string, set<string> > classToProtocols;
	unordered_map<string, string> classToSuperClass;

	unordered_map<string, set<string> > protocolToImps;
    
    /*In Swift in case of class definition - class someClass: x, y, z
     We don't know if "x" is a class, a protocol, a struct or an enum. So we will keep a map of
     classes to their respective x's. Once we have the class and protocol list, we will check for each questionable case if it's a class or not. If it's in the class list, we will update the classToSuperClass map. If it's in the protocol list, we will update the classToProtocols map. Otherwise it's a class or a protocol not defined by us. So in these cases the Boostrapper will ignore it.*/
    unordered_map<string, string> swiftClassToUknownSuperClassOrProtocol;
    
  	vector<string> headerEntries = split(headerEntriesAsString, "\n");

  	//parse
  	for(vector<string>::const_iterator headerEntriesIterator = headerEntries.begin(); headerEntriesIterator != headerEntries.end(); headerEntriesIterator++ ) {
		string entry = *headerEntriesIterator;
		entry = trim(entry);
		parseLine(entry, protocolToSuperProtocols, classToSuperClass, classToProtocols, swiftClassToUknownSuperClassOrProtocol, classOrProtocolToModule);
  	}
    
    resolveSwiftClassOrProtocolMap(protocolToSuperProtocols, classToSuperClass, classToProtocols, swiftClassToUknownSuperClassOrProtocol);

  	//build dictionary
    for (unordered_map<string, string>::const_iterator it = classToSuperClass.begin(); it != classToSuperClass.end(); ++it) {
    	string className = it->first;

        set<string> implementedProtocols;
        
        protocolsImplementedByClass(className, classToSuperClass, classToProtocols, prefixesToIgnore, implementedProtocols);
        
        addBindToResultList(className, implementedProtocols, protocolToSuperProtocols, protocolToImps);
    }
    ////
    
    
    ////
    return protocolToImps;
}

set<string> getPrefixesToIgnore(string prefixesStr) {
    set<string> prefixesToIgnore;
    vector<string> prefixEntries = split(prefixesStr, ",");
    
    for(vector<string>::const_iterator prefixesIterator = prefixEntries.begin(); prefixesIterator != prefixEntries.end(); prefixesIterator++ ) {
        string prefix = *prefixesIterator;
        prefixesToIgnore.insert(trim(prefix));
    }
    return prefixesToIgnore;
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
    
    set<string> prefixesToIgnore;
    if (argc > 1) {
        prefixesToIgnore = getPrefixesToIgnore(argv[1]);
    }
    /*When working with Dynamic Frameworks which have their own domain, we must know the class/protocol module when creating the bindings. If a swift protocol resides in a module, then on runtime it can only be identified as ${MODULE_NAME}.${PROTOCOL_NAME}. It's the responsibility of the user of AppleGuice to mark a protocol or class with the designated module. He can do it by creating a protocol named ${MODULE_NAME}AppleGuiceModule, and making sure that the protocol/class conforms to it.*/
    unordered_map<string, string> classOrProtocolToModule;
    
    unordered_map<string, set<string> > protocolToImps = generateProtocolsToImpsMap(headerEntriesAsString, prefixesToIgnore, classOrProtocolToModule);
    
    //generate code
    string generatedCode = generateAppleGuiceCode(protocolToImps, classOrProtocolToModule);
    
    cout << generatedCode;
}

