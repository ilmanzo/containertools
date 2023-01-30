# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import unittest2
import containertools
from strutils import splitLines

# helper to compare two spec files avoiding newline issues
proc equalToReference(image: string, sourceFile: string): bool =
  image.splitLines == sourceFile.readFile.splitLines


suite "Basic dsl test":
  test "can create basic container":
    let image = containerSpec:
      FROM "opensuse/leap"
      CMD "echo Hello" # commands will be auto-splitted in an array
    check: image.equalToReference("reference/Dockerfile.hello")

  test "can create containers with exposed port":
    let image = containerSpec:
      FROM "node:16"
      COPY ". ."
      RUN "npm install"
      EXPOSE 3000
      CMD @["node", "index.js"]
    check: image.equalToReference("reference/Dockerfile.unoptimized.nodejs")



