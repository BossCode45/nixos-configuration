;;; teh-config-mu4e.el --- My config - mu4e
;;; Commentary:
;;; My config files

;;; Code:

;;(add-to-list 'load-path "/usr/share/emacs/site-lisp/mu4e")
(use-package mu4e
  :ensure nil
  :config
  (setq mu4e-mu-binary (executable-find "mu"))
  (setq user-mail-address "boss@tehbox.org")

  ;; SMTP settings:
  (setq send-mail-function 'smtpmail-send-it
		smtpmail-smtp-server "tehbox.org"
		smtpmail-smtp-user "boss"
		smtpmail-mail-address "boss@tehbox.org"
		smtpmail-smtp-service 587
		smtpmail-stream-type 'starttls)

  ;; Mail folders:
  (setq mu4e-drafts-folder "/drafts"
		mu4e-sent-folder   "/sent"
		mu4e-trash-folder  "/trash")
  
  ;; The command used to get your emails (adapt this line, see section 2.3):
  (setq mu4e--get-mail-password-regexp "^Password (tehbox): $"
		mu4e-get-mail-command "mbsync --config ~/.emacs.d/.mbsyncrc tehbox"
		mu4e-change-filenames-when-moving t)
  (defun mu4e-open () (interactive)
		 (mu4e-update-mail-and-index nil)
		 (mu4e nil))
  
  ;; Further customization:
  (setq mu4e-html2text-command "w3m -T text/html"
		mu4e-update-interval 300
		mu4e-headers-auto-update nil
		mu4e-view-show-images t
		mu4e-compose-signature-auto-include nil
		mu4e-use-fancy-chars t)

  ;; Functions
  (defun mu4e-email-file (&optional file)
	"Starts an email with FILE as an attachment, defaults to current open file"
	(interactive)
	(unless file
	  (setq file (buffer-file-name)))
	(if (file-exists-p file)
		(progn
		  (mu4e-compose-new)
		  (mail-add-attachment file))
	  (message "Not a file"))))

(provide 'teh-config-mu4e)

;;; teh-config-mu4e.el ends here
