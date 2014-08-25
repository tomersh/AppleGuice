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

#import "AppleGuiceInstanceCreatorProtocol.h"

@protocol AppleGuiceMockProviderProtocol;

@interface AppleGuiceInstanceCreator : NSObject<AppleGuiceInstanceCreatorProtocol>

@property (nonatomic, retain) id<AppleGuiceProtocolLocatorProtocol> protocolLocator;
@property (nonatomic, retain) id<AppleGuiceSingletonRepositoryProtocol> singletonRepository;
@property (nonatomic, retain) id<AppleGuiceSettingsProviderProtocol> settingsProvider;
@property (nonatomic, retain) id<AppleGuiceInjectorProtocol> injector;
@property (nonatomic, retain) id<AppleGuiceMockProviderProtocol> mockProvoider;

@end
