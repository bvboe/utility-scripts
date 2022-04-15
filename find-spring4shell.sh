#!/bin/bash
# Detect deployments of spring-core that are vulnerable to cve-2022-22965
# See https://tanzu.vmware.com/security/cve-2022-22965 for more info

# Use regex to find version numbers that are vulnerable
# - 5.3.0 to 5.3.17
# - 5.2.0 to 5.2.19
# - Older, unsupported versions are also affected
LIBRARY_SEARCH_PATTERNS=("spring-core-5\.3\.[0-9]\..*" #spring-core-5.3.0-9
    "spring-core-5\.3\.1[0-7]\..*"                     #spring-core-5.3.10-17
    "spring-core-5\.2\.[0-9]\..*"                      #spring-core-5.2.0-9
    "spring-core-5\.2\.1[0-9]\..*"                     #spring-core-5.2.10-19
    "spring-core-5\.[0-1]\.[0-9]*"                     #spring-core-5.0-1
    "spring-core-[0-4]\.[0-9]*\.[0-9]*\..*"            #spring-core-0-4
    "log4j-api-2\.[0-9]\..*"                           #log4j-api-2.0-9
    "log4j-api-2\.1[0-6]\..*"                          #log4j-api-2.10-16
    "log4j-api-2\.17\.0.*"                             #log4j-api-2.17.0
    )

function analyzeArchive {
    local ARCHIVE=$1
    local APP=$2
    local n=""

    for n in ${LIBRARY_SEARCH_PATTERNS[@]}; do
        doAnalyzeArchive $n $ARCHIVE $APP
    done
}

function doAnalyzeArchive {
    local LIBRARY_PATTERN=$1
    local ARCHIVE=$2
    local APP=$3
    local FILE=$(basename $ARCHIVE)
    if [[ $FILE =~ $LIBRARY_PATTERN ]]
    then
        if [[ $APP == "" ]]
        then
            echo $FILE in $ARCHIVE
        else
            echo $FILE in $APP
        fi
    fi
}

function analyzeApplication {
    local APP=$1
    local ARCHIVE=""
    analyzeArchive $APP ""

    for ARCHIVE in $(tar -tf $APP '*.jar' 2>/dev/null)
    do
        analyzeArchive $ARCHIVE $APP
    done
}

for a in $(find . -type f -name \*.jar -or  -type f -name \*.war 2>/dev/null)
do
    analyzeApplication $a
done
