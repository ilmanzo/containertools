# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import unittest2
import containertools
from strutils import splitLines
from sequtils import zip

# helper to compare two spec files avoiding newline issues
proc equalToReference(image: ContainerSpec, sourceFile: string): bool =
  let spec = $image
  for item in zip(spec.splitLines, sourceFile.readFile.splitLines):
    if item[0] != item[1]:
      echo "expected:", item[1], "got:", item[0]
      return false
  return true


suite "Basic dsl test":
  test "can create basic container":
    let image = container:
      FROM "opensuse/leap"
      CMD "echo Hello" # commands will be auto-splitted in an array
    check: image.equalToReference("reference/Containerfile.hello")

  test "can create containers with exposed port":
    let image = container:
      FROM "node:16"
      COPY ". ."
      RUN "npm install"
      EXPOSE 3000
      CMD @["node", "index.js"]
    check: image.equalToReference("reference/Containerfile.unoptimized.nodejs")

  test "can create image with env variables":
    let image = container:
      FROM "busybox"
      ENV "FOO=/bar"
      WORKDIR "${FOO}"
      ADD ". $FOO"
      COPY "$FOO /quux"
    check: image.equalToReference("reference/Containerfile.withenv")

  




