import unittest2
import containertools

suite "consolidation feature test":
  test "can merge RUN entries":
    let bad_image = fromFile("tests/data/Containerfile.redundant")
    let ref_image = container:
      FROM "debian:latest"
      WORKDIR "/app"
      RUN "git clone https://some.project.git && cd project && make && mv ./binary /usr/bin/"
    check: bad_image.consolidate == ref_image



