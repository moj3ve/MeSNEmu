#!/bin/bash

rm -r -f build MeSNEmu.ipa
xcodebuild -project MeSNEmu.xcodeproj | xcpretty
cd build/Release-iphoneos
mkdir -p Build
cd Build
mkdir -p Payload
cd Payload
mv ~/Desktop/MeSNEmu/build/Release-iphoneos/MeSNEmu.app ~/Desktop/MeSNEmu/build/Release-iphoneos/Build/Payload/MeSNEmu.app
cd ../
zip -r -X ../../../"MeSNEmu.ipa" * > /dev/null
cd ../../../
rm -r -f build