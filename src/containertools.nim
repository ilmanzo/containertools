import macros except body
from std/strutils import join,format,split
from sequtils import mapIt

const DEFAULT_BASE_IMAGE ="opensuse/leap";

type 
  ContainerCommand = enum 
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
  CommandTuple=tuple[c: ContainerCommand, v : ArgValue]        

  Spec = object
    commands:seq[CommandTuple]

proc newSpec*(fromImage: string=DEFAULT_BASE_IMAGE): Spec =
  let base: CommandTuple = (FROM, ArgValue(kind:string, svalue: fromImage))
  Spec(commands: @[base])

proc parseSpec*(spec: string) : Spec =
  discard

proc `entrypoint=`*(c: var Spec, entrypoint: string) {.inline.} = c.entrypoint = entrypoint
proc baseImage*(s: Spec): string {.inline.} = return s.baseImage


# returns string representation of a container image
proc `$`*(self: Spec): string =
  for item in self.commands:
    let value=item.v
    let outvalue = case value.kind 
      of uint16: $value.ivalue
      of string: value.svalue
      of openArray: "[" & value.avalue.mapit('"' & $it & '\"').join(",") & "]"
    case item.c: 
      of COMMENT: 
        result.add "# $1\n".format(outvalue)
      else:
        result.add "$1 $2\n".format(item.c,outvalue)

# instead of writing a bunch of templates, like
# 
# template FROM*(baseImage: string) = s.add(FROM, baseImage)
# template COMMENT*(text: string) = s.add(COMMENT, text)
#
# we simply generate with a macro
macro autoGenAllTheTemplates() = 
  var allTemplates : string
  for item in ContainerCommand:
    if item==EXPOSE or item==CMD:
      continue
    let cmd = $item
    allTemplates.add "template $1*(value: string) = spec.commands.add ($1,ArgValue(kind: string, svalue: value))\n".format(cmd)
  parseStmt allTemplates

autoGenAllTheTemplates()
# some commands have special cases
template EXPOSE*(port: uint16) = spec.commands.add (EXPOSE,ArgValue(kind: uint16, ivalue: port))
template CMD*(items: openArray) = spec.commands.add (CMD,ArgValue(kind: openArray, avalue: items))
template CMD*(arg: string) = spec.commands.add (CMD,ArgValue(kind: openArray, avalue: arg.split))


template containerSpec*(cmds: untyped) : string =
  var spec {.inject.} : Spec
  cmds
  $spec


  

#proc parseSpec(spec: string) : Spec =


