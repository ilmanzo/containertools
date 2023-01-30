# containertools
a work-in-progress library and a DSL to handle container spec files

starting develoment as a HackWeek project : https://hackweek.opensuse.org/22/projects/containerfile-slash-dockerfile-generator-library 

## basic usage examples:

```nim
import containertools
let image = containerSpec:
    FROM "opensuse/leap"
    CMD "echo Hello"

image.save "Containerfile"
image.build  
```

```nim
import containertools
let image = containerSpec:
    FROM "node:16"
    COPY ". ."
    RUN "npm install"
    EXPOSE 3000
    CMD @["node", "index.js"]
image.save "Containerfile"
image.build  
```
