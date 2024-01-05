set -eo pipefail

source "$__BUILD_TOOLS_PATH/scripts/log.sh"

set_default_values() {
  if [ ! -f init_template.csv ]; then
    f_log "Missing init_template.csv configuration file."
    exit 1
  fi  
  _INIT_CFG=()
  while IFS= read -r line || [[ "$line" ]]; do
  _INIT_CFG+=("$line")
  done < init_template.csv
  i=0
  while [ "$i" -lt "${#_INIT_CFG[@]}" ]; do
  _PATTERN=$(echo ${_INIT_CFG[$i]}|cut -d \; -f1)
  _KEY=$(echo ${_INIT_CFG[$i]}|cut -d \; -f2 | sed -r 's/\//\\\//g') # Add escape character when string has slashes
  _FILES=$(echo ${_INIT_CFG[$i]}|cut -d \; -f3)
  sed -i "s/$_PATTERN/$_KEY/g" $_FILES
  i=$(expr $i + 1)
  done
  f_log "INFO: All done!"
  f_log "      Config file backed up as .init_template.csv."
  f_log "      When it's all done, you can delete it safely."
  mv init_template.csv .init_template.csv
}
