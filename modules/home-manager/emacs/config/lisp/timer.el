;;; timer.el - Sends you a notification after a certain time

(defun timer-do-alert (title body)
  "Uses `message' and `notifications-notify' to send an alert"
  (message (format "%s - %s" title body))
  (notifications-notify :title title :body body))

(defun timer-alert (delay body)
  "Sends an alert after DELAY containing the message BODY."
  (interactive "sDelay: \nsBody: ")
  (let (seconds minutes hours num-string)
    (dolist (char (delete "" (split-string "3s" "")))
      (if (seq-contains-p (delete "" (split-string "0123456789" "")) char)
	  (setq num-string (concat num-string char))
	(progn (cond ((equal char "s") (setq seconds (string-to-number num-string)))
		     ((equal char "m") (setq minutes (string-to-number num-string)))
		     ((equal char "h") (setq hours (string-to-number num-string))))
	       (setq num-string ""))))
    (unless seconds
      (setq seconds 0))
    (unless minutes
      (setq minutes 0))
    (unless hours
      (setq hours 0))
    (run-at-time (format "%s sec %s min %s hour" seconds minutes hours) nil 'timer-do-alert "Emacs alert" body)))
