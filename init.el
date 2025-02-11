(message "package-user-dir: '%s'" package-user-dir)
(setq debug-on-error t)

(if (version< emacs-version "28.0")
    (message "OLD EMACS")
  (message "RECENT EMACS"))


(require 'package)
(message "After require package package-user-dir: '%s'" package-user-dir)


(package-initialize)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(message "after package-initialize: package-user-dir: '%s'" package-user-dir)

(unless (package-installed-p 'use-package)
  (message "Installing use-package")
  (package-refresh-contents)
  (package-install 'use-package))
(eval-when-compile (require 'use-package))

(message "package-user-dir: '%s'" package-user-dir)

;; Define 'leader-key': SPC in normal mode
(define-prefix-command 'leader-key)

;; Remember place like Vim
(save-place-mode)

(message "use-package : evil")
;; Install and configure 'evil-mode'
;; There is an error Eager macro-expansion failure: (wrong-number-of-arguments (2 . 2) 4)
;; somewhere in here but I don't know where it comes from
(use-package evil :ensure t
  :init
  (setq evil-want-C-i-jump nil)
  (setq evil-want-integration t)
  (setq evil-want-C-u-scroll t)
  :config
  (evil-mode 1)
  (define-key evil-normal-state-map (kbd "SPC") 'leader-key)
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)
  ;; Because it is a prefix global map, when in normal mode,
  ;; it does all kinds of weird stuff.  I therefore us
  (global-unset-key (kbd "ESC"))
  ;; For some reason ESC seems like it isn't mapped to take me out
  ;; of insert-mode.
  (define-key evil-insert-state-map (kbd "ESC") 'evil-normal-state)
  (define-key evil-visual-state-map (kbd "ESC") 'evil-normal-state)
  (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
  (add-hook 'with-editor-mode-hook 'evil-insert-state))

(message "use-package : which-key")
(use-package which-key :ensure t :delight
  :init
  (setq which-key-separator " ")
  (setq which-key-prefix-prefix "+")
  (setq which-key-idle-delay 0.5)
  :config
  (which-key-mode))

;; Install and configure helm
(message "use-package : helm")
(use-package helm :ensure t
  :bind (("M-x" . helm-M-x)
         ("C-x C-f" . helm-find-files)
         ("C-x C-r" . helm-recentf)
         ("C-h C-i" . helm-info)
         ("C-x C-b" . helm-buffers-list)
         ("C-c g" . helm-grep-do-git-grep))
  :config
  (setq helm-move-to-line-cycle-in-source nil)
  (helm-mode 1))

;; Define leader key mappings
(define-key leader-key (kbd "SPC") 'helm-M-x)
;; Files
(defun open-emacs-config-file () (interactive) (find-file "~/.emacs.d/init.el"))
(defun open-master-emacs-config-file () (interactive) (find-file "~/Repositories/github.com/philippecarphin/emacs.d/config.org"))
(define-prefix-command 'files)
(define-key leader-key (kbd "f") 'files)
(define-key files (kbd "c") 'open-emacs-config-file)
(define-key files (kbd "C") 'open-master-emacs-config-file)
(define-key files (kbd "f") 'helm-find-files)
(define-key files (kbd "r") 'helm-recentf)
(define-key files (kbd "s") 'save-buffer)
;; Buffers
(define-prefix-command 'buffers)
(define-key leader-key (kbd "b") 'buffers)
(define-key buffers (kbd "b") 'helm-buffers-list)
(define-key buffers (kbd "k") 'kill-buffer)
;; Others
(define-key leader-key (kbd "q") 'save-buffers-kill-emacs)

;; Scrolling behavior
(setq scroll-step 1) ;; Normal behavior is to jump by half a screen when the
;; cursor reaches the edge which is annoying

(setq-default scroll-margin 10) ;; Same as vim scrolloff setting

;; Auto hard-wrap at 80 chars.  I only use emacs for orgmode and exporting
;; so I always want to have autofill on.
(setq-default auto-fill-function 'do-auto-fill)
(setq-default fill-column 80)

;; (setq vc-follow-symlinks t)

(use-package org :defer t
  :config
  ;; Centrer le curseur dans l'écran après avoir fait shift-TAB
  (advice-add 'org-global-cycle :after #'recenter)
  ;; Mettre le curseur au début de la ligne après avoir fait shift-TAB
  (advice-add 'org-global-cycle :after #'org-beginning-of-line)
  ;; In the terminal, there is a problem with 'C-,' where the application seems
  ;; to just receive ','.  When doing the default key binding 'C-c C-,', the
  ;; application just receives 'C-c ,'.  Since I never use what 'C-c ,' does,
  ;; I rebind it to do what 'C-c C-,' normally does.
  (define-key org-mode-map (kbd "C-c ,") 'org-insert-structure-template))
