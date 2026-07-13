#!/bin/sh

cd $(dirname $0)
defaults write org.hammerspoon.Hammerspoon MJConfigFile "$(pwd)/init.lua"
