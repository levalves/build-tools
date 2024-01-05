# Shell Overrides

This library replaces some Shell functions, such as `popd` and `pushd`, to improve logs readability.

Just import the functions on your script and your're ready to go.

```
#!/usr/bin/env bash
set +x

if [ ! -d "$PWD/build-tools" ]; then
  git clone --single-branch --branch v0 git@github.com:levalves/build-tools.git "$PWD/build-tools"
fi

__BUILD_TOOLS_PATH="./build-tools"

source "$__BUILD_TOOLS_PATH/scripts/shell_overrides.sh"
```
