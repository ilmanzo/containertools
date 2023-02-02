# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import unittest2
import containertools
import strutils
from sequtils import zip
import std/strformat

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
      CMD "echo Hello"
    check: image.equalToReference("tests/data/Containerfile.hello")

  test "can create containers with exposed port":
    let image = container:
      FROM "node:16"
      COPY ". ."
      RUN "npm install"
      EXPOSE 3000
      CMD @["node", "index.js"]
    check: image.equalToReference("tests/data/Containerfile.unoptimized.nodejs")

  test "can create image with env variables":
    let image = container:
      FROM "busybox"
      ENV "FOO=/bar"
      WORKDIR "${FOO}"
      ADD ". $FOO"
      COPY "$FOO /quux"
    check: image.equalToReference("tests/data/Containerfile.withenv")

suite "Dynamic dsl test":
  test "can make conditional containers":
    var images = newSeq[ContainerSpec](4)
    for i in countup(0, 3):
      images[i] = container:
        FROM "opensuse/leap"
        if i mod 2 == 0:
          ENV &"buildno={i}.0"
          LABEL "Environment=PROD"
          RUN "zypper install nginx-stable"
        else:
          ENV &"buildno={i}.1"
          LABEL "Environment=DEV"
          RUN "zypper install nginx-testing"
    check: images.len == 4
    let referenceobj = Instruction(cmd: BuildInstruction.LABEL,
        kind: Ak_string, str_val: "Environment=PROD")
    check: images[0][2] == referenceobj













