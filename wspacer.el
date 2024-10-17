;;; wspacer.el --- Simple code styling tools

;; Author: Nicholas Tsaplev
;; Keywords: cpp
;; Version: 0.0.1

;;; Commentary:
;; A few functions to help format cpp code

;;; Code:

(defun wsp-tabs-to-spaces (spaces-in-tab)
  "Replace all tabs in the current buffer with SPACES-IN-TAB spaces."
  (interactive "nNumber of spaces in a tab: ")
  (goto-char (point-min))
  (while (and (search-forward "\n" nil t) (char-after))
    (while (= (char-after) ?\t)
      (delete-char 1)
      (insert (make-string spaces-in-tab ?\s))
      )
    )
  )


(defun wsp-spaces-to-tabs (spaces-in-tab)
  "Replace all tabulation spaces in the current buffer with tabs.
SPACES-IN-TAB spaces into one tab character."
  (interactive "nNumber of spaces in a tab: ")
  (goto-char (point-min))
  (while (and (search-forward "\n" nil t) (char-after))
    (defvar space-counter 0)
    (while (= (char-after) ?\s)
      (delete-char 1)
      (setq space-counter (+ space-counter 1))
      )
    (insert (make-string (/ space-counter spaces-in-tab) ?\t))
    )
  )

(defun line-empty (line)
  "Return t if LINE is composed of spaces, newlines and tabs.  nil otherwise."
  (if (= (length line) 0) t
    (if (or (= (seq-elt line 0) ?\s)
            (= (seq-elt line 0) ?\t)
            (= (seq-elt line 0) ?\n)
            )
        (line-empty (seq-drop line 1))
      nil)
    )
  )

(defun wsp-delete-empty-lines ()
  "Make all lines in the current buffer with only whitespaces/tabs empty."
  (interactive)
  (goto-char (point-min))
  (while (and (search-forward "\n" nil t) (char-after))
    (if (line-empty (thing-at-point `line))
        (while (and (char-after) (not (= (char-after) ?\n))) (delete-char 1))
      )
    )
  )

(defun wsp-replace-all (replacing replacement)
  "Replace all occurences of REPLACING with REPLACEMENT in the current buffer."
  
  (goto-char (point-min))
  (while (search-forward replacing nil t)
    (replace-match replacement))
  )

(defun wsp-fix-operators-cpp ()
  "Replace op( with op ( for some cpp operators."
  (interactive)
  (wsp-replace-all "for(" "for (")
  (wsp-replace-all "if(" "if (")
  (wsp-replace-all "while(" "while (")
  
  )

(defun wsp-run-linter (filepath)
  "Execute cpplint on FILEPATH file.
Show the output in a new window to right of the current one."
  (interactive (list
                (read-string "Filename to check against google codestyle: " (buffer-name (current-buffer)
                                                                                         ))))

  (defconst linter-buffer-name (concat "lint-" filepath))

  
  (when (get-buffer linter-buffer-name)
      (seq-do #'delete-window (get-buffer-window-list linter-buffer-name))
      (kill-buffer (get-buffer linter-buffer-name))
      )
    
  (get-buffer-create linter-buffer-name)
    
  
  (defconst old-window (selected-window))
  (select-window (split-window nil nil 'right))
  
  
 
  (set-buffer linter-buffer-name)
  (insert (shell-command-to-string (concat "cpplint ./" filepath))
          )
  (read-only-mode)
  (switch-to-buffer linter-buffer-name)

  (select-window old-window)
  
  )

(defvar wspacer-menu-bar-menu (make-sparse-keymap "Spaces & tabs"))
(define-key global-map [menu-bar wspacer-menu] (cons "Spaces & tabs" wspacer-menu-bar-menu))

(define-key wspacer-menu-bar-menu [tabs-to-spaces]
            '(menu-item "Convert tabs into spaces" wsp-tabs-to-spaces :help "Replaces all tabs in the buffer with amount of spaces provided"))
(define-key wspacer-menu-bar-menu [spaces-to-tabs]
            '(menu-item "Convert spaces into tabs" wsp-spaces-to-tabs :help "Replaces all tabulation spaces in the buffer with tabs"))
(define-key wspacer-menu-bar-menu [delete-empty-lines]
            '(menu-item "Empty the empty lines" wsp-delete-empty-lines :help "Makes all lines with only whitespaces/tabs empty"))
(define-key wspacer-menu-bar-menu [fix-operators-cpp]
            '(menu-item "Fix missing ( as in if(" wsp-fix-operators-cpp :help "Replaces op( with op ( for some cpp operators"))
(define-key wspacer-menu-bar-menu [run-linter-cpp]
            '(menu-item "Check codestyle" wsp-run-linter :help "Checks compliance with google codestyle"))




;(define-key wspacer-menu-bar-menu [my-cmd2]
;  '(menu-item "My Command 2" my-cmd2 :help "Do what my-cmd2 does"))
(provide 'wspacer)
;;; wspacer.el ends here
