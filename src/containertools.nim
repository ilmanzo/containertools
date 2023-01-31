import macros except body
from std/strutils import join, format, split, strip, parseEnum, startsWith
import std/sequtils


type
  BuildInstruction* = enum
    FROM, RUN, COPY, ENV, WORKDIR, EXPOSE, CMD, COMMENT, ADD, USER, VOLUME,
        LABEL, ENTRYPOINT, ARG, ONBUILD, STOPSIGNAL, HEALTHCHECK, SHELL
  ArgKind* = enum Ak_int, Ak_string, Ak_array
  SpecItem* = object
    instr*: BuildInstruction
    case kind*: ArgKind
    of Ak_int:
      int_val*: uint16
    of Ak_string:
      str_val*: string
    of Ak_array:
      array_val*: seq[string]

  ContainerSpec* = seq[SpecItem]

# equality operator for SpecItem
proc `==`*(self, other: SpecItem): bool =
  if self.instr != other.instr:
    return false
  case self.kind
  of Ak_string:
    if self.str_val != other.str_val:
      return false
  of Ak_int:
    if self.int_val != other.int_val:
      return false
  of Ak_array:
    if self.array_val != other.array_val:
      return false
  return true

# string conversion for SpecItem
proc `$`*(self: SpecItem): string =
  let arg_str = case self.kind
    of Ak_int: $self.int_val
    of Ak_string: self.str_val
    of Ak_array: "[" & self.array_val.mapIt('"' & $it & '\"').join(",") & "]"
  case self.instr
  of COMMENT:
    result = "# " & arg_str
  else:
    result = $self.instr & " " & arg_str


proc parseSpec*(spec: string): ContainerSpec =
  discard

# returns string representation of a complete container image
proc `$`*(self: ContainerSpec): string = self.mapIt($it).join("\n")

# checks presence of FROM and one of CMD,ENTRYPOINT
proc isValid*(self: ContainerSpec): bool =
  var foundFROM: bool = false
  var foundCMD_or_ENTRYPOINT: bool = false
  var firstFOUND = true
  for item in self:
    case item.instr
      of COMMENT: continue
      of FROM: foundFROM = true
      of CMD, ENTRYPOINT:
        foundCMD_or_ENTRYPOINT = true
        if not foundFROM:
          firstFOUND = false
      else:
        if not foundFROM:
          firstFOUND = false
  result = foundFROM and foundCMD_or_ENTRYPOINT and firstFOUND

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

template CMD*(items: openArray) =
  spec.add SpecItem(instr: CMD, kind: Ak_array, array_val: items)
template CMD*(arg: string) =
  spec.add SpecItem(instr: CMD, kind: Ak_array, array_val: arg.split)

autoGenAllTheTemplates()

# some commands have special cases for argument type
template EXPOSE*(port: uint16) =
  spec.add SpecItem(instr: EXPOSE, kind: Ak_int, int_val: port)

template container*(instructions: untyped): ContainerSpec =
  var spec {.inject.}: ContainerSpec
  instructions
  spec

proc fromFile*(filename: string): ContainerSpec =
  for line in filename.lines:
    let tokens = line.strip().split(' ', 2)
    if line.startsWith("#"):
      result.add(SpecItem(instr: COMMENT, kind: Ak_string,
          str_val: tokens[1]))
      continue
    let parsed_instr = parseEnum[BuildInstruction](tokens[0])
    result.add(SpecItem(
        instr: parsed_instr, kind: Ak_string,
        str_val: tokens[1]))



