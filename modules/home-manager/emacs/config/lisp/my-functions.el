;;; my-functions.el --- My random functions
;;; Commentary:
;;; Some random functions

;;; Code:

;;; Karate
(defun karate-new (timestamp)
  "Creates new document for karate lesson plans based on a template."
  (interactive
   (list (org-read-date nil t)))
  (let ((date (format-time-string "%d-%m-%Y" timestamp)))
  (copy-file "~/Documents/karate/lessonPlans/default.org"
			 (concat "~/Documents/karate/lessonPlans/" date ".org") 1)
  (switch-to-buffer (find-file-noselect (concat "~/Documents/karate/lessonPlans/" date ".org")))
  (replace-string "DATEHERE" date)
  (goto-char (point-min))
  (forward-line 5)
  (end-of-line)))

;;; Scratch
(defun start-scratch ()
  "Function to call when starting the scratch window, or to enter scratchpad mode."
  (interactive)
  ;; Make window not transparent
  (set-frame-parameter (selected-frame) 'alpha '(100 100))
  ;; Make change WM_NAME to "scratch-emacs"
  (set-frame-parameter (selected-frame) 'name "scratch-emacs")
  (org-agenda nil "n")
  (delete-other-windows)
  )
(defun stop-scratch ()
  "Function to call to stop the scratch window."
  (interactive)
  ;; Make window transparent
  (set-frame-parameter (selected-frame) 'alpha '(80 80))
  (set-frame-parameter (selected-frame) 'name nil))

;;; Terminal
(require 'multi-vterm)
(defun start-terminal ()
  "Function to call to start a terminal and switch to insert mode, usually used for the keybind $mod+Shift+Return."
  (interactive)
  (multi-vterm))

(provide 'my-functions)

;;; my-functions.el ends here
