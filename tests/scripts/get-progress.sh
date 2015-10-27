#!/bin/sh

qdbus com.canonical.Unity.Launcher /com/canonical/Unity/Launcher/$1 org.freedesktop.DBus.Properties.Get com.canonical.Unity.Launcher.Item progress
