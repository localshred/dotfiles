function hosts() {
  filter=$@
  if [[ -z $filter ]]; then
    command="oz list | grep stu-cm | awk '{print \$2}' | sort"
  else
    command="oz list | grep stu-cm | awk '{print \$2}' | sort | grep ${filter}"
  fi
  ssh mgr -q -tt -C $command
}

function kssh() {
  ssh -t mgr ssh stu-cm-$1
}
