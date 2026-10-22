;;; teh-config-trust.el --- My config - trusted-content -*- lexical-binding: t; -*-
;;; Commentary:
;;; Manage Emacs 30's `trusted-content' via trust-manager.
;;; Code:

(use-package trust-manager
  :ensure nil ; built by Nix
  :config
  (trust-manager-mode 1))

(provide 'teh-config-trust)
;;; teh-config-trust.el ends here
