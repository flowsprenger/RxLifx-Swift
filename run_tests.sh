#!/bin/bash
carthage bootstrap  --no-use-binaries --use-xcframeworks


CONFIGURATION=(Debug)
BUILD_DIRECTORY="build"
DESTINATION="platform=iOS Simulator,name=iPhone 8"
ACTION="test"
WORKSPACE="RxLifx.xcworkspace"

SCHEME="LifxDomainTests"

mkdir -p build

xcodebuild -workspace "${WORKSPACE}" \
		-scheme "${SCHEME}" \
		-configuration "${CONFIGURATION}" \
		-derivedDataPath "${BUILD_DIRECTORY}" \
		-destination "$DESTINATION" \
		$ACTION | tee build/last-build-output.txt

SCHEME="RxLifxTests"

xcodebuild -workspace "${WORKSPACE}" \
		-scheme "${SCHEME}" \
		-configuration "${CONFIGURATION}" \
		-derivedDataPath "${BUILD_DIRECTORY}" \
		-destination "$DESTINATION" \
		$ACTION | tee build/last-build-output.txt

SCHEME="RxLifxApiTests"

xcodebuild -workspace "${WORKSPACE}" \
        -scheme "${SCHEME}" \
        -configuration "${CONFIGURATION}" \
        -derivedDataPath "${BUILD_DIRECTORY}" \
        -destination "$DESTINATION" \
        $ACTION | tee build/last-build-output.txt