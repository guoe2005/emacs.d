(setq package-archives '(("gnu"    . "https://mirrors.tuna.tsinghua.edu.cn/elpa/gnu/")
                         ("nongnu" . "https://mirrors.tuna.tsinghua.edu.cn/elpa/nongnu/")
                         ("melpa"  . "https://mirrors.tuna.tsinghua.edu.cn/elpa/melpa/")))

(setq inhibit-startup-screen t)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'package)
(unless (bound-and-true-p package--initialized)
  (package-initialize))

(require 'use-package)
(setq use-package-always-ensure t)

(use-package better-defaults)

(use-package helm
  :bind (("M-x" . helm-M-x)
         ("C-x C-f" . helm-find-files))
  :config
  (helm-mode 1))

(use-package flycheck
  :init ;; 在 (require) 之前需要执行的
  (setq flycheck-emacs-lisp-load-path 'inherit)
  :config
  (global-flycheck-mode))

(use-package srcery-theme
    :config
    (load-theme 'srcery t))

;; (use-package zenburn-theme
;;   :ensure t
;;   :config
;;   (load-theme 'zenburn t)) 

(add-to-list 'load-path (expand-file-name (concat user-emacs-directory "lisp")))
(setq gc-cons-threshold most-positive-fixnum)

(use-package company
  :hook (after-init . global-company-mode)
  :config
 (setq company-minimum-prefix-length 3) ; 只需敲 1 个字母就开始进行自动补全
 (setq company-tooltip-align-annotations t)
 (setq company-idle-delay 0.0)
 (setq company-show-numbers t) ;; 给选项编号 (按快捷键 M-1、M-2 等等来进行选择).
 (setq company-selection-wrap-around t)
 (setq company-transformers '(company-sort-by-occurrence))) ; 根据选择的频率进行排序，读者如果不喜欢可以去掉

(use-package projectile
  :config
  ;; 把它的缓存挪到 ~/.emacs.d/.cache/ 文件夹下，让 gitignore 好做
  (setq projectile-cache-file (expand-file-name ".cache/projectile.cache" user-emacs-directory))
  ;; 全局 enable 这个 minor mode
  (projectile-mode 1)
  ;; 定义和它有关的功能的 leader key
  (define-key projectile-mode-map (kbd "C-c C-p") 'projectile-command-map))

(use-package helm-projectile
  :if (functionp 'helm) ;; 如果使用了 helm 的话，让 projectile 的选项菜单使用 Helm 呈现
  :config
  (helm-projectile-on))

(use-package magit)
(use-package helm-ag)

(use-package helm-swoop
  ;; 更多关于它的配置方法: https://github.com/ShingoFukuyama/helm-swoop
  ;; 以下我的配置仅供参考
  :bind
  (("M-i" . helm-swoop)
   ("M-I" . helm-swoop-back-to-last-point)
   ("C-c M-i" . helm-multi-swoop)
   ("C-x M-i" . helm-multi-swoop-all)
   :map isearch-mode-map
   ("M-i" . helm-swoop-from-isearch)
   :map helm-swoop-map
   ("M-i" . helm-multi-swoop-all-from-helm-swoop)
   ("M-m" . helm-multi-swoop-current-mode-from-helm-swoop))
  :config
  ;; 它像 helm-ag 一样，可以直接修改搜索结果 buffer 里的内容并 apply
  (setq helm-multi-swoop-edit-save t)
  ;; 如何给它新开分割窗口
  ;; If this value is t, split window inside the current window
  (setq helm-swoop-split-with-multiple-windows t))

(use-package anzu)
(use-package multiple-cursors
  :bind (("C-S-c" . mc/edit-lines) ;; 每行一个光标
         ("C->" . mc/mark-next-like-this-symbol) ;; 全选光标所在单词并在下一个单词增加一个光标。通常用来启动一个流程
         ("C-M->" . mc/skip-to-next-like-this) ;; 跳过当前单词并跳到下一个单词，和上面在同一个流程里。
         ("C-<" . mc/mark-previous-like-this-symbol) ;; 同样是开启一个多光标流程，但是是「向上找」而不是向下找。
         ("C-M-<" . mc/skip-to-previous-like-this) ;; 跳过当前单词并跳到上一个单词，和上面在同一个流程里。
         ("C-c C->" . mc/mark-all-symbols-like-this)))


(use-package crux
  :bind (("C-a" . crux-move-beginning-of-line)
         ("C-x ^" . crux-top-join-line)
         ("C-x ," . crux-find-user-init-file)
         ("C-S-d" . crux-duplicate-current-line-or-region)
         ("C-S-k" . crux-smart-kill-line)))

(use-package which-key
  :defer nil
  :config (which-key-mode))

(use-package eglot
  :hook ((c-mode
          c++-mode
          go-mode
          java-mode
          js-mode
          python-mode
          rust-mode
          web-mode) . eglot-ensure)
  :bind (("C-c e f" . #'eglot-format)
         ("C-c e a" . #'eglot-code-actions)
         ("C-c e i" . #'eglot-code-action-organize-imports)
         ("C-c e q" . #'eglot-code-action-quickfix))
  :config
  ;; (setq eglot-ignored-server-capabilities '(:documentHighlightProvider))
  (add-to-list 'eglot-server-programs '(web-mode "vls"))
  (defun eglot-actions-before-save()
    (add-hook 'before-save-hook
              (lambda ()
                (call-interactively #'eglot-format)
                (call-interactively #'eglot-code-action-organize-imports))))
  (add-hook 'eglot--managed-mode-hook #'eglot-actions-before-save))

(require 'rust-mode)
(add-hook 'rust-mode-hook 'eglot-ensure)
(use-package rust-mode
  :init
  (setq rust-mode-treesitter-derive t))

(use-package ivy
 :ensure t
 :init
 (ivy-mode 1)
 (counsel-mode 1)
 :config
 (setq ivy-use-virtual-buffers t)
 (setq search-default-mode #'char-fold-to-regexp)
 (setq ivy-count-format "(%d/%d) ")
 :bind
 (("C-s" . 'swiper)
  ("C-x b" . 'ivy-switch-buffer)
  ("C-c v" . 'ivy-push-view)
  ("C-c s" . 'ivy-switch-view)
  ("C-c V" . 'ivy-pop-view)
  ("C-x C-@" . 'counsel-mark-ring); 在某些终端上 C-x C-SPC 会被映射为 C-x C-@，比如在 macOS 上，所以要手动设置
  ("C-x C-SPC" . 'counsel-mark-ring)
  :map minibuffer-local-map
  ("C-r" . counsel-minibuffer-history)))

(use-package counsel
  :ensure t)

(use-package smart-mode-line
  :init
  (setq sml/no-confirm-load-theme t)
  (sml/setup))

(use-package good-scroll
 :ensure t
 :if window-system     ; 在图形化界面时才使用这个插件
 :init (good-scroll-mode))

(global-set-key (kbd "C-j") nil)

(use-package avy
 :ensure t
 :bind
 (("C-'" . avy-goto-char-timer)
  ("C-c C-j" . avy-resume))
   :config
  (setq avy-background t ;; 打关键字时给匹配结果加一个灰背景，更醒目
        avy-all-windows t ;; 搜索所有 window，即所有「可视范围」
        avy-timeout-seconds 0.3)) ;; 「关键字输入完毕」信号的触发时间x

(use-package dashboard
 :ensure t
 :config
 (setq dashboard-banner-logo-title "Welcome to Emacs!") ;; 个性签名，随读者喜好设置
 ;; (setq dashboard-projects-backend 'projectile) ;; 读者可以暂时注释掉这一行，等安装了 projectile 后再使用
 (setq dashboard-startup-banner 'official) ;; 也可以自定义图片
 (setq dashboard-items '((recents . 9)  ;; 显示多少个最近文件
  (bookmarks . 9) ;; 显示多少个最近书签
  (projects . 10))) ;; 显示多少个最近项目
 (dashboard-setup-startup-hook))

(use-package rainbow-delimiters
 :ensure t
 :hook (prog-mode . rainbow-delimiters-mode))

(use-package yasnippet
 :ensure t
 :hook
 (prog-mode . yas-minor-mode)
 :config
 (yas-reload-all)
 ;; add company-yasnippet to company-backends
 ;; (defun company-mode/backend-with-yas (backend)
 ;;  (if (and (listp backend) (member 'company-yasnippet backend))
 ;;   backend
 ;;   (append (if (consp backend) backend (list backend))
 ;;        '(:with company-yasnippet))))
 ;; (setq company-backends (mapcar #'company-mode/backend-with-yas company-backends))
 ;; unbind <TAB> completion
 (define-key yas-minor-mode-map [(tab)]    nil)
 (define-key yas-minor-mode-map (kbd "TAB")  nil)
 (define-key yas-minor-mode-map (kbd "<tab>") nil)
 :bind
 (:map yas-minor-mode-map ("S-<tab>" . yas-expand)))
  
(use-package yasnippet-snippets
 :ensure t
 :after yasnippet)

(global-set-key (kbd "M-/") 'hippie-expand)

;; (use-package nix-mode
;;   :mode "\\.nix\\'")

(require 'recentf)
;; get rid of `find-file-read-only' and replace it with something
;; more useful.
(global-set-key (kbd "C-x C-r") 'recentf)
(global-set-key (kbd "C-c c") 'comment-or-uncomment-region)

;; enable recent files mode.
(recentf-mode t)

; 50 files ought to be enough.
(setq recentf-max-saved-items 50)
(setq scroll-conservatively 101)
;; scroll one line at a time (less "jumpy" than defaults)
(setq mouse-wheel-scroll-amount '(1 ((shift) . 1))) ;; one line at a time
(setq mouse-wheel-progressive-speed nil) ;; don't accelerate scrolling
(setq mouse-wheel-follow-mouse 't) ;; scroll window under mouse
(setq scroll-step 1) ;; keyboard scroll one line at a time
(pixel-scroll-mode 1)
(good-scroll-mode 1)

(require 'init-org)
(require 'org-tempo)

(use-package org-download
  :config
  (setq-default org-download-heading-lvl nil)
  (setq-default org-download-image-dir "C:/Users/guoe2/Pictures/Screenshots")
  (setq org-download-backend "wget")
  (setq org-download-abbreviate-filename-function (lambda (fn) fn)) ; use original filename
  (defun dummy-org-download-annotate-function (link)
    "")
  (setq org-download-annotate-function
        #'dummy-org-download-annotate-function)
  )

(global-set-key (kbd "C-c n") 'org-capture)

(use-package desktop
  :commands restart-emacs-without-desktop
  :init (desktop-save-mode)
  :config
  ;; inhibit no-loaded prompt
  (setq desktop-file-modtime (file-attribute-modification-time
                              (file-attributes
                               (desktop-full-file-name)))
        desktop-lazy-verbose nil
        desktop-load-locked-desktop t
        desktop-restore-eager 1
        desktop-restore-frames nil
        desktop-save t)

  (defun restart-emacs-without-desktop (&optional args)
    "Restart emacs without desktop."
    (interactive)
    (restart-emacs (cons "--no-desktop" args))))

(use-package vertico ; 竖式展开小缓冲区
  :custom (verticle-cycle t)
  :config (vertico-mode))

(use-package marginalia ; 更多信息
  :config (marginalia-mode))

(use-package orderless ; 乱序补全
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion)))))
(use-package exec-path-from-shell
  :config (exec-path-from-shell-initialize))

(use-package org-download
  :config
  (setq-default org-download-heading-lvl nil)
  (setq-default org-download-image-dir "C:/Users/guoe2/Pictures/Screenshots")
  (setq org-download-backend "wget")
  (setq org-download-abbreviate-filename-function (lambda (fn) fn)) ; use original filename
  (defun dummy-org-download-annotate-function (link)
    "")
  (setq org-download-annotate-function
        #'dummy-org-download-annotate-function)
  )


;; (when (eq system-type 'windows-nt)
;;   (setq fonts '("Consolas" "微软雅黑"))
;;   (set-fontset-font t 'unicode "Segoe UI Emoji" nil 'prepend)
;;   (set-face-attribute 'default nil :font
;;                       (format "%s:pixelsize=%d" (car fonts) 34)))
;; (if (display-graphic-p)
;;     (dolist (charset '(kana han symbol cjk-misc bopomofo))
;;       (set-fontset-font (frame-parameter nil 'font) charset
;;                         (font-spec :family (car (cdr fonts))))))


;; (set-default-coding-systems 'utf-8)
;; (set-language-environment "UTF-8")

(add-to-list 'load-path "~/.emacs.d/lisp/cndict/")
(require 'cndict)
;; Change 应用ID and 应用秘钥 to yours
(setq youdao-dictionary-app-key "693be602850d0a15"
      youdao-dictionary-secret-key "ZsB7cscDT2nPduYaVmZ9xSNxyk5Bs3Cf")

(add-to-list 'load-path "~/.emacs.d/lisp/emacs-application-framework/")
(require 'eaf)
(require 'eaf-map)
(require 'eaf-git)
(require 'eaf-file-sender)
(require 'eaf-file-browser)
(require 'eaf-video-player)
(require 'eaf-markdown-previewer)
(require 'eaf-pdf-viewer)
(require 'eaf-rss-reader)
(require 'eaf-org-previewer)
(require 'eaf-file-manager)
(require 'eaf-markmap)
(require 'eaf-terminal)
(require 'eaf-js-video-player)
(require 'eaf-demo)
(require 'eaf-image-viewer)
(require 'eaf-mindmap)
(require 'eaf-browser)
(require 'eaf-jupyter)


(defun my-org-oxauto ()
  "Auto export when saving for Org mode."
  (let ((oxauto (org-collect-keywords '("oxauto"))))
    (when oxauto
      (dolist (keywords oxauto)
        (let ((export-formats (split-string (cadr keywords) "," t " ")))
          (dolist (export-format export-formats)
            (pcase export-format
              ("latex"
               (setq org-export-in-background t)
               (add-hook 'after-save-hook 'org-latex-export-to-latex nil t))
              ("html"
               (setq org-export-in-background t)
               (add-hook 'after-save-hook 'org-html-export-to-html nil t))
              ("pdf"
               (setq org-export-in-background t)
               (add-hook 'after-save-hook 'org-latex-export-to-pdf nil t))
              )))))))
(add-hook 'org-mode-hook 'my-org-oxauto)
