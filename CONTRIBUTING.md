# How to contribute

## Workflow

To submit a pull request:
- Create a new branch from the master branch
- Commit your code within this branch
- Open a PR to the master branch and wait for the Code Owners review
- No breaking changes: Once your code is in the master branch, open a pull request to the desired major branch and wait for the Code Owners review
- Has breaking changes: Once your code is in the master branch, create a new major version branch from the master branch
- Create a new release pointing to the HEAD commit on the major branch created/updated

## Versioning

The chosen versioning model is based on the [GitHub's versioning model for actions](https://docs.github.com/en/actions/creating-actions/about-actions#using-release-management-for-actions).

The `master` branch has the most up to date code, that should never be used by the end-user, since the code **may not be stable**. Each major release has it's own branch (`v0`, `v1`, etc). A new major release is created if there are breaking changes merged into the master branch. End-users should always reference a major branch when using this library. Minor releases are expected to be released on the major branches since no breaking changes are introduced.

## Style Guide

We have defined some rules to minimize the risk of naming conflicts between the names defined on our library with names defined elsewhere.

- Local variables must start with `_`
- Parameter variables must start with `__`
- Output variables (variables expected to be used by the calling script) must start with `___`

Complete example:

```
my_function() {
  __PARAM_1=$1
  __PARAM_2=${2:-"default-value"}

  _LOCAL_VAR=$__PARAM_1
  ___RETURN_VALUE="this variable is expected to be used by the calling script"
}
```
