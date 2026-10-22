;;; teh-config-completion.el --- My config - completion
;;; Commentary:
;;; My config files

;;; Code:

;;; Eglot
(use-package eglot
  :config (setq eglot-autoshutdown t)
  (add-to-list 'eglot-server-programs '(nix-mode . ("nil"))))
(use-package eldoc-box
  :config (add-hook 'eglot-managed-mode-hook #'eldoc-box-hover-at-point-mode t))

;;; Corfu
(use-package corfu
  :diminish
  :after eglot
  :hook (eglot-managed-mode . corfu-mode)
  :config
  (global-corfu-mode 1)
  ;;(corfu-popupinfo-mode)
  (corfu-popupinfo-mode 1)
  (setq corfu-auto t
	corfu-quit-no-match 'separator
	corfu-auto-delay 0)
  (set-face-bold 'corfu-current t)
  (set-face-background 'corfu-current "#4E5579")
  (set-face-foreground 'corfu-current nil)
  (set-face-bold 'orderless-match-face-0 t)
  (set-face-background 'orderless-match-face-0 nil)
  (set-face-foreground 'orderless-match-face-0 "#C792EA")
  (set-face-foreground 'completions-common-part "#C792EA")
  (set-face-bold 'vertico-current t))

(use-package kind-icon :after corfu
  :custom
  (kind-icon-default-face 'corfu-default)
  :config
  (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter)
  (setq kind-icon-blend-background nil))

;;; Languages
(use-package nix-mode
  :mode "\\.nix\\'"
  :config
  (add-hook 'nix-mode-hook (lambda () (setq tab-width 4))))
(use-package haskell-mode)
(use-package typst-ts-mode)
(use-package glsl-mode)
(use-package rust-mode)
;; (treesit-install-language-grammar 'typescript)
;; (treesit-install-language-grammar 'tsx)
(use-package typescript-ts-mode
  :mode (("\\.ts\\'" . typescript-ts-mode)
         ("\\.tsx\\'" . tsx-ts-mode)))

;; (use-package jupyter)
(use-package ein)
;; (use-package code-cells)


;; Hooks to start eglot
(use-package typescript-mode)
(add-hook 'c-mode-hook 'eglot-ensure)
(add-hook 'c++-mode-hook 'eglot-ensure)
(add-hook 'js-mode-hook 'eglot-ensure)
(add-hook 'ts-mode-hook 'eglot-ensure)
(add-hook 'nix-mode-hook 'eglot-ensure)
(add-hook 'java-mode-hook 'eglot-ensure)
(add-hook 'haskell-mode-hook 'eglot-ensure)
(add-hook 'rust-mode-hook 'eglot-ensure)
(add-hook 'emacs-lisp-mode-hook 'corfu-mode)
;;;(add-hook 'emacs-lisp-mode-hook 'flycheck-mode)

;;; Treesitter
(use-package tree-sitter
  :config
  (global-tree-sitter-mode)
  (add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode))
(use-package tree-sitter-langs :after tree-sitter)

;;; Imenu
(add-hook 'emacs-lisp-mode-hook (lambda ()
								  (add-to-list 'imenu-generic-expression '("Title" "^;;; \\(.*\\)$" 1))))

;;; Ghostel (terminal backend for Claude Code)
(use-package ghostel)

;;; Claude code
(use-package claude-code-ide
  :vc (:url "https://github.com/manzaltu/claude-code-ide.el" :rev :newest)
  :bind ("C-c C-'" . claude-code-ide-menu)
  :config
  (setq claude-code-ide-terminal-backend 'ghostel)
  (claude-code-ide-emacs-tools-setup))

(provide 'teh-config-completion)

;;; teh-config-completion.el ends here
