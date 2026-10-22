;;; teh-config.el --- My config
;;; Commentary:
;;; My config files

;;; Code:

;;; Make sure packages work
(require 'package)
(add-to-list 'package-archives
	     '("melpa" . "https://melpa.org/packages/"))
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))
;; Make sure to run list-packages and update with U every so often
;; use-package is built in; packages Nix provides count as installed, so
;; :ensure only downloads the ones Nix doesn't have
(require 'use-package)
(setq use-package-always-ensure t)

;;; Require rest of config
(require 'teh-config-general)
(require 'teh-config-auth)
(require 'teh-config-trust)
(require 'teh-config-completion)
(require 'teh-config-erc)
(require 'teh-config-org-mode)
(require 'teh-config-emms)
(require 'teh-config-looks)
(require 'teh-config-keybinds)

;;; Require random functions
(require 'my-functions)

;; (let ((frame (make-frame)))
;; 	  (select-frame-set-input-focus frame)
;; 	  (start-scratch))

(provide 'teh-config)

;;; teh-config.el ends here
