#!/bin/bash
set -e

# Task Variables
build_name=oldscape
output_location=${bamboo.build.working.directory}/output

echo -e "\n Begin: ${bamboo.shortJobName} Task: BuildScript "
# into checkout Directory
pushd ${bamboo.build.working.directory}/$build_name
echo $pwd

#Running a temp Groovy Script to get the 'branchOrTagName' property 
echo "task printProperty { doLast { println project.hasProperty('branchOrTagName') \
? project.'branchOrTagName' : 'NULL' }}" > temp_build.gradle
branchOrTagName=$(./gradlew -q -Pprop=branchOrTagName -b  temp_build.gradle printProperty)
rm temp_build.gradle

if [ "$branchOrTagName" = "NULL" ]; then
  echo " Error getting branchOrTagName property value, please check logs.."
  exit 1
fi

#Save output to a prop file in artifact location
echo "oldscape_artifact_name=server_$branchOrTagName.jar" > $output_location/variable.properties
echo "Printing output"
echo  $output_location/variable.properties

#Task Variables
jarfile_name=server_$branchOrTagName.jar
jarfile_location=${bamboo.build.working.directory}/$build_name/build/branches/$branchOrTagName/server/pack

# Invoking Build, arguments are passed as given in the bamboo plan "Old School RuneScape/oldschool-desktop"
echo -e "Begin: Gradle Build \n"
./gradlew clean rs2_v4:server:buildServer  -Pjdk118Dir=$REPODIR/jdk1.1.8 \
-Pjdk16Src=$REPODIR/jdk1.6.0_24/src.zip \
-Pjdk16JavaxSrc=$REPODIR/jdk1.6.0_24/javax.zip \
-PsigntoolsDir=$REPODIR/signtools \
-Pjava16=$JDK16/bin/java \
-Ppack200_16=$JDK16/bin/pack200 \
-Punpack200_16=$JDK16/bin/unpack200 \
-Pjarsigner16=$JDK16/bin/jarsigner \
-Pjava18=$JDK18/bin/java

# Validating output directory
pushd $jarfile_location
if [ -f $jarfile_location/$jarfile_name ]; then
    echo "$jarfile_name available, copying to a shared location, and renaming it with the default name 'server_dev.jar' "
    cp 	$jarfile_name  $output_location/server_dev.jar
else
    echo "$jarfile_name is missing, build failed please check the logs"
    exit 1
fi

echo "** End : Build script **"