;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-


;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "BJ Neilsen"
      user-mail-address "bj.neilsen@gmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
(setq doom-font (font-spec :family "Fira Code" :size 16))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

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

(use-package evil-lisp-state
  :init
  (setq evil-lisp-state-global t)

  :config
  (map! :leader
        :desc "evil-lisp-state" "k" evil-lisp-state-map))

(use-package clojure-mode
  :config
  (require 'flycheck-clj-kondo))

(use-package prettier-js
  :config
  (setq prettier-js-command "/Users/bj/.nvm/versions/node/v12.15.0/bin/prettier-standard"))

;; prettier-emacs (js)
(defun enable-minor-mode (my-pair)
  "Enable minor mode if filename match the regexp.  MY-PAIR is a cons cell (regexp . minor-mode)."
  (if (buffer-file-name)
      (if (string-match (car my-pair) buffer-file-name)
          (funcall (cdr my-pair)))))

(use-package rjsx-mode
  :mode "\\.js$")

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
