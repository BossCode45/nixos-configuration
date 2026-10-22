;;; teh-config-auth.el --- My config - Auth config
;;; Commentary:
;;; Unix pass and totp

;;; Code:

;; Unix pass
(auth-source-pass-enable)
(setq auth-source-pass-filename "~/.password-store")
(setq auth-sources '(password-store "~/.authinfo.gpg" "~/.authinfo" "~/.netrc"))
(use-package pass) ;; For viewing passwords, not sure if i should keep

;; Totp
(use-package totp)

(provide 'teh-config-auth)

;;; teh-config-auth.el ends here
