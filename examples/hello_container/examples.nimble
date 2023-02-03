# Package

version       = "0.1.0"
author        = "Andrea Manzini"
description   = "a demo program for containertools library"
license       = "GPL-3.0-only"
srcDir        = "src"
bin           = @["hello"]


# Dependencies

requires "nim >= 1.6.10"
requires "containertools"