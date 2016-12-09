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


/*
 All classes marked with AppleGuiceLazyLoad protocol will return a proxy class when Injected. Upon calling an instance method on the service, the proxy will be replaced by a real implementation.
 Instances that are marked with with id<x, AppleGuiceLazyLoad> will result in initializing a proxy class. Upon calling an instance method on the service, the proxy will be replaced by a real implementation.
 */
@protocol AppleGuiceLazyLoad <NSObject>


@end