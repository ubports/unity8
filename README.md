# Lomiri

A convergent desktop environment.


[![Unity 8](http://ubuntufun.de/wp-content/uploads/2016/05/screenshot20160518_232322980.png)](https://lomiri.io)


### How to install

The latest development preview of Lomiri for desktop can be installed on Ubuntu 16.04 (xenial) and 18.04 (bionic) as follows:

1. Run the install script
```
bash <(wget -qO- https://raw.githubusercontent.com/ubports/lomiri-desktop-install-tools/master/install.sh)
```
2. Reboot, select "lomiri" at the login prompt, and enjoy :)


**NOTE:**  The above installation instructions currently only work on Ubuntu 16.04 (xenial) and 18.04 (bionic). Please be aware that the script will install the latest *development preview* of Lomiri for desktop.  ***Expect bugs!***  Only install this preview if you understand the risks and are willing/able to fix your system if the preview breaks anything.  You are advised *not* to install this preview onto a production system.

See [CODING](CODING) for build instructions.


### Where to report issues

Issues related to the version of Lomiri for desktop (the latest development preview) installed using the above instructions should be reported on the [Lomiri issue tracker](https://github.com/ubports/lomiri/issues) in *this* repository.

Note that issues related to the version of Lomiri that currently runs on Ubuntu Touch devices should *NOT* be reported in this repository, but instead should be reported on the [Ubuntu Touch issue tracker](https://github.com/ubports/ubuntu-touch/issues). This will change once Ubuntu Touch moves to the latest version of Lomiri.


### What works / what does not work

*This list is incomplete, please help improve it*

What works:
- Most Wayland apps work
- Many report being able to log in using LightDM, but may require a few attempts

Does not work:
- Most Xapps don't (yet) work
- Proprietary drivers don't (yet) work
- Many report being unable to log in using GDM


### Get involved

* [Kanban-Board](https://github.com/ubports/lomiri/projects/1)
* If you are interesting in helping us in any way you can join [Lomiri Forum](https://forums.ubports.com/category/36/lomiri).
* For reporting bugs or filing feature-requests, please use the project’s [issues page](https://github.com/ubports/lomiri/issues).
* For IM you can join our Telegram group [for Developer users](https://t.me/UBports_Lomiri).
