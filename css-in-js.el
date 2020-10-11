;;; css-in-js.el --- A minor mode used for CSS-in-JS -*- lexical-binding: t; -*-

;;; Version: 1.0.0

;;; Author: Dan Orzechowski

;;; URL: https://github.com/orzechowskid/css-in-js.el

;; Package-Requires: ((mmm-mode "20200908.2236") (scss-mode "20180123.1708"))

;;; License: GPLv3

;;; Commentary:
;; A minor mode for webapps that use css-in-js libraries like styled-components or emotion.  Based on `scss-mode' and `mmm-mode'.  Enable it with `M-x css-in-js-mode [RET]'.
;; Alternately, add a mode hook for your preferred major mode to automatically enable this mode when opening files:
;;
;; (add-hook 'js-mode-hook (lambda () (css-in-js-mode t)))
;;
;; Indentation is controlled by the value of `css-indent-offset'.

;;; Code:


;; dependencies


(require 'smie)

(require 'mmm-mode)
(require 'scss-mode)


;; internals


;; there has got to be a better way to do this
(defun css-in-js--do-indent ()
  "Internal function.  You probably don't want to call this directly."

  (let ((external-offset ;; indentation of the line before our region
         (save-excursion
           (goto-char (- (overlay-start mmm-current-overlay) 1))
           (back-to-indentation)
           (current-column)))
        (base-offset ;; indentation for first line of CSS
         (save-excursion
           (goto-char (overlay-start mmm-current-overlay))
           (back-to-indentation)
           (current-column))))
    (save-restriction
      ;; temporarily narrow our buffer to only include the important bits
      (narrow-to-region (overlay-start mmm-current-overlay) (overlay-end mmm-current-overlay))
      ;; remove all leading whitespace for all lines, or else smie gets heartburn
      (indent-rigidly (point-min) (point-max) (- base-offset))
      ;; indent the line (finally!)
      (smie-indent-line)
      ;; put back the right amount of leading whitespace for all lines
      (indent-rigidly (point-min) (point-max) (+ external-offset css-indent-offset)))))


(define-derived-mode css-in-js--mmm-mode scss-mode "style"
  "Internal function.  You probably want `css-in-js-mode' instead."

  (setq indent-line-function 'css-in-js--do-indent))


(defvar css-in-js--mmm-classes-alist
  '(
    ;; styled-components, emotion
    (css-in-js--styled-components-class
     :submode css-in-js--mmm-mode
     :face font-lock-string-face
     :creation-hook (lambda () (mmm-set-local-variables nil nil))
     :front "\\(styled\\|css\\)[.()<>[:alnum:]]?+`"
     :front-offset 1
     :back "`;"
     :back-offset -1)
    ;; styled-jsx
    (css-in-js--styled-jsx-class
     :submode css-in-js--mmm-mode
     :face font-lock-string-face
     :creation-hook (lambda () (mmm-set-local-variables nil nil))
     :front "<style jsx[[:blank:][:alnum:]]?+>{`"
     :front-offset 1
     :back "`}"
     :back-offset -1))
  "Internal variable.")

(defvar css-in-js--ext-classes-alist
  '(
    (nil nil css-in-js--styled-components-class)
    (nil nil css-in-js--styled-jsx-class))
  "Internal variable.")

(defvar css-in-js--manage-mmm nil
  "Internal variable.")


(defun css-in-js--capf ()
  "Internal function."

  ;; Autocompletion in `css-mode' is correctly triggered for CSS *selectors* on the first line of a managed buffer, but is not triggered for CSS *property names*.  Which is fair; that's not valid [S]CSS, but it IS valid for styled-components.  This is a poor attempt to address that shortcoming
  (when
      (and
       (boundp 'mmm-current-submode)
       (eq mmm-current-submode 'css-in-js--mmm-mode))
    (save-excursion
      ;; most of this was lifted from css-mode and just modified to return completion candidates if we end up at beginning of buffer
      (let ((pos (point)))
        (skip-chars-backward "-[:alnum:]")
        (let ((start (point)))
          (save-restriction
            (narrow-to-region (overlay-start mmm-current-overlay) (overlay-end mmm-current-overlay))
            (skip-chars-backward " \t\r\n")
            (when (bobp) ;; beginning of "buffer", aka the narrowed region
              (list start pos css-property-ids))))))))


;; set up mmm-mode


;; don't let css-mode's capf to spill over into the rest of the buffer (this one isn't in `mmm-save-local-variables' by default)
(add-to-list 'mmm-save-local-variables '(completion-at-point-functions))
;; add each of our custom subregion definitions to mmm-mode's list
(dolist (cls css-in-js--mmm-classes-alist)
  (add-to-list 'mmm-classes-alist cls))


(defun css-in-js--setup ()
  "Internal function."

  (message "enabling...")
  (make-local-variable 'mmm-mode-ext-classes-alist)
  (dolist (cls css-in-js--ext-classes-alist)
    (add-to-list 'mmm-mode-ext-classes-alist cls))
  (unless mmm-mode
    (setq css-in-js--manage-mmm t)
    (mmm-mode t)))


(defun css-in-js--teardown ()
  "Internal function."

  (dolist (cls css-in-js--ext-classes-alist)
    (setq mmm-mode-ext-classes-alist (delete cls mmm-mode-ext-classes-alist)))
  (when css-in-js--manage-mmm
    (mmm-mode -1)))


;; the actual minor mode


;;;###autoload
(define-minor-mode css-in-js-mode
  "Minor mode for editing css-in-js."

  nil nil nil

  (if css-in-js-mode ; automatically managed for us.  t if enabling, nil otherwise
      (css-in-js--setup)
    (css-in-js--teardown)))


(provide 'css-in-js)


;;; css-in-js ends here
