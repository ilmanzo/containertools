import unittest2
import containertools

suite "parse single line":
  test "can parse some instruction":
    let testTable = [
      ("FROM opensuse/leap", Instruction(cmd: BuildInstruction.FROM,
          kind: Ak_string, str_val: "opensuse/leap")),
      ("CMD command param1 param2", Instruction(cmd: BuildInstruction.CMD,
          kind: Ak_string, str_val: "command param1 param2")),
      (r"CMD [""/usr/bin/mongod""]", Instruction(cmd: BuildInstruction.CMD,
          kind: Ak_array, array_val: @["/usr/bin/mongod"])),
      ("COPY start.sh start.sh", Instruction(cmd: BuildInstruction.COPY,
          kind: Ak_string, str_val: "start.sh start.sh")),
      ("RUN rm /usr/sbin/policy-rc.d", Instruction(cmd: BuildInstruction.RUN,
          kind: Ak_string, str_val: "rm /usr/sbin/policy-rc.d"))
    ]
    for items in testTable:
      check: items[0].parse == items[1]

suite "parse feature":
  test "can parse basic containerfile":
    let image1 = fromFile("tests/data/Containerfile.hello")
    let image2 = container:
      FROM "opensuse/leap"
      CMD "echo Hello"
    check: image1 == image2

  test "can parse containerfile with comments":
    let image1 = fromFile("tests/data/Containerfile.with_comments")
    let image2 = container:
      COMMENT "this is a simple containerfile"
      FROM "opensuse/leap"
      COMMENT "with comments added"
      CMD @["echo", "Hello"]
    check: image1 == image2



