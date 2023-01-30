import unittest2
import containertools
from sequtils import zip

# helper to compare two spec files
# TODO: need to work on payload compare
proc equal(self, other: ContainerSpec): bool =
  for j, item1 in self:
    let item2 = other[j]
    if item1.instr != item2.instr:
      echo "expected:", item2, "got:", item1
      return false
  return true


suite "Basic parsing test":
  test "can parse basic containerfile":
    let image1 = fromFile("reference/Containerfile.hello")
    let image2 = container:
      FROM "opensuse/leap"
      CMD "echo Hello" # commands will be auto-splitted in an array
    check: image1.equal image2


