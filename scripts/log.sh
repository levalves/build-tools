set -eo pipefail

# Mac OS users should install gdate: brew install coreutils
if [ -e /usr/local/bin/gdate ]
then
  function date() {
    gdate "$@"
  }
fi

LOG_FILE=${LOG_FILE:-"$PWD/build.log"}

f_log() {
  echo "$(date -Iseconds) - $@" | tee -a "$LOG_FILE"
}
