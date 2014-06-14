appleHDAReset
=============

OS X Menu App to run resetHDA helper script

Be sure to create ~/resetHDA.sh (/Users/<username>/resetHDA.sh) with the following contents:

`#!/bin/sh
sudo kextunload /System/Library/Extensions/AppleHDA.kext
sudo kextload /System/Library/Extensions/AppleHDA.kext
sudo killall coreaudiod`

Once that is created be sure to chmod +x ~/resetHDA.sh