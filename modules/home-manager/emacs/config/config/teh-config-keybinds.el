;;; teh-config-keybinds.el --- My config keybinds
;;; Commentary:
;;; My config files

;;; Code:

;;; Keymap mode
;;; https://emacs.stackexchange.com/questions/65080/stop-major-modes-from-overwriting-my-keybinding
;; (defvar tehkeys-keymap (make-keymap)
;;   "Keymap for tehkeys-mode")

;; (define-minor-mode tehkeys-mode
;;   "Minor mode for my personal keybindings."
;;   :init-value t
;;   :global t
;;   :keymap tehkeys-keymap)

;; (add-to-list 'emulation-mode-map-alists
;;              `((tehkeys-mode . ,tehkeys-keymap)))

;;; Window jumping
(use-package ace-window
  :bind* (("M-o" . 'ace-window))
  :bind (("M-o" . 'ace-window))
  :config
  (setq aw-dispactch-always t
		aw-dispatch-when-more-than 1
		aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l))
  (ace-window-display-mode 1)
  (set-face-attribute 'aw-mode-line-face nil :foreground "#ff5370" :weight 'bold)
  (set-face-attribute 'aw-leading-char-face nil :weight 'bold :height 4.0))
;;; Window zooming
(defun teh/zoom-window-ignore-side-windows (orig &rest args)
  "Call ORIG with `ignore-window-parameters' set, so zooming also hides
side windows (e.g. claude-code-ide) that set `no-delete-other-windows'."
  (let ((ignore-window-parameters t))
	(apply orig args)))
(use-package zoom-window
  :bind (("C-x 1" . zoom-window-zoom))
  :config
  (advice-add 'zoom-window-zoom :around #'teh/zoom-window-ignore-side-windows))
;;(general-define-key :prefix "M-o"
;;					"p" 'windmove-up
;;					"n" 'windmove-down
;;					"f" 'windmove-right
;;					"b" 'windmove-left)

;;; Require lisp for keybinds
(require 'insert-date)
(require 'recentf)
;; (require 'teh-config-mu4e)
;; (require 'multi-vterm)
(require 'popterm)
(require 'consult)
(require 'org)
(require 'org-roam)

;;; Init emacs says
(require 'emacs-says)
(emacs-says-load-quotes)

;;; Which key
(use-package which-key
  :diminish
  :init (which-key-mode))

;;; General keybinds
(global-unset-key (kbd "C-z"))
(use-package general)
(general-create-definer leader-def
  :prefix "C-z")
(leader-def
  "i" 'consult-imenu
  "f" '(:which-key "Files")
  "f r" 'consult-recent-file
  "f c" (lambda () (interactive) (cd "~/.emacs.d/config") (call-interactively 'find-file))
  ;; "e" 'mu4e-open
  ;; "RET" 'multi-vterm
  "RET" 'popterm-toggle-cd
  "d" 'insert-date
  "r" '(:which-key "Random")
  "r q" 'emacs-says-quote
  "m" '(:which-key "Music")
  "m p" 'emms-pause
  "m r" '(:which-key "Repeat")
  "m r t" 'emms-toggle-repeat-track
  "m r p" 'emms-toggle-repeat-playlist
  "o" '(:which-key "Org mode")
  "o b" 'org-switchb
  "o a" 'org-agenda
  "o f" 'org-roam-node-find
  "o c" '(:which-key "Capture")
  "o c r" 'org-roam-capture
  "o c t" 'org-capture
  "o t" 'org-roam-tag-add
  "o l" 'org-roam-node-insert
  )
(general-define-key "C-x C-b" 'ibuffer)
(general-define-key :keymaps 'flymake-mode-map
					"C-c e" 'flymake-goto-next-error
					"C-c E" 'flymake-goto-prev-error)
(general-define-key :keymaps 'eglot-mode-map
					"C-c a" 'eglot-code-actions
					"C-c r" 'eglot-rename)


;;; Remove annoying keybinds
(global-unset-key (kbd "C-<mouse-4>"))
(global-unset-key (kbd "C-<mouse-5>"))
(global-unset-key (kbd "C-<wheel-down>"))
(global-unset-key (kbd "C-<wheel-up>"))

;;; Misc
(global-subword-mode 1)
(diminish 'subword-mode)

(provide 'teh-config-keybinds)

;;; teh-config-keybinds.el ends here
