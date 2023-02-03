# containertools
a work-in-progress library and a DSL to handle container spec files

starting develoment as a HackWeek project : https://hackweek.opensuse.org/22/projects/containerfile-slash-dockerfile-generator-library 

## basic usage examples:

```nim
import containertools
let image = container:
    FROM "opensuse/leap"
    CMD "echo Hello"

image.save "Containerfile"
image.build  
```

```nim
import containertools
let image = container:
    FROM "node:16"
    COPY ". ."
    RUN "npm install"
    EXPOSE 3000
    CMD @["node", "index.js"]
image.save "Containerfile"
image.build  
```

## a dynamic example:

```nim
for i in countup(0, 3):
    images[i] = container:
    FROM "opensuse/leap"
    if i mod 2 == 0:
        ENV &"buildno={i}.0"
        LABEL "Environment=PROD"
        RUN "zypper install nginx-stable"
    else:
        ENV &"buildno={i}.1"
        LABEL "Environment=DEV"
        RUN "zypper install nginx-testing"
#images.mapIt(push(it,MY_REGISTRY)) # pushes all to remote registry
```