# testsuite to exercise the container checker

# To run these tests, simply execute `nimble test`.

import unittest2
import containertools


suite "Basic self-check test":
  test "container without FROM should not be valid":
    let image = container:
      CMD "hello, world"
      ENV "foo=bar"
    check: not image.isValid

  test "container without CMD nor ENTRYPOINT should not be valid":
    let image = container:
      FROM "opensuse/leap"
      LABEL "foo=bar"
      ENV "foo=bar"
    check: not image.isValid

  test "container with FROM as not-first statement should not be valid":
    let image = container:
      RUN "/bin/bash"
      FROM "ubuntu"
      CMD @["/usr/bin/wc", "--help"]
    check: not image.isValid






