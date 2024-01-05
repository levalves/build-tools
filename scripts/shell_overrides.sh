# overrides pushd and popd so they don't output the stack
pushd () {
  command pushd "$@" > /dev/null
}

popd () {
  command popd "$@" > /dev/null
}
