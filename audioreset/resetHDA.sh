#!/bin/sh

#  resetHDA.sh
#  audioreset
#
#  Created by Michael Clifford on 6/13/14.
#  Copyright (c) 2014 Suite Potato. All rights reserved.

launchctl unload /System/Library/LaunchDaemons/com.apple.audio.coreaudiod.plist
kextunload /System/Library/Extensions/AppleHDA.kext
kextload /System/Library/Extensions/AppleHDA.kext
launchctl load /System/Library/LaunchDaemons/com.apple.audio.coreaudiod.plist
