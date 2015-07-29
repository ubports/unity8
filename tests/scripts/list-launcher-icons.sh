#!/bin/sh

qdbus com.canonical.Unity | grep Launcher | cut -f6 -d/
