#!/bin/bash

#LIBRARY_NAMES=("spring-core-" "spring-beans-" "spring-webmvc-" )
LIBRARY_NAMES=("spring-core-")

function analyzeArchive {
    ARCHIVE=$1
    APP=$2

    for n in ${LIBRARY_NAMES[@]}; do
        doAnalyzeArchive $n $ARCHIVE $APP
    done
}

function doAnalyzeArchive {
    LIBRARY=$1
    FILE=$(basename $ARCHIVE)
    if [[ $FILE = $LIBRARY* ]]
    then
        echo $FILE in $APP/$ARCHIVE
    fi
}

function analyzeApplication {
    analyzeArchive $1 ""

    for ARCHIVE in $(tar -tf $1 '*.jar' 2>/dev/null)
    do
        analyzeArchive $ARCHIVE $1
    done
}

for APP in $(find . -type f -name \*.jar -or  -type f -name \*.war 2>/dev/null)
do
    analyzeApplication $APP
done




