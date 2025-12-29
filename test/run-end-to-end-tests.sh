#! /bin/bash -e

if [ -d app/application ] ; then 
    cd app/application
else
    cd ../application
fi

./gradlew :endToEndTestsUsingKind

