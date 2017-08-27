#!/bin/bash
carthage bootstrap


CONFIGURATION=(Debug)
BUILD_DIRECTORY="build"
DESTINATION="platform=iOS Simulator,name=iPhone 5"
ACTION="test"
WORKSPACE="RxLifx.xcworkspace"

SCHEME="LifxDomainTests"

mkdir -p build

xcodebuild -workspace "${WORKSPACE}" \
		-scheme "${SCHEME}" \
		-configuration "${CONFIGURATION}" \
		-derivedDataPath "${BUILD_DIRECTORY}" \
		-destination "$DESTINATION" \
		$ACTION | tee build/last-build-output.txt | xcpretty -c

SCHEME="RxLifxTests"

xcodebuild -workspace "${WORKSPACE}" \
		-scheme "${SCHEME}" \
		-configuration "${CONFIGURATION}" \
		-derivedDataPath "${BUILD_DIRECTORY}" \
		-destination "$DESTINATION" \
		$ACTION | tee build/last-build-output.txt | xcpretty -c

SCHEME="RxLifxApiTests"

xcodebuild -workspace "${WORKSPACE}" \
        -scheme "${SCHEME}" \
        -configuration "${CONFIGURATION}" \
        -derivedDataPath "${BUILD_DIRECTORY}" \
        -destination "$DESTINATION" \
        $ACTION | tee build/last-build-output.txt | xcpretty -c