# Lomiri

Lomiri is the operating environment for everywhere. It is able to span the gaps between touch, mouse, and keyboard; between phones, tablets, and workstations; and look good doing it.

If you want to contribute to Lomiri on Ubuntu Touch, you've come to the right place. If you want to package Lomiri for other operating systems, you'll be better served by the main branch on the repository that we're migrating to: https://gitlab.com/ubports/core/lomiri

Lomiri has been renamed from Unity8. Most of the software on-device in Ubuntu Touch based on Ubuntu 16.04 is still called `unity8`.

## Where to report issues

Issues related to the version of Lomiri that currently runs on Ubuntu Touch devices may still be reported on this repository. We will move these reports to the GitLab repository as part of our final migration.

## Developing Lomiri on Ubuntu Touch

This repository contains the code for Lomiri currently running on Ubuntu Touch. If you would like to modify this version of Lomiri, follow the steps below. If you would like to modify Lomiri in another operating system, check out our new repository: https://gitlab.com/ubports/core/lomiri

Lomiri can be built and its test suite run using [`clickable`](https://clickable-ut.dev). This is a convenient method to try out most graphical changes to Lomiri without an annoying redeployment process. If you wish to test your changes on your device or make changes that are more difficult to test without real hardware, check out [Making changes and testing locally on the UBports documentation](https://docs.ubports.com/en/latest/systemdev/testing-locally.html). If not, read on.

Before you start, [install Clickable](https://clickable-ut.dev/en/latest/install.html).

Now, clone this repository to your computer: `git clone https://github.com/ubports/unity8.git`

Move into this directory: `cd unity8`

Now you can use the full suite of tools provided by this repository's [clickable.json](clickable.json). For example:

* `clickable ide qtcreator` will open QtCreator with this repository open as a project. You can edit and build the project this way, but running the tests will be a bit difficult.
* `clickable build-libs --debug` will build Lomiri in the same environment as it would receive in Ubuntu Touch.
* `clickable test-libs` will run the entire Lomiri test suite. This test suite includes graphical tests (which are run on a virtual, invisible desktop) and non-graphical unit tests. These tests make sure Lomiri functions as prescribed and prevents new bugs from being added. You should run them before you create a PR on this repository. This command takes about 7 minutes on an Intel i7-8550U, so plan your time accordingly and use the next two options to reduce the number of times you need to run the whole test suite...
* `clickable ide 'cd build/x86_64-linux-gnu/unity8/ && make tryShell'` and similar commands that replace the `Shell` with another test target defined in [tests/qmltests/CMakeLists.txt](tests/qmltests/CMakeLists.txt) allow trying out some Lomiri components in a mock environment. You can use this to try out your changes to Lomiri as you develop.
* `clickable ide 'cd build/x86_64-linux-gnu/unity8/ && make xvfbtestShell'` and similar commands that replace the `Shell` with another test target defined in [tests/qmltests/CMakeLists.txt](tests/qmltests/CMakeLists.txt) allow running a single TestCase. You can remove the `xvfb` part of the make target to run the test case graphically, which might help you see what is causing the test to fail.
