## Todo

- [ ] implement Containerfile, Dockerfile parsing
  - [ ] improve parsing, COMMENT should become #
- [ ] tidy: remove duplicates, ex. merge consequent "RUN" lines
- [ ] add save feature
- [ ] add build feature that permits to run our image
  - remember to use -p for any EXPOSEd port
- [ ] add example and documentation
- [ ] define syntax validation rules and error reporting
  - some examples:  https://github.com/marquesmps/dockerfile_validator/blob/develop/src/rule_files/default_rules.yaml
  - https://github.com/hadolint/hadolint
- [ ] check for leaked secrets in ENV


## In progress

- [ ] add more tests
- [ ] implement more instructions
  - dockerfile syntax reference: https://docs.docker.com/engine/reference/builder/

## Done ✓

- [x] Create and publish project
- [x] add github CI to run test suite on push
  - tests runs on linux, mac, windows





