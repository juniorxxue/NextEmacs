;; -*- lexical-binding: t -*-
;; ---------------- MY CONFIG ----------------------------------------
(package-initialize)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

;;; On-demand installation of packages
(require 'cl-lib)
(defun require-package (package &optional min-version no-refresh)
  "Install given PACKAGE, optionally requiring MIN-VERSION.
If NO-REFRESH is non-nil, the available package lists will not be
re-downloaded in order to locate PACKAGE."
  (or (package-installed-p package min-version)
      (let* ((known (cdr (assoc package package-archive-contents)))
             (versions (mapcar #'package-desc-version known)))
        (if (cl-find-if (lambda (v) (version-list-<= min-version v)) versions)
            (package-install package)
          (if no-refresh
              (error "No version of %s >= %S is available" package min-version)
            (package-refresh-contents)
            (require-package package min-version t))))))

;; custom.el
;; check: package-autoremove
(package-initialize)
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(unless (file-exists-p custom-file)
  (write-region "" nil custom-file))

;; $PATH
(require-package 'exec-path-from-shell)
(require 'exec-path-from-shell)
(when (memq window-system '(mac ns x))
  (exec-path-from-shell-initialize))

;; Path to nano emacs modules (mandatory)
(add-to-list 'load-path "/Users/xuxue/.emacs.d/nano-emacs")
(add-to-list 'load-path ".")

(setq-default cursor-type 'bar)

;; counsel
(require-package 'counsel)
(require-package 'smex)

;; proof general
(require-package 'proof-general)
(setq proof-splash-enable nil)
(setq proof-next-command-insert-space nil)

(require-package 'company)

(setq company-coq-live-on-the-edge t)
(require-package 'company-coq)
(add-hook 'coq-mode-hook #'company-coq-mode)
(add-hook 'coq-mode-hook (lambda ()
                           ;; fix broken faces
                           (set-face-attribute 'coq-solve-tactics-face nil
                                               :foreground "#00008b")
                           (setq coq-compile-before-require 't)
                           ))

(eval-after-load "proof-script"
  '(progn
     (define-key proof-mode-map (kbd "M-n")
         'proof-assert-next-command-interactive)
     (define-key proof-mode-map (kbd "<C-return>")
       'proof-goto-point)
     (define-key proof-mode-map (kbd "M-p")
       'proof-undo-last-successful-command)))

;; advise M-n
(add-hook 'coq-mode-hook (lambda ()
                           (advice-add 'proof-assert-next-command-interactive
                                       :after (lambda (&optional ARG PRED)
                                                (skip-chars-backward " \t\n")))))


(require-package 'drag-stuff)
(require 'drag-stuff)
(drag-stuff-global-mode 1)
(drag-stuff-define-keys)

(require-package 'projectile)
(projectile-mode +1)
(define-key projectile-mode-map (kbd "s-p") 'projectile-command-map)
(define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)



;; ---------------- MY CONFIG ----------------------------------------

;; Default layout (optional)
(require 'nano-layout)

;; Theming Command line options (this will cancel warning messages)
(add-to-list 'command-switch-alist '("-dark"   . (lambda (args))))
(add-to-list 'command-switch-alist '("-light"  . (lambda (args))))
(add-to-list 'command-switch-alist '("-default"  . (lambda (args))))
(add-to-list 'command-switch-alist '("-no-splash" . (lambda (args))))
(add-to-list 'command-switch-alist '("-no-help" . (lambda (args))))
(add-to-list 'command-switch-alist '("-compact" . (lambda (args))))


(cond
 ((member "-default" command-line-args) t)
 ((member "-dark" command-line-args) (require 'nano-theme-dark))
 (t (require 'nano-theme-light)))

;; Customize support for 'emacs -q' (Optional)
;; You can enable customizations by creating the nano-custom.el file
;; with e.g. `touch nano-custom.el` in the folder containing this file.
(let* ((this-file  (or load-file-name (buffer-file-name)))
       (this-dir  (file-name-directory this-file))
       (custom-path  (concat this-dir "nano-custom.el")))
  (when (and (eq nil user-init-file)
             (eq nil custom-file)
             (file-exists-p custom-path))
    (setq user-init-file this-file)
    (setq custom-file custom-path)
    (load custom-file)))

;; Theme
(require 'nano-faces)
(nano-faces)

(require 'nano-theme)
;; (require 'nano-theme-dark)
(nano-theme)
;; (nano-theme-set-dark)


;; Nano default settings (optional)
(require 'nano-defaults)

;; Nano session saving (optional)
(require 'nano-session)

;; Nano header & mode lines (optional)
(require 'nano-modeline)

;; Nano key bindings modification (optional)
(require 'nano-bindings)

;; Compact layout (need to be loaded after nano-modeline)
(when (member "-compact" command-line-args)
  (require 'nano-compact))
  
;; Nano counsel configuration (optional)
;; Needs "counsel" package to be installed (M-x: package-install)
(require 'nano-counsel)

;; Welcome message (optional)
(let ((inhibit-message t))
  (message "Welcome to GNU Emacs / N Λ N O edition")
  (message (format "Initialization time: %s" (emacs-init-time))))

;; Splash (optional)
(require 'nano-splash)

;; Help (optional)
(unless (member "-no-help" command-line-args)
  (require 'nano-help))
