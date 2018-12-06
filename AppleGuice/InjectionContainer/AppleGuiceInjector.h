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

#import "AppleGuiceInjectorProtocol.h"

@protocol AppleGuiceSettingsProviderProtocol;
@protocol AppleGuiceInstanceCreatorProtocol;
@protocol AppleGuiceSwiftProtocolDemanglerProtocol;

@protocol InjectedProtocol <NSObject>
@end

@interface AppleGuiceInjector : NSObject<AppleGuiceInjectorProtocol>

@property (nonatomic, retain) id<AppleGuiceInstanceCreatorProtocol> instanceCreator;
@property (nonatomic, retain) id<AppleGuiceSettingsProviderProtocol> settingsProvider;
@property (nonatomic, retain) id<AppleGuiceSwiftProtocolDemanglerProtocol> swiftProtocolDemangler;
@end
