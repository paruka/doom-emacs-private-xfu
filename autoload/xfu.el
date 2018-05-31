;; autoload/xfu.el -*- lexical-binding: t; -*-
;;;###autoload
(defun dwim-jump ()
  (interactive)
  (cond ((eq 'org-mode (buffer-local-value 'major-mode (current-buffer)))
         (counsel-org-goto))
        ((eq 'org-agenda-mode (buffer-local-value 'major-mode (current-buffer)))
         (counsel-org-goto-all))
        ((bound-and-true-p outline-minor-mode)
         (counsel-oi))
        (t (counsel-imenu))))

;;;###autoload
(defun mac-iTerm-shell-command (text)
  "Write TEXT into iTerm like user types it with keyboard."
  (interactive
   (list
    (read-shell-command "Run Shell command in iTerm: "
                        (when (use-region-p)
                          (buffer-substring-no-properties
                           (region-beginning)
                           (region-end))))))
  (do-applescript
   (concat
    "tell application \"iTerm\"\n"
    "    activate\n"
    "    create window with default profile\n"
    "    tell current session of current window\n"
    "        write text \"" text "\"\n"
    "    end tell\n"
    "end tell")))
;;;###autoload
(defun mac-iTerm-shell-command-current (text)
  "Write TEXT into iTerm like user types it with keyboard."
  (interactive
   (list
    (read-shell-command "Run Shell command in iTerm: "
                        (when (use-region-p)
                          (buffer-substring-no-properties
                           (region-beginning)
                           (region-end))))))
  (do-applescript
   (concat
    "tell application \"iTerm\"\n"
    "    activate\n"
    "    tell current session of current window\n"
    "        write text \"" text "\"\n"
    "    end tell\n"
    "end tell")))
;;;###autoload
(defun mac-iTerm-cd (dir)
  "Switch to iTerm and change directory there to DIR."
  (interactive (list
                ;; Because shell doesn't expand 'dir'
                (expand-file-name
                 (if current-prefix-arg
                     (read-directory-name "cd to: ")
                   default-directory))))
  (if (file-remote-p dir)
      (let* (
             (host (tramp-file-name-host (tramp-dissect-file-name dir)))
             (dir (tramp-file-name-localname (tramp-dissect-file-name dir)))
             (sshcmd (format "ssh %s" host))
             (cdcmd (format "cd %s" dir))
             )
        (mac-iTerm-shell-command sshcmd)
        (mac-iTerm-shell-command-current cdcmd)
        )
    (let ((cmd (format "cd %s" dir)))
      (mac-iTerm-shell-command cmd))
    )
  )
;;;###autoload
(defun applescript-quote-string (argument)
  "Quote a string for passing as a string to AppleScript."
  (if (or (not argument) (string-equal argument ""))
      "\"\""
    ;; Quote using double quotes, but escape any existing quotes or
    ;; backslashes in the argument with backslashes.
    (let ((result "")
          (start 0)
          end)
      (save-match-data
        (if (or (null (string-match "[^\"\\]" argument))
                (< (match-end 0) (length argument)))
            (while (string-match "[\"\\]" argument start)
              (setq end (match-beginning 0)
                    result (concat result (substring argument start end)
                                   "\\" (substring argument end (1+ end)))
                    start (1+ end))))
        (concat "\"" result (substring argument start) "\"")))))
;;;; Edit
;;;###autoload
(defun highlight-grammar ()
  (interactive)
  (highlight-regexp "\\\w+s[\\\., ;]" 'hi-yellow))

;;;; Org
;;;###autoload
(defun org-agenda-show-daily (&optional arg)
  (interactive "P")
  (org-agenda arg "a"))

;;;###autoload
(defun cfw:open-org-calendar-withoutkevin ()
  (interactive)
  (let ((org-agenda-files '("~/Dropbox/org/" "~/Dropbox/org/cal/cal.org")))
    (call-interactively '+calendar/open-calendar)))

;;;###autoload
(defun cfw:open-org-calendar-withkevin ()
  (interactive)
  (let ((org-agenda-files '("~/Dropbox/org/" "~/Dropbox/org/cal/")))
    (call-interactively '+calendar/open-calendar)))

;;;###autoload
(defun sort-setq-next-record ()
    (condition-case nil
            (progn
                (forward-sexp 1)
                (backward-sexp))
        ('scan-error (end-of-buffer))))

;;;###autoload
(defun sort-setq ()
  (interactive)
  (save-excursion
    (save-restriction
      (let ((sort-end (progn (end-of-defun)
                             (backward-char)
                             (point-marker)))
            (sort-beg (progn (beginning-of-defun)
                             (re-search-forward "[ \\t]*(" (point-at-eol))
                             (forward-sexp)
                             (re-search-forward "\\<" (point-at-eol))
                             (point-marker))))
        (narrow-to-region (1- sort-beg) (1+ sort-end))
        (sort-subr nil #'sort-setq-next-record #'sort-setq-end-record)))))

;;;###autoload
(defun sort-setq-end-record ()
  (condition-case nil
      (forward-sexp 2)
    ('scan-error (end-of-buffer))))


;;;###autoload
(defun +my-workspace/goto-main-window (pname frame)
    (let ((window (car (+my-doom-visible-windows))))
      (if (window-live-p window)
          (select-window window))))

;;;###autoload
(defun +my-doom-visible-windows (&optional window-list)
  "Return a list of the visible, non-popup windows."
  (cl-loop for window in (or window-list (window-list))
           unless (window-dedicated-p window)
           collect window))

;;;###autoload
(defun +my-workspace/close-window-or-workspace ()
  "Close the selected window. If it's the last window in the workspace, close
the workspace and move to the next."
  (interactive)
  (let ((delete-window-fn (if (featurep 'evil) #'evil-window-delete #'delete-window)))
    (if (window-dedicated-p)
        (funcall delete-window-fn)
      (let ((current-persp-name (+workspace-current-name)))
        (cond ((or (+workspace--protected-p current-persp-name)
                   (cdr (+my-doom-visible-windows)))
               (funcall delete-window-fn))
              ((cdr (+workspace-list-names))
               (+workspace/delete current-persp-name)))))))

;;;###autoload
(defun +xfu/browse-private ()
  (interactive) (doom-project-browse "~/.doom.d/"))
;;;###autoload
(defun +xfu/find-in-private ()
  (interactive) (doom-project-find-file "~/.doom.d/"))

;;;###autoload
(defun +xfu/browse-playground ()
  (interactive) (doom-project-browse "~/Source/playground/"))
;;;###autoload
(defun +xfu/find-in-playground ()
  (interactive) (doom-project-find-file "~/Source/playground/"))

;;;###autoload
(defun +xfu/browse-work ()
  (interactive) (doom-project-browse "~/Source/work/"))
;;;###autoload
(defun +xfu/find-in-work ()
  (interactive) (doom-project-find-file "~/Source/work/"))

;;;###autoload
(defun +xfu/browse-snippets ()
  (interactive) (doom-project-browse "~/.doom.d/snippets/"))

;;;###autoload
(defun +xfu/find-in-snippets ()
  (interactive) (doom-project-find-file "~/.doom.d/snippets/"))


;; ;;;###autoload
;; (defun +eshell/history ()
;;   "Interactive search eshell history."
;;   (interactive)
;;   (require 'em-hist)
;;   (save-excursion
;;     (let* ((start-pos (eshell-bol))
;; 	   (end-pos (point-at-eol))
;; 	   (input (buffer-substring-no-properties start-pos end-pos)))
;;       (let* ((command (ivy-read "Command: "
;; 				(delete-dups
;; 				 (when (> (ring-size eshell-history-ring) 0)
;; 				   (ring-elements eshell-history-ring)))
;; 				:initial-input input
;; 				:action #'ivy-completion-in-region-action))
;; 	     (cursor-move (length command)))
;; 	(kill-region (+ start-pos cursor-move) (+ end-pos cursor-move))
;; 	)))
;;   ;; move cursor to eol
;;   (end-of-line))

;;;###autoload
(defun *flycheck-posframe-show-posframe (errors)
    "Display ERRORS, using posframe.el library."
    (when errors
      (posframe-show
       flycheck-posframe-buffer
       :string (flycheck-posframe-format-errors errors)
       :background-color (face-background 'flycheck-posframe-background-face nil t)
       :override-parameters '((internal-border-width . 10))
       :position (point))
      (dolist (hook flycheck-posframe-hide-posframe-hooks)
        (add-hook hook #'flycheck-posframe-hide-posframe nil t))))

;;;###autoload
(defun *flycheck-posframe-delete-posframe ()
    "Delete messages currently being shown if any."
    (posframe-hide flycheck-posframe-buffer)
    (dolist (hook flycheck-posframe-delete-posframe-hooks)
      (remove-hook hook #'flycheck-posframe-hide-posframe t)))

;;;###autoload
(defun +syntax-checker*cleanup-popup ()
    "TODO"
    (if (and EMACS26+
             (display-graphic-p))
        (flycheck-posframe-hide-posframe)
      (if (display-graphic-p)
          (flycheck-popup-tip-delete-popup))))

;;;###autoload
(defun *lv-window ()
    "Ensure that LV window is live and return it."
    (if (window-live-p lv-wnd)
        lv-wnd
      (let ((ori (selected-window))
            buf)
        (prog1 (setq lv-wnd
                     (select-window
                      (let ((ignore-window-parameters t))
                        (split-window
                         (frame-root-window) -1 'below))))
          (if (setq buf (get-buffer " *LV*"))
              (switch-to-buffer buf)
            (switch-to-buffer " *LV*")
            (set-window-hscroll lv-wnd 0)
            (setq window-size-fixed t)
            (setq mode-line-format nil)
            (setq cursor-type nil)
            (set-window-dedicated-p lv-wnd t)
            (set-window-fringes lv-wnd 0 0 nil)
            (set-window-parameter lv-wnd 'no-other-window t))
          (select-window ori)))))

;;;###autoload
(defun counsel-faces ()
    "Show a list of all defined faces.

You can describe, customize, insert or kill the name or selected
candidate."
    (interactive)
    (let* ((minibuffer-allow-text-properties t)
           (max-length
            (apply #'max
                   (mapcar
                    (lambda (x)
                      (length (symbol-name x)))
                    (face-list))))
           (counsel--faces-fmt (format "%%-%ds  " max-length))
           (ivy-format-function #'counsel--faces-format-function))
      (ivy-read "%d Face: " (face-list)
                :require-match t
                :action #'counsel-faces-action-describe
                :preselect (symbol-name (face-at-point t))
                :history 'counsel-faces-history
                :caller 'counsel-faces
                :sort t)))

;;;###autoload
(defun +ivy-recentf-transformer (str)
    "Dim recentf entries that are not in the current project of the buffer you
started `counsel-recentf' from. Also uses `abbreviate-file-name'."
    (abbreviate-file-name str))

;;;###autoload
(defun +ivy-top ()
    (interactive)
    (let* ((output (shell-command-to-string ivy-top-command))
           (lines (progn
                    (string-match "TIME" output)
                    (split-string (substring output (+ 1 (match-end 0))) "\n")))
           (candidates (mapcar (lambda (line)
                                 (list line (split-string line " " t)))
                               lines)))
      (ivy-read "process: " candidates)))

;;;###autoload
(defun +ivy/reloading (cmd)
  (lambda (x)
    (funcall cmd x)
    (ivy--reset-state ivy-last)))

;;;###autoload
(defun +ivy/given-file (cmd prompt)     ; needs lexical-binding
  (lambda (source)
    (let ((target
           (let ((enable-recursive-minibuffers t))
             (read-file-name
              (format "%s %s to:" prompt source)))))
      (funcall cmd source target 1))))

;;;###autoload
(defun +ivy/confirm-delete-file (x)
  (dired-delete-file x 'confirm-each-subdirectory))

;;;###autoload
(defun *ivy--switch-buffer-action (buffer)
  "Switch to BUFFER.
BUFFER may be a string or nil."
  (with-ivy-window
    (if (zerop (length buffer))
        (display-buffer
         ivy-text nil 'force-same-window)
      (let ((virtual (assoc buffer ivy--virtual-buffers))
            (view (assoc buffer ivy-views)))
        (cond ((and virtual
                    (not (get-buffer buffer)))
               (find-file (cdr virtual)))
              (view
               (delete-other-windows)
               (let (
                     ;; silence "Directory has changed on disk"
                     (inhibit-message t))
                 (ivy-set-view-recur (cadr view))))
              (t
               (display-buffer
                buffer nil 'force-same-window)))))))


;;;###autoload
(defun +ivy/helpful-function (prompt)
  (helpful-function (intern prompt)))


;;;###autoload
(defun evil-mc-mouse-click (event)
  "multi-cursor"
  (interactive "e")
  (let* ((es (event-start event)))
    (goto-char (posn-point es))
    (evil-mc-make-cursor-here)))


;;;###autoload
(defun *colir--blend-background (start next prevn face object)
  (let ((background-prev (face-background prevn)))
    (progn
      (put-text-property
       start next
       (if background-prev
           (cons `(background-color
                   . ,(colir-blend
                       (colir-color-parse background-prev)
                       (colir-color-parse (face-background face nil t))))
                 prevn)
         (list face prevn))
       object))))

;;;###autoload
(defun *colir-blend-face-background (start end face &optional object)
    "Append to the face property of the text from START to END the face FACE.
When the text already has a face with a non-plain background,
blend it with the background of FACE.
Optional argument OBJECT is the string or buffer containing the text.
See also `font-lock-append-text-property'."
    (let (next prev prevn)
      (while (/= start end)
        (setq next (next-single-property-change start 'face object end))
        (setq prev (get-text-property start 'face object))
        (setq prevn (if (listp prev)
                        (cl-find-if #'atom prev)
                      prev))
        (cond
         ((or (keywordp (car-safe prev)) (consp (car-safe prev)))
          (put-text-property start next 'face (cons face prev) nil object))
         ((facep prevn)
          (colir--blend-background start next prevn face object))
         (t
          (put-text-property start next 'face face nil object)))
        (setq start next))))

;;;###autoload
(defun *magit-list-repositories ()
    "Display a list of repositories.

Use the options `magit-repository-directories'
and `magit-repository-directories-depth' to
control which repositories are displayed."
    (interactive)
    (if magit-repository-directories
        (with-current-buffer (get-buffer-create "*Magit Repositories*")
          (magit-repolist-mode)
          (magit-repolist-refresh)
          (tabulated-list-print)
          (pop-to-buffer (current-buffer)))
      (message "You need to customize `magit-repository-directories' %s"
               "before you can list repositories")))

;;;###autoload
(defun +magit/quit (&optional _kill-buffer)
    (interactive)
    (magit-restore-window-configuration)
    (mapc #'kill-buffer (doom-buffers-in-mode 'magit-mode nil t)))

;;;###autoload
(defun *xwidget-webkit-goto-url (url)
    "Goto URL."
    (if (xwidget-webkit-current-session)
        (progn
          (xwidget-webkit-goto-uri (xwidget-webkit-current-session) url)
          (display-buffer xwidget-webkit-last-session-buffer))
      (xwidget-webkit-new-session url)))

(defun *xwidget-webkit-new-session (url)
    "Create a new webkit session buffer with URL."
    (let*
        ((bufname (generate-new-buffer-name "xwidget-webkit"))
         xw)
      (setq xwidget-webkit-last-session-buffer (get-buffer-create bufname))
      (setq xwidget-webkit-created-window (display-buffer xwidget-webkit-last-session-buffer))
      ;; The xwidget id is stored in a text property, so we need to have
      ;; at least character in this buffer.
      ;; Insert invisible url, good default for next `g' to browse url.
      (with-selected-window xwidget-webkit-created-window
        (insert url)
        (put-text-property 1 (+ 1 (length url)) 'invisible t)
        (setq xw (xwidget-insert 1 'webkit bufname
                                 (xwidget-window-inside-pixel-width (selected-window))
                                 (xwidget-window-inside-pixel-height (selected-window))))
        (xwidget-put xw 'callback 'xwidget-webkit-callback)
        (xwidget-webkit-mode)
        (xwidget-webkit-goto-uri (xwidget-webkit-last-session) url))))

;;;###autoload
(defun dirtrack-filter-out-pwd-prompt (string)
  "Remove the PWD match from the prompt."
  (if (and (stringp string) (string-match "^.*AnSiT.*\n.*\n.*AnSiT.*$" string))
      (replace-match "" t t string 0)
    string))
