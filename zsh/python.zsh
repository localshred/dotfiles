function load_pyenv() {
  # https://github.com/pyenv/pyenv-installer
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
}
