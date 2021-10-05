;;; conventional-commit.el --- Completion function for writing conventional commits -*- lexical-binding: t -*-

;; Copyright (C) 2021 Akira Komamura

;; Author: Akira Komamura <akira.komamura@gmail.com>
;; Version: 0.1
;; Package-Requires: ((emacs "27.1"))
;; Keywords: convenience vc
;; URL: https://github.com/akirak/conventional-commit.el

;; This file is not part of GNU Emacs.

;;; License:

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; This library provides a `completion-at-point' function for conventional
;; commits <https://www.conventionalcommits.org/en/v1.0.0/>. By adding
;; `conventional-commit-capf' to `completion-at-point-functions' in
;; `git-commit-mode' and `company-capf' to `company-backends', you can get
;; completion of types, which is configured globally, or scopes, which is
;; configured locally.

;;; Code:

(defgroup conventional-commit
  nil
  "Completion function for conventional commits."
  :link '(url-link "https://www.conventionalcommits.org/en/v1.0.0/")
  :group 'completion
  :group 'git-commit-mode)

(defcustom conventional-commit-type-list
  '("feat"
    "fix"
    "build"
    "chore"
    "ci"
    "docs"
    "style"
    "refactor"
    "perf"
    "test")
  "List of types allowed at the beginning of a message.

See <https://github.com/angular/angular/blob/22b96b9/CONTRIBUTING.md#type>
for an example."
  :type '(repeat string))

(defcustom conventional-commit-scope-table nil
  "List of scope names allowed for the project.

It is recommended that you set this as a directory-local variable
in your project.

You can use any completion table as the value. For example, it
can be a list of strings or a dynamic completion table created by
`lazy-completion-table'. See also
`completion-at-point-functions'."
  :type '(or (repeat string)
             function)
  :local t)

;;;###autoload
(defun conventional-commit-capf ()
  "`completion-at-point-functions' entry for conventional commits."
  (when (= 0 (cdr (posn-actual-col-row (posn-at-point (point)))))
    (cond
     ((looking-back (rx bol (+ alpha)) 0)
      (list (match-beginning 0)
            (match-end 0)
            conventional-commit-type-list
            :exclusive t))
     ((looking-back (rx bol (+ alpha) "(" (group (+ (not (any ")"))))) 0)
      (list (match-beginning 1)
            (match-end 1)
            conventional-commit-scope-table
            :exclusive t)))))

;;;###autoload
(defun conventional-commit-setup ()
  "Set up `completion-at-point-functions' for the current buffer."
  (add-hook 'completion-at-point-functions #'conventional-commit-capf
            'append 'local))

(provide 'conventional-commit)
;;; conventional-commit.el ends here
