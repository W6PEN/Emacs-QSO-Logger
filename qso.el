;;; qso.el --- A basic QSO logger for amateur radio operators        -*- lexical-binding: t; -*-

;; Copyright (C) 2023  

;; Author: W6PEN
;; Keywords: lisp
;; Version: 0.7.3

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

;; This provides basic functions to capture and log new amateur radio contacts (QSOs). It captures data for Frequency, Mode, Callsign, RST Sent, RST Received, QTH, Operator, and Comment
;; Two real time QSO recording functions, `qso-add` and `qso-add-multi`, are optimized to different use cases but are still functional for most real time uses. These functions request basic QSO data via the minibuffer and appends that information to a text file called `qso-log.txt` and to an ADIF file `qso-log.adi` in the user's home directory. 
;; They automatically enter the date and time of the QSO in UTC by taking the current-time immediately after entering the callsign.
;; `qso-add` is optimized for use when responding to a CQ, requesting Frequency, Mode, Callsign, RST Received, RST Sent, QTH, Operator, and Comment, in that order.
;; `qso-add-previous` performs the same function as `qso-add` except the date and time of the QSO is entered manually. 
;; `qso-add-multi` is a loop optimized for use when calling CQ and expecting more than one response, so the mode and frequency are entered only once per session, and RST Sent is requested prior to RST Received. C-g exits the loop.
;; `qso-add-multi-previous` performs the same function as `qso-add-multi` except the date and time for each QSO is entered manually.
;; `qso-export-adif` exports the entire contents of `qso-log.txt` to an ADIF file `qso-log-export.adi` in the user's home directory.
;; ADIF files can then be further processed in Emacs or imported into an external logging program or database that supports the ADIF format.

;;; Code:

(defun qso-add ()
  "Prompt the user for information about a new amateur radio contact (QSO) in real time and append it to the txt and ADIF logbooks."
  (interactive)
  (let ((frequency (read-string "Frequency (MHz): "))
        (mode (read-string "Mode: "))
        (callsign (read-string "Callsign: "))
        (date (format-time-string "%Y%m%d" (current-time) t))
        (time (format-time-string "%H%M" (current-time) t))
        (rstrcvd (read-string "RST Rcvd: "))
        (rstsent (read-string "RST Sent: "))
        (location (read-string "Location: "))
        (operator (read-string "Operator: "))
        (comment (read-string "Comment: "))
        (timeoff (format-time-string "%H%M" (current-time) t)))
    (with-temp-buffer
      (insert (format "Callsign: %s\nDate: %s\nTime On: %s\nTime Off: %s\nMode: %s\nFrequency: %s\nRST Sent: %s\nRST Rcvd: %s\nOperator: %s\nLocation: %s\nComment: %s\n\n"
                      callsign date time timeoff mode frequency rstsent rstrcvd operator location comment))
      (append-to-file (point-min) (point-max) "~/qso-log.txt"))
    (with-temp-buffer    
      (insert (format "<CALL:%d>%s<QSO_DATE:%d>%s<TIME_ON:%d>%s<TIME_OFF:%d>%s<MODE:%d>%s<FREQ:%d>%s<RST_SENT:%d>%s<RST_RCVD:%d>%s<NAME:%d>%s<QTH:%d>%s<COMMENT:%d>%s<eor>\n"
                        (length callsign) callsign
                        (length date) date
                        (length time) time
                        (length timeoff) timeoff
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
        (time (read-string "QSO UTC Time On (HHMM): "))
        (timeoff (read-string "QSO UTC Time Off (HHMM): "))
        (rstrcvd (read-string "RST Rcvd: "))
        (rstsent (read-string "RST Sent: "))
        (location (read-string "Location: "))
        (operator (read-string "Operator: "))
        (comment (read-string "Comment: ")))
    (with-temp-buffer
      (insert (format "Callsign: %s\nDate: %s\nTime On: %s\nTime Off: %s\nMode: %s\nFrequency: %s\nRST Sent: %s\nRST Rcvd: %s\nOperator: %s\nLocation: %s\nComment: %s\n\n"
                      callsign date time timeoff mode frequency rstsent rstrcvd operator location comment))
      (append-to-file (point-min) (point-max) "~/qso-log.txt"))
    (with-temp-buffer    
      (insert (format "<CALL:%d>%s<QSO_DATE:%d>%s<TIME_ON:%d>%s<TIME_OFF:%d>%s<MODE:%d>%s<FREQ:%d>%s<RST_SENT:%d>%s<RST_RCVD:%d>%s<NAME:%d>%s<QTH:%d>%s<COMMENT:%d>%s<eor>\n"
                        (length callsign) callsign
                        (length date) date
                        (length time) time
                        (length timeoff) timeoff
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
        (mode (read-string "Mode: ")))
	(while (eq 1 1)
	  (let ((callsign (read-string "Callsign: "))
		(date (format-time-string "%Y%m%d" (current-time) t))
		(time (format-time-string "%H%M" (current-time) t))
		(rstsent (read-string "RST Sent: "))
		(rstrcvd (read-string "RST Rcvd: "))
		(location (read-string "Location: "))
		(operator (read-string "Operator: "))
		(comment (read-string "Comment: "))
		(timeoff (format-time-string "%H%M" (current-time) t)))
	    (with-temp-buffer
	      (insert (format "Callsign: %s\nDate: %s\nTime On: %s\nTime Off: %s\nMode: %s\nFrequency: %s\nRST Sent: %s\nRST Rcvd: %s\nOperator: %s\nLocation: %s\nComment: %s\n\n"
			      callsign date time timeoff mode frequency rstsent rstrcvd operator location comment))
	      (append-to-file (point-min) (point-max) "~/qso-log.txt"))
	    (with-temp-buffer    
	      (insert (format "<CALL:%d>%s<QSO_DATE:%d>%s<TIME_ON:%d>%s<MODE:%d>%s<FREQ:%d>%s<RST_SENT:%d>%s<RST_RCVD:%d>%s<NAME:%d>%s<QTH:%d>%s<COMMENT:%d>%s<eor>\n"
			      (length callsign) callsign
			      (length date) date
			      (length time) time
			      (length timeoff) timeoff
			      (length mode) mode
			      (length frequency) frequency
			      (length rstsent) rstsent
			      (length rstrcvd) rstrcvd
			      (length operator) operator
			      (length location) location
			      (length comment) comment))
	      (append-to-file (point-min) (point-max) "~/qso-log.adi"))))))

(defun qso-add-multi-previous ()
  "Prompt the user for information about previous amateur radio contacts responding to your CQ and add them to the txt and ADIF logbooks."
  (interactive)
  (let ((frequency (read-string "Frequency (MHz): "))
        (mode (read-string "Mode: ")))
	(while (eq 1 1)
	  (let ((callsign (read-string "Callsign: "))
		(date (read-string "QSO UTC Date (YYYYMMDD): "))
		(time (read-string "QSO UTC Time On (HHMM): "))
	        (timeoff (read-string "QSO UTC Time Off (HHMM): "))
		(rstsent (read-string "RST Sent: "))
		(rstrcvd (read-string "RST Rcvd: "))
		(location (read-string "Location: "))
		(operator (read-string "Operator: "))
		(comment (read-string "Comment: ")))
	    (with-temp-buffer
	      (insert (format "Callsign: %s\nDate: %s\nTime On: %s\nTime Off: %s\nMode: %s\nFrequency: %s\nRST Sent: %s\nRST Rcvd: %s\nOperator: %s\nLocation: %s\nComment: %s\n\n"
			      callsign date time timeoff mode frequency rstsent rstrcvd operator location comment))
	      (append-to-file (point-min) (point-max) "~/qso-log.txt"))
	    (with-temp-buffer    
	      (insert (format "<CALL:%d>%s<QSO_DATE:%d>%s<TIME_ON:%d>%s<TIME_OFF:%d>%s<MODE:%d>%s<FREQ:%d>%s<RST_SENT:%d>%s<RST_RCVD:%d>%s<NAME:%d>%s<QTH:%d>%s<COMMENT:%d>%s<eor>\n"
			      (length callsign) callsign
			      (length date) date
			      (length time) time
			      (length timeoff) timeoff
			      (length mode) mode
			      (length frequency) frequency
			      (length rstsent) rstsent
			      (length rstrcvd) rstrcvd
			      (length operator) operator
			      (length location) location
			      (length comment) comment))
	      (append-to-file (point-min) (point-max) "~/qso-log.adi"))))))

(provide 'qso)
;;; qso.el ends here
