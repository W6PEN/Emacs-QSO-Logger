;; This code defines the functions to prompt the user for information about a new amateur radio contact (QSO) and adds it to a text file called `qso-log.txt` and an ADIF file `qso-log.adi` in the user's home directory.
;; The `add-qso` function is optimized for use when responding to a CQ. The `add-qso-cq` function is optimized for use when calling CQ and expecting more than one response, so the mode and frequency are entered only once per session, and C-g exits the loop.
;; The logbook(s) can then be processed within Emacs or import the ADIF file into another logging program or platform that supports the ADIF format for further processing.

(defun add-qso ()
  "Prompt the user for information about a new amateur radio contact and add it to the logbook."
  (interactive)
  (let ((frequency (read-string "Frequency (MHz): "))
        (mode (read-string "Mode: "))
        (callsign (read-string "Callsign: "))
        (date (format-time-string "%Y%m%d" (current-time) t))
        (time (format-time-string "%H%M%S" (current-time) t))
        (rstrcvd (read-string "RST Rcvd: "))
        (rstsent (read-string "RST Sent: "))
        (operator (read-string "Operator: "))
        (location (read-string "Location: "))
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
  "Prompt the user for information about amateur radio contacts responding to your CQ and add them to the logbook."
  (interactive)
  (let ((frequency (read-string "Frequency (MHz): "))
        (mode (read-string "Mode: "))
        (while (eq 1 1)
               (let ((callsign (read-string "Callsign: "))
                     (date (format-time-string "%Y%m%d" (current-time) t))
                     (time (format-time-string "%H%M%S" (current-time) t))
                     (rstsent (read-string "RST Sent: "))
                     (rstrcvd (read-string "RST Rcvd: "))
                     (operator (read-string "Operator: "))
                     (location (read-string "Location: "))
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
