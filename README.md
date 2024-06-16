# Emacs-QSO-Logger
This LISP code provides some basic functions for Emacs to rapidly capture and log amateur radio contacts (QSOs).
Further processing of the logs can be done within Emacs or by importing the ADIF file into another logging program. 

There are two, independent sets of code provided with different features. Use only one of them. 
  - qso.el has some very basic QSO logging features with a fixed set of fields.
  - qsologger.el provides for a customizable, dynamic form to log QSOs and with the ability to add almost any ADIF 
    field in the ADIF 3.1.4 specification. 

Each of these is customizable.
