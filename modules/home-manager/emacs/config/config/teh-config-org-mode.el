;;; teh-config-org-mode.el --- My config - <BLANK>
;;; Commentary:
;;; My config files

;;; Code:

;;; Fancy stars
(use-package org-superstar
  :after org
  :hook (org-mode . org-superstar-mode)
  :config
  (setq org-hide-leading-stars nil
		org-superstar-leading-bullet ?\s
		org-imenu-depth 3))

;;; Fancy header outdent
(use-package org-margin
  :ensure nil ; built by Nix
  :config
  (add-hook 'org-mode-hook (lambda () (org-margin-mode 1))))


;;; NO spell check for embedded snippets
(defadvice org-mode-flyspell-verify (after org-mode-flyspell-verify-hack activate)
  (let* ((rlt ad-return-value)
		 (begin-regexp "^[ \t]*#\\+begin_\\(src\\|html\\|latex\\|example\\|quote\\)")
		 (end-regexp "^[ \t]*#\\+end_\\(src\\|html\\|latex\\|example\\|quote\\)")
		 (case-fold-search t)
		 b e)
	(when ad-return-value
	  (save-excursion
		(setq b (re-search-backward begin-regexp nil t))
		(if b (setq e (re-search-forward end-regexp nil t))))
	  (if (and b e (< (point) e)) (setq rlt nil)))
	(setq ad-return-value rlt)))

(require 'org)

;;; Spell check
(add-hook 'org-mode-hook (lambda () (flyspell-mode) (flyspell-buffer)))

;;; Font sizes
(set-face-attribute 'org-level-1 nil :weight 'bold :height 1.6)
(set-face-attribute 'org-level-2 nil :weight 'bold :height 1.4)
(set-face-attribute 'org-level-3 nil :weight 'bold :height 1.3)
(set-face-attribute 'org-level-4 nil :weight 'normal :slant 'italic :height 1.2)
(set-face-attribute 'org-level-5 nil :weight 'normal :slant 'italic :height 1.15)

;;; Org agenda
(require 'org-agenda)
(setq org-default-notes-file (concat org-directory "/notes.org"))
(setq org-agenda-files '("~/Documents/org/agenda/"))
(setq org-agenda-custom-commands
	  '(
		("n" "Agenda and all TODOs"
		 ((agenda #1="")
		  (alltodo #1#)))

		("c" "Custom view"
		 ((agenda ""
				  ((org-agenda-sorting-strategy '(category-keep habit-down time-up priority-down))))
		  (todo ""
				((org-agenda-sorting-strategy '(category-keep priority-down))))))))

;;; Org capture
(setq org-capture-templates
      '(("t" "Todo" entry (file+headline "~/Documents/org/agenda/general.org" "Tasks")
         "* TODO %?\n  %i")
		("h" "Homework" entry (file+headline "~/Documents/org/agenda/uni.org" "Homework")
         "* TODO %?\n  %i")
		("a" "Assignments" entry (file+headline "~/Documents/org/agenda/uni.org" "Assignments")
         "* TODO %?\n  %i")
		("c" "Classes/Meetings" entry (file+headline "~/Documents/org/agenda/uni.org" "Classes/Meetings")
         "* TODO %?\n  %i")))

;;; Org roam
(use-package org-roam
  :after org
  :config
  (unless (f-directory-p "~/org-roam")
	(make-directory "~/org-roam"))
  (setq org-roam-directory (file-truename "~/org-roam")
		org-roam-node-display-template
		(concat "${title:*} "
				(propertize "${tags:25}" 'face 'org-tag)))
  (org-roam-db-autosync-mode))

;;; Nixos org pdf
(setq org-latex-compiler "lualatex")
(setq org-preview-latex-default-process 'dvisvgm)

;;; Jupyter
;; (org-babel-do-load-languages
;;  'org-babel-load-languages
;;  '((emacs-lisp . t)
;;    (julia . t)
;;    (python . t)
;;    (jupyter . t)))

;;; Keybinds
(use-package org :after general
  :config
  (general-define-key :keymaps 'org-mode-map "C-c C-x M-v" "C-c C-x C-v C-c C-x C-v" )
  (general-define-key :keymaps 'org-mode-map "C-c a" 'ispell-word))

(provide 'teh-config-org-mode)

;;; teh-config-org-mode.el ends here
