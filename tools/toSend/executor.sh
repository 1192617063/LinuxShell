#!/usr/bin/env bash
expect << eof
    spawn ssh-keygen -t rsa
    expect {
        "assword*"                              {send "$1\n"   ; exp_continue}
        "yes/no*"                               {send "yes\n"  ; exp_continue}
        "Enter file in which to save the key*"  {send "\n"     ; exp_continue}
        "Enter passphrase*"                     {send "\n"     ; exp_continue}
        "Enter same passphrase again*"          {send "\n"     ; exp_continue}
        "Overwrite (y/n)*"                      {send "y\n"    ; exp_continue}
        eof                                     {exit}
    }
eof