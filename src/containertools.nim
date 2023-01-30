import macros except body
from std/strutils import join,format,split
from sequtils import mapIt

const DEFAULT_BASE_IMAGE ="opensuse/leap";

type 
  ContainerInstruction = enum 
    FROM, RUN, COPY, ENV, WORKDIR, EXPOSE, CMD , COMMENT , ADD, USER, VOLUME, LABEL, ENTRYPOINT, ARG, ONBUILD, STOPSIGNAL, HEALTHCHECK , SHELL 
  ArgKind=enum uint16,string,openArray
  ArgValue=object 
      case kind: ArgKind:
      of uint16:
        ivalue : int
      of string:
        svalue : string
      of openArray:
        avalue : seq[string]
  InstructionTuple=tuple[c: ContainerInstruction, v : ArgValue]        

  Spec = object
    instructions:seq[InstructionTuple]
    entrypoint: string 
    baseImage : string 

proc parseSpec*(spec: string) : Spec =
  discard

# returns string representation of a container image
proc `$`*(self: Spec): string =
  var tmpout : seq[string]
  for item in self.instructions:
    let value=item.v
    let outvalue = case value.kind 
      of uint16: $value.ivalue
      of string: value.svalue
      of openArray: "[" & value.avalue.mapit('"' & $it & '\"').join(",") & "]"
    case item.c: 
      of COMMENT: 
        tmpout.add("# $1".format(outvalue))
      else:
        tmpout.add("$1 $2".format(item.c,outvalue))
  tmpout.join("\n")
  

# instead of writing a bunch of templates, like
# 
# template FROM*(baseImage: string) = s.add(FROM, baseImage)
# template COMMENT*(text: string) = s.add(COMMENT, text)
#
# we simply generate with a macro
macro autoGenAllTheTemplates() = 
  var allTemplates : string
  for item in ContainerInstruction:
    if item==EXPOSE or item==CMD:
      continue
    let cmd = $item
    allTemplates.add "template $1*(value: string) = spec.instructions.add ($1,ArgValue(kind: string, svalue: value))\n".format(cmd)
  parseStmt allTemplates

autoGenAllTheTemplates()
# some commands have special cases for argument type
template EXPOSE*(port: uint16) = spec.instructions.add (EXPOSE,ArgValue(kind: uint16, ivalue: port))
template CMD*(items: openArray) = spec.instructions.add (CMD,ArgValue(kind: openArray, avalue: items))
template CMD*(arg: string) = spec.instructions.add (CMD,ArgValue(kind: openArray, avalue: arg.split))

template containerSpec*(cmds: untyped) : string =
  var spec {.inject.} : Spec
  cmds
  $spec



