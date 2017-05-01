===========================
New machine, new challenges
===========================

:date: 2015-12-27 23:37:38
:slug: new-machine-new-challenges
:authors: matael
:summary: Because at some point eeepc are not enough
:tags: perso, imported

After years using an old eeePC from Asus as my only laptop (and therefore the only computer I can use when I'm not at
home), I finally switched to a brand new Dell ultrabook.

It took months to make a clear choice, but a lot of exchanges about laptops with friends oriented me to a Dell XPS 13
computer.

No touchscreen on mine : I wouldn't have used it, no QHD+ either since it's only available on touch-enable machines. The
setup is good though : with a i5 6200U processor, 8GiB of RAM and a 256GiB SSD it's a huge step away from the low-perf
eeepc.

Installation
============

First step with the machine in hands : install an fresh ArchLinux_.

The model I have is the 2016 version of the 13" laptop (9350). As it just went out, there's no official support yet
and some components are not working out-of-the-box.

It's the case of the Broadcom wifi chip (*sic*), fortunately, I had an old Sweex wifi-usb dongle lying around (there's no
Ethernet socket on the XPS).

The Arch install went smoothly, as usual: ``fdisk``, mount, ``pacstrap``, ``chroot`` and here you go !
The newly named **cedar** is born !

Be sure to change the SATA-controller settings to *AHCI* or *Off* instead of *Raid On* in the BIOS before trying to boot
on USB.

Emancipation from the dongle
----------------------------

After reading the `great-as-usual page`_ about the XPS on the Archlinux Wiki, I decided to switch to a
``linux-mainline`` kernel (available `from the AUR`_). The kernel compiled in a reasonable time and after adding the
`right firmware`_ blob for the wifi card everything went well.

About Keyboard lights
---------------------

A dive into ``/sys/class`` tell you that you can control your keyboard backlight through ``/sys/class/leds/dell::kbd_backlight/brightness``.
Googling around, and crawling the AUR_, I found kbdlight_, a C utility able to control keyboard backlight of MacBooks.

All you have to do is forking it, modify the line 5 to ``/sys/class/leds/dell::kbd_backlight/`` and then :

.. code-block:: bash

        $ sudo make PREFIX=/usr/ install

Fix the permissions on the brightness file and here you go !

Impressions
===========

On the past few days, I used the XPS a lot (since I had to prepare it for an overbooked first week of January).

My first impressions are excellent : the chiclet keyboard is pretty comfortable and the InfinityEdge display is
**awesome**, really. I enjoy having a powerful 13 inches ultrabook with such a small size.

I may need an adapter to get additional USB & HDMI from the Thunderbolt port since 2 USB are clearly not enough for a
day to day use.

I didn't try the camera yet, but it seems that given its position (bottom left of the screen) it'll be noisy and poorly
framed... I don't really care : it'll still be sufficient for my scarce webcam usage.

Final setup
===========

As I never detailled my setup, here it is :

- i3wm_ as a window manager (tiling is perfect)
- rxvt unicode with solarized_ theme, zsh (and omz_), tmux_, git_
- mutt as a mail client (fetchmail and msmtp as relays)
- vim_ + vundle_, CtrlP, YouCompleteMe and some others
- TaskWarrior_ for tasks
- Firefox_, Ghostery_
- Zotero_ & Pocket_ for researches and readings

This new machine was finally a way for me to tidy a bit my `dotfiles repo`_! Pick what you need !

.. _AUR: https://aur.archlinux.org/
.. _kbdlight: https://github.com/hobarrera/kbdlight/
.. _dotfiles repo: https://github.com/Matael/dotfiles
.. _Archlinux: http://archlinux.org
.. _great-as-usual page: https://wiki.archlinux.org/index.php/Dell_XPS_13_%282016%29
.. _from the AUR: https://aur.archlinux.org/packages/linux-mainline/
.. _right firmware: https://git.kernel.org/cgit/linux/kernel/git/firmware/linux-firmware.git/plain/brcm/brcmfmac4350-pcie.bin
.. _i3wm: http://i3wm.org/
.. _solarized: http://ethanschoonover.com/solarized
.. _omz: http://ohmyz.sh/
.. _tmux: https://tmux.github.io/
.. _git: http://www.git-scm.com/
.. _vim: http://www.vim.org/
.. _vundle: https://github.com/VundleVim/Vundle.vim
.. _TaskWarrior: http://taskwarrior.org/
.. _Firefox: https://www.mozilla.org/firefox/
.. _Ghostery: https://www.ghostery.com/
.. _Zotero: https://www.zotero.org/
.. _Pocket: http://getpocket.com/a/
