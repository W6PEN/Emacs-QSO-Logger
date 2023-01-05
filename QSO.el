;; This code defines basic functions to capture and process new amateur radio contacts (QSOs). Two functions, each optimized to different use cases but still functional for most uses, capture and append new QSOs to a text file called `qso-log.txt` and an ADIF file `qso-log.adi` in the user's home directory. 
;; The `add-qso` function is optimized for use when responding to a CQ. The `add-qso-cq` function is optimized for use when calling CQ and expecting more than one response, so the mode and frequency are entered only once per session, and C-g exits the loop.
;; A third function, `export-adif`, is provided to allow for a wholesale export of the `qso-log.txt` to a different ADIF file. 
;; The ADIF file can then be further processed in Emacs (e.g. adding an ADIF header) or imported into an external logging program or database that supports the ADIF format.

(defun add-qso ()
  "Prompt the user for information about a new amateur radio contact (QSO) and append it to the txt and ADIF logbooks."
  (interactive)
  (let ((frequency (read-string "Frequency (MHz): "))
        (mode (read-string "Mode: "))
        (callsign (read-string "Callsign: "))
        (date (format-time-string "%Y%m%d" (current-time) t))
        (time (format-time-string "%H%M%S" (current-time) t))
        (rstrcvd (read-string "RST Rcvd: "))
        (rstsent (read-string "RST Sent: "))
        (location (read-string "Location: "))
        (operator (read-string "Operator: "))
        (comment (read-string "Comment: ")))
    (with-temp-buffer
      (insert (format "Callsign: %s\nDate: %s\nTime: %s\nMode: %s\nFrequency: %s\nRST Sent: %s\nRST Rcvd: %s\nOperator: %s\nLocation: %s\nComment: %s\n\n"
                      callsign date time mode frequency rstsent rstrcvd operator location comment))
      (append-to-file (point-min) (point-max) "~/qso-log.txt"))
    (with-temp-buffer    
      (insert (format "<CALL:%d>%s<QSO_DATE:%d>%s<TIME_ON:%d>%s<MODE:%d>%s<FREQ:%d>%s<RST_SENT:%d>%s<RST_RCVD:%d>%s<NAME:%d>%s<QTH:%d>%s<COMMENT:%d>%s<eor>\n"
                        (length callsign) callsign
                        (length date) date
                        (length time) time
                        (length mode) mode
                        (length frequency) frequency
                        (length rstsent) rstsent
                        (length rstrcvd) rstrcvd
                        (length operator) operator
                        (length location) location
                        (length comment) comment))
      (append-to-file (point-min) (point-max) "~/qso-log.adi"))))

(defun add-qso-cq ()
  "Prompt the user for information about amateur radio contacts responding to your CQ and add them to the txt and ADIF logbooks."
  (interactive)
  (let ((frequency (read-string "Frequency (MHz): "))
        (mode (read-string "Mode: "))
        (while (eq 1 1)
               (let ((callsign (read-string "Callsign: "))
                     (date (format-time-string "%Y%m%d" (current-time) t))
                     (time (format-time-string "%H%M%S" (current-time) t))
                     (rstsent (read-string "RST Sent: "))
                     (rstrcvd (read-string "RST Rcvd: "))
                     (location (read-string "Location: "))
                     (operator (read-string "Operator: "))
                     (comment (read-string "Comment: ")))
               (with-temp-buffer
                 (insert (format "Callsign: %s\nDate: %s\nTime: %s\nMode: %s\nFrequency: %s\nRST Sent: %s\nRST Rcvd: %s\nOperator: %s\nLocation: %s\nComment: %s\n\n"
                      callsign date time mode frequency rstsent rstrcvd operator location comment))
                 (append-to-file (point-min) (point-max) "~/qso-log.txt"))
               (with-temp-buffer    
                 (insert (format "<CALL:%d>%s<QSO_DATE:%d>%s<TIME_ON:%d>%s<MODE:%d>%s<FREQ:%d>%s<RST_SENT:%d>%s<RST_RCVD:%d>%s<NAME:%d>%s<QTH:%d>%s<COMMENT:%d>%s<eor>\n"
                        (length callsign) callsign
                        (length date) date
                        (length time) time
                        (length mode) mode
                        (length frequency) frequency
                        (length rstsent) rstsent
                        (length rstrcvd) rstrcvd
                        (length operator) operator
                        (length location) location
                        (length comment) comment))
                 (append-to-file (point-min) (point-max) "~/qso-log.adi")))))))

;; Define a function to export the entire txt QSO logbook to a new file in ADIF format
(defun export-adif ()
  "Export the entire QSO txt logbook to a new file in ADIF format."
  (interactive)
  (with-temp-buffer
    (insert-file-contents "~/qso-log.txt")
    (goto-char (point-min))
    (while (not (eobp))
      (let ((callsign (progn (search-forward "Callsign: ") (thing-at-point 'word)))
            (mode (progn (search-forward "Mode: ") (thing-at-point 'word)))
            (frequency (progn (search-forward "Frequency: ") (thing-at-point 'word)))
            (date (progn (search-forward "Date: ") (thing-at-point 'word)))
            (time (progn (search-forward "Time: ") (thing-at-point 'word)))
            (rstsent (progn (search-forward "RST Sent: ") (thing-at-point 'word)))
            (rstrcvd (progn (search-forward "RST Rcvd: ") (thing-at-point 'word)))
            (operator (progn (search-forward "Operator: ") (thing-at-point 'word)))
            (location (progn (search-forward "Location: ") (thing-at-point 'word))))
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
(write-file "~/qso-log-export.adi")))
