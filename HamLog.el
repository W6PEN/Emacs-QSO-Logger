;; This code defines two functions: `add-log-entry` and `export-logbook-adif`. The `add-log-entry` function prompts the user for information about a new amateur radio contact and adds it to a text file called `radio-log.txt` in the user's home directory. The `export-logbook-adif` function reads the contents of `radio-log.txt` and converts it to ADIF format, writing the result to a file called `radio-logbook.adi`.

;; To use these functions, you would first invoke `add-log-entry` to add one or more entries to the logbook, and then invoke `export-logbook-adif` to export the logbook to ADIF format. You can then use the resulting ADIF file to import the logbook into another logging program or platform that supports the ADIF format.

;; Define a function to add a new entry to the logbook
(defun add-log-entry ()
  "Prompt the user for information about a new amateur radio contact and add it to the logbook."
  (interactive)
  (let ((callsign (read-string "Callsign: "))
        (mode (read-string "Mode: "))
        (frequency (read-string "Frequency: "))
        (date (read-string "UTC Date (YYYYMMDD): "))
        (time (read-string "UTC Time (HHMM): "))
        (rstrcvd (read-string "RST Rec'd: "))
        (rstsent (read-string "RST Sent: "))
        (operator (read-string "Operator: "))
        (location (read-string "Location: "))
        (comment (read-string "Comment: ")))
    (with-temp-buffer
      (insert (format "Callsign: %s\nMode: %s\nFrequency: %s\nDate: %s\nTime: %s\nRST Rec'd: %s\nRST Sent: %s\nOperator: %s\nLocation: %s\nComment: %s\n"
                      callsign mode frequency date time rstrcvd rstsent operator location comment))
      (append-to-file (point-min) (point-max) "~/radio-log.txt"))))

;; Define a function to export the logbook to ADIF format
(defun export-logbook-adif ()
  "Export the amateur radio logbook to a file in ADIF format."
  (interactive)
  (with-temp-buffer
    (insert-file-contents "~/radio-log.txt")
    (goto-char (point-min))
    (while (not (eobp))
      (let ((callsign (progn (search-forward "Callsign: ") (thing-at-point 'word)))
            (mode (progn (search-forward "Mode: ") (thing-at-point 'word)))
            (frequency (progn (search-forward "Frequency: ") (thing-at-point 'word)))
            (date (progn (search-forward "Date: ") (thing-at-point 'word)))
            (time (progn (search-forward "Time: ") (thing-at-point 'word)))
            (rstrcvd (progn (search-forward "RST Rec'd: ") (thing-at-point 'word)))
            (rstsent (progn (search-forward "RST Sent: ") (thing-at-point 'word)))
            (operator (progn (search-forward "Operator: ") (thing-at-point 'word)))
            (location (progn (search-forward "Location: ") (thing-at-point 'word)))
            (comment (progn (search-forward "Comment: ") (thing-at-point 'word))))
        (insert (format "<CALL:%d>%s <MODE:%d>%s <FREQ:%d>%s <QSO_DATE:%d>%s <TIME_ON:%d>%s <RST_RCVD:%d>%s <RST_SENT:%d>%s <NAME:%d>%s <QTH:%d>%s<COMMENT:%d>%s\n"
                        (length callsign) callsign
                        (length mode) mode
                        (length frequency) frequency
                        (length date) date
                        (length time) time
                        (length rstrcvd) rstrcvd
                        (length rstsent) rstsent
                        (length operator) operator
                        (length location) location
                        (length comment) comment))
        (forward-line))
(write-file "~/radio-logbook.adi")))
