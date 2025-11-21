;;; gptel-utils.el --- Some conveniences for gptel, the general LLM interface

;; Copyright (C) 2025 Mark A. Jensen

;; Author: Mark A. Jensen <maj-git@fortinbras.us>
;; Package-Requires: ((emacs "27.1") (gptel "0.9.9"))
;; Keywords: chat, LLM, gptel
;; URL: https://github.com/majensen/gptel-utils

;;SPDX-License-Identifier: GPL-3.0-or-later

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

;; This file is NOT part of GNU Emacs.

;;; Commentary:

;; gptel <https://github.com/karthink/gptel> is a very complete package for
;; chat interaction with almost any LLM.  gptel-utils.el  provides some
;; additional functionality to the gptel package, including the following features:
;;
;; - Autosave of chat buffers (if desired) to a directory of your choice
;; - Quick switch to an open chat buffer
;; - Next/previous navigation among open chat buffers                               
;;

;;; Code:
(defcustom gptel-utils-autosave-dir "~/.gptel/saved-chats/"
  "Directory in which to save gptel chat content."
  :type 'directory)

(defcustom gptel-utils-autosave-chats t
  "If set, automatically save model chats in files
in `gptel-utils-autosave-dir`"
  :type 'boolean)

(defvar gptel-utils-chat-buffer-ring-size 10
  "Size of the gptel chat buffer ring.")

(defvar gptel-utils-chat-buffer-ring (make-ring gptel-utils-chat-buffer-ring-size)
  "Ring of open gptel chat buffers")

(defun gptel-utils-ensure-saved (&rest beg end)
  "Ensure gptel buffer (current) has a file and save it."
  (when (and (gptel-mode) gptel-utils-autosave-chats)
    (unless (buffer-file-name)
      (let* ((timestamp (format-time-string "%Y%m%d-%H%M%S"))
             (extension (if (derived-mode-p 'org-mode) "org" "md"))
             (filename (expand-file-name
                       (format "chat-%s-%s.%s" gptel-model timestamp extension)
                       gptel-utils-autosave-dir)))
        (unless (file-exists-p gptel-utils-autosave-dir)
          (make-directory gptel-utils-autosave-dir t))
        (setq buffer-file-name filename)
        ))
    (write-region (point-min) (point-max) buffer-file-name)
    (set-buffer-modified-p nil)
    ))

(defun gptel-utils--add-chat-buffer ()
  (when gptel-mode
    (when (not (ring-member gptel-utils-chat-buffer-ring (current-buffer)))
      (ring-insert gptel-utils-chat-buffer-ring (current-buffer))
    )))

(defun gptel-utils--rm-chat-buffer ()
  (when (and gptel-mode buffer-file-name)
    (save-buffer))
  (if (not (ring-empty-p gptel-utils-chat-buffer-ring))
      (let ((pos (ring-member
                  gptel-utils-chat-buffer-ring
                  (current-buffer))))
        (if pos (ring-remove gptel-utils-chat-buffer-ring pos)))
    ))

(defun gptel-utils-get-chat-buffers ()
  "Get list of current gptel chat buffers"
  (let* (
         (bufs (buffer-list))
         (ch-bufs (seq-filter
                   (lambda (b) (buffer-local-value 'gptel-mode b))
                   bufs))
         )
    ch-bufs
    ))

;;;###autoload
(defun gptel-utils-switch-to-chat (idx)
  (interactive "p")
  (when (not (buffer-local-value 'gptel-mode
                                 (current-buffer)))
    (if (not idx)
        (setq idx 0))
    (if (ring-empty-p gptel-utils-chat-buffer-ring)
        (message "No chats open")
      (switch-to-buffer (ring-ref gptel-utils-chat-buffer-ring idx))
      )))

;;;###autoload
(defun gptel-utils-next-chat ()
  (interactive)
  (if (buffer-local-value 'gptel-mode (current-buffer))
      (switch-to-buffer (ring-next gptel-utils-chat-buffer-ring (current-buffer)))
    ))

;;;###autoload
(defun gptel-utils-prev-chat ()
  (interactive)
  (if (buffer-local-value 'gptel-mode (current-buffer))
      (switch-to-buffer (ring-previous gptel-utils-chat-buffer-ring (current-buffer)))
    ))

;;;###autoload
(defun gptel-utils-restore-chat (chatfile)
  "Open a previously saved chat"
  (interactive
   (list (read-file-name "Chat: " gptel-utils-autosave-dir "")))
  (when (not (eq chatfile ""))
    (find-file chatfile)
    (gptel-mode)))


;;; gptel-utils.el ends here
