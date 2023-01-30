import macros except body
from std/strutils import join, format, split
import std/sequtils
import std/sugar

type
  ContainerInstruction = enum
    FROM, RUN, COPY, ENV, WORKDIR, EXPOSE, CMD, COMMENT, ADD, USER, VOLUME,
        LABEL, ENTRYPOINT, ARG, ONBUILD, STOPSIGNAL, HEALTHCHECK, SHELL
  ArgKind = enum uint16, string, openArray
  ArgValue = object
    case kind: ArgKind:
    of uint16:
      ivalue: int
    of string:
      svalue: string
    of openArray:
      avalue: seq[string]
  InstructionTuple = tuple[instr: ContainerInstruction, arg: ArgValue]

  ContainerSpec* = seq[InstructionTuple]

proc parseSpec*(spec: string): ContainerSpec =
  discard

# returns string representation of a container image
proc `$`*(self: ContainerSpec): string =
  var tmpout: seq[string]
  for item in self:
    let argvalue = item.arg
    let outvalue = case argvalue.kind
      of uint16: $argvalue.ivalue
      of string: argvalue.svalue
      of openArray: "[" & argvalue.avalue.mapit('"' & $it & '\"').join(",") & "]"
    case item.instr:
      of COMMENT:
        tmpout.add("# $1".format(outvalue))
      else:
        tmpout.add("$1 $2".format(item.instr, outvalue))
  tmpout.join("\n")

proc isValid*(self: ContainerSpec): bool =
  # check presence of at least one FROM statement
  if not self.any(x => (x.instr == FROM)):
    return false
  return true


# instead of writing a bunch of templates, like
#
# template FROM*(baseImage: string) = s.add(FROM, baseImage)
# template COMMENT*(text: string) = s.add(COMMENT, text)
#
# we simply generate with a macro
macro autoGenAllTheTemplates() =
  var allTemplates: string
  for item in ContainerInstruction:
    if item == EXPOSE or item == CMD:
      continue
    let cmd = $item
    allTemplates.add "template $1*(value: string) = spec.add ($1,ArgValue(kind: string, svalue: value))\n".format(cmd)
  parseStmt allTemplates

autoGenAllTheTemplates()
# some commands have special cases for argument type
template EXPOSE*(port: uint16) =
  spec.add (EXPOSE, ArgValue(kind: uint16, ivalue: port))
template CMD*(items: openArray) =
  spec.add (CMD, ArgValue(kind: openArray, avalue: items))
template CMD*(arg: string) =
  spec.add (CMD, ArgValue(kind: openArray, avalue: arg.split))

template container*(instructions: untyped): ContainerSpec =
  var spec {.inject.}: ContainerSpec
  instructions
  spec
