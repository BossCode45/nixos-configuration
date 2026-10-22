;;; package --- insert-date.el
;;; commentary:
;;; Package to insert a date

;;; CODE:

(defcustom insert-date-format
  "%m-%d-%Y"
  "Format for the `insert-date' function."
  :type '(string)
  :group 'insert-date)

(defun insert-date ()
  "Insert the date into the curret buffer.
Format can be changed with `insert-date-format'."
  (interactive)
  (insert (format-time-string insert-date-format (current-time))))

(provide 'insert-date)

;;; insert-date.el ends here
