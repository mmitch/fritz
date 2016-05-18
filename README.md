Fritz - perl module for AVM Fritz!Box interaction via TR-064
============================================================

[![Build Status](https://travis-ci.org/mmitch/fritz.svg?branch=master)](https://travis-ci.org/mmitch/fritz)
[![Coverage Status](https://codecov.io/github/mmitch/fritz/coverage.svg?branch=master)](https://codecov.io/github/mmitch/fritz?branch=master)
[![GPL 2+](https://img.shields.io/badge/license-GPL%202%2B-blue.svg)](http://www.gnu.org/licenses/gpl-2.0-standalone.html)


what? why?
----------

I wanted to use an old analog field telephone with my FritzBox and
VoIP.  While this works quite out-of-the box (it’s just an ordinary
analog phone) for receiving calls, I have no way to dial a number for
outgoing calls.

Luckily the Fritz!Box has a call helper mode where you can tell it to
dial a number and patch it through to any local phone, but I found no
Perl library to use this feature.  So I wrote my own library - the one
you’re looking at right now.


where to get it
---------------

The Fritz library is hosted at https://github.com/mmitch/fritz


more information
----------------

An example of how to use this library as a dial helper and call log
tool can be seen at https://github.com/mmitch/fritzdial

A blog article covering my setup is here:
https://www.cgarbs.de/blog/archives/1113-Feldtelefon-an-Fritzbox.html (German only)


copyright
---------

Copyright (C) 2015  Christian Garbs <mitch@cgarbs.de>  
Licensed under GNU GPL v2 or later.
