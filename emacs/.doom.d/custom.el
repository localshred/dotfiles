(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(browse-at-remote-remote-type-regexps
   '((:host "^spiff[-_]emu" :type "github" :actual-host "github.com")
     (:host "^codeberg\\.org$" :type "codeberg")
     (:host "^github\\.com$" :type "github")
     (:host "^bitbucket\\.org$" :type "bitbucket")
     (:host "^gitlab\\.com$" :type "gitlab")
     (:host "^git\\.savannah\\.gnu\\.org$" :type "gnu")
     (:host "^gist\\.github\\.com$" :type "gist")
     (:host "^git\\.sr\\.ht$" :type "sourcehut")
     (:host "^.*\\.visualstudio\\.com$" :type "ado")
     (:host "^pagure\\.io$" :type "pagure")
     (:host "^.*\\.fedoraproject\\.org$" :type "pagure")
     (:host "^.*\\.googlesource\\.com$" :type "gitiles")
     (:host "^gitlab\\.gnome\\.org$" :type "gitlab")
     (:host "^gitlab\\." :type "gitlab")))
 '(custom-safe-themes
   '("aec7b55f2a13307a55517fdf08438863d694550565dee23181d2ebd973ebd6b8"
     "38f5f8ca86091357362a4ed9b25548b6f2591981172e76eb08cf6b75e8aba21d"
     "e4859d01ed34c7e21d9388186673c98e26fed30cb0dbbf9795b3ca7174ec9ec3"
     "ea3457622f413bd4ab667d3e4f26e4e01e9f8285467c968274bdbc0724ce2adb"
     "0325a6b5eea7e5febae709dab35ec8648908af12cf2d2b569bedc8da0a3a81c1"
     "5c7720c63b729140ed88cf35413f36c728ab7c70f8cd8422d9ee1cedeb618de5"
     "7964b513f8a2bb14803e717e0ac0123f100fb92160dcf4a467f530868ebaae3e"
     "10e5d4cc0f67ed5cafac0f4252093d2119ee8b8cb449e7053273453c1a1eb7cc"
     "c5878086e65614424a84ad5c758b07e9edcf4c513e08a1c5b1533f313d1b17f1"
     "88f7ee5594021c60a4a6a1c275614103de8c1435d6d08cc58882f920e0cec65e"
     "9f297216c88ca3f47e5f10f8bd884ab24ac5bc9d884f0f23589b0a46a608fe14"
     "4ade6b630ba8cbab10703b27fd05bb43aaf8a3e5ba8c2dc1ea4a2de5f8d45882" default))
 '(ignored-local-variable-values '((ispell-dictionary . "english")))
 '(magit-todos-insert-after '(bottom) nil nil "Changed by setter of obsolete option `magit-todos-insert-at'")
 '(mmm-mode-ext-classes-alist
   '((tsx-ts-mode nil ts-graphql-gql) (js-ts-mode nil ts-graphql-gql)
     (js-mode nil ts-graphql-gql) (typescript-ts-mode nil ts-graphql-gql)
     (typescript-mode nil ts-graphql-gql) (ruby-mode nil ruby-graphql)
     (ruby-mode nil ruby-sql)) nil (mmm-mode))
 '(package-selected-packages
   '(ox-reveal ox-latex-subfigure ob-mermaid osx-plist robe treemacs-all-the-icons
     all-the-icons))
 '(safe-local-variable-values
   '((eval cider-register-cljs-repl-type 'hostpro-ui
      "(do\12        (require\12        '[clojure.core.async :as async]\12        '[shadow.cljs.devtools.api :as shadow]\12        '[clojure.java.shell :as shell])\12       (shadow/watch :ui)\12       (shadow/watch :static)\12       (async/go\12        (async/<! (async/timeout 5000))\12        (shell/sh \"node\" \"./resources/bin/static.js\"))\12       (shadow/nrepl-select :ui))")
     (eval cider-register-cljs-repl-type 'hostpro-ui
      "(do\12        (require\12        '[clojure.core.async :as async]\12        '[shadow.cljs.devtools.api :as shadow]\12        '[clojure.java.shell :as shell])\12       (shadow/watch :ui)\12       (shadow/watch :static)\12       (shadow/nrepl-select :ui)\12       (async/go\12        (async/<! (async/timeout 5000))\12        (shell/sh \"node\" \"./resources/bin/static.js\")))")
     (cider-ns-refresh-before-fn . "crx.hostpro.repl/cider-ns-refresh-before-fn")
     (cider-ns-refresh-after-fn . "crx.hostpro.repl/cider-ns-refresh-after-fn")
     (eval cider-register-cljs-repl-type 'crxdev-ui
      "(do\12        (require\12        '[clojure.core.async :as async]\12        '[shadow.cljs.devtools.api :as shadow]\12        '[clojure.java.shell :as shell])\12       (shadow/watch :ui)\12       (shadow/watch :static)\12       (async/go\12        (async/<! (async/timeout 5000))\12        (shell/sh \"node\" \"./resources/bin/static.js\"))\12       :started)")
     (eval cider-register-cljs-repl-type 'hostpro-ui
      "(do\12        (require\12        '[clojure.core.async :as async]\12        '[shadow.cljs.devtools.api :as shadow]\12        '[clojure.java.shell :as shell])\12       (shadow/watch :ui)\12       (shadow/watch :static)\12       (async/go\12        (async/<! (async/timeout 5000))\12        (shell/sh \"node\" \"./resources/bin/static.js\"))\12       :started)")
     (cider-default-clj)
     (eval cider-register-cljs-repl-type 'hostpro-ui
      "(do\12        (require\12        '[clojure.core.async :as async]\12        '[shadow.cljs.devtools.api :as shadow]\12        '[clojure.java.shell :as shell])\12       (shadow/watch :browser)\12       (shadow/watch :static)\12       (async/go\12        (async/<! (async/timeout 5000))\12        (shell/sh \"node\" \"./resources/bin/static.js\"))\12       :started)")
     (cider-cljs-repl-types
      (edge "(do (require 'dev-extras) ((resolve 'dev-extras/cljs-repl)))"))
     (cider-repl-init-code "(dev)")
     (cider-ns-refresh-after-fn . "dev-extras/resume")
     (cider-ns-refresh-before-fn . "dev-extras/suspend")
     (cider-cljs-repl-type . browser)
     (eval cider-register-cljs-repl-type 'portal-app2
      "(do\12        (require\12        '[clojure.core.async :as async]\12        '[shadow.cljs.devtools.api :as shadow]\12        '[clojure.java.shell :as shell])\12       (shadow/watch :browser)\12       (shadow/watch :static)\12       (async/go\12        (async/<! (async/timeout 5000))\12        (shell/sh \"node\" \"./resources/bin/static.js\"))\12       :started)")
     (eval cider-register-cljs-repl-type 'portal-app
      "(do (require '[nuid.repl.shadow :as r]) (r/-main \"watch\"))"))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
