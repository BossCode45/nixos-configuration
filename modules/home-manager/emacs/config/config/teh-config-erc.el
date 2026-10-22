;;; teh-config-erc.el --- My config
;;; Commentary:
;;; My config files

;;; Code:

(require 'erc)

;; erc-sasl
(require 'erc-sasl)
;; Add SASL server to list of SASL servers (start a new list, if it did not exist)
(add-to-list 'erc-sasl-server-regexp-list "irc\\.libera\\.chat")
;; Redefine/Override the erc-login() function from the erc package, so that
;; it now uses SASL
;; (defun erc-login ()
;;   "Perform user authentication at the IRC server. (PATCHED)"
;;   (erc-log (format "login: nick: %s, user: %s %s %s :%s"
;; 				   (erc-current-nick)
;; 				   (user-login-name)
;; 				   (or erc-system-name (system-name))
;; 				   erc-session-server
;; 				   erc-session-user-full-name))
;;   (if erc-session-password
;; 	  (erc-server-send (format "PASS %s:%s" (erc-current-nick) erc-session-password))
;; 	(message "Logging in without password"))
;;   (when (and (featurep 'erc-sasl) (erc-sasl-use-sasl-p))
;; 	(erc-server-send "CAP REQ :sasl"))
;;   (erc-server-send (format "NICK %s" (erc-current-nick)))
;;   (erc-server-send
;;    (format "USER %s %s %s :%s"
;; 		   ;; hacked - S.B.
;; 		   (if erc-anonymous-login erc-email-userid (user-login-name))
;; 		   "0" "*"
;; 		   erc-session-user-full-name))
;;   (erc-update-mode-line))

(defun erc-login ()
  "Perform user authentication at the IRC server."
  (erc-log (format "login: nick: %s, user: %s %s %s :%s"
                   (erc-current-nick)
                   (user-login-name)
                   (or erc-system-name (system-name))
                   erc-session-server
                   erc-session-user-full-name))
  (if erc-session-password
      (erc-server-send (concat "PASS " (erc-current-nick) ":" (erc--unfun erc-session-password)))
    (message "Logging in without password"))
  (erc-server-send (format "NICK %s" (erc-current-nick)))
  (erc-server-send
   (format "USER %s %s %s :%s"
           ;; hacked - S.B.
           erc-session-username
           "0" "*"
           erc-session-user-full-name))
  (erc-update-mode-line))

(setq erc-format-nick-function 'erc-format-@nick)

;;; Truncating
(add-hook 'erc-mode-hook 'erc-truncate-disable)
(add-hook 'erc-mode-hook (lambda () (erc-truncate-mode 0)))
(defun erc-cmd-TRUNCATE () (interactive)
	   (erc-truncate-buffer)
	   (end-of-buffer))
(define-key erc-mode-map (kbd "C-c t") 'erc-cmd-TRUNCATE)

;;; Completion
(add-hook 'erc-mode-hook 'corfu-mode)

;;; Keybindings
(defun erc-reconnect () (interactive)
	   (erc-cmd-RECONNECT))
(define-key erc-mode-map (kbd "C-c r") 'erc-reconnect)

(defun erc-cmd-RAT () (interactive)
	   (erc-send-message "~~,=,^>"))
(define-key erc-mode-map (kbd "C-c P") 'erc-cmd-RAT)

;;; Join config
(setq erc-server "tehbox.org"
	  erc-port 5000
	  erc-nick "boss/rizon"
	  erc-track-shorten-start 8
	  erc-autojoin-delay 0
	  erc-autojoin-timing 'ident
	  erc-kill-buffer-on-part t
	  erc-kill-buffer-on-quit t
	  erc-auto-query 'bury
	  erc-max-buffer-size 350000
	  erc-insert-timestamp-function 'erc-insert-timestamp-right
	  erc-timestamp-format "[%H:%M]"
	  erc-timestamp-format-left "[%H:%M]"
	  erc-timestamp-format-right "[%H:%M]")

(defun erc-server-reconnect ()
  "Reestablish the current IRC connection.
Make sure you are in an ERC buffer when running this."
  (let ((buffer (erc-server-buffer)))
    (unless (buffer-live-p buffer)
      (if (eq major-mode 'erc-mode)
          (setq buffer (current-buffer))
        (error "Reconnect must be run from an ERC buffer")))
    (with-current-buffer buffer
      (erc-update-mode-line)
      (erc-set-active-buffer (current-buffer))
      (setq erc-server-last-sent-time 0)
      (setq erc-server-lines-sent 0)
      (let ((erc-server-connect-function (or erc-session-connector
                                             #'erc-open-network-stream))
            (erc--server-reconnecting (buffer-local-variables)))
        (erc-open erc-session-server erc-session-port erc-nick
                  erc-session-user-full-name t erc-session-password
                  nil nil nil erc-session-client-certificate
                  erc-session-username
                  (erc-networks--id-given erc-networks--id))
        (defvar erc-reuse-buffers)
        (unless (with-suppressed-warnings ((obsolete erc-reuse-buffers))
                  erc-reuse-buffers)
          (cl-assert (not (eq buffer (current-buffer)))))))))

;; Nick highlighting
;; (use-package erc-hl-nicks
;;  :after erc
;;  :config
;;  ;;; Face for my nick
;;  (defface erc-nick-face
;; 	'((t
;; 	   :foreground "#c792ea"
;; 	   :inherit 'erc-hl-nicks-nick-base-face))
;; 	"Face for your nick in ERC"
;; 	:group 'erc-hl-nicks)
;;  (set-face-attribute 'erc-my-nick-face nil :foreground "#c792ea")
;;  ;;; Change highlighting function
;;  (defun erc-hl-nicks-make-face (nick)
;; 	"Create and cache a new face for the given nick"
;; 	(if (string-equal-ignore-case nick (erc-current-nick))
;; 		"erc-nick-face"
;; 	  (or
;; 	   (gethash (if (string-match "j+[oa]k+e" (downcase nick)) "jjakke" (downcase nick)) ;erc-hl-nicks-face-table)
;;       (let ((color (erc-hl-nicks-color-for-nick (downcase nick)))
;;             (new-nick-face (erc-hl-nicks-face-name (downcase nick))))
;;         (copy-face 'erc-hl-nicks-nick-base-face new-nick-face)
;;         (set-face-foreground new-nick-face color)
;;         (puthash (downcase nick) new-nick-face erc-hl-nicks-face-table)))))
;;  (erc-hl-nicks-force-nick-face "jjakke" "#ff5050" t)))

;; Command alias
(defalias 'erc-cmd-LL 'erc-cmd-LASTLOG)

;;; Mentions
(define-minor-mode erc-mentions-mode
  "Enables ERC mention recording"
  nil
  :global t
  :lighter " ERC mentions"
  :init-value nil
  (defun update-mentions (arg1 response)
	(let ((contents (erc-response.contents response)))
	  (when (string-match (regexp-quote (erc-current-nick)) contents)
		(save-excursion
		  (set-buffer (get-buffer-create "*ERC Mentions*"))
		  (erc-mentions-list-mode)
		  (let ((inhibit-read-only t))
			(end-of-buffer)
			(insert (current-time-string) ": <" (car (split-string (erc-response.sender response) "!")) "> " contents "\n")
			)
		  (end-of-buffer)
		  )))
	nil)
  (if erc-mentions-mode
	  (progn
		(add-hook 'erc-server-PRIVMSG-functions 'update-mentions)
		(message "ERC mentions mode enabled"))
	(progn
	  (remove-hook 'erc-server-PRIVMSG-functions 'update-mentions)
	  (message "ERC mentions mode disabled"))))
(define-derived-mode erc-mentions-list-mode
  special-mode "*ERC Mentions*"
  "Mode for the ERC mentions list"
  :interactive nil)
(add-to-list 'auto-mode-alist '("\\*ERC Mentions\\*\\'" . erc-mentions-list-mode))

(use-package jabber)


(provide 'teh-config-erc)

;;; teh-config-erc.el ends here
