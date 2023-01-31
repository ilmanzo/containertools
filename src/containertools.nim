import macros
from std/strutils import format, split
import containertools/specitem
import containertools/containerspec
export specitem
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
    case item:
      of CMD, EXPOSE: continue
      else: allTemplates.add "template $1*(arg: string) = spec.add SpecItem(instr: $1,kind: Ak_string, str_val: arg)\n".format($item)
  parseStmt allTemplates

# some commands have special cases for argument type
template CMD*(items: openArray) =
  spec.add SpecItem(instr: CMD, kind: Ak_array, array_val: items)
template CMD*(arg: string) =
  spec.add SpecItem(instr: CMD, kind: Ak_array, array_val: arg.split)
template EXPOSE*(port: uint16) =
  spec.add SpecItem(instr: EXPOSE, kind: Ak_int, int_val: port)

# run macro
autoGenAllTheTemplates()

# our DSL implementation
template container*(instructions: untyped): ContainerSpec =
  var spec {.inject.}: ContainerSpec
  instructions
  spec

