#!/bin/bash
#Copyright 2013 Tomer Shiri appleGuice@shiri.info
#
#Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License.
#You may obtain a copy of the License at
#
#http://www.apache.org/licenses/LICENSE-2.0
#
#Unless required by applicable law or agreed to in writing, software
#distributed under the License is distributed on an "AS IS" BASIS,
#WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#See the License for the specific language governing permissions and
#limitations under the License.

if [ ! "$1" ]; then
	echo "Usage: $0 <path to directory> <output destination>";
	exit 1;
fi

bootstrapper="bootStrapper";

path=$1;
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ ! -f ${scriptDir}/${bootstrapper} ]
then
    cd ${scriptDir};
    make EXENAME=${bootstrapper} CXXFLAGS=-mios-version-min=7.0.0
fi

interfaceDeclerations=$(grep -sirhE --include=*.h --regexp='((@interface[^:]+:\s*[^>{}*/!]*>?)|(@protocol[^<]*<[^>]+>))' ${path});

result=$(echo "${interfaceDeclerations}" | ${scriptDir}/${bootstrapper});

if [ "$2" ]; then
	echo > $2;
	echo "${result}" >> $2;
else
	echo "${result}"
fi
exit 0;
