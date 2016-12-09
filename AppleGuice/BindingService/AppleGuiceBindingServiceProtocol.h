//Copyright 2013 Tomer Shiri appleguice@shiri.info
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

typedef enum appleGuiceBindingType {
    appleGuiceBindingTypeUserBinding = 1,
    appleGuiceBindingTypeCachedBinding = 2
} appleGuiceBindingType;

@protocol AppleGuiceBindingServiceProtocol <NSObject>

-(void) setImplementation:(Class)clazz withProtocol:(Protocol*)protocol withBindingType:(appleGuiceBindingType) bindingType;
-(void) setImplementations:(NSArray*)classes withProtocol:(Protocol*)protocol withBindingType:(appleGuiceBindingType) bindingType;

-(void) setImplementationFromString:(NSString*)classAsString withProtocolAsString:(NSString*)protocolAsString withBindingType:(appleGuiceBindingType)bindingType;
-(void) setImplementationsFromStrings:(NSArray*)classesAsString withProtocolAsString:(NSString*)protocolAsString withBindingType:(appleGuiceBindingType)bindingType;

-(void) unsetImplementationOfProtocol:(Protocol*) protocol;
-(void) unsetAllImplementationsWithType:(appleGuiceBindingType) bindingType;

-(NSArray*) getClassesForProtocol:(Protocol*) protocol;

@end
