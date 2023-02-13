;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!

(setq
 display-line-numbers-type t ;; For relative line numbers, set this to `relative'.
 doom-font (font-spec :family "Fira Code" :size 16)
 doom-theme 'doom-one
 org-directory "~/org/"
 user-full-name "BJ Neilsen"
 user-mail-address "bj.neilsen@gmail.com"
 )

(use-package aggressive-indent
  :ensure t
  :hook ((clojure-mode clojurescript-mode emacs-lisp-mode racket-mode cider-repl) . aggressive-indent-mode)
  :config
  ;; Indentation of function forms
  ;; https://github.com/clojure-emacs/clojure-mode#indentation-of-function-forms
  ;; (setq clojure-indent-style 'align-arguments)
  (setq clojure-indent-style 'always-indent)
  ;;
  ;; Vertically align s-expressions
  ;; https://github.com/clojure-emacs/clojure-mode#vertical-alignment
  (setq clojure-align-forms-automatically true)
  ;;
  )

;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c g k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c g d') to jump to their definition and see how
;; they are implemented.
(use-package! cider
  :config
  (map! (:localleader
          (:map (clojure-mode-map clojurescript-mode-map)
            (:prefix ("e" . "eval")
              (:prefix ("c" . "eval comment")
                "e" #'cider-pprint-eval-last-sexp-to-comment
                "f" #'cider-pprint-eval-defun-to-comment)
              "f" #'cider-eval-defun-at-point
              "F" #'cider-insert-defun-in-repl
              )))))

(use-package clojure-mode
  :config
  (require 'flycheck-clj-kondo))

(use-package evil-lisp-state
  :init
  (setq evil-lisp-state-global t)

  :config
  (map! :leader
        :desc "evil-lisp-state" "k" evil-lisp-state-map))

(use-package! neil
  :config
  (setq neil-prompt-for-version-p nil
        neil-inject-dep-to-project-p t))

(use-package prettier-js
  :config
  (setq prettier-js-command "/Users/bj/.nvm/versions/node/v12.15.0/bin/prettier-standard"))

(use-package rjsx-mode
  :mode "\\.js$")

(use-package lsp-mode
  :commands lsp
  :hook
  (sh-mode . lsp))

(use-package magit-delta
  :hook (magit-mode . magit-delta-mode))

;; prettier-emacs (js)
(defun enable-minor-mode (my-pair)
  "Enable minor mode if filename match the regexp.  MY-PAIR is a cons cell
(regexp . minor-mode)."
  (if (buffer-file-name)
      (if (string-match (car my-pair) buffer-file-name)
          (funcall (cdr my-pair)))))

(defun setup-js-modes ()
  (prettier-js-mode))

(add-hook 'js2-mode-hook 'setup-js-modes)
(add-hook 'js-jsx-mode-hook 'setup-js-modes)
(add-hook 'rjsx-mode-hook 'setup-js-modes)
(add-hook 'web-mode-hook 'setup-js-modes)
(add-hook 'web-mode-hook #'(lambda ()
                            (enable-minor-mode
                             '("\\.js\\'" . prettier-js-mode))))


(rassq-delete-all 'prettify-symbols-mode auto-mode-alist)

(setq js2-basic-offset 2)
(setq typescript-indent-level 2)

(set-formatter! 'pretter-standard-fmt  "prettier-standard --format --lint" :modes '(js2-mode))
;; (set-formatter! 'cljfmt "cljfmt 2> /dev/null" :modes '(clojure-mode clojurescript-mode))

(add-hook 'go-mode-hook 'lsp-deferred)

;; glasserc/ethan-wspace
(add-hook 'clojure-mode-hook 'ethan-wspace-mode)
(setq mode-require-final-newline nil)
