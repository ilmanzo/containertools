import containertools
let image = container:
    FROM "opensuse/leap"
    CMD "echo Hello"

image.save "Containerfile"
image.build  