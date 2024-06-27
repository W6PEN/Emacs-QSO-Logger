# Emacs-QSO-Logger
This LISP code provides some basic functions for Emacs to rapidly capture and log amateur radio contacts (QSOs).
qsologger.el provides a fuction that generates a customizable, dynamic form (qso-log-form) for the purposes of 
logging amateur radio QSOs using almost any combination of ADIF fields in the ADIF 3.1.4 specification. This allows 
the user to customize the form for use in constests or general logging. All customizations are accessable in the 
qso-logger group, whose parent is the Emacs "Applications" group, accessed with `M-x customize`.

Further processing of the logs can be done within Emacs or by importing the ADIF file into another logging program.  

## Installation
1) Place qsologger.el in the load path. If one hasn't been established, you can place it in `~/.emacs.d/lisp/` and
   then, in the init.el file (located in ~/.emacs.d/) add: `(add-to-list 'load-path "~/.emacs.d/lisp/")`
2) Add to the init.el file: `(require 'qsologger)`
3) Restart Emacs

## Getting Started
1) Execute `M-x customize`, select "Applications" and then select "QSO Logger" to see the customization options
2) Enter your callsign in the Operator field.
3) Enter the path to the ADIF file you will be using (e.g. `~/qsolog.adi`)
4) Add, remove, or reorder the fields you wish to have on the form.
5) Select or deselect form fields that you wish you have cleared after a QSO submission (especially helpful for costests)
6) Click "Apply" or "Apply and Save" as appropriate.
7) Execute `M-x qso-log-form` to bring up and begin using the log entry form.
