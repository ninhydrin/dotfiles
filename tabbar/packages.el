;;; packages.el --- tabbar Layer packages File for Spacemacs
;;
;;
;; save as ~/.emacs.d/private/tabbar/packages.el
;; add to ~/.spacemacs layers `tabbar `
;;
;; please feel free to make this nicer and contribute it back
;;
;; original from: https://gist.github.com/3demax/1264635
;; This are setting for nice tabbar items
;; to have an idea of what it looks like http://imgur.com/b0SNN
;; inspired by Amit Patel screenshot http://www.emacswiki.org/pics/static/NyanModeWithCustomBackground.png

(defvar tabbar-packages
  '(
    tabbar
    )
  "List of all packages to install and/or initialize. Built-in packages
which require an initialization must be listed explicitly in the list.")

(defvar tabbar-excluded-packages '()
  "List of packages to exclude.")

;; For each package, define a function tabbar/init-<package-tabbar>
;;
;; (defun tabbar/init-my-package ()
;;   "Initialize my package"
;;   )
;;
;; Often the body of an initialize function uses `use-package'
;; For more info on `use-package', see readme:
;; https://github.com/jwiegley/use-package
(defun tabbar/init-tabbar ()
  "Initialize tabbar"
  (use-package tabbar
    :init

    (tabbar-mode 1)
	(global-set-key "\M-]" 'tabbar-forward)  ; 次のタブ
	(global-set-key "\M-[" 'tabbar-backward) ; 前のタブ

	(set-face-attribute
	 'tabbar-default nil
	 :background "gray20"
	 :foreground "gray20"
	 :box '(:line-width 1 :color "gray20" :style nil))
	(set-face-attribute
	 'tabbar-unselected nil
	 :background "gray30"
	 :foreground "white"
	 :box '(:line-width 5 :color "gray30" :style nil))
	(set-face-attribute
	 'tabbar-selected nil
	 :background "gray75"
	 :foreground "black"
	 :box '(:line-width 5 :color "gray75" :style nil))
	(set-face-attribute
	 'tabbar-highlight nil
	 :background "white"
	 :foreground "black"
	 :underline nil
	 :box '(:line-width 5 :color "white" :style nil))
	(set-face-attribute
	 'tabbar-button nil
	 :box '(:line-width 1 :color "gray20" :style nil))
	(set-face-attribute
	 'tabbar-separator nil
	 :background "gray20"
	 :height 0.6)
	(setq tabbar-separator '(1.5))
	;; グループ化しない
	(setq tabbar-buffer-groups-function nil)
	;; 左に表示されるボタンを無効化
	(dolist (btn '(tabbar-buffer-home-button
				   tabbar-scroll-left-button
				   tabbar-scroll-right-button))
	  (set btn (cons (cons "" nil)
					 (cons "" nil))))
	;; タブに表示させるバッファの設定
	(defvar my-tabbar-displayed-buffers
	  '("*Backtrace*" "*Colors*" "*Faces*" "*vc-" "*ein: 8888-")
	  "*Regexps matches buffer names always included tabs.")

	(defun my-tabbar-buffer-list ()
	  "Return the list of buffers to show in tabs.
Exclude buffers whose name starts with a space or an asterisk.
The current buffer and buffers matches `my-tabbar-displayed-buffers'
are always included."
	  (let* ((hides (list ?\  ?\*))
			 (re (regexp-opt my-tabbar-displayed-buffers))
			 (cur-buf (current-buffer))
			 (tabs (delq nil
						 (mapcar (lambda (buf)
								   (let ((name (buffer-name buf)))
									 (when (or (string-match re name)
											   (not (memq (aref name 0) hides)))
									   buf)))
								 (buffer-list)))))
		;; Always include the current buffer.
		(if (memq cur-buf tabs)
			tabs
		  (cons cur-buf tabs))))

	(setq tabbar-buffer-list-function 'my-tabbar-buffer-list)

	;; Chrome ライクなタブ切り替えのキーバインド
	(global-set-key (kbd "<M-s-right>") 'tabbar-forward-tab)
	(global-set-key (kbd "<M-s-left>") 'tabbar-backward-tab)

	;; タブ上をマウス中クリックで kill-buffer
	(defun my-tabbar-buffer-help-on-tab (tab)
	  "Return the help string shown when mouse is onto TAB."
	  (if tabbar--buffer-show-groups
		  (let* ((tabset (tabbar-tab-tabset tab))
				 (tab (tabbar-selected-tab tabset)))
			(format "mouse-1: switch to buffer %S in group [%s]"
					(buffer-name (tabbar-tab-value tab)) tabset))
		(format "\
mouse-1: switch to buffer %S\n\
mouse-2: kill this buffer\n\
mouse-3: delete other windows"
				(buffer-name (tabbar-tab-value tab)))))

	(defun my-tabbar-buffer-select-tab (event tab)
	  "On mouse EVENT, select TAB."
	  (let ((mouse-button (event-basic-type event))
			(buffer (tabbar-tab-value tab)))
		(cond
		 ((eq mouse-button 'mouse-2)
		  (with-current-buffer buffer
			(kill-buffer)))
		 ((eq mouse-button 'mouse-3)
		  (delete-other-windows))
		 (t
		  (switch-to-buffer buffer)))
		;; Don't show groups.
		(tabbar-buffer-show-groups nil)))

	(setq tabbar-help-on-tab-function 'my-tabbar-buffer-help-on-tab)
	(setq tabbar-select-tab-function 'my-tabbar-buffer-select-tab)

    )
  )
