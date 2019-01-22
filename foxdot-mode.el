;;; foxdot-mode.el --- foxdot interactive mode       -*- lexical-binding: t; -*-

;; Copyright (C) 2018, 2019  nilninull

;; Author: nilninull <nilninull@gmail.com>
;; Keywords: languages

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;;

;; (add-hook 'foxdot-load-hook (lambda ()
;;                               (foxdot-toggle-auto-enable 1)))
;;
;; (add-hook 'foxdot-preparation-hook (lambda ()
;;                                      (sclang-eval-string "FoxDot.start")))

;;; Code:

(require 'elpy)

(defconst foxdot-scratch-buffer-name "*FoxDot*")

;; (define-derived-mode foxdot-mode python-mode "FoxDot"
;;   "Major mode for play FoxDot")

(defvar foxdot-mode-map (make-sparse-keymap))

;;;###autoload
(define-minor-mode foxdot-mode "for playing FoxDot"
  nil
  " FoxDot"
  foxdot-mode-map)

(define-key foxdot-mode-map [(control .)] #'foxdot-clear-clock)
;; (define-key foxdot-mode-map [(control return)] #'foxdot-evaluate-block)
;; (define-key foxdot-mode-map [(alt return)] #'foxdot-evaluate-line)
;; (define-key foxdot-mode-map [(alt return)] #'foxdot-stop-at)
(define-key foxdot-mode-map "\C-c\C-q" #'foxdot-stop-current-line)
(define-key foxdot-mode-map "\C-cQ" #'foxdot-clear-clock)

(defvar foxdot-load-hook nil)

(defvar foxdot-preparation-hook nil)

;;;###autoload
(defun foxdot-start ()
  ""
  (interactive)
  (setq python-shell-interpreter "jupyter"
        python-shell-interpreter-args "console --simple-prompt"
        python-shell-prompt-detect-failure-warning nil
        elpy-company-add-completion-from-shell t)

  (add-to-list 'python-shell-completion-native-disabled-interpreters "jupyter")

  (run-hooks 'foxdot-preparation-hook)

  (setenv "PYFLAKES_BUILTINS" (shell-command-to-string "python -c 'import FoxDot; print(\",\".join(dir(FoxDot)), end=\"\")' | tail -n 1"))

  (with-current-buffer (get-buffer-create foxdot-scratch-buffer-name)
    (python-mode)
    (foxdot-mode)
    (elpy-shell-get-or-create-process)
    (python-shell-send-string "from FoxDot import *")
    (switch-to-buffer-other-window foxdot-scratch-buffer-name)))

(defun foxdot-clear-clock ()
  ""
  (interactive)
  (python-shell-send-string "Clock.clear()"))

;; (defun foxdot-evaluate-block ()
;;   ""
;;   (interactive)
;;   )

;; (defun foxdot-evaluate-line ()
;;   ""
;;   (interactive)
;;   )

(defun foxdot-stop-at ()
  "Evaluate stop() method on the under curosr object."
  (interactive)
  (let ((obj (thing-at-point 'symbol)))
    (python-shell-send-string (format "%s.stop()" obj))))

(defun foxdot-stop-current-line ()
  "Evaluate stop() method on the current line."
  (interactive)
  (let ((obj (thing-at-point 'line)))
    (python-shell-send-string (format "%s.stop()" (s-trim obj)))))

(defun foxdot-insert-import-decl ()
  ""
  (interactive)
  (end-of-line)
  (insert "\nfrom FoxDot import *\n"))

(defun foxdot-toggle-auto-enable (&optional arg)
  ""
  (interactive "P")
  (message "auto foxdot mode %s"
           (if (if arg
                   (> 0 (prefix-numeric-value arg))
                 (memq 'foxdot-mode python-mode-hook))
               (progn
                 (remove-hook 'python-mode-hook 'foxdot-mode)
                 (remove-hook 'inferior-python-mode 'foxdot-mode)
                 "disabled")
             (add-hook 'python-mode-hook 'foxdot-mode)
             (add-hook 'inferior-python-mode 'foxdot-mode)
             "enabled")))

(provide 'foxdot-mode)

(run-hooks 'foxdot-load-hook)
;;; foxdot-mode.el ends here
