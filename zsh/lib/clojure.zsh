function cljrepl () {
  clj -A:repl
}

function classpath() {
  clj -Spath | sed 's/:/\'$'\n''/g'
}
