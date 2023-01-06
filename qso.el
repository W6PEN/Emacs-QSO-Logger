;;; qso.el --- a simple QSO logger for amateur radio operators        -*- lexical-binding: t; -*-

;; Copyright (C) 2023  David Pentrack

;; Author: David Pentrack
;; Keywords: lisp
;; Version: 0.6.0

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This provides basic functions to capture and log new amateur radio contacts (QSOs). 
;; Two real time QSO recording functions, `qso-add` and `qso-add-multi`, are optimized to different use cases but are still functional for most real time uses. These functions request basic QSO data via the minibuffer and appends that information to a text file called `qso-log.txt` and to an ADIF file `qso-log.adi` in the user's home directory. 
;; They automatically enter the date and time of the QSO in UTC by taking the current-time immediately after entering the callsign.
;; `qso-add` is optimized for use when responding to a CQ: Frequency, Mode, Callsign, RST Received, RST Sent, Location, Operator, and Comment, in that order.
;; `qso-add-previous` performs the same function as `qso-add` except the date and time of the QSO is entered manually. 
;; `qso-add-multi` is a loop optimized for use when calling CQ and expecting more than one response, so the mode and frequency are entered only once per session, and RST Sent is requested prior to RST Received. C-g exits the loop.
;; `qso-add-multi-previous` performs the same function as `qso-add-multi` except the date and time for each QSO is entered manually.
;; `qso-export-adif`, is provided to allow for a wholesale export of the `qso-log.txt` file to an ADIF file `qso-log-export.adi` in the user's home directory.
;; ADIF files can then be further processed in Emacs or imported into an external logging program or database that supports the ADIF format.

;;; Code:

(defun qso-add ()
  "Prompt the user for information about a new amateur radio contact (QSO) in real time and append it to the txt and ADIF logbooks."
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

(defun qso-add-previous ()
  "Prompt the user for information about a previous amateur radio contact (QSO) and append it to the txt and ADIF logbooks."
  (interactive)
  (let ((frequency (read-string "Frequency (MHz): "))
        (mode (read-string "Mode: "))
        (callsign (read-string "Callsign: "))
        (date (read-string "QSO UTC Date (YYYYMMDD): "))
        (time (read-string "QSO UTC Time (HHMMSS): "))
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

(defun qso-add-multi ()
  "Prompt the user for information about amateur radio contacts responding to your CQ in real time and add them to the txt and ADIF logbooks."
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

(defun qso-add-multi-previous ()
  "Prompt the user for information about previous amateur radio contacts responding to your CQ and add them to the txt and ADIF logbooks."
  (interactive)
  (let ((frequency (read-string "Frequency (MHz): "))
        (mode (read-string "Mode: "))
        (while (eq 1 1)
               (let ((callsign (read-string "Callsign: "))
                     (date (read-string "QSO UTC Date (YYYYMMDD): "))
                     (time (read-string "QSO UTC Time (HHMMSS): "))
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

(defun qso-export-adif ()
  "Export the entire contents of the `qso-log.txt` in the user's home directory to an ADIF format file, `qso-log-export.adi`."
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
        (forward-line))
    (write-file "~/qso-log-export.adi")))

(provide 'qso)
;;; qso.el ends here
