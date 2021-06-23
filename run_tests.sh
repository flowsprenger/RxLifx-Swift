#!/bin/bash
swift --version
swift build
TEST=1 swift test
