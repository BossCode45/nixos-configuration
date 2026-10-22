;;; emacs-says.el --- Some quotes from #emacs on libera.chat

;; Author: TehBoss
;; Version: 0.1

;;; Commentary:
;; This package provides functions to get some funny quotes
;; Make sure you have emacs-quotes.txt in the same directory as this file

;;;###autoload
(defvar emacs-says-quotes
  nil
  "Quotes for `emacs-says-quote`")

(defcustom emacs-says-default-file
  (expand-file-name "emacs-quotes.txt" (file-name-directory load-file-name))
  "Default file for `emacs-says-load-quotes'")

(defun emacs-says-load-quotes (&optional file)
  "Loads the quotes from FILE into the `emacs-says-quotes' variable
If FILE is not specified use `emacs-says-default-file'"
  (unless file
	(setq file emacs-says-default-file))
  (setq emacs-says-quotes nil)
  (save-excursion
	(set-buffer (find-file-noselect file))
	(goto-char (point-min))
	(while (re-search-forward "^[^\n]+$" (point-max) 1)
	  (push (match-string 0) emacs-says-quotes))
	(kill-buffer))
  (setq emacs-says-quotes (reverse emacs-says-quotes)))

(defun emacs-says-quote (&optional quote)
  "Gets a random quote from `emacs-says-quotes' or gives the quote specified by QUOTE"
  (interactive)
  (if emacs-says-quotes
	  (progn
		(if quote
			(setq quote (1- quote))
		  (setq quote (random (length emacs-says-quotes))))
		(if (or (>= quote (length emacs-says-quotes)) (<= quote -1))
			(message "Quote value too high or too low")
		  (message (nth quote emacs-says-quotes)))
		(nth quote emacs-says-quotes))
  	(message "Emacs quotes not loaded, use `emacs-says-load-quotes'")))

(provide 'emacs-says)
