function nrepl () {
  clj -Sdeps '{:deps {cider/cider-nrepl {:mvn/version "0.22.4"} }}' -m nrepl.cmdline --middleware "[cider.nrepl/cider-middleware]"
}

function classpath() {
  clj -Spath
}
