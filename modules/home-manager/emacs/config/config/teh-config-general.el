;;; teh-config-general.el --- My config - General config
;;; Commentary:
;;; My config files

;;; Code:

;;; Recent
(use-package recentf
  :config
  (recentf-mode))

;;; Sudo edit
(use-package sudo-edit)

;;; Vertico
(use-package vertico
  :init (vertico-mode)
  :config (setq vertico-cycle t))

;;; Marginalia
(use-package marginalia :after vertico
  :init (marginalia-mode))

;;; Orderless
(use-package orderless
  :config
  (define-minor-mode orderless-mode
	"Toggles orderless"
	nil
	:global t
	:group 'orderless
	:lighter " Orderless"

	(if orderless-mode
		(progn
		  (setq completion-styles '(orderless basic))
		  (message "Orderless mode enabled"))
	  (progn
		(setq completion-styles '(basic partial-completion emacs22))
		(message "Orderless mode disabled"))))
  (orderless-mode)
  (diminish 'orderless-mode))

;;; Consult
(use-package consult
  :bind (("C-S-s" . consult-line)
		 ("C-x b" . consult-buffer)))

;;; Embark
(use-package embark
  :bind (("C-\\" . embark-act)))

;;; Embark consult
(use-package embark-consult)

;;; Vterm
;; (use-package vterm
;;   :config
;;   (setq vterm-environment '("EDITOR=emacsclient")))
;; (use-package multi-vterm)

;;; Ghostel
(use-package ghostel)

;;; Popterm (terminal toggler; replaces multi-vterm, backed by ghostel)
(use-package posframe)
(use-package popterm
  :config
  (setq popterm-backend 'ghostel
        popterm-display-method 'window
        popterm-scope 'project
        popterm-auto-cd t)
  (popterm-global-mode 1))

;;; Helpful
(use-package helpful
  :bind
  (("C-h f" . helpful-callable)
  ("C-h v" . helpful-variable)
  ("C-h k" . helpful-key)
  ("C-h x" . helpful-command)))

;;; Backups
(setq backup-directory-alist `(("" . "~/.saves") ("." . "~/.saves") (".*" . "~/.saves")))
(setq delete-old-versions t
	  version-control t)

;;; Magit
(use-package magit
  :config
  (add-hook 'magit-process-find-password-functions
            'magit-process-password-auth-source))

;;; Projectile
(defun projectile-run-ghostel (&optional arg)
  "Invoke `ghostel' in the project's root.

Switch to the project specific ghostel buffer if it already exists.

Use a prefix argument ARG to indicate creation of a new instance instead."
  (interactive "P")
  (unless (require 'ghostel nil 'noerror)
    (error "Package `ghostel' is not available"))
  (let* ((project (projectile-acquire-root))
		 (ghostel-buffer-name (format "*ghostel %s*" (projectile-project-name project)))
		 (default-directory project))
	(ghostel arg)))

(defun projectile-claude-code-ide-menu ()
  "Open `claude-code-ide-menu' for a projectile project.

The menu's commands run after it returns, so binding `default-directory'
isn't enough; when the chosen project isn't the current one, visit its
root first so the menu acts on it."
  (interactive)
  (let ((project (projectile-acquire-root)))
	(unless (equal project (projectile-project-root))
	  (dired project))
	(call-interactively #'claude-code-ide-menu)))

(use-package projectile
  :diminish
  :config
  (projectile-mode +1)
  (define-key projectile-mode-map
			  (kbd "C-c p") 'projectile-command-map)
  ;; Overrides the stock "x v" -> `projectile-run-vterm' binding; comment
  ;; this out to fall back to it.
  (define-key projectile-command-map (kbd "x v") #'projectile-run-ghostel)
  (define-key projectile-command-map (kbd "C-'") #'projectile-claude-code-ide-menu))

;;; Treemacs
(use-package treemacs)
(use-package treemacs-projectile
  :after treemacs projectile)

;;; Occur
(defun occur-scroll ()
  (end-of-buffer-other-window 0))
(add-hook 'occur-hook 'occur-scroll)

;;; Dired
(setq dired-kill-when-opening-new-dired-buffer t)
;(use-package diredc
;  :load-path "~/.emacs.d/packages/emacs-diredc"
;  :bind (("C-x C-d" . diredc))
;  :custom
;  (diredc-make-new-frame nil))
(use-package casual-dired
  :bind (:map dired-mode-map ("C-o" . 'casual-dired-tmenu)))

;;; Direnv
(use-package direnv
  :config
  (direnv-mode))

;;; Qalc
(require 'qalc)
  
;;; Random stuff
;;(tab-bar-mode 1)
(setq use-short-answers t)
(setq sentence-end-double-space nil)
(delete-selection-mode 1)
(defun emacs ()
  (interactive)
  (message "Godly editor"))
(defun vim ()
  (interactive)
  (message "Spawn of the devil"))

(provide 'teh-config-general)

;;; teh-config-general.el ends here
