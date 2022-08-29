(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(safe-local-variable-values
   '((eval cider-register-cljs-repl-type 'hostpro-ui "(do
        (require
        '[clojure.core.async :as async]
        '[shadow.cljs.devtools.api :as shadow]
        '[clojure.java.shell :as shell])
       (shadow/watch :ui)
       (shadow/watch :static)
       (async/go
        (async/<! (async/timeout 5000))
        (shell/sh \"node\" \"./resources/bin/static.js\"))
       :started)")
     (cider-default-clj)
     (eval cider-register-cljs-repl-type 'hostpro-ui "(do
        (require
        '[clojure.core.async :as async]
        '[shadow.cljs.devtools.api :as shadow]
        '[clojure.java.shell :as shell])
       (shadow/watch :browser)
       (shadow/watch :static)
       (async/go
        (async/<! (async/timeout 5000))
        (shell/sh \"node\" \"./resources/bin/static.js\"))
       :started)")
     (cider-cljs-repl-types
      (edge "(do (require 'dev-extras) ((resolve 'dev-extras/cljs-repl)))"))
     (cider-repl-init-code "(dev)")
     (cider-ns-refresh-after-fn . "dev-extras/resume")
     (cider-ns-refresh-before-fn . "dev-extras/suspend")
     (cider-cljs-repl-type . browser)
     (eval cider-register-cljs-repl-type 'portal-app2 "(do
        (require
        '[clojure.core.async :as async]
        '[shadow.cljs.devtools.api :as shadow]
        '[clojure.java.shell :as shell])
       (shadow/watch :browser)
       (shadow/watch :static)
       (async/go
        (async/<! (async/timeout 5000))
        (shell/sh \"node\" \"./resources/bin/static.js\"))
       :started)")
     (eval cider-register-cljs-repl-type 'portal-app "(do (require '[nuid.repl.shadow :as r]) (r/-main \"watch\"))"))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
