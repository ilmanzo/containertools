import std/sequtils
import std/strutils

type
  BuildInstruction* = enum
    FROM, RUN, COPY, ENV, WORKDIR, EXPOSE, CMD, COMMENT, ADD, USER, VOLUME,
        LABEL, ENTRYPOINT, ARG, ONBUILD, STOPSIGNAL, HEALTHCHECK, SHELL
  ArgKind* = enum Ak_int, Ak_string, Ak_array
  Instruction* = object
    cmd*: BuildInstruction
    case kind*: ArgKind
    of Ak_int:
      int_val*: uint16
    of Ak_string:
      str_val*: string
    of Ak_array:
      array_val*: seq[string]

  ContainerSpec* = seq[Instruction]

# equality operator for Instruction
proc `==`*(self, other: Instruction): bool =
  if self.cmd != other.cmd:
    return false
  if self.kind != other.kind:
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

# string conversion for Instruction
proc `$`*(self: Instruction): string =
  let arg_str = case self.kind
    of Ak_int: $self.int_val
    of Ak_string: self.str_val
    of Ak_array: "[" & self.array_val.mapIt('"' & $it & '\"').join(",") & "]"
  case self.cmd
  of COMMENT:
    result = "# " & arg_str
  else:
    result = $self.cmd & " " & arg_str

# convert from ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"] to an array of strings
proc unquote(s: string): seq[string] =
  result = s.strip[1..^2].split(',').mapIt(it.strip[1..^2])

proc isNumeric(x: string): bool =
  try:
    discard parseInt(x)
    result = true
  except ValueError:
    result = false


# parse a string into a Instruction
proc parse*(str: string): Instruction =
  let tokens = str.strip().split(maxsplit = 1)
  if str.startsWith("#"):
    return Instruction(cmd: COMMENT, kind: Ak_string, str_val: tokens[1])
  let arg = tokens[1].strip
  let parsed_instr = parseEnum[BuildInstruction](tokens[0].strip)
  if (parsed_instr == CMD or parsed_instr == RUN or parsed_instr ==
      ENTRYPOINT) and arg.startsWith('['):
    return Instruction(cmd: parsed_instr, kind: Ak_array, array_val: unquote(arg))
  if parsed_instr == EXPOSE and arg.isNumeric:
    return Instruction(cmd: EXPOSE, kind: Ak_int, int_val: uint16(
        arg.parseInt)) # TODO: can overflow
  result = Instruction(cmd: parsed_instr, kind: Ak_string, str_val: arg)






