;;; teh-config-looks.el --- My config looks
;;; Commentary:
;;; My config files

;;; Code:

;;; Colorscheme
(use-package doom-themes
  :config
  (setq doom-themes-enable-bold t
		doom-themes-ename-italic t)
  (load-theme 'doom-palenight t)
  (doom-themes-visual-bell-config)
  (doom-themes-org-config))

;;; Diminishing modes
(use-package diminish)

;;; Fonts
;;; Normal
(set-face-attribute 'isearch nil
					:underline t)
(set-face-attribute 'default nil
					:font "Cousine Nerd Font 10"
					:weight 'medium)
(set-face-attribute 'variable-pitch nil
					:font "Cousine Nerd Font 10"
					:weight 'medium)
(set-face-attribute 'fixed-pitch nil
					:font "Cousine Nerd Font 10"
					:weight 'medium)
(add-to-list 'default-frame-alist '(font . "Cousine Nerd Font 10"))
(set-frame-font "Cousine Nerd Font 10")
;;; Emoji
(set-fontset-font t 'emoji
				  '("Noto Color Emoji" . "iso10646-1") nil 'prepend)

;;; Transparency
(set-frame-parameter (selected-frame) 'alpha '(80 . 80))
(add-to-list 'default-frame-alist '(alpha . (80 . 80)))
;;(set-frame-parameter nil 'alpha-background 80)
;;(add-to-list 'default-frame-alist '(alpha-background . 80))

;;; No bars
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

;;; Fix scroll
(setq scroll-conservatively 10000
	  scroll-preserve-screen-position 1)

;;; Line numbers and visual lines
(global-display-line-numbers-mode 1)
(global-visual-line-mode 1)
(add-hook 'org-mode-hook (lambda () (display-line-numbers-mode 0)))
(diminish 'visual-line-mode)

;;; Cursor
(setq-default cursor-type 'bar)

;;; Tabs
(electric-indent-mode 1)
(setq tab-width 4
      c-default-style "linux")
(setq-default indent-tabs-mode t
	      tab-width 4)
(defvaralias 'c-basic-offset 'tab-width)

;;; ibuffer
(add-hook 'ibuffer-mode-hook
		  (lambda ()
			(ibuffer-switch-to-saved-filter-groups "Default")
			(setq ibuffer-show-empty-filter-groups nil)
			(ibuffer-auto-mode 1)))
(setq ibuffer-saved-filter-groups
	  '(("Default"
		 ("Files" (filename . "[~\/].*"))
		 ("ERC" (mode . erc-mode))
		 ("System" (name . "\*.*\*"))
		 ("Modified" (predicate buffer-modified-p (current-buffer)))
		 ("Other" (name . ".*"))
		 )))

;;; Icons
(use-package nerd-icons)

;;; Dashboard
(use-package dashboard :after nerd-icons
  :config
  (setq dashboard-set-heading-icons t
		dashboard-set-navigator t
		dashboard-set-file-icons t
		dashboard-startup-banner "~/.emacs.d/gnu.png"
		dashboard-banner-logo-title "\\(^-^)/"
		dashboard-set-init-info t
		dashboard-center-content t
		dashboard-items '((recents . 10)
						  (projects . 5 )
						  (bookmarks . 5)))
  (add-hook 'dashboard-mode #'display-line-numbers-mode)
  (setq initial-buffer-choice (lambda () (get-buffer-create "*dashboard*")))
  (dashboard-setup-startup-hook)
  (dashboard-modify-heading-icons '((recents . "file-text")
									(bookmarks . "book"))))

;;; Tree sitter
(use-package tree-sitter :diminish
  :config
  (global-tree-sitter-mode)
  (add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode))
(use-package tree-sitter-langs :after tree-sitter)

;;; Modeline - DISABLED
;;;(use-package doom-modeline
  ;;;:after nerd-icons
  ;;;:config
  ;;;(doom-modeline-mode 1)
  ;;;(setq doom-modeline-buffer-file-name-style 'relative-from-project
		;;;doom-modeline-hud nil))

;;; Mark - DISABLED
;;(use-package visible-mark
  ;;:config (transient-mark-mode 0)
  ;;(global-visible-mark-mode t)
  ;;(warn "Transient mark mode disabled")
  ;;)

;;; Beacon - DISABLED
;;;(use-package beacon
  ;;;:config (beacon-mode 1)
  ;;;(setq beacon-color "#c792ea"
		;;;beacon-blink-delay 0
		;;;beacon-blink-duration 0.6))

(provide 'teh-config-looks)

;;; teh-config-looks.el ends here
