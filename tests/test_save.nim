import unittest2
import containertools

suite "save feature":
  test "can save basic containerfile":
    let image = container:
      FROM "opensuse/leap"
      CMD "echo Hello" # CMD will be auto-splitted in an array
    image.save("tests/data/Containerfile.basic")

