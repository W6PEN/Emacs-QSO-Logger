;;; qsologger.el --- Customizable, Dynamic QSO Logger  -*- lexical-binding: t; -*-

;; Copyright (C) 2024, W6PEN

;; Author: W6PEN
;; Keywords: lisp
;; Version: 0.8.4

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

(require 'wid-edit)
(require 'cl-lib)

(defgroup qso-logger nil
  "QSO Logger"
  :tag "QSO Logger"
  :group 'applications)

(defcustom qso-adif-path "~/qso-log.adi"
  "Path to QSO ADIF File"
  :tag "QSO ADIF Path"
  :type 'string
  :group 'qso-logger)

(defcustom OPERATOR "MYCALL"
  "Operator's Callsign"
  :type 'string
  :group 'qso-logger)

(defcustom qso-form-fields
  '((CALL . t)
    (NAME . t)
    (RST_RCVD . t)
    (RST_SENT . nil)
    (FREQ . nil)
    (BAND . nil)
    (MODE . nil)
    (NOTES . t))
  "Fields to be shown in the QSO Log Entry form and whether they should be cleared after submission.
Each entry is a cons cell where the car is the field name and the cdr is a boolean indicating if the field should be cleared after submission."
  :tag "QSO Form Fields"
  :type '(alist :key-type (choice (const :tag "ADDRESS" ADDRESS)
				  (const :tag "ADDRESS_INTL" ADDRESS_INTL)
				  (const :tag "AGE" AGE)
				  (const :tag "ALTITUDE" ALTITUDE)
				  (const :tag "ANT_AZ" ANT_AZ)
				  (const :tag "ANT_EL" ANT_EL)
				  (const :tag "ANT_PATH" ANT_PATH)
				  (const :tag "ARRL_SECT" ARRL_SECT)
				  (const :tag "AWARD_GRANTED" AWARD_GRANTED)
				  (const :tag "AWARD_SUBMITTED" AWARD_SUBMITTED)
				  (const :tag "A_INDEX" A_INDEX)
				  (const :tag "BAND" BAND)
				  (const :tag "BAND_RX" BAND_RX)
				  (const :tag "CALL" CALL)
				  (const :tag "CHECK" CHECK)
				  (const :tag "CLASS" CLASS)
				  (const :tag "CLUBLOG_QSO_UPLOAD_DATE" CLUBLOG_QSO_UPLOAD_DATE)
				  (const :tag "CLUBLOG_QSO_UPLOAD_STATUS" CLUBLOG_QSO_UPLOAD_STATUS)
				  (const :tag "CNTY" CNTY)
				  (const :tag "COMMENT" COMMENT)
				  (const :tag "COMMENT_INTL" COMMENT_INTL)
				  (const :tag "CONT" CONT)
				  (const :tag "CONTACTED_OP" CONTACTED_OP)
				  (const :tag "CONTEST_ID" CONTEST_ID)
				  (const :tag "COUNTRY" COUNTRY)
				  (const :tag "COUNTRY_INTL" COUNTRY_INTL)
				  (const :tag "CQZ" CQZ)
				  (const :tag "CREDIT_SUBMITTED" CREDIT_SUBMITTED)
				  (const :tag "CREDIT_GRANTED" CREDIT_GRANTED)
				  (const :tag "DARC_DOK" DARC_DOK)
				  (const :tag "DISTANCE" DISTANCE)
				  (const :tag "DXCC" DXCC)
				  (const :tag "EMAIL" EMAIL)
				  (const :tag "EQ_CALL" EQ_CALL)
				  (const :tag "EQSL_QSLRDATE" EQSL_QSLRDATE)
				  (const :tag "EQSL_QSLSDATE" EQSL_QSLSDATE)
				  (const :tag "EQSL_QSL_RCVD" EQSL_QSL_RCVD)
				  (const :tag "EQSL_QSL_SENT" EQSL_QSL_SENT)
				  (const :tag "FISTS" FISTS)
				  (const :tag "FISTS_CC" FISTS_CC)
				  (const :tag "FORCE_INIT" FORCE_INIT)
				  (const :tag "FREQ" FREQ)
				  (const :tag "FREQ_RX" FREQ_RX)
				  (const :tag "GRIDSQUARE" GRIDSQUARE)
				  (const :tag "GRIDSQUARE_EXT" GRIDSQUARE_EXT)
				  (const :tag "GUEST_OP" GUEST_OP)
				  (const :tag "HAMLOGEU_QSO_UPLOAD_DATE" HAMLOGEU_QSO_UPLOAD_DATE)
				  (const :tag "HAMLOGEU_QSO_UPLOAD_STATUS" HAMLOGEU_QSO_UPLOAD_STATUS)
				  (const :tag "HAMQTH_QSO_UPLOAD_DATE" HAMQTH_QSO_UPLOAD_DATE)
				  (const :tag "HAMQTH_QSO_UPLOAD_STATUS" HAMQTH_QSO_UPLOAD_STATUS)
				  (const :tag "HRDLOG_QSO_UPLOAD_DATE" HRDLOG_QSO_UPLOAD_DATE)
				  (const :tag "HRDLOG_QSO_UPLOAD_STATUS" HRDLOG_QSO_UPLOAD_STATUS)
				  (const :tag "IOTA" IOTA)
				  (const :tag "IOTA_ISLAND_ID" IOTA_ISLAND_ID)
				  (const :tag "ITUZ" ITUZ)
				  (const :tag "K_INDEX" K_INDEX)
				  (const :tag "LAT" LAT)
				  (const :tag "LON" LON)
				  (const :tag "LOTW_QSLRDATE" LOTW_QSLRDATE)
				  (const :tag "LOTW_QSLSDATE" LOTW_QSLSDATE)
				  (const :tag "LOTW_QSL_RCVD" LOTW_QSL_RCVD)
				  (const :tag "LOTW_QSL_SENT" LOTW_QSL_SENT)
				  (const :tag "MAX_BURSTS" MAX_BURSTS)
				  (const :tag "MODE" MODE)
				  (const :tag "MS_SHOWER" MS_SHOWER)
				  (const :tag "MY_ALTITUDE" MY_ALTITUDE)
				  (const :tag "MY_ANTENNA" MY_ANTENNA)
				  (const :tag "MY_ANTENNA" MY_ANTENNA)
				  (const :tag "MY_ARRL_SECT" MY_ARRL_SECT)
				  (const :tag "MY_CITY" MY_CITY)
				  (const :tag "MY_CITY_INTL" MY_CITY_INTL)
				  (const :tag "MY_CNTY" MY_CNTY)
				  (const :tag "MY_COUNTRY" MY_COUNTRY)
				  (const :tag "MY_COUNTRY_INTL" MY_COUNTRY_INTL)
				  (const :tag "MY_CQ_ZONE" MY_CQ_ZONE)
				  (const :tag "MY_DXCC" MY_DXCC)
				  (const :tag "MY_FISTS" MY_FISTS)
				  (const :tag "MY_GRIDSQUARE" MY_GRIDSQUARE)
				  (const :tag "MY_GRIDSQUARE_EXT" MY_GRIDSQUARE_EXT)
				  (const :tag "MY_IOTA" MY_IOTA)
				  (const :tag "MY_IOTA_ISLAND_ID" MY_IOTA_ISLAND_ID)
				  (const :tag "MY_ITU_ZONE" MY_ITU_ZONE)
				  (const :tag "MY_LAT" MY_LAT)
				  (const :tag "MY_LON" MY_LON)
				  (const :tag "MY_NAME" MY_NAME)
				  (const :tag "MY_NAME_INTL" MY_NAME_INTL)
				  (const :tag "MY_POSTAL_CODE" MY_POSTAL_CODE)
				  (const :tag "MY_POSTAL_CODE_INTL" MY_POSTAL_CODE_INTL)
				  (const :tag "MY_POTA_REF" MY_POTA_REF)
				  (const :tag "MY_RIG" MY_RIG)
				  (const :tag "MY_RIG_INTL" MY_RIG_INTL)
				  (const :tag "MY_SIG" MY_SIG)
				  (const :tag "MY_SIG_INTL" MY_SIG_INTL)
				  (const :tag "MY_SIG_INFO" MY_SIG_INFO)
				  (const :tag "MY_SIG_INFO_INTL" MY_SIG_INFO_INTL)
				  (const :tag "MY_SOTA_REF" MY_SOTA_REF)
				  (const :tag "MY_STATE" MY_STATE)
				  (const :tag "MY_STREET" MY_STREET)
				  (const :tag "MY_STREET_INTL" MY_STREET_INTL)
				  (const :tag "MY_USACA_COUNTIES" MY_USACA_COUNTIES)
				  (const :tag "MY_VUCC_GRIDS" MY_VUCC_GRIDS)
				  (const :tag "MY_WWFF_REF" MY_WWFF_REF)
				  (const :tag "NAME" NAME)
				  (const :tag "NAME_INTL" NAME_INTL)
				  (const :tag "NOTES" NOTES)
				  (const :tag "NOTES_INTL" NOTES_INTL)
				  (const :tag "NR_BURSTS" NR_BURSTS)
				  (const :tag "NR_PINGS" NR_PINGS)
;				  (const :tag "OPERATOR" OPERATOR)
				  (const :tag "OWNER_CALLSIGN" OWNER_CALLSIGN)
				  (const :tag "PFX" PFX)
				  (const :tag "POTA_REF" POTA_REF)
				  (const :tag "PRECEDENCE" PRECEDENCE)
				  (const :tag "PROP_MODE" PROP_MODE)
				  (const :tag "PUBLIC_KEY" PUBLIC_KEY)
				  (const :tag "QRZCOM_QSO_UPLOAD_DATE" QRZCOM_QSO_UPLOAD_DATE)
				  (const :tag "QRZCOM_QSO_UPLOAD_STATUS" QRZCOM_QSO_UPLOAD_STATUS)
				  (const :tag "QSLMSG" QSLMSG)
				  (const :tag "QSLMSG_INTL" QSLMSG_INTL)
				  (const :tag "QSLRDATE" QSLRDATE)
				  (const :tag "QSLSDATE" QSLSDATE)
				  (const :tag "QSL_RCVD" QSL_RCVD)
				  (const :tag "QSL_RCVD_VIA" QSL_RCVD_VIA)
				  (const :tag "QSL_SENT" QSL_SENT)
				  (const :tag "QSL_SENT_VIA" QSL_SENT_VIA)
				  (const :tag "QSL_VIA" QSL_VIA)
				  (const :tag "QSO_COMPLETE" QSO_COMPLETE)
;				  (const :tag "QSO_DATE" QSO_DATE)
				  (const :tag "QSO_DATE_OFF" QSO_DATE_OFF)
				  (const :tag "QSO_RANDOM" QSO_RANDOM)
				  (const :tag "QTH" QTH)
				  (const :tag "QTH_INTL" QTH_INTL)
				  (const :tag "REGION" REGION)
				  (const :tag "RIG" RIG)
				  (const :tag "RIG_INTL" RIG_INTL)
				  (const :tag "RST_RCVD" RST_RCVD)
				  (const :tag "RST_SENT" RST_SENT)
				  (const :tag "RX_PWR" RX_PWR)
				  (const :tag "SAT_MODE" SAT_MODE)
				  (const :tag "SAT_NAME" SAT_NAME)
				  (const :tag "SFI" SFI)
				  (const :tag "SIG" SIG)
				  (const :tag "SIG_INTL" SIG_INTL)
				  (const :tag "SIG_INFO" SIG_INFO)
				  (const :tag "SIG_INFO_INTL" SIG_INFO_INTL)
				  (const :tag "SILENT_KEY" SILENT_KEY)
				  (const :tag "SKCC" SKCC)
				  (const :tag "SOTA_REF" SOTA_REF)
				  (const :tag "SRX" SRX)
				  (const :tag "SRX_STRING" SRX_STRING)
				  (const :tag "STATE" STATE)
				  (const :tag "STATION_CALLSIGN" STATION_CALLSIGN)
				  (const :tag "STX" STX)
				  (const :tag "STX_STRING" STX_STRING)
				  (const :tag "SUBMODE" SUBMODE)
				  (const :tag "SWL" SWL)
				  (const :tag "TEN_TEN" TEN_TEN)
				  (const :tag "TIME_OFF" TIME_OFF)
;				  (const :tag "TIME_ON" TIME_ON)
				  (const :tag "TX_PWR" TX_PWR)
				  (const :tag "UKSMG" UKSMG)
				  (const :tag "USACA_COUNTIES" USACA_COUNTIES)
				  (const :tag "VE_PROV" VE_PROV)
				  (const :tag "VUCC_GRIDS" VUCC_GRIDS)
				  (const :tag "WEB" WEB)
				  (const :tag "WWFF_REF" WWFF_REF)
                                  (const :tag "Custom Choice" custom-choice))
                :value-type (boolean :tag "Clear after submission"))
  :group 'qso-logger)

(defvar qso-form-field-definitions
  '((ADDRESS . (editable-field :format "ADDRESS: %v\n" :size 40 :value ""))
    (ADDRESS_INTL . (editable-field :format "ADDRESS_INTL: %v\n" :size 40 :value ""))
    (AGE . (editable-field :format "AGE: %v\n" :size 40 :value ""))
    (ALTITUDE . (editable-field :format "ALTITUDE: %v\n" :size 40 :value ""))
    (ANT_AZ . (editable-field :format "ANT_AZ: %v\n" :size 40 :value ""))
    (ANT_EL . (editable-field :format "ANT_EL: %v\n" :size 40 :value ""))
    (ANT_PATH . (editable-field :format "ANT_PATH: %v\n" :size 40 :value ""))
    (ARRL_SECT . (editable-field :format "ARRL_SECT: %v\n" :size 40 :value ""))
    (AWARD_GRANTED . (editable-field :format "AWARD_GRANTED: %v\n" :size 40 :value ""))
    (AWARD_SUBMITTED . (editable-field :format "AWARD_SUBMITTED: %v\n" :size 40 :value ""))
    (A_INDEX . (editable-field :format "A_INDEX: %v\n" :size 40 :value ""))
    (BAND . (menu-choice :tag "BAND" :format "BAND: %[%v%]" :value ""
			 (item :tag "2190m" :value "2190m")
			 (item :tag "630m" :value "630m")
			 (item :tag "560m" :value "560m")
			 (item :tag "160m" :value "160m")
			 (item :tag "80m" :value "80m")
			 (item :tag "60m" :value "60m")
			 (item :tag "40m" :value "40m")
			 (item :tag "30m" :value "30m")
			 (item :tag "20m" :value "20m")
			 (item :tag "17m" :value "17m")
			 (item :tag "15m" :value "15m")
			 (item :tag "12m" :value "12m")
			 (item :tag "10m" :value "10m")
			 (item :tag "8m" :value "8m")
			 (item :tag "6m" :value "6m")
			 (item :tag "5m" :value "5m")
			 (item :tag "4m" :value "4m")
			 (item :tag "2m" :value "2m")
			 (item :tag "1.25m" :value "1.25m")
			 (item :tag "70cm" :value "70cm")
			 (item :tag "33cm" :value "33cm")
			 (item :tag "23cm" :value "23cm")
			 (item :tag "13cm" :value "13cm")
			 (item :tag "9cm" :value "9cm")
			 (item :tag "6cm" :value "6cm")
			 (item :tag "3cm" :value "3cm")
			 (item :tag "1.25cm" :value "1.25cm")
			 (item :tag "6mm" :value "6mm")
			 (item :tag "4mm" :value "4mm")
			 (item :tag "2.5mm" :value "2.5mm")
			 (item :tag "2mm" :value "2mm")
			 (item :tag "1mm" :value "1mm")
			 (item :tag "submm" :value "submm")))
    (BAND_RX . (editable-field :format "BAND_RX: %v\n" :size 40 :value ""))
    (CALL . (editable-field :format "CALL: %v\n" :size 10 :value ""))
    (CHECK . (editable-field :format "CHECK: %v\n" :size 40 :value ""))
    (CLASS . (editable-field :format "CLASS: %v\n" :size 40 :value ""))
    (CLUBLOG_QSO_UPLOAD_DATE . (editable-field :format "CLUBLOG_QSO_UPLOAD_DATE: %v\n" :size 40 :value ""))
    (CLUBLOG_QSO_UPLOAD_STATUS . (editable-field :format "CLUBLOG_QSO_UPLOAD_STATUS: %v\n" :size 40 :value ""))
    (CNTY . (editable-field :format "CNTY: %v\n" :size 40 :value ""))
    (COMMENT . (editable-field :format "COMMENT: %v\n" :size 40 :value ""))
    (COMMENT_INTL . (editable-field :format "COMMENT_INTL: %v\n" :size 40 :value ""))
    (CONT . (editable-field :format "CONT: %v\n" :size 40 :value ""))
    (CONTACTED_OP . (editable-field :format "CONTACTED_OP: %v\n" :size 40 :value ""))
    (CONTEST_ID . (editable-field :format "CONTEST_ID: %v\n" :size 40 :value ""))
    (COUNTRY . (editable-field :format "COUNTRY: %v\n" :size 40 :value ""))
    (COUNTRY_INTL . (editable-field :format "COUNTRY_INTL: %v\n" :size 40 :value ""))
    (CQZ . (editable-field :format "CQZ: %v\n" :size 40 :value ""))
    (CREDIT_SUBMITTED . (editable-field :format "CREDIT_SUBMITTED: %v\n" :size 40 :value ""))
    (CREDIT_GRANTED . (editable-field :format "CREDIT_GRANTED: %v\n" :size 40 :value ""))
    (DARC_DOK . (editable-field :format "DARC_DOK: %v\n" :size 40 :value ""))
    (DISTANCE . (editable-field :format "DISTANCE: %v\n" :size 40 :value ""))
    (DXCC . (editable-field :format "DXCC: %v\n" :size 40 :value ""))
    (EMAIL . (editable-field :format "EMAIL: %v\n" :size 40 :value ""))
    (EQ_CALL . (editable-field :format "EQ_CALL: %v\n" :size 40 :value ""))
    (EQSL_QSLRDATE . (editable-field :format "EQSL_QSLRDATE: %v\n" :size 40 :value ""))
    (EQSL_QSLSDATE . (editable-field :format "EQSL_QSLSDATE: %v\n" :size 40 :value ""))
    (EQSL_QSL_RCVD . (editable-field :format "EQSL_QSL_RCVD: %v\n" :size 40 :value ""))
    (EQSL_QSL_SENT . (editable-field :format "EQSL_QSL_SENT: %v\n" :size 40 :value ""))
    (FISTS . (editable-field :format "FISTS: %v\n" :size 40 :value ""))
    (FISTS_CC . (editable-field :format "FISTS_CC: %v\n" :size 40 :value ""))
    (FORCE_INIT . (editable-field :format "FORCE_INIT: %v\n" :size 40 :value ""))
    (FREQ . (editable-field :format "FREQ: %v\n" :size 10 :value ""))
    (FREQ_RX . (editable-field :format "FREQ_RX: %v\n" :size 40 :value ""))
    (GRIDSQUARE . (editable-field :format "GRIDSQUARE: %v\n" :size 40 :value ""))
    (GRIDSQUARE_EXT . (editable-field :format "GRIDSQUARE_EXT: %v\n" :size 40 :value ""))
    (GUEST_OP . (editable-field :format "GUEST_OP: %v\n" :size 40 :value ""))
    (HAMLOGEU_QSO_UPLOAD_DATE . (editable-field :format "HAMLOGEU_QSO_UPLOAD_DATE: %v\n" :size 40 :value ""))
    (HAMLOGEU_QSO_UPLOAD_STATUS . (editable-field :format "HAMLOGEU_QSO_UPLOAD_STATUS: %v\n" :size 40 :value ""))
    (HAMQTH_QSO_UPLOAD_DATE . (editable-field :format "HAMQTH_QSO_UPLOAD_DATE: %v\n" :size 40 :value ""))
    (HAMQTH_QSO_UPLOAD_STATUS . (editable-field :format "HAMQTH_QSO_UPLOAD_STATUS: %v\n" :size 40 :value ""))
    (HRDLOG_QSO_UPLOAD_DATE . (editable-field :format "HRDLOG_QSO_UPLOAD_DATE: %v\n" :size 40 :value ""))
    (HRDLOG_QSO_UPLOAD_STATUS . (editable-field :format "HRDLOG_QSO_UPLOAD_STATUS: %v\n" :size 40 :value ""))
    (IOTA . (editable-field :format "IOTA: %v\n" :size 40 :value ""))
    (IOTA_ISLAND_ID . (editable-field :format "IOTA_ISLAND_ID: %v\n" :size 40 :value ""))
    (ITUZ . (editable-field :format "ITUZ: %v\n" :size 40 :value ""))
    (K_INDEX . (editable-field :format "K_INDEX: %v\n" :size 40 :value ""))
    (LAT . (editable-field :format "LAT: %v\n" :size 40 :value ""))
    (LON . (editable-field :format "LON: %v\n" :size 40 :value ""))
    (LOTW_QSLRDATE . (editable-field :format "LOTW_QSLRDATE: %v\n" :size 40 :value ""))
    (LOTW_QSLSDATE . (editable-field :format "LOTW_QSLSDATE: %v\n" :size 40 :value ""))
    (LOTW_QSL_RCVD . (editable-field :format "LOTW_QSL_RCVD: %v\n" :size 40 :value ""))
    (LOTW_QSL_SENT . (editable-field :format "LOTW_QSL_SENT: %v\n" :size 40 :value ""))
    (MAX_BURSTS . (editable-field :format "MAX_BURSTS: %v\n" :size 40 :value ""))
    (MODE . (menu-choice :tag "MODE" :format "MODE: %[%v%]" :value ""
			  (item :tag "AM" :value "AM")
			  (item :tag "ARDOP" :value "ARDOP")
			  (item :tag "ATV" :value "ATV")
			  (item :tag "CHIP" :value "CHIP")
			  (item :tag "CLO" :value "CLO")
			  (item :tag "CONTESTI" :value "CONTESTI")
			  (item :tag "CW" :value "CW")
			  (item :tag "DIGITALVOICE" :value "DIGITALVOICE")
			  (item :tag "DOMINO" :value "DOMINO")
			  (item :tag "DYNAMIC" :value "DYNAMIC")
			  (item :tag "FAX" :value "FAX")
			  (item :tag "FM" :value "FM")
			  (item :tag "FSK441" :value "FSK441")
			  (item :tag "FT8" :value "FT8")
			  (item :tag "HELL" :value "HELL")
			  (item :tag "ISCAT" :value "ISCAT")
			  (item :tag "JT4" :value "JT4")
			  (item :tag "JT6M" :value "JT6M")
			  (item :tag "JT9" :value "JT9")
			  (item :tag "JT44" :value "JT44")
			  (item :tag "JT65" :value "JT65")
			  (item :tag "MFSK" :value "MFSK")
			  (item :tag "MSK144" :value "MSK144")
			  (item :tag "MT63" :value "MT63")
			  (item :tag "OLIVIA" :value "OLIVIA")
			  (item :tag "OPERA" :value "OPERA")
			  (item :tag "PAC" :value "PAC")
			  (item :tag "PAX" :value "PAX")
			  (item :tag "PKT" :value "PKT")
			  (item :tag "PSK" :value "PSK")
			  (item :tag "PSK2K" :value "PSK2K")
			  (item :tag "Q15" :value "Q15")
			  (item :tag "QRA64" :value "QRA64")
			  (item :tag "ROS" :value "ROS")
			  (item :tag "RTTY" :value "RTTY")
			  (item :tag "RTTYM" :value "RTTYM")
			  (item :tag "SSB" :value "SSB")
			  (item :tag "SSTV" :value "SSTV")
			  (item :tag "T10" :value "T10")
			  (item :tag "THOR" :value "THOR")
			  (item :tag "THRB" :value "THRB")
			  (item :tag "TOR" :value "TOR")
			  (item :tag "V4" :value "V4")
			  (item :tag "VOI" :value "VOI")
			  (item :tag "WINMOR" :value "WINMOR")
			  (item :tag "WSPR" :value "WSPR")))
    (MS_SHOWER . (editable-field :format "MS_SHOWER: %v\n" :size 40 :value ""))
    (MY_ALTITUDE . (editable-field :format "MY_ALTITUDE: %v\n" :size 40 :value ""))
    (MY_ANTENNA . (editable-field :format "MY_ANTENNA: %v\n" :size 40 :value ""))
    (MY_ARRL_SECT . (editable-field :format "MY_ARRL_SECT: %v\n" :size 40 :value ""))
    (MY_CITY . (editable-field :format "MY_CITY: %v\n" :size 40 :value ""))
    (MY_CITY_INTL . (editable-field :format "MY_CITY_INTL: %v\n" :size 40 :value ""))
    (MY_CNTY . (editable-field :format "MY_CNTY: %v\n" :size 40 :value ""))
    (MY_COUNTRY . (editable-field :format "MY_COUNTRY: %v\n" :size 40 :value ""))
    (MY_COUNTRY_INTL . (editable-field :format "MY_COUNTRY_INTL: %v\n" :size 40 :value ""))
    (MY_CQ_ZONE . (editable-field :format "MY_CQ_ZONE: %v\n" :size 40 :value ""))
    (MY_DXCC . (editable-field :format "MY_DXCC: %v\n" :size 40 :value ""))
    (MY_FISTS . (editable-field :format "MY_FISTS: %v\n" :size 40 :value ""))
    (MY_GRIDSQUARE . (editable-field :format "MY_GRIDSQUARE: %v\n" :size 40 :value ""))
    (MY_GRIDSQUARE_EXT . (editable-field :format "MY_GRIDSQUARE_EXT: %v\n" :size 40 :value ""))
    (MY_IOTA . (editable-field :format "MY_IOTA: %v\n" :size 40 :value ""))
    (MY_IOTA_ISLAND_ID . (editable-field :format "MY_IOTA_ISLAND_ID: %v\n" :size 40 :value ""))
    (MY_ITU_ZONE . (editable-field :format "MY_ITU_ZONE: %v\n" :size 40 :value ""))
    (MY_LAT . (editable-field :format "MY_LAT: %v\n" :size 40 :value ""))
    (MY_LON . (editable-field :format "MY_LON: %v\n" :size 40 :value ""))
    (MY_NAME . (editable-field :format "MY_NAME: %v\n" :size 40 :value ""))
    (MY_NAME_INTL . (editable-field :format "MY_NAME_INTL: %v\n" :size 40 :value ""))
    (MY_POSTAL_CODE . (editable-field :format "MY_POSTAL_CODE: %v\n" :size 40 :value ""))
    (MY_POSTAL_CODE_INTL . (editable-field :format "MY_POSTAL_CODE_INTL: %v\n" :size 40 :value ""))
    (MY_POTA_REF . (editable-field :format "MY_POTA_REF: %v\n" :size 40 :value ""))
    (MY_RIG . (editable-field :format "MY_RIG: %v\n" :size 40 :value ""))
    (MY_RIG_INTL . (editable-field :format "MY_RIG_INTL: %v\n" :size 40 :value ""))
    (MY_SIG . (editable-field :format "MY_SIG: %v\n" :size 40 :value ""))
    (MY_SIG_INTL . (editable-field :format "MY_SIG_INTL: %v\n" :size 40 :value ""))
    (MY_SIG_INFO . (editable-field :format "MY_SIG_INFO: %v\n" :size 40 :value ""))
    (MY_SIG_INFO_INTL . (editable-field :format "MY_SIG_INFO_INTL: %v\n" :size 40 :value ""))
    (MY_SOTA_REF . (editable-field :format "MY_SOTA_REF: %v\n" :size 40 :value ""))
    (MY_STATE . (editable-field :format "MY_STATE: %v\n" :size 40 :value ""))
    (MY_STREET . (editable-field :format "MY_STREET: %v\n" :size 40 :value ""))
    (MY_STREET_INTL . (editable-field :format "MY_STREET_INTL: %v\n" :size 40 :value ""))
    (MY_USACA_COUNTIES . (editable-field :format "MY_USACA_COUNTIES: %v\n" :size 40 :value ""))
    (MY_VUCC_GRIDS . (editable-field :format "MY_VUCC_GRIDS: %v\n" :size 40 :value ""))
    (MY_WWFF_REF . (editable-field :format "MY_WWFF_REF: %v\n" :size 40 :value ""))
    (NAME . (editable-field :format "NAME: %v\n" :size 40 :value ""))
    (NAME_INTL . (editable-field :format "NAME_INTL: %v\n" :size 40 :value ""))
    (NOTES . (editable-field :format "NOTES: %v\n" :size 40 :value ""))
    (NOTES_INTL . (editable-field :format "NOTES_INTL: %v\n" :size 40 :value ""))
    (NR_BURSTS . (editable-field :format "NR_BURSTS: %v\n" :size 40 :value ""))
    (NR_PINGS . (editable-field :format "NR_PINGS: %v\n" :size 40 :value ""))
;    (OPERATOR . (editable-field :format "OPERATOR: %v\n" :size 40 :value ""))
    (OWNER_CALLSIGN . (editable-field :format "OWNER_CALLSIGN: %v\n" :size 40 :value ""))
    (PFX . (editable-field :format "PFX: %v\n" :size 40 :value ""))
    (POTA_REF . (editable-field :format "POTA_REF: %v\n" :size 40 :value ""))
    (PRECEDENCE . (editable-field :format "PRECEDENCE: %v\n" :size 40 :value ""))
    (PROP_MODE . (menu-choice :tag "PROP_MODE" :format "PROP_MODE: %[%v%]" :value ""
			      (item :tag "Aircraft Scatter" :value "AS")
			      (item :tag "Aurora-E" :value "AUE")
			      (item :tag "Aurora" :value "AUR")
			      (item :tag "Back scatter" :value "BS")
			      (item :tag "EchoLink" :value "ECH")
			      (item :tag "Earth-Moon-Earth" :value "EME")
			      (item :tag "Sporadic E" :value "ES")
			      (item :tag "F2 Reflection" :value "F2")
			      (item :tag "Field Aligned Irregularities" :value "FAI")
			      (item :tag "Ground Wave" :value "GWAVE")
			      (item :tag "Internet-assisted" :value "INTERNET")
			      (item :tag "Ionoscatter" :value "ION")
			      (item :tag "IRLP" :value "IRL")
			      (item :tag "Line of Sight (includes transmission through obstacles such as walls)" :value "LOS")
			      (item :tag "Meteor scatter" :value "MS")
			      (item :tag "Terrestrial or atmospheric repeater or transponder" :value "RPT")
			      (item :tag "Rain scatter" :value "RS")
			      (item :tag "Satellite" :value "SAT")
			      (item :tag "Trans-equatorial" :value "TEP")
			      (item :tag "Tropospheric ducting" :value "TR")))
    (PUBLIC_KEY . (editable-field :format "PUBLIC_KEY: %v\n" :size 40 :value ""))
    (QRZCOM_QSO_UPLOAD_DATE . (editable-field :format "QRZCOM_QSO_UPLOAD_DATE: %v\n" :size 40 :value ""))
    (QRZCOM_QSO_UPLOAD_STATUS . (editable-field :format "QRZCOM_QSO_UPLOAD_STATUS: %v\n" :size 40 :value ""))
    (QSLMSG . (editable-field :format "QSLMSG: %v\n" :size 40 :value ""))
    (QSLMSG_INTL . (editable-field :format "QSLMSG_INTL: %v\n" :size 40 :value ""))
    (QSLRDATE . (editable-field :format "QSLRDATE: %v\n" :size 40 :value ""))
    (QSLSDATE . (editable-field :format "QSLSDATE: %v\n" :size 40 :value ""))
    (QSL_RCVD . (editable-field :format "QSL_RCVD: %v\n" :size 40 :value ""))
    (QSL_RCVD_VIA . (editable-field :format "QSL_RCVD_VIA: %v\n" :size 40 :value ""))
    (QSL_SENT . (editable-field :format "QSL_SENT: %v\n" :size 40 :value ""))
    (QSL_SENT_VIA . (editable-field :format "QSL_SENT_VIA: %v\n" :size 40 :value ""))
    (QSL_VIA . (editable-field :format "QSL_VIA: %v\n" :size 40 :value ""))
    (QSO_COMPLETE . (editable-field :format "QSO_COMPLETE: %v\n" :size 40 :value ""))
    (QSO_DATE . (editable-field :format "QSO_DATE: %v\n" :size 40 :value ""))
    (QSO_DATE_OFF . (editable-field :format "QSO_DATE_OFF: %v\n" :size 40 :value ""))
    (QSO_RANDOM . (editable-field :format "QSO_RANDOM: %v\n" :size 40 :value ""))
    (QTH . (editable-field :format "QTH: %v\n" :size 40 :value ""))
    (QTH_INTL . (editable-field :format "QTH_INTL: %v\n" :size 40 :value ""))
    (REGION . (editable-field :format "REGION: %v\n" :size 40 :value ""))
    (RIG . (editable-field :format "RIG: %v\n" :size 40
    :value ""))
    (RIG_INTL . (editable-field :format "RIG_INTL: %v\n" :size 40 :value ""))
    (RST_RCVD . (editable-field :format "RST_RCVD: %v\n" :size 6 :value ""))
    (RST_SENT . (editable-field :format "RST_SENT: %v\n" :size 6 :value ""))
    (RX_PWR . (editable-field :format "RX_PWR: %v\n" :size 40 :value ""))
    (SAT_MODE . (editable-field :format "SAT_MODE: %v\n" :size 40 :value ""))
    (SAT_NAME . (editable-field :format "SAT_NAME: %v\n" :size 40 :value ""))
    (SFI . (editable-field :format "SFI: %v\n" :size 40 :value ""))
    (SIG . (editable-field :format "SIG: %v\n" :size 40 :value ""))
    (SIG_INTL . (editable-field :format "SIG_INTL: %v\n" :size 40 :value ""))
    (SIG_INFO . (editable-field :format "SIG_INFO: %v\n" :size 40 :value ""))
    (SIG_INFO_INTL . (editable-field :format "SIG_INFO_INTL: %v\n" :size 40 :value ""))
    (SILENT_KEY . (editable-field :format "SILENT_KEY: %v\n" :size 40 :value ""))
    (SKCC . (editable-field :format "SKCC: %v\n" :size 40 :value ""))
    (SOTA_REF . (editable-field :format "SOTA_REF: %v\n" :size 40 :value ""))
    (SRX . (editable-field :format "SRX: %v\n" :size 40 :value ""))
    (SRX_STRING . (editable-field :format "SRX_STRING: %v\n" :size 40 :value ""))
    (STATE . (editable-field :format "STATE: %v\n" :size 40 :value ""))
    (STATION_CALLSIGN . (editable-field :format "STATION_CALLSIGN: %v\n" :size 40 :value ""))
    (STX . (editable-field :format "STX: %v\n" :size 40 :value ""))
    (STX_STRING . (editable-field :format "STX_STRING: %v\n" :size 40 :value ""))
    (SUBMODE . (menu-choice :format "SUBMODE: %[%v%]" :value ""
			    (item :tag "8PSK125 (PSK)" :value "8PSK125")
			    (item :tag "8PSK125F (PSK)" :value "8PSK125F")
			    (item :tag "8PSK125FL (PSK)" :value "8PSK125FL")
			    (item :tag "8PSK250 (PSK)" :value "8PSK250")
			    (item :tag "8PSK250F (PSK)" :value "8PSK250F")
			    (item :tag "8PSK250FL (PSK)" :value "8PSK250FL")
			    (item :tag "8PSK500 (PSK)" :value "8PSK500")
			    (item :tag "8PSK500F (PSK)" :value "8PSK500F")
			    (item :tag "8PSK1000 (PSK)" :value "8PSK1000")
			    (item :tag "8PSK1000F (PSK)" :value "8PSK1000F")
			    (item :tag "8PSK1200F (PSK)" :value "8PSK1200F")
			    (item :tag "AMTORFEC (TOR)" :value "AMTORFEC")
			    (item :tag "ASCI (RTTY)" :value "ASCI")
			    (item :tag "C4FM (DIGITALVOICE)" :value "C4FM")
			    (item :tag "CHIP64 (CHIP)" :value "CHIP64")
			    (item :tag "CHIP128 (CHIP)" :value "CHIP128")
			    (item :tag "DMR (DIGITALVOICE)" :value "DMR")
			    (item :tag "DOM-M (DOMINO)" :value "DOM-M")
			    (item :tag "DOM4 (DOMINO)" :value "DOM4")
			    (item :tag "DOM5 (DOMINO)" :value "DOM5")
			    (item :tag "DOM8 (DOMINO)" :value "DOM8")
			    (item :tag "DOM11 (DOMINO)" :value "DOM11")
			    (item :tag "DOM16 (DOMINO)" :value "DOM16")
			    (item :tag "DOM22 (DOMINO)" :value "DOM22")
			    (item :tag "DOM44 (DOMINO)" :value "DOM44")
			    (item :tag "DOM88 (DOMINO)" :value "DOM88")
			    (item :tag "DOMINOEX (DOMINO)" :value "DOMINOEX")
			    (item :tag "DOMINOF (DOMINO)" :value "DOMINOF")
			    (item :tag "DSTAR (DIGITALVOICE)" :value "DSTAR")
			    (item :tag "FMHELL (HELL)" :value "FMHELL")
			    (item :tag "FREEDV (DIGITALVOICE)" :value "FREEDV")
			    (item :tag "FSK31 (PSK)" :value "FSK31")
			    (item :tag "FSKHELL (HELL)" :value "FSKHELL")
			    (item :tag "FSQCALL (MFSK)" :value "FSQCALL")
			    (item :tag "FST4 (MFSK)" :value "FST4")
			    (item :tag "FST4W (MFSK)" :value "FST4W")
			    (item :tag "FT4 (MFSK)" :value "FT4")
			    (item :tag "GTOR (TOR)" :value "GTOR")
			    (item :tag "HELL80 (HELL)" :value "HELL80")
			    (item :tag "HELLX5 (HELL)" :value "HELLX5")
			    (item :tag "HELLX9 (HELL)" :value "HELLX9")
			    (item :tag "HFSK (HELL)" :value "HFSK")
			    (item :tag "ISCAT-A (ISCAT)" :value "ISCAT-A")
			    (item :tag "ISCAT-B (ISCAT)" :value "ISCAT-B")
			    (item :tag "JS8 (MFSK)" :value "JS8")
			    (item :tag "JT4A (JT4)" :value "JT4A")
			    (item :tag "JT4B (JT4)" :value "JT4B")
			    (item :tag "JT4C (JT4)" :value "JT4C")
			    (item :tag "JT4D (JT4)" :value "JT4D")
			    (item :tag "JT4E (JT4)" :value "JT4E")
			    (item :tag "JT4F (JT4)" :value "JT4F")
			    (item :tag "JT4G (JT4)" :value "JT4G")
			    (item :tag "JT9-1 (JT9)" :value "JT9-1")
			    (item :tag "JT9-2 (JT9)" :value "JT9-2")
			    (item :tag "JT9-5 (JT9)" :value "JT9-5")
			    (item :tag "JT9-10 (JT9)" :value "JT9-10")
			    (item :tag "JT9-30 (JT9)" :value "JT9-30")
			    (item :tag "JT9A (JT9)" :value "JT9A")
			    (item :tag "JT9B (JT9)" :value "JT9B")
			    (item :tag "JT9C (JT9)" :value "JT9C")
			    (item :tag "JT9D (JT9)" :value "JT9D")
			    (item :tag "JT9E (JT9)" :value "JT9E")
			    (item :tag "JT9E FAST (JT9)" :value "JT9E FAST")
			    (item :tag "JT9F (JT9)" :value "JT9F")
			    (item :tag "JT9F FAST (JT9)" :value "JT9F FAST")
			    (item :tag "JT9G (JT9)" :value "JT9G")
			    (item :tag "JT9G FAST (JT9)" :value "JT9G FAST")
			    (item :tag "JT9H (JT9)" :value "JT9H")
			    (item :tag "JT9H FAST (JT9)" :value "JT9H FAST")
			    (item :tag "JT65A (JT65)" :value "JT65A")
			    (item :tag "JT65B (JT65)" :value "JT65B")
			    (item :tag "JT65B2 (JT65)" :value "JT65B2")
			    (item :tag "JT65C (JT65)" :value "JT65C")
			    (item :tag "JT65C2 (JT65)" :value "JT65C2")
			    (item :tag "JTMS (MFSK)" :value "JTMS")
			    (item :tag "LSB (SSB)" :value "LSB")
			    (item :tag "M17 (DIGITALVOICE)" :value "M17")
			    (item :tag "MFSK4 (MFSK)" :value "MFSK4")
			    (item :tag "MFSK8 (MFSK)" :value "MFSK8")
			    (item :tag "MFSK11 (MFSK)" :value "MFSK11")
			    (item :tag "MFSK16 (MFSK)" :value "MFSK16")
			    (item :tag "MFSK22 (MFSK)" :value "MFSK22")
			    (item :tag "MFSK31 (MFSK)" :value "MFSK31")
			    (item :tag "MFSK32 (MFSK)" :value "MFSK32")
			    (item :tag "MFSK64 (MFSK)" :value "MFSK64")
			    (item :tag "MFSK64L (MFSK)" :value "MFSK64L")
			    (item :tag "MFSK128 (MFSK)" :value "MFSK128")
			    (item :tag "MFSK128L (MFSK)" :value "MFSK128L")
			    (item :tag "NAVTEX (TOR)" :value "NAVTEX")
			    (item :tag "OLIVIA 4/125 (OLIVIA)" :value "OLIVIA 4/125")
			    (item :tag "OLIVIA 4/250 (OLIVIA)" :value "OLIVIA 4/250")
			    (item :tag "OLIVIA 8/250 (OLIVIA)" :value "OLIVIA 8/250")
			    (item :tag "OLIVIA 8/500 (OLIVIA)" :value "OLIVIA 8/500")
			    (item :tag "OLIVIA 16/500 (OLIVIA)" :value "OLIVIA 16/500")
			    (item :tag "OLIVIA 16/1000 (OLIVIA)" :value "OLIVIA 16/1000")
			    (item :tag "OLIVIA 32/1000 (OLIVIA)" :value "OLIVIA 32/1000")
			    (item :tag "OPERA-BEACON (OPERA)" :value "OPERA-BEACON")
			    (item :tag "OPERA-QSO (OPERA)" :value "OPERA-QSO")
			    (item :tag "PAC2 (PAC)" :value "PAC2")
			    (item :tag "PAC3 (PAC)" :value "PAC3")
			    (item :tag "PAC4 (PAC)" :value "PAC4")
			    (item :tag "PAX2 (PAX)" :value "PAX2")
			    (item :tag "PCW (CW)" :value "PCW")
			    (item :tag "PSK10 (PSK)" :value "PSK10")
			    (item :tag "PSK31 (PSK)" :value "PSK31")
			    (item :tag "PSK63 (PSK)" :value "PSK63")
			    (item :tag "PSK63F (PSK)" :value "PSK63F")
			    (item :tag "PSK63RC10 (PSK)" :value "PSK63RC10")
			    (item :tag "PSK63RC20 (PSK)" :value "PSK63RC20")
			    (item :tag "PSK63RC32 (PSK)" :value "PSK63RC32")
			    (item :tag "PSK63RC4 (PSK)" :value "PSK63RC4")
			    (item :tag "PSK63RC5 (PSK)" :value "PSK63RC5")
			    (item :tag "PSK125 (PSK)" :value "PSK125")
			    (item :tag "PSK125RC10 (PSK)" :value "PSK125RC10")
			    (item :tag "PSK125RC12 (PSK)" :value "PSK125RC12")
			    (item :tag "PSK125RC16 (PSK)" :value "PSK125RC16")
			    (item :tag "PSK125RC4 (PSK)" :value "PSK125RC4")
			    (item :tag "PSK125RC5 (PSK)" :value "PSK125RC5")
			    (item :tag "PSK250 (PSK)" :value "PSK250")
			    (item :tag "PSK250RC2 (PSK)" :value "PSK250RC2")
			    (item :tag "PSK250RC3 (PSK)" :value "PSK250RC3")
			    (item :tag "PSK250RC5 (PSK)" :value "PSK250RC5")
			    (item :tag "PSK250RC6 (PSK)" :value "PSK250RC6")
			    (item :tag "PSK250RC7 (PSK)" :value "PSK250RC7")
			    (item :tag "PSK500 (PSK)" :value "PSK500")
			    (item :tag "PSK500RC2 (PSK)" :value "PSK500RC2")
			    (item :tag "PSK500RC3 (PSK)" :value "PSK500RC3")
			    (item :tag "PSK500RC4 (PSK)" :value "PSK500RC4")
			    (item :tag "PSK800RC2 (PSK)" :value "PSK800RC2")
			    (item :tag "PSK1000 (PSK)" :value "PSK1000")
			    (item :tag "PSK1000RC2 (PSK)" :value "PSK1000RC2")
			    (item :tag "PSKAM10 (PSK)" :value "PSKAM10")
			    (item :tag "PSKAM31 (PSK)" :value "PSKAM31")
			    (item :tag "PSKAM50 (PSK)" :value "PSKAM50")
			    (item :tag "PSKFEC31 (PSK)" :value "PSKFEC31")
			    (item :tag "PSKHELL (HELL)" :value "PSKHELL")
			    (item :tag "QPSK31 (PSK)" :value "QPSK31")
			    (item :tag "Q65 (MFSK)" :value "Q65")
			    (item :tag "QPSK63 (PSK)" :value "QPSK63")
			    (item :tag "QPSK125 (PSK)" :value "QPSK125")
			    (item :tag "QPSK250 (PSK)" :value "QPSK250")
			    (item :tag "QPSK500 (PSK)" :value "QPSK500")
			    (item :tag "QRA64A (QRA64)" :value "QRA64A")
			    (item :tag "QRA64B (QRA64)" :value "QRA64B")
			    (item :tag "QRA64C (QRA64)" :value "QRA64C")
			    (item :tag "QRA64D (QRA64)" :value "QRA64D")
			    (item :tag "QRA64E (QRA64)" :value "QRA64E")
			    (item :tag "ROS-EME (ROS)" :value "ROS-EME")
			    (item :tag "ROS-HF (ROS)" :value "ROS-HF")
			    (item :tag "ROS-MF (ROS)" :value "ROS-MF")
			    (item :tag "SIM31 (PSK)" :value "SIM31")
			    (item :tag "SITORB (TOR)" :value "SITORB")
			    (item :tag "SLOWHELL (HELL)" :value "SLOWHELL")
			    (item :tag "THOR-M (THOR)" :value "THOR-M")
			    (item :tag "THOR4 (THOR)" :value "THOR4")
			    (item :tag "THOR5 (THOR)" :value "THOR5")
			    (item :tag "THOR8 (THOR)" :value "THOR8")
			    (item :tag "THOR11 (THOR)" :value "THOR11")
			    (item :tag "THOR16 (THOR)" :value "THOR16")
			    (item :tag "THOR22 (THOR)" :value "THOR22")
			    (item :tag "THOR25X4 (THOR)" :value "THOR25X4")
			    (item :tag "THOR50X1 (THOR)" :value "THOR50X1")
			    (item :tag "THOR50X2 (THOR)" :value "THOR50X2")
			    (item :tag "THOR100 (THOR)" :value "THOR100")
			    (item :tag "THRBX (THRB)" :value "THRBX")
			    (item :tag "THRBX1 (THRB)" :value "THRBX1")
			    (item :tag "THRBX2 (THRB)" :value "THRBX2")
			    (item :tag "THRBX4 (THRB)" :value "THRBX4")
			    (item :tag "THROB1 (THRB)" :value "THROB1")
			    (item :tag "THROB2 (THRB)" :value "THROB2")
			    (item :tag "THROB4 (THRB)" :value "THROB4")
			    (item :tag "USB (SSB)" :value "USB")
			    (item :tag "VARA HF (DYNAMIC)" :value "VARA HF")
			    (item :tag "VARA SATELLITE (DYNAMIC)" :value "VARA SATELLITE")
			    (item :tag "VARA FM 1200 (DYNAMIC)" :value "VARA FM 1200")
			    (item :tag "VARA FM 9600 (DYNAMIC)" :value "VARA FM 9600")))
    (SWL . (editable-field :format "SWL: %v\n" :size 40 :value ""))
    (TEN_TEN . (editable-field :format "TEN_TEN: %v\n" :size 40 :value ""))
    (TIME_OFF . (editable-field :format "TIME_OFF: %v\n" :size 40 :value ""))
    (TIME_ON . (editable-field :format "TIME_ON: %v\n" :size 40 :value ""))
    (TX_PWR . (editable-field :format "TX_PWR: %v\n" :size 40 :value ""))
    (UKSMG . (editable-field :format "UKSMG: %v\n" :size 40 :value ""))
    (USACA_COUNTIES . (editable-field :format "USACA_COUNTIES: %v\n" :size 40 :value ""))
    (VE_PROV . (editable-field :format "VE_PROV: %v\n" :size 40 :value ""))
    (VUCC_GRIDS . (editable-field :format "VUCC_GRIDS: %v\n" :size 40 :value ""))
    (WEB . (editable-field :format "WEB: %v\n" :size 40 :value ""))
    (WWFF_REF . (editable-field :format "WWFF_REF: %v\n" :size 40 :value ""))
    (custom-choice . (menu-choice :tag "Choose" :format "Choose: %[%v%]\n" :value "This"
                                  :help-echo "Choose me, please!"
                                  :notify (lambda (widget &rest ignore)
                                            (message "%s is a good choice!"
                                                     (widget-value widget)))
                                  (item :tag "This option" :value "This")
                                  (item :tag "That option" :value "That")
                                  (editable-field :menu-tag "No option" :value "Thus option"))))
  "QSO field definitions for the QSO Log Entry form.")

(defun qso-log-form ()
  "Create a dynamic QSO form based on `qso-form-fields`."
  (interactive)
  (switch-to-buffer "*QSO Log Entry*")
  (kill-all-local-variables)
  (let ((inhibit-read-only t))
    (erase-buffer))
  (remove-overlays)
  (widget-insert "OPERATOR: " OPERATOR " \n")
  (let ((widget-alist '()))
    ;; Create widgets for each field and store in widget-alist in the same order
    (dolist (field-info qso-form-fields)
      (let* ((field (car field-info))
             (clear-after-submit (cdr field-info))
             (field-definition (alist-get field qso-form-field-definitions)))
        (when field-definition
          (let ((widget (apply 'widget-create field-definition)))
            (setq widget-alist (append widget-alist (list (list field widget clear-after-submit))))))))

    ;; Add submit and quit buttons
    (widget-insert "\n")
    (widget-create 'push-button
                   :notify (lambda (&rest _)
                             (let ((adif-string ""))
                               ;; Collect data from each widget
                               (dolist (field-pair widget-alist)
                                 (let* ((field (nth 0 field-pair))
                                        (widget (nth 1 field-pair))
                                        (clear-after-submit (nth 2 field-pair))
                                        (value (widget-value widget)))
				   ;; Generate the adif-string with non-empty field values
				   (unless (string-empty-p value)
                                     (setq adif-string
                                           (concat adif-string
                                                   (format "<%s:%d>%s"
                                                           (upcase (symbol-name field))
                                                           (length (format "%s" value))
                                                           value))))
                                   ;; Clear the widget if it is marked for clearing
                                   (when clear-after-submit
                                     (widget-value-set widget ""))))
                               ;; Append data to file
                               (with-temp-buffer
                                 (insert "<QSODATE:8>" (format-time-string "%Y%m%d" (current-time) t)
					 "<TIME_ON:6>" (format-time-string "%H%M%S" (current-time) t)
					 adif-string
					 "<OPERATOR:" 
					 (format "%d" (length (format "%s" OPERATOR))) ">"
					 (format "%s" OPERATOR)"<eor>\n")
                                 (write-region (point-min) (point-max) qso-adif-path t)))
                             (message "QSO logged!"))
                   "Submit")
    (widget-insert " ") ;; Add a space between buttons
    (widget-create 'push-button
                   :notify (lambda (&rest _)
                             (kill-buffer "*QSO Log Entry*"))
                   "Quit")
    (use-local-map widget-keymap)
    (widget-setup)))

(provide 'qsologger)
;;; qsologger.el ends here
