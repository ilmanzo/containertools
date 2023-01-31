import std/sequtils
from std/strutils import join

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

