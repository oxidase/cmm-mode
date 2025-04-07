;; -*- mode: emacs-lisp; lexical-binding: t -*-
;;; comamo-mode-el -- Major mode for editing Command Macro Module scripts

;; Author: Michael Krasnyk <michael.krasnyk@gmail.com>
;; Created: 7 Apr 2025

;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:
;;
;; This mode is used for editing Command Macro Module scripts.

;;; Code:

(require 'regexp-opt)

(defvar comamo-mode-hook nil)
(defvar comamo-mode-map
  (let ((map (make-sparse-keymap)))
    map)
  "Keymap for CMM major mode.")

(defun comamo--word (str)
  "Wrap STR with \< and \> to make it break on word boundaries."
  (concat "\\<" str "\\>"))

(eval-and-compile
(defun comamo--get-strings (name)
  (let* ((src (or load-file-name byte-compile-current-file (buffer-file-name)))
         (dir (when src (file-name-directory (file-truename src)))))
    (with-temp-buffer
      (insert-file-contents (expand-file-name name (concat dir "resources")))
      (split-string (buffer-string) "\n" t))
  )))


(defconst comamo--internal-keywords (eval-when-compile (regexp-opt (comamo--get-strings "internal.keywords") t)))
(defconst comamo--general-keywords-1 (eval-when-compile (regexp-opt (comamo--get-strings "general_ref1.keywords") t)))
(defconst comamo--general-keywords-2 (eval-when-compile (regexp-opt (comamo--get-strings "general_ref2.keywords") t)))
(defconst comamo--general-keywords-3 (eval-when-compile (regexp-opt (comamo--get-strings "general_ref3.keywords") t)))
(defconst comamo--general-keywords-4 (eval-when-compile (regexp-opt (comamo--get-strings "general_ref4.keywords") t)))
(defconst comamo--ide-keywords (eval-when-compile (comamo--get-strings "ide_ref.keywords")))
(defconst comamo--variable-regexp "&\\w+")
(defconst comamo--constant-regexp "%\\w+")
(defconst comamo--label-regexp "\\w+:")
(defconst comamo--hex-address-regexp "0x[[:xdigit:]]+")
(defconst comamo--builtins
  '("TRUE"
    "FALSE"))


(defvar comamo-font-lock-keywords
  (append
   `((,(comamo--word comamo--internal-keywords) . font-lock-keyword-face)
     (,(comamo--word comamo--general-keywords-1) . font-lock-type-face)
     (,(comamo--word comamo--general-keywords-2) . font-lock-type-face)
     (,(comamo--word comamo--general-keywords-3) . font-lock-type-face)
     (,(comamo--word comamo--general-keywords-4) . font-lock-type-face)
     (,(comamo--word (regexp-opt comamo--ide-keywords t)) . font-lock-constant-face)
     (,(comamo--word (regexp-opt comamo--builtins t)) . font-lock-builtin-face)
     (,comamo--variable-regexp . font-lock-variable-name-face)
     (,comamo--constant-regexp . font-lock-constant-face)
     (,comamo--label-regexp . font-lock-constant-face)
     (":NONE" . font-lock-warning-face)
     )
   )
  )

(defvar comamo-mode-syntax-table
  (let ((syntax-table (make-syntax-table)))
    ;; Semicolon comments
    (modify-syntax-entry ?\; "<" syntax-table)
    (modify-syntax-entry ?\/ ". 124" syntax-table)
    (modify-syntax-entry ?* ". 23b" syntax-table)
    (modify-syntax-entry ?\n ">" syntax-table)

    (modify-syntax-entry ?_ "w" syntax-table)
    syntax-table))

(defgroup cmm nil
  "Major mode for editing CMM scripts"
  :group 'languages)

(defun comamo-mode ()
  "Major mode for editing CMM script files."
  (interactive)

  ;; Syntax
  (set-syntax-table comamo-mode-syntax-table)

  ;; Font lock
  (setq-local font-lock-keywords-case-fold-search t)
  (set (make-local-variable 'font-lock-defaults) '(comamo-font-lock-keywords))

  ;; Comments
  (setq-local comment-start ";")
  (setq-local comment-start-skip "\\(;+\\|//+\\)\\s-*")
  (setq-local comment-end "")
  (setq-local comment-use-syntax t)

  ;; Indentation
  ; (set (make-local-variable 'indent-line-function) 'comamo-indent-line)

  (setq major-mode 'comamo-mode)
  (setq mode-name "CMM")
  (run-hooks 'comamo-mode-hook)
  (font-lock-ensure))

;;;###autoload
(add-to-list 'auto-mode-alist (cons "\\.cmm\\'" 'comamo-mode))

(provide 'comamo-mode)

;; (eval-when-compile
;;   (message "Generating code before byte-compilation")
;;   ;; Possibly create or validate other files
;;   )

;;; comamo-mode.el ends here
