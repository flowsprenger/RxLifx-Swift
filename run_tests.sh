#!/bin/bash
swift --version
swift clean
swift build
TEST=1 swift test
