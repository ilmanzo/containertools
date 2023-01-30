# testsuite to exercise the container checker

# To run these tests, simply execute `nimble test`.

import unittest2
import containertools

suite "Basic self-check test":
  test "container without FROM should not be valid":
    let image = container:
      RUN "hello, world"
      ENV "foo=bar"
    check: not image.isValid


