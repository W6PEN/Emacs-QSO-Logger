;; This code defines the function `add-qso` function which prompts the user for information about a new amateur radio contact (QSO) and adds it to a text file called `qso-log.txt` and an ADIF file `qso-log.adi` in the user's home directory.

;; To use this functions, you would first invoke `add-qso` to add one or more entries to the logbook, and then process within Emacs or import the ADIF file into another logging program or platform that supports the ADIF format for further processing.

(defun add-qso ()
  "Prompt the user for information about a new amateur radio contact and add it to the logbook."
  (interactive)
  (let ((callsign (read-string "Callsign: "))
        (date (format-time-string "%Y%m%d" (current-time) t))
        (time (format-time-string "%H%M%S" (current-time) t))
        (mode (read-string "Mode: "))
        (frequency (read-string "Frequency: "))
        (rstrcvd (read-string "RST Rcvd: "))
        (rstsent (read-string "RST Sent: "))
        (operator (read-string "Operator: "))
        (location (read-string "Location: "))
        (comment (read-string "Comment: ")))
    (with-temp-buffer
      (insert (format "Callsign: %s\nDate: %s\nTime: %s\nMode: %s\nFrequency: %s\nRST Rcvd: %s\nRST Sent: %s\nOperator: %s\nLocation: %s\nComment: %s\n\n"
                      callsign date time mode frequency rstrcvd rstsent operator location comment))
      (append-to-file (point-min) (point-max) "~/qso-log.txt"))
    (with-temp-buffer    
      (insert (format "<CALL:%d>%s<QSO_DATE:%d>%s<TIME_ON:%d>%s<MODE:%d>%s<FREQ:%d>%s<RST_RCVD:%d>%s<RST_SENT:%d>%s<NAME:%d>%s<QTH:%d>%s<COMMENT:%d>%s<eor>\n"
                        (length callsign) callsign
                        (length date) date
                        (length time) time
                        (length mode) mode
                        (length frequency) frequency
                        (length rstrcvd) rstrcvd
                        (length rstsent) rstsent
                        (length operator) operator
                        (length location) location
                        (length comment) comment))
      (append-to-file (point-min) (point-max) "~/qso-log.adi"))))
