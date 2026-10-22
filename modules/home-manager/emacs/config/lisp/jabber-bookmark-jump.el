;;; package --- jabber.el
;;; commentary:
;;; not really sure how i'm supposed to format this


;;; CODE:

(defun jabber-bookmark-jump (bookmark)
  "Opens muc bookmark BOOKMARK."
  (interactive (list (completing-read "Bookmark: "
									  (let ((acc (fsm-get-state-data (jabber-read-account)))
											(names))
										(dolist (elem
												 (gethash (plist-get acc :original-jid) jabber-bookmarks))
										  (setq names (cons (list (cdr (car (nth 1 elem)))) names)))
										names))))
  (let ((acc (fsm-get-state-data (jabber-read-account)))
		(nick))
	(dolist (elem
			 (gethash (plist-get acc :original-jid) jabber-bookmarks))
			 (if (equal (cdr (car (nth 1 elem))) bookmark)
				   (setq nick (nth 2 (nth 2 elem)))))
	(jabber-muc-join (jabber-read-account) bookmark nick t)))

(provide 'jabber-bookmark-jump)

;;; jabber-bookmark-jump.el ends here
