import macros except body
from std/strutils import join,format

const DEFAULT_BASE_IMAGE ="opensuse/leap";

type ContainerCommand=enum
  FROM, RUN, COPY, ENV, WORKDIR, EXPOSE, CMD , COMMENT , ADD, USER, VOLUME, LABEL, ENTRYPOINT, ARG, ONBUILD, STOPSIGNAL, HEALTHCHECK , SHELL 

type CommandTuple=tuple[c: ContainerCommand, v:string]

type Spec = seq[CommandTuple]

proc newSpec*(fromImage: string=DEFAULT_BASE_IMAGE): Spec =
  Spec(@[(FROM , fromImage)])

proc parseSpec*(spec: string) : Spec =
  discard

proc `entrypoint=`*(c: var Spec, entrypoint: string) {.inline.} = c.entrypoint = entrypoint
proc baseImage*(s: Spec): string {.inline.} = return s.baseImage

# returns string representation of a container image
proc `$`*(self: Spec): string =
  for item in self:
    case item.c: 
      of COMMENT: 
        result.add "# $1\n".format(item.v)
      of FROM, WORKDIR:
        result.add "$1 $2\n".format(item.c,item.v)
      of CMD,ENTRYPOINT:
        result.add "$1 [\"$2\"]\n".format(item.c,item.v)
      else:
        result.add "$1 \"$2\"\n".format(item.c,item.v)

# instead of writing a bunch of templates, like
# 
# template FROM*(baseImage: string) = s.add(FROM, baseImage)
# template COMMENT*(text: string) = s.add(COMMENT, text)
#
# we simply generate with a macro
macro autoGenAllTheTemplates() = 
  var allTemplates : string
  for item in ContainerCommand:
    let cmd = $item
    allTemplates.add "template $1*(value: string) = spec.add(($1,value))\n".format(cmd)
  parseStmt allTemplates

autoGenAllTheTemplates()

template containerSpec*(cmds: untyped) : string =
  var spec {.inject.} : Spec
  cmds
  $spec


  

#proc parseSpec(spec: string) : Spec =


