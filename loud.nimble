version = "0.1.0"
author = "NSASPY"
description = "Generate network noise to hinder"
license = "GPL 3"
# deps
requires "nim >= 1.4.8"
requires "nimquery"
requires "ndns"
requires "cligen"
srcDir = "src"

bin = @["loud"]
