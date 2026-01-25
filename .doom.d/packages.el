;; -*- no-byte-compile: t; -*-
;;; $DOOMDIR/packages.el

;; To install a package with Doom you must declare them here, run 'doom sync' on
;; the command line, then restart Emacs for the changes to take effect.
;; Alternatively, use M-x doom/reload.

;; Doom's packages are pinned to a specific commit and updated from release to
;; release. The `unpin!' macro allows you to unpin single packages...
                                        ;(unpin! pinned-package)
;; ...or multiple packages
                                        ;(unpin! pinned-package another-pinned-package)
;; ...Or *all* packages (NOT RECOMMENDED; will likely break things)
                                        ;(unpin! t)

;; To install SOME-PACKAGE from MELPA, ELPA or emacsmirror:
                                        ;(package! some-package)

;; To install a package directly from a particular repo, you'll need to specify
;; a `:recipe'. You'll find documentation on what `:recipe' accepts here:
;; https://github.com/raxod502/straight.el#the-recipe-format
                                        ;(package! another-package
                                        ;  :recipe (:host github :repo "username/repo"))

;; If the package you are trying to install does not contain a PACKAGENAME.el
;; file, or is located in a subdirectory of the repo, you'll need to specify
;; `:files' in the `:recipe':
                                        ;(package! this-package
                                        ;  :recipe (:host github :repo "username/repo"
                                        ;           :files ("some-file.el" "src/lisp/*.el")))

;; If you'd like to disable a package included with Doom, for whatever reason,
;; you can do so here with the `:disable' property:
                                        ;(package! builtin-package :disable t)

;; You can override the recipe of a built in package without having to specify
;; all the properties for `:recipe'. These will inherit the rest of its recipe
;; from Doom or MELPA/ELPA/Emacsmirror:
                                        ;(package! builtin-package :recipe (:nonrecursive t))
                                        ;(package! builtin-package-2 :recipe (:repo "myfork/package"))

;; Specify a `:branch' to install a package from a particular branch or tag.
;; This is required for some packages whose default branch isn't 'master' (which
;; our package manager can't deal with; see raxod502/straight.el#279)
                                        ;(package! builtin-package :recipe (:branch "develop"))

(package! aggressive-indent)
(package! asdf :recipe (:host github
                        :repo "tabfugnic/asdf.el"
                        :files ("asdf.el")))
(package! claude-code-ide :recipe (:host github
                                   :repo "manzaltu/claude-code-ide.el"))
(package! docker)
(package! docker-compose-mode)
(package! dockerfile-mode)
(package! ethan-wspace :recipe (:host github
                                :repo "glasserc/ethan-wspace"))
(package! evil-lion)
(package! evil-lisp-state)
(package! evil-surround)
(package! flycheck-clj-kondo)
;; See https://github.com/hlissner/doom-emacs/issues/5667#issuecomment-948229579
(package! gitconfig-mode :recipe (:host github
                                  :repo "magit/git-modes"
                                  :files ("gitconfig-mode.el")))
(package! gitignore-mode :recipe (:host github
                                  :repo "magit/git-modes"
                                  :files ("gitignore-mode.el")))
(package! graphql-mode)
;; heex-ts-mode and elixir-ts-mode are handled by Doom's elixir module
(package! jest-test-mode)
(package! magit-delta)
(package! mmm-mode :recipe (:host github :repo "dgutov/mmm-mode"))
(package! neil :recipe (:host github
                        :repo "babashka/neil"
                        :files ("*.el")))
(package! ob-mermaid)
(package! org-roam)
;; (package! ox-reveal)
(package! pbcopy)
(package! pinentry) ;; be sure to `M-x pinentry-start`
(package! prettier-js)
(package! rubocop)
(package! sqlformat)

;;;
;;; sf code-genie + ellama
;;;
(package! llm)
(package! gptel)
(package! ellama)
;;;
;;; end sf code-genie + ellama
;;;
