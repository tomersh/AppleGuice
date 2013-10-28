############################################################################
# Copyright 2013 Tomer Shiri applejuice@shiri.info                         #
#                                                                          #
# Licensed under the Apache License, Version 2.0 (the "License");          #
# you may not use this file except in compliance with the License.         #
# You may obtain a copy of the License at                                  #
#                                                                          #
# http://www.apache.org/licenses/LICENSE-2.0                               #
#                                                                          #
# Unless required by applicable law or agreed to in writing, software      #
# distributed under the License is distributed on an "AS IS" BASIS,        #
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. #
# See the License for the specific language governing permissions and      #
# limitations under the License.                                           #
############################################################################
SHELL = /bin/sh

EXENAME = bootStrapper

all: init clean link end
init:
	$(info * [Starting build])
clean:
	$(info * [Cleaning old build])
	$(RM) -f $(EXENAME)
%.o : %.cpp
	$(info * [Creating $@ from $<])
	$(CXX) -c $(CXXFLAGS) $< -o $@
link:
	$(info * [Linking])
	$(CXX) -o $(EXENAME) appleGuiceBootstrapper.cpp -std=c++11 -stdlib=libc++ $(CXXFLAGS)
end:
	$(info * [Build successful. $(EXENAME) was created])
.PHONY: all init clean mkdir link end
.PRECIOUS: link %.o
.SILENT:
#FIN
