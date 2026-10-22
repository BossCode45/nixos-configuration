;;; teh-config-emms.el --- My config for emms
;;; Commentary:
;;; My config files

;;; Code:

(use-package emms
  :config
  (emms-all)
  (setq emms-player-list '(emms-player-mpv)
		emms-info-functions '(emms-info-native))
  (emms-add-directory-tree "~/Music")
  (emms-mode-line-enable))

(provide 'teh-config-emms)

;;; teh-config-emms.el ends here
