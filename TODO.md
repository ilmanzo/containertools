## Todo

- [ ] tidy: remove duplicates, ex. merge consequent "RUN" lines
- [ ] add build feature that permits to run our image
  - remember to use -p for any EXPOSEd port
- [ ] add examples and documentation
- [ ] define syntax validation rules and error reporting
  - some examples:  https://github.com/marquesmps/dockerfile_validator/blob/develop/src/rule_files/default_rules.yaml
  - https://github.com/hadolint/hadolint
- [ ] check for leaked secrets in ENV
- [ ] publish package on nimble https://github.com/nim-lang/nimble#creating-packages

## In progress

- [ ] add more tests
- [ ] implement more instructions
  - dockerfile syntax reference: https://docs.docker.com/engine/reference/builder/

## Done ✓

- [x] Create and publish project
- [x] add github CI to run test suite on push
  - tests runs on linux, mac, windows
- [x] save feature and serialize to string
- [x] basic Containerfile, Dockerfile parsing
  - [x] improve parsing, COMMENT should become #






