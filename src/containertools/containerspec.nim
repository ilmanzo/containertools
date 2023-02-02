import std/sequtils
from std/strutils import join, startsWith, strip, split
import instruction

# returns string representation of a complete container image
proc `$`*(self: ContainerSpec): string = self.mapIt($it).join("\n")

# checks presence of FROM and one of CMD,ENTRYPOINT
proc isValid*(self: ContainerSpec): bool =
  var foundFROM: bool = false
  var foundCMD_or_ENTRYPOINT: bool = false
  var firstFOUND = true
  for item in self:
    let instr = item.cmd
    if instr == COMMENT:
      continue # skip any comments
    if instr == FROM:
      foundFROM = true
      continue
    if instr == CMD or instr == ENTRYPOINT:
      foundCMD_or_ENTRYPOINT = true
    if not foundFROM:
      firstFOUND = false
  result = foundFROM and foundCMD_or_ENTRYPOINT and firstFOUND

proc save*(self: ContainerSpec, filename: string) = writeFile(filename, $self)

proc fromFile*(filename: string): ContainerSpec =
  for line in filename.lines:
    result.add instruction.parse(line)

# look for consecutive RUN commands and merge all in one
proc consolidate*(src: ContainerSpec): ContainerSpec =
  var commands: seq[string]
  for item in src:
    if item.cmd == RUN:
      commands.add item.str_val
    else:
      if commands.len > 0:
        result.add Instruction(cmd: RUN, kind: Ak_string,
            str_val: commands.join(" && "))
        commands.setLen 0
      result.add item
  if commands.len > 0:
    result.add Instruction(cmd: RUN, kind: Ak_string, str_val: commands.join(" && "))

