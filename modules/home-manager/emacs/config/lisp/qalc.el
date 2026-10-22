(defvar qalc-cli-file-path ""
  "Path to the program used by `run-qalc'")

(defvar qalc-cli-arguments '()
  "Commandline arguments to pass to `qalc-cli'.")

(defvar qalc-mode-map
  (let ((map (nconc (make-sparse-keymap) comint-mode-map)))
    ;; example definition
    (define-key map "\t" 'completion-at-point)
    map)
  "Basic mode map for `run-qalc'.")

(defvar qalc-prompt-regexp "^\\(?:>\\)"
  "Prompt for `run-qalc'.")

(defvar qalc-buffer-name "*Qalc*"
  "Name of the buffer to use for the `run-qalc' comint instance.")

(defun run-qalc ()
  "Run an inferior instance of `qalc-cli' inside Emacs."
  (interactive)
  (let* ((qalc-program (executable-find "qalc"))
         (buffer (get-buffer-create qalc-buffer-name))
         (proc-alive (comint-check-proc buffer))
         (process (get-buffer-process buffer)))
    ;; if the process is dead then re-create the process and reset the
    ;; mode.
    (unless proc-alive
      (with-current-buffer buffer
        (apply 'make-comint-in-buffer "Qalc" buffer
               qalc-program '() qalc-cli-arguments)
        (qalc-mode)))
    ;; Regardless, provided we have a valid buffer, we pop to it.
    (when buffer
      (pop-to-buffer buffer))))

(defun qalc--initialize ()
  "Helper function to initialize Qalc."
  (setq comint-process-echoes nil)
  (setq comint-use-prompt-regexp t)
  (setq comint-prompt-read-only t)
  (add-hook 'comint-preoutput-filter-functions 'comint-set-text-read-only))


(defun comint-set-text-read-only (text)
  (propertize text 'read-only t))

(add-hook 'qalc-mode-hook 'qalc--initialize)

(define-derived-mode qalc-mode comint-mode "Qalc"
  "Major mode for `run-qalc'.

\\<qalc-mode-map>"
  ;; this sets up the prompt so it matches >
  (setq comint-prompt-regexp qalc-prompt-regexp)
  ;; this makes it read only; a contentious subject as some prefer the
  ;; buffer to be overwritable.
  (setq comint-prompt-read-only t)
  ;; this makes it so commands like M-{ and M-} work.
  (set (make-local-variable 'paragraph-separate) "\\'")
  (set (make-local-variable 'paragraph-start) qalc-prompt-regexp))

(provide 'qalc)
