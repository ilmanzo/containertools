# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

# import unittest2
# import containertools
# from strutils import dedent

# suite "Basic creation tests":
#   test "can create basic image":
#     var c = newSpec(fromImage = "opensuse/leap")
#     check: $c == "FROM opensuse/leap"

#   test "can create hello world container":
#     var c = newSpec(fromImage = "opensuse/leap")
#     let reference = dedent """
#     FROM opensuse/leap
#     ENTRYPOINT ["echo Hello,World!"]"""
#     c.entrypoint = "echo Hello,World!"
#     check: $c == reference

