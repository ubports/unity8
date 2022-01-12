# Lomiri

Lomiri is the operating environment for everywhere. It is able to span the gaps between touch, mouse, and keyboard; between phones, tablets, and workstations; and look good doing it.

This repository contains the new version of Lomiri which powers Ubuntu Touch based on Ubuntu 20.04 and serves as the upstream for packaging Lomiri outside of Ubuntu Touch. Most of the time, you'll want to contribute to the version of Lomiri on Ubuntu Touch based on Ubuntu 16.04, available on [GitHub](https://github.com/ubports/unity8). Changes there will be merged back into this repository from time to time.

Lomiri has been renamed from Unity8. Most of the software on-device in Ubuntu Touch based on Ubuntu 16.04 is still called `unity8`.

## Developing Lomiri on Ubuntu Touch

This section is still being developed. Meanwhile, please have a look at our general guide at: https://docs.ubports.com/en/latest/systemdev/testing-locally.html

<!--- clickable support needs update when clickable supports Focal.
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
--->
