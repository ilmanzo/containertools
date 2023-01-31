import std/sequtils
from std/strutils import join, startsWith, strip, split, parseEnum
import specitem

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

proc save*(self: ContainerSpec, filename: string) = writeFile(filename, $self)

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



