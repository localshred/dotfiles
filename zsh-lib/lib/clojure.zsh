function cljrepl () {
  clj -A:repl
}

function classpath() {
  clj -Spath | sed 's/:/\'$'\n''/g'
}

function cljfmt-hack() {
  clj_file=$(mktemp)
  tee $clj_file > /dev/null
  clojure -Sdeps '{:deps {cljfmt {:mvn/version "0.8.0"}}}' -m cljfmt.main fix $clj_file > /dev/null
  cat $clj_file
}
