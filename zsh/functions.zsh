# Grep ps output
function psgrep()
{
  ps aux | grep $@
}

# Grep the history.
function hgrep()
{
  history | grep $@
}

function ackvim()
{
    ack $@ --no-color | vim -
}

# Cat the contents of the file and put it in
# the pastboard.
#
#   `pbc foo.txt`
function pbc()
{
  cat $@ | pbcopy
}

function take() {
  mkdir -p $1
  cd $1
}

function zsh_stats()
{
  history | awk '{CMD[$2]++;count++;}END { for (a in CMD)print CMD[a] " " CMD[a]/count*100 "% " a;}' | grep -v "./" | column -c3 -s " " -t | sort -nr | nl |  head -n20
}

# Source all function files
for shell_file in $(ls $(dirname $0)/functions/*.zsh); do
  source $shell_file
done
