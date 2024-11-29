(use-package org-roam
;  :ensure t ;; 自动安装
  :custom
  (org-roam-directory "/mnt/D/obsidian/org/") ;; 默认笔记目录, 提前手动创建好
  (org-roam-dailies-directory "daily/") ;; 默认日记目录, 上一目录的相对路径
  (org-roam-db-gc-threshold most-positive-fixnum) ;; 提高性能
  (org-roam-complete-everywhere t)
  :bind (("C-c r f" . org-roam-node-find)
         ;; 如果你的中文输入法会拦截非 ctrl 开头的快捷键, 也可考虑类似如下的设置
         ;; ("C-c C-n C-f" . org-roam-node-find)
         ("C-c r i" . org-roam-node-insert)
         ("C-c r c" . org-roam-capture)
         ("C-c r l" . org-roam-buffer-toggle) ;; 显示后链窗口
         ("C-c r u" . org-roam-ui-mode)
         :map org-mode-map
         ("C-M-i" . completion-at-point-functions)) 

  :bind-keymap
  ("C-c r d" . org-roam-dailies-map) ;; 日记菜单
  :config
  (require 'org-roam-dailies)  ;; 启用日记功能
  (org-roam-db-autosync-mode)) ;; 启动时自动同步数据库

(use-package org-roam-ui
 ; :ensure t ;; 自动安装
  :after org-roam
  :custom
  (org-roam-ui-sync-theme t) ;; 同步 Emacs 主题
  (org-roam-ui-follow t) ;; 笔记节点跟随
  (org-roam-ui-update-on-save t))

(provide 'init-org)

(use-package vertico ;; 补全界面优化
  :ensure t
  :config
  (vertico-mode))
(use-package orderless ;; 无序搜索
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion)))))

(setq org-todo-keywords
      '((sequence "TODO(t)" "DELAY(D)" "SOMETIME(s)" "|" "DONE(d)")
        (sequence "REPORT(r)" "BUG(b)" "KNOWNCAUSE(k)" "|" "FIXED(f)")
        (sequence "|" "CANCELED(C)")
        (sequence "困难(n)")
        ))
(add-hook 'org-mode-hook
	  (lambda()
	    (setq truncate-lines nil))) 



(setq org-capture-templates
             '(("t" "Task To Do!" entry
                (file+headline "/mnt/D/obsidian/org/task.org" "GTD")
                "* TODO %^{Task Name:}\n%u\n%a\n" :clock-in t :clock-resume t)
               ("r" "Book Reading Task" entry
                (file+headline "/mnt/D/obsidian/org/task.org" "Reading")
                "* TODO %^{Book Name:}\n%u\n%a\n" :clock-in t :clock-resume t)
               ("j" "Journal!!!" entry
                (file+olp+datetree "/mnt/D/obsidian/org/journal.org")
                "* %U - %^{heading} %^g\n %?\n")
               ("n" "Notes!!!" entry
                (file+headline "/mnt/D/obsidian/org/notes.org" "NOTES")
                "* %^{heading} %t %^g\n %?\n")
               ("d" "difficulties!!!" entry
                (file+headline "/mnt/D/obsidian/org/notes.org" "难题")
                "* %a %?\n")))

(require 'ox-latex)
(add-to-list 'org-latex-classes
             '("article"
               "\\documentclass{article}
                \\usepackage{ctex}
                \\usepackage{hyperref}
\\usepackage{amsmath,nccmath}
                 [NO-DEFAULT-PACKAGES]
                 [NO-PACKAGES]"
               ("\\section{%s}" . "\\section*{%s}")
               ("\\subsection{%s}" . "\\subsection*{%s}")
               ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
               ("\\paragraph{%s}" . "\\paragraph*{%s}")
               ("\\subparagraph{%s}" . "\\subparagraph*{%s}")))

(setq org-latex-compiler "xelatex")
(setq org-latex-pdf-process '("xelatex %f"))

;; 生成PDF后清理辅助文件
;; https://answer-id.com/53623039
(setq org-latex-logfiles-extensions 
      (quote ("lof" "lot" "tex~" "tex" "aux" 
              "idx" "log" "out" "toc" "nav" 
              "snm" "vrb" "dvi" "fdb_latexmk" 
              "blg" "brf" "fls" "entoc" "ps" 
              "spl" "bbl" "xdv")))
