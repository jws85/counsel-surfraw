;;; counsel-surfraw.el -- Use counsel to do web searches using surfraw

;;; Commentary:
;; Author: J. W. Smith <jwsmith2spam at gmail dot com>
;; Keywords: ivy, counsel, surfraw, web, net, search
;;
;; `counsel-surfraw' performs web searches from Emacs using several
;; different search engines, by way of Surfraw.  Surfraw is a command
;; line tool; basically a bunch of individual shell scripts (which
;; it calls "elvi") that builds a query URL for a specific search
;; engine.  You will usually need to install surfraw; on Ubuntu it
;; is as simple as "apt-get install surfraw".
;;
;; There are two parts to the `counsel-surfraw' command; first it
;; asks the user for the search string, then it provides the user
;; with a list of installed search engines ("elvi").  The second
;; part makes use of ivy/counsel.

(require 'ivy)

(defun counsel-surfraw ()
  "Search for something online, using the surfraw command."
  (interactive)
  (let ((search-for (read-string "Search for: " nil 'counsel-surfraw-search-history
                                 (if (use-region-p)
                                     (buffer-substring-no-properties
                                      (region-beginning) (region-end))
                                   (thing-at-point 'symbol)))))
    (ivy-read (format "Search for `%s` with: " search-for)
              #'counsel-surfraw-elvi
              :require-match t
              :history 'counsel-surfraw-engine-history
              :sort t
              :action
              (lambda (selected-elvis)
                (browse-url (shell-command-to-string
                             (format "sr %s -p %s"
                                     (get-text-property 0 'elvis selected-elvis)
                                     search-for)))))))

(defun counsel-surfraw-elvi (str pred _)
  "Return a list of surfraw elvi (search engines).

I don't know what the parameters are, they are for compatibility with `all-completions'.
Just listing them here to keep flycheck happy:  STR PRED _"
  (mapcar
   'counsel-surfraw-elvis
   (seq-remove
    (lambda (str) (not (string-match-p "--" str)))
    (split-string (shell-command-to-string "surfraw -elvi") "\n"))))

(defun counsel-surfraw-elvis (elvis)
  "Process an individual surfraw ELVIS."
  (let* ((list (split-string elvis "--"))
         (key (string-trim (nth 0 list)))
         (value (string-trim (nth 1 list)))
         (text (format "%-20s %s" key value)))
    (propertize text 'elvis key)))

(provide 'counsel-surfraw)

;;; counsel-surfraw.el ends here
