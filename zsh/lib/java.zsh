function clojure_prompt() {
  if [[ -s deps.edn || -s project.clj ]]; then
    version=""
    if command -v clj > /dev/null; then
      version=$(clj --version | awk '{ print $4 }')
    else
      version=$(asdf current clojure | awk '{print $2}')
    fi
    if [ -n "$version" ]; then
      echo "clj:$version"
    fi
  fi
}

function java_prompt() {
  if [[ -s deps.edn || -s pom.xml ]]; then
    version=$(java --version | grep openjdk | awk '{print $2}')
    if [ -n "$version" ]; then
      echo "java:$version"
    else
      echo "java:system"
    fi
  fi
}
