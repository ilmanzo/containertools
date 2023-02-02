import macros
from std/strutils import format, split
import containertools/instruction
import containertools/containerspec
export instruction
export containerspec

# instead of writing a bunch of templates, like
#
# template FROM*(baseImage: string) = s.add(FROM, baseImage)
# template COMMENT*(text: string) = s.add(COMMENT, text)
#
# we simply generate with a macro
macro autoGenAllTheTemplates() =
  var allTemplates: string
  for item in BuildInstruction:
    allTemplates.add "template $1*(arg: string) = spec.add Instruction(cmd: $1,kind: Ak_string, str_val: arg)\n".format($item)
  parseStmt allTemplates

# some commands have special cases for argument type
template CMD*(items: openArray) =
  spec.add Instruction(cmd: CMD, kind: Ak_array, array_val: items)
template ENTRYPOINT*(items: openArray) =
  spec.add Instruction(cmd: ENTRYPOINT, kind: Ak_array, array_val: items)
template RUN*(items: openArray) =
  spec.add Instruction(cmd: RUN, kind: Ak_array, array_val: items)
template EXPOSE*(port: uint16) =
  spec.add Instruction(cmd: EXPOSE, kind: Ak_int, int_val: port)

# run macro
autoGenAllTheTemplates()

# our DSL implementation
template container*(instructions: untyped): ContainerSpec =
  var spec {.inject.}: ContainerSpec
  instructions
  spec

