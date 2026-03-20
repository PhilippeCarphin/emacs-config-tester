;;;;;;;;;;;;;;;;;;;;;;;;;; Faciliter l'installation de packages ;;;;;;;;;;;;;;;;
(require 'package)
;; from https://gnu.emacs.bug.narkive.com/GK4dLaQT/bug-36725-26-1-emacs-can-t-connect-to-gnu-elpa
;; Older emacs may need this line uncommented otherwise connection to GNU
;; elpa may not work
;; (setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3")
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t)
(add-to-list 'package-archives '("org"   . "http://orgmode.org/elpa/") t)
(add-to-list 'package-archives '("gnu"   . "http://elpa.gnu.org/packages/") t)
(add-to-list 'package-archives '("gnu-devel" "https://elpa.gnu.org/devel/") t)
(package-initialize)
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(eval-when-compile (require 'use-package))
;;;;;;;;;;;;;;;;;;;;; Petites configs ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Choisis celui que tu aimes en faisant Alt-x load-theme ENTER TAB
(load-theme 'misterioso)
(defun open-emacs-init-file () (interactive) (find-file "~/.emacs.d/init.el"))

;;;;;;;;;;;;;;;;;;;;; Packages qui améliorent notre vie ;;;;;;;;;;;;;;;;;;;;;;;;
(use-package helm :ensure t
  :bind (("M-x" . helm-M-x)
         ("C-x C-f" . helm-find-files)
         ("C-x C-r" . helm-recentf)
         ("C-h C-i" . helm-info)
         ("C-x b" . helm-buffers-list)
         ("C-c g" . helm-grep-do-git-grep)))
(helm-mode)

(use-package which-key
  :ensure t
  :delight
  :init (setq which-key-separator " ")
  (setq which-key-prefix-prefix "+")
  (setq which-key-idle-delay 0.5)
  :config (which-key-mode))

;;;;;;;;;;;;;;;;;;;;;;;;; Org mode ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Centrer le curseur après shift-TAB
(defun my/org-post-global-cycle () (interactive)
       (recenter)
       (org-beginning-of-line))
(advice-add 'org-cycle-global :after #'my/org-post-global-cycle)

;; J'aime que mes documents org commencent complètement collapsés
(custom-set-variables '(org-startup-folded t))

;; Rouler des commandes shell direct dans un document org
(org-babel-do-load-languages 'org-babel-load-languages
                             '((shell . t)
                               (python . t)))

;; Don't prompt when evaluating org source blocks
;; (setq org-confirm-babel-evaluate nil)

;; Indentation visuelle des noeuds de l'arbre
;; (add-hook 'org-mode-hook (lambda () (electric-indent-mode 0) (org-indent-mode 1)))

;; Orgmode, please don't mess with me by indenting source blocks.
(setq org-edit-src-content-indentation 0)

;; Configure refile (don't worry about it)
(setq org-outline-path-complete-in-steps nil)
(setq org-refile-use-outline-path 'file)
(setq org-refile-allow-creating-parent-nodes 'confirm)

;;;;;;;;;;;;;;;;;;;;;;;;; Agenda ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Liste de fichiers org qui devraient être regardés par l'agenda
(setq my/org-agenda-dir "~/Documents/gtd")
(setq org-agenda-files (list my/org-agenda-dir))

;; Prompt for closing notes when change from a not-done state to a done state
(setq org-log-done 'note)

;; A modifier selon tes désirs.  Tout ça c'est parce qu'on pourra définir
;; des raccourcis à partir de ce qui est défini ici.
(setq gtd-in-tray-file (concat my/org-agenda-dir "/" "GTD_InTray.org")
      gtd-next-actions-file (concat my/org-agenda-dir "/" "GTD_NextActions.org")
      gtd-reference-file (concat my/org-agenda-dir "/" "GTD_Reference.org")
      gtd-project-list-file (concat my/org-agenda-dir "/" "GTD_ProjectList.org"))
(defun gtd-open-in-tray              () (interactive) (find-file gtd-in-tray-file))
(defun gtd-open-project-list         () (interactive) (find-file gtd-project-list-file))
(defun gtd-open-reference            () (interactive) (find-file gtd-reference-file))
(defun gtd-open-next-actions         () (interactive) (find-file gtd-next-actions-file))

;; Entrer quelque chose dans In Tray
(setq org-capture-templates
      '(("i" "GTD Input" entry
         (file gtd-in-tray-file)
         "* GTD-IN %?\n %i\n %a" :kill-buffer t :hook evil-insert-state)))
(defun org-capture-input () (interactive) (org-capture nil "i"))

;; Refile targets: current file + org-agenda-files
(setq org-refile-targets '((nil :maxlevel . 3) (org-agenda-files :maxlevel . 3)))

;; Display des items dans l'agenda
(setq org-agenda-prefix-format  '((agenda . "    %-12t%-12s")))
(setq org-agenda-time-grid '((daily today require-timed)
                             (800 900 1000 1100 1200 1300 1400 1500 1600 1700 1800)
                             "......" "----------------"))

;; Définir des todo keywords additionnels éventuellement
(setq org-todo-keywords '((sequence "TODO(!@)" "|" "DONE(!@)")
                          (sequence "GTD-ACTION(a)"
                                    "GTD-IN(i)"
                                    "GTD-CLARIFY(c)"
                                    "GTD-PROJECT(p)"
                                    "GTD-DORMANT(O)"
                                    "GTD-SOMEDAY-MAYBE(s)"
                                    "GTD-NEXT-ACTION(n)"
                                    "GTD-WAITING(w)"
                                    "|"
                                    "GTD-REFERENCE(r!)"
                                    "GTD-DELEGATED(g)"
                                    "GTD-DONE(d)")
                          (sequence "HABIT(h)" "|" "done-habit(x!)")
                          (sequence "APPOINTMENT(p)"
                                    "MEETING(m)"
                                    "EVENT(e)"
                                    "|" )))

;; Définir l'aspect visuel des différents TODO keywords
(setq org-todo-keyword-faces
      '(("GTD-IN" :foreground "#ff8800" :weight normal :underline t :size small)
        ("GTD-PROJECT" :foreground "#0088ff" :weight bold :underline t)
        ("GTD-DORMANT" :foreground "#7c7c74" :weight bold :underline nil)
        ("GTD-ACTION" :foreground "#0088ff" :weight normal :underline nil)
        ("GTD-NEXT-ACTION" :foreground "#0088ff" :weight bold :underline nil)
        ("GTD-WAITING" :foreground "#aaaa00" :weight normal :underline nil)
        ("GTD-REFERENCE" :foreground "#00ff00" :weight normal :underline nil)
        ("GTD-SOMEDAY-MAYBE" :foreground "#7c7c74" :weight normal :underline nil)
        ("GTD-DONE" :foreground "#00ff00" :weight normal :underline nil)

        ("HABIT" :foreground "#7c7c74" :weight bold :underline nil)

        ("MEETING" :foreground "#5faf00" :weight bold :underline nil)
        ("EVENT" :foreground "#5faf00" :weight bold :underline nil)
        ("APPOINTMENT" :foreground "#5faf00" :weight bold :underline nil)))
(setq org-stuck-projects
      '("TODO=\"GTD-PROJECT\"" ;; Search query
        ("GTD-NEXT-ACTION" "GTD-WAITING")    ;; Not stuck if contains
        ()                     ;; Stuck if contains
        ""))                   ;; General regex

(setq org-agenda-span 9
      org-agenda-start-on-weekday 0
      org-agenda-start-day "-2d")

(setq org-agenda-custom-commands
      '(("a" "Agenda"
         ((agenda "" ((org-agenda-skip-function '(org-agenda-skip-entry-if 'todo 'done))))))
        ("N" "Project Next Actions"
         ((todo "GTD-NEXT-ACTION" ((org-agenda-prefix-format
                                    '((todo . "%(my/org-path-from-todo-keyword \"GTD-PROJECT\")\n    > ")))))))
        ("c" "Complete agenda view"
         ((tags "PRIORITY=\"A\"" ((org-agenda-skip-function '(org-agenda-skip-entry-if 'todo 'done))))
          (tags "PRIORITY=\"C\"" ((org-agenda-skip-function '(org-agenda-skip-entry-if 'todo 'done))))
          (stuck "")
          (agenda "" ((org-agenda-start-day ".")
                      (org-agenda-span 'day)
                      (org-agenda-skip-function '(org-agenda-skip-entry-if 'todo 'done))))
          (todo "GTD-ACTION" ((org-agenda-files (list gtd-next-actions-file))
                              (org-agenda-prefix-format '((todo . " ")))
                              (org-agenda-skip-function '(org-agenda-skip-entry-if 'scheduled 'deadline))))
          (todo "GTD-WAITING" ((org-agenda-prefix-format '((todo . "vvvvvvvvvvv [WAITING_ON:%(org-entry-get (point) \"WAITING_ON\")]\n ")))))))
        ("s" "Split agenda view"
         ((agenda "" ((org-agenda-skip-function '(org-agenda-skip-entry-if 'scheduled 'deadline))))
          (agenda "" ((org-agenda-skip-function '(org-agenda-skip-entry-if 'notscheduled))))
          (agenda "" ((org-agenda-skip-function '(org-agenda-skip-entry-if 'notdeadline))))))
        ("h" "Habits" tags "STYLE=\"habit\"" ((org-agenda-prefix-format " ")
                                              (org-habit-graph-column 30)
                                              (org-agenda-overriding-header "Habits")))
        ("g" . "GTD keyword searches searches")
        ("gt" todo "TODO")
        ("gi" todo "GTD-IN")
        ("gc" todo "GTD-CLARIFY")
        ("ga" todo "GTD-ACTION")
        ("gw" todo "GTD-WAITING")
        ("gn" todo-tree "GTD-NEXT-ACTION")
        ("gp" todo "GTD-PROJECT")))

(defun my/org-get-parent (e)
  (plist-get (car (cdr e)) :parent))
(defun my/org-path-from-todo-keyword (todo-keyword)
  "Create a string that reprensents a path to the current headline from the
first ancestor headline whose TODO keyword is TODO-KEYWORD.

When called interactively, the user is prompted for the TODO keyword."
  (interactive "sTodo keyword please ")
  (let ((eap (org-element-at-point))
        (path ""))
    (while (not (string-equal (car eap) "headline"))
      (setq eap (my/org-get-parent eap)))
    (while (and eap (not (string-equal (plist-get (car (cdr eap)) :todo-keyword) todo-keyword)))
      (setq eap (my/org-get-parent eap))
      (setq path (concat (plist-get (car (cdr eap)) :raw-value) "/" path))
      (when (string-equal (car eap) "org-data")
        (setq eap nil)
        (setq path (format "*Not inside a %s*" todo-keyword))))
    path))

(setq org-fold-show-context-detail
      '((occur-tree . ancestors)
        (default . local)))

;;; Habits
(add-to-list 'org-modules 'org-habit)
(eval-after-load 'org
  '(org-load-modules-maybe t))

;; Change habit display
(setq org-habit-graph-column 60)
(setq org-habit-show-habits-only-for-today t)
(setq org-log-into-drawer t)
(setq org-treat-insert-todo-heading-as-state-change t)
;; This code from https://emacs.stackexchange.com/a/17328/19972 solves makes
;; consistency graphs show up in all agenda views.
(defvar my/org-habit-show-graphs-everywhere t
  "If non-nil, show habit graphs in all types of agenda buffers.

Normally, habits display consistency graphs only in
\"agenda\"-type agenda buffers, not in other types of agenda
buffers.  Set this variable to any non-nil variable to show
consistency graphs in all Org mode agendas.")

(defun my/org-agenda-mark-habits ()
  "Mark all habits in current agenda for graph display.

This function enforces `my/org-habit-show-graphs-everywhere' by
marking all habits in the current agenda as such.  When run just
before `org-agenda-finalize' (such as by advice; unfortunately,
`org-agenda-finalize-hook' is run too late), this has the effect
of displaying consistency graphs for these habits.

When `my/org-habit-show-graphs-everywhere' is nil, this function
has no effect."
  (when (and my/org-habit-show-graphs-everywhere
             (not (get-text-property (point) 'org-series)))
    (let ((cursor (point))
          item data)
      (while (setq cursor (next-single-property-change cursor 'org-marker))
        (setq item (get-text-property cursor 'org-marker))
        (when (and item (org-is-habit-p item))
          (with-current-buffer (marker-buffer item)
            (setq data (org-habit-parse-todo item)))
          (put-text-property cursor
                             (next-single-property-change cursor 'org-marker)
                             'org-habit-p data))))))
(advice-add #'org-agenda-finalize :before #'my/org-agenda-mark-habits)
;;;;;;;;;;;;;;;;;;;;;;;;;;; PHIL STUFF ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Laisser ça pour me permettre de tester ta config
(use-package evil
  :ensure t
  :init (setq evil-want-C-i-jump nil)
  (setq evil-want-integration t)
  (setq evil-want-C-u-scroll t))
(let ((user (getenv "USER")))
  (when (or (string-equal user "pcarphin")
            (string-equal user "phc001"))
    (message "Turning on evil-mode for Phil")
    (evil-mode 1)))
;;;;;;;;;;;;;;;;;;;;;;;;;;; LEADER KEY ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
          (setq my/shortcuts-key "C-o")
(defvar-keymap my/org-mode-shortcuts-map
  :doc "Selected orgmode functions"
  "t" #'org-set-tags-command
  "C-t" #'org-todo
  "c" #'org-capture-input)
(defvar-keymap my/org-agenda-shortcuts-map
  "a" #'org-agenda
  "s" #'org-schedule
  "d" #'org-deadline)
(defvar-keymap my/help-shortcuts-map
  "k" #'describe-key
  "f" #'describe-function
  "i" #'info)
(defvar-keymap my/shortcuts-map
  "o" `("orgmode" . ,my/org-mode-shortcuts-map)
  "a" `("agenda" . ,my/org-agenda-shortcuts-map)
  "h" `("help" . ,my/help-shortcuts-map))
(keymap-set global-map my/shortcuts-key my/shortcuts-map)
(evil-global-set-key 'normal (kbd my/shortcuts-key) my/shortcuts-map)
