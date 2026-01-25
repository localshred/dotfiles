;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

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

;;
;; Private Config Vars
;;
(setq
 debug-on-error nil
 display-line-numbers-type t ;; For relative line numbers, set this to `relative'.
 doom-font (font-spec :family "Fira Code" :size 16)
 doom-theme 'doom-one
 evil-shift-width 2
 indent-tabs-mode nil
 ispell-personal-dictionary "~/.doom.d/ispell_personal.dict"
 projectile-project-search-path '("~/code/src")
 tab-width 2
 user-full-name "BJ Neilsen"
 user-mail-address "bj.neilsen@gmail.com"
 )

;;
;; Org Mode configurations
;;
;; See https://github.com/james-stoup/emacs-org-mode-tutorial
;;
(setq org-agenda-files '("~/code/org/"
                         "~/code/org/journal"
                         "~/code/org/journal/2024"
                         "~/code/org/journal/2025"
                         "~/code/org/meetings"
                         "~/code/org/projects"
                         "~/code/org/repos"
                         ))
(setq org-directory "~/code/org/")
(setq org-log-done 'time)
(setq org-return-follows-link  t)
(setq org-tag-alist '(
                      ;; Ticket types
                      (:startgroup)
                      ("bug"                . ?t)
                      ("feature"            . ?t)
                      ("chore"              . ?t)
                      ("spike"              . ?t)
                      ("investigation"      . ?t)
                      (:endgroup)
                      ;; Issue priorities
                      (:startgroup)
                      ("p0"                 . ?p)
                      ("p1"                 . ?p)
                      ("p2"                 . ?p)
                      ("p3"                 . ?p)
                      ("p4"                 . ?p)
                      (:endgroup)
                      ;; Ticket flags
                      ("@needs_ticket"      . ?n)
                      ("@emergency"         . ?e)
                      ("@research"          . ?h)
                      ;; Meeting types
                      (:startgrouptag)
                      ("grooming"           . ?M)
                      ("retro"              . ?M)
                      ("planning"           . ?M)
                      ("standup"            . ?M)
                      ("townhall"           . ?M)
                      (:endgrouptag)
                      ;; Code tags
                      ("qa"                 . ?q)
                      ("db"                 . ?d)
                      ("cache"              . ?u)
                      ("backend"            . ?c)
                      ("frontend"           . ?i)
                      ("mobile"             . ?o)
                      ("ruby"               . ?y)
                      ("elixir"             . ?x)
                      ("js"                 . ?j)
                      ("ts"                 . ?t)
                      ("react"              . ?w)
                      ("rails"              . ?a)
                      ("phoenix"            . ?l)
                      ("ash"                . ?z)
                      ("sdk"                . ?s)
                      ;; Misc tags
                      ("accomplishment")
                      ("blocker")
                      ("pairing")
                      ))

(setq org-tag-faces '(
                      ;; ("planning"  . (:foreground "mediumPurple1" :weight bold))
                      ;; ("backend"   . (:foreground "royalblue1"    :weight bold))
                      ;; ("frontend"  . (:foreground "forest green"  :weight bold))
                      ;; ("meeting"   . (:foreground "yellow1"       :weight bold))
                      ("@needs_ticket" . (:foreground "yellow"        :weight bold))
                      ("blocker"       . (:foreground "yellow"        :weight bold))
                      ("p0"            . (:foreground "red1"          :weight bold))
                      ("p1"            . (:foreground "red1"          :weight bold))
                      ("p2"            . (:weight bold))
                      ("@emergency"    . (:foreground "red1"          :weight bold))
                      ))

(setq org-tags-match-list-sublevels t)

(setq org-todo-keywords '((sequence
                           "TODO(t)"
                           "DOING(s@/!)"
                           "VERIFYING(v!)"
                           "BLOCKED(b@)"
                           "|"
                           "DONE(d!)"
                           "NEVER(n@/!)"
                           )))

(setq org-todo-keywords-for-agenda '("TODO" "DOING" "VERIFYING" "BLOCKED" "DONE" "NEVER"))

(setq org-todo-keyword-faces '(
                               ("TODO" . (:foreground "GoldenRod" :weight bold))
                               ("DOING" . (:foreground "Cyan" :weight bold))
                               ("VERIFYING" . (:foreground "DarkOrange" :weight bold))
                               ("BLOCKED" . (:foreground "Red" :weight bold))
                               ("DONE" . (:foreground "Grey" :weight bold))
                               ("NEVER" . (:foreground "Grey"))
                               ))

(setq my-org-capture-templates
      '(
        ("i" "Inbox"
         entry (file "inbox.org")
         "* TODO %?\n:Created: %T\n%i\n%a\n"
         :empty-lines 0
         :unnarrowed)
        ("j" "Journal Entry"
         entry (file+olp+datetree "journal.org")
         "* TODO %?"
         :empty-lines 0
         :unnarrowed)
        ("n" "Note"
         entry (file+headline "notes.org" "Random Notes")
         "** %?"
         :empty-lines 0)
        ))

(setq
 org-capture-templates                    my-org-capture-templates
 counsel-projectile-org-capture-templates my-org-capture-templates
 )

;;
;; Package Configurations (Alphabetical)
;;

(use-package aggressive-indent
  :hook ((clojure-mode clojurescript-mode emacs-lisp-mode racket-mode cider-repl) . aggressive-indent-mode)
  )

;; Configure Apheleia to use Rubocop for Ruby formatting
(after! apheleia
  ;; Define rubocop formatter
  (add-to-list 'apheleia-formatters
               '(rubocop . ("bundle" "exec" "rubocop" "--autocorrect" "--stdin" file "--format" "quiet" "--stderr")))

  ;; Use rubocop for ruby-mode files
  (add-to-list 'apheleia-mode-alist '(ruby-mode . rubocop)))

(use-package asdf
  :config
  (asdf-enable)
  (setq asdf-binary "/opt/homebrew/bin/asdf"))

(use-package browse-at-remote
  :config
  (add-to-list 'browse-at-remote-remote-type-regexps
               '(:host "^localshred" :type "github" :actual-host "github.com")))

(use-package cider
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

(use-package claude-code-ide
  :bind ("C-c C-'" . claude-code-ide-menu) ; Set your favorite keybinding
  :config
  (claude-code-ide-emacs-tools-setup)) ; Optionally enable Emacs MCP tools

(use-package clojure-mode
  :config
  (require 'flycheck-clj-kondo)
  (setq
   clojure-indent-style 'always-indent
   ;; FIXME throwing an error b/c it's not loaded or something...
   ;; clojure-align-forms-automatically true
   ;;
   ))

(use-package evil-lisp-state
  :init
  (setq evil-lisp-state-global t)

  :config
  (map! :leader
        :desc "evil-lisp-state" "k" evil-lisp-state-map))

(after! files
  (setq mode-require-final-newline nil)
  (rassq-delete-all 'prettify-symbols-mode auto-mode-alist))

;; (after! go-mode
;;   (add-hook 'go-mode-hook 'lsp-deferred))

(use-package jest-test-mode
  :commands jest-test-mode
  :hook (typescript-ts-mode js-ts-mode tsx-ts-mode))

(use-package lsp-mode
  :commands lsp
  :config
  (lsp-toggle-symbol-highlight)

  ;; Reduce LSP responsiveness to prevent UI issues
  (setq lsp-idle-delay 1.0)                    ; Delay before sending changes (default 0.2)
  (setq lsp-completion-show-detail nil)        ; Disable detailed completion info
  (setq lsp-completion-show-kind nil)          ; Disable completion kind icons
  (setq lsp-headerline-breadcrumb-enable nil)  ; Disable breadcrumb header
  (setq lsp-signature-auto-activate nil)       ; Disable automatic signature help
  (setq lsp-signature-render-documentation nil) ; Disable signature documentation
  (setq lsp-eldoc-enable-hover nil)            ; Disable eldoc hover
  (setq lsp-modeline-code-actions-enable nil)  ; Disable code actions in modeline
  (setq lsp-modeline-diagnostics-enable nil)   ; Disable diagnostics in modeline

  ;; Additional performance settings
  (setq lsp-enable-symbol-highlighting nil)    ; Disable symbol highlighting
  (setq lsp-enable-on-type-formatting nil)     ; Disable on-type formatting
  (setq lsp-enable-indentation nil)            ; Disable LSP indentation
  (setq lsp-enable-folding nil)                ; Disable code folding
  (setq lsp-semantic-tokens-enable nil)        ; Disable semantic tokens
  (setq lsp-enable-text-document-color nil)    ; Disable color information

  ;; File watcher configuration
  (setq lsp-file-watch-threshold 2000)         ; Watch up to 2000 files
  (setq lsp-file-watch-ignored-directories      ; Ignore these directories
        '("[/\\\\]\\.git$"
          "[/\\\\]\\.svn$"
          "[/\\\\]\\.hg$"
          "[/\\\\]\\.bzr$"
          "[/\\\\]_darcs$"
          "[/\\\\]\\.tox$"
          "[/\\\\]build$"
          "[/\\\\]_build$"                      ; Elixir build directory
          "[/\\\\]dist$"
          "[/\\\\]target$"
          "[/\\\\]node_modules$"
          "[/\\\\]coverage$"
          "[/\\\\]__pycache__$"
          "[/\\\\]\\.pytest_cache$"
          "[/\\\\]\\.mypy_cache$"
          "[/\\\\]\\.vscode$"
          "[/\\\\]\\.idea$"
          "[/\\\\]vendor$"
          "[/\\\\]tmp$"
          "[/\\\\]temp$"
          "[/\\\\]log$"
          "[/\\\\]logs$"))

  :hook
  (sh-mode . lsp))

(use-package magit-delta
  :hook (magit-mode . magit-delta-mode)
  :config
  (add-to-list 'magit-delta-delta-args "magit")
  (add-to-list 'magit-delta-delta-args "--features"))

(use-package mmm-mode
  :config
  ;; Enable mmm-mode for ruby files
  (setq mmm-global-mode 'maybe)
  (setq mmm-submode-decoration-level 2)

  ;; Define SQL HEREDOC submode for ruby
  (mmm-add-classes
   '((ruby-sql
      :submode sql-mode
      :front "<<[-~]?['\"]?SQL['\"]?"
      :back "^[\s]*SQL"
      :face mmm-declaration-submode-face)))

  ;; Define GraphQL HEREDOC submode for ruby
  (mmm-add-classes
   '((ruby-graphql
      :submode graphql-mode
      :front "<<[-~]?['\"]?GQL['\"]?"
      :back "^[\s]*GQL"
      :face mmm-declaration-submode-face)))

  ;; Apply to ruby-mode files
  (mmm-add-mode-ext-class 'ruby-mode nil 'ruby-sql)
  (mmm-add-mode-ext-class 'ruby-mode nil 'ruby-graphql)

  ;; Auto-enable mmm-mode in files
  (add-hook 'ruby-mode-hook 'mmm-mode))

(use-package neil
  :config
  (setq neil-prompt-for-version-p nil
        neil-inject-dep-to-project-p t))

;; npm install -g @mermaid-js/mermaid-cli
(use-package ob-mermaid
  :config
  ;; (setq ob-mermaid-cli-path "/usr/local/bin/mmdc")
  )

(use-package pbcopy
  :config
  (turn-on-pbcopy))

(use-package robe
  :after 'ruby-mode
  :config
  (global-hi-lock-mode 1)
  (set-lookup-handlers! 'ruby-mode
    :documentation #'robe-doc
    :definition #'robe-jump))

(after! rspec-mode
  (setq rspec-use-rvm nil)
  (setq rspec-use-bundler-when-possible t)

  ;; Configure rspec buffers to open in a vertical split
  (add-to-list 'display-buffer-alist
               '("\\*rspec-compilation\\*"
                 (display-buffer-reuse-window
                  display-buffer-same-window)
                 (inhibit-same-window . t)))

  ;; Function to toggle the rspec test window
  (defun my/toggle-rspec-window ()
    "Show or hide the rspec compilation window."
    (interactive)
    (if-let ((window (get-buffer-window "*rspec-compilation*")))
        ;; Window is visible, hide it
        (delete-window window)
      ;; Window is not visible, show it if buffer exists
      (when-let ((buffer (get-buffer "*rspec-compilation*")))
        (display-buffer buffer))))

  ;; Bind to SPC m t d (major mode > tests > dismiss/show)
  (map! :localleader
        :map ruby-mode-map
        (:prefix ("t" . "test")
         :desc "toggle spec results"
         "d" #'my/toggle-rspec-window)))

(after! settings
  (set-formatter! 'cljfmt "cljfmt 2> /dev/null" :modes '(clojure-mode clojurescript-mode))
  (set-formatter! 'erlfmt "erlfmt -" :modes '(erlang-mode))
  (set-popup-rule! "*doom:scratch*" :side 'right :size 0.5 :select t))

(after! sh-script
  (setq sh-basic-offset 2
        sh-indentation 2))

(use-package sqlformat
  :config
  (setq sqlformat-command 'pgformatter)
  (setq sqlformat-args '("-s2"))
  )

;;
;; Tiltfile Configuration
;;
(define-derived-mode tiltfile-mode
  python-mode "Tiltfile"
  "Major mode for Tilt Dev."
  (setq-local case-fold-search nil))

(add-to-list 'auto-mode-alist '("Tiltfile$" . tiltfile-mode))

(after! lsp-mode
  (add-to-list 'lsp-language-id-configuration
               '(tiltfile-mode . "tiltfile"))

  (lsp-register-client
   (make-lsp-client :new-connection (lsp-stdio-connection '("tilt" "lsp" "start"))
                    :activation-fn (lsp-activate-on "tiltfile")
                    :server-id 'tilt-lsp)))

(use-package web-mode
  :config
  (setq
   web-mode-code-indent-offset 2
   web-mode-css-indent-offset 2
   web-mode-enable-comment-interpolation t
   web-mode-enable-css-colorization t
   web-mode-enable-current-column-highlight t
   web-mode-enable-current-element-highlight t
   web-mode-markup-comment-indent-offset 3
   web-mode-markup-indent-offset 2
   web-mode-sql-indent-offset 2
   ))

;;
;; Mode Hooks & Custom Functions
;;

;; glasserc/ethan-wspace
(add-hook 'clojure-mode-hook 'ethan-wspace-mode)

;; Install tree-sitter grammars
(when (treesit-available-p)
  (setq treesit-language-source-alist
        '((typescript "https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src")
          (tsx "https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src")
          (javascript "https://github.com/tree-sitter/tree-sitter-javascript" "master" "src")))

  ;; Install grammars if they don't exist
  (dolist (lang '(typescript tsx javascript))
    (unless (treesit-language-available-p lang)
      (treesit-install-language-grammar lang)))

  ;; Helper function to manually install grammars
  (defun install-js-ts-grammars ()
    "Install JavaScript, TypeScript, and TSX tree-sitter grammars."
    (interactive)
    (dolist (lang '(typescript tsx javascript))
      (message "Installing %s grammar..." lang)
      (treesit-install-language-grammar lang)
      (message "%s grammar installed!" lang)))

  )

;; Convert log output with escape codes in it to apply the ansi codes correctly
;; (e.g. color the output)
;; See https://emacs.stackexchange.com/a/74922/26911
(defun u/ansi-color-apply-on-region (begin end)
  (interactive "r")
  (ansi-color-apply-on-region begin end t))

;;
;; Load work config if $dotfiles_work is set
;;
(let ((work-dotfiles (getenv "dotfiles_work")))
  (when work-dotfiles
    (let ((work-config (expand-file-name "doom/work-config.el" work-dotfiles)))
      (when (file-exists-p work-config)
        (load work-config)))))