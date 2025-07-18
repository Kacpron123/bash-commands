#!/bin/bash

filesrc="src"
fileotut="out"

jvfile(){
   local remove_files=false
   local code_files=false
   OPTIND=1
   while getopts ":cr" opt; do
      case $opt in
         r)
            if [ "$remove_files" = "c" ]; then
               echo -e 'you cannot use flag -r and -c together'
               exit 1
            fi
            remove_files=true
            ;;
         c)
            if [ "$remove_files" = "true" ]; then
               echo -e 'you cannot use flag -r and -c together'
               exit 1
            fi
            if [ ! command -v code &> /dev/null ]; then
              echo "Error: 'code' command not found. Please install a code editor or modify the script to use a different editor."
              exit 1
            fi
            code_files=true
            ;;
         *)
            exit 1
            ;;
         esac
      done
   shift $((OPTIND - 1))
   if [ $# -eq 0 ]; then
      echo -e 'give names of filesn\-r: remove files'
   else
      mkdir -p $filesrc
      for file in "$@"; do
         if [ "$remove_files" = true ]; then
            read -p "are you sure to delete $file? (y/n) " -n 1 -r
            echo  ""
            if [[ $REPLY =~ ^[Yy]$ ]]; then
               rm -f $filesrc/"$file.java"
            fi
         else
            # $file.java
            if [ ! -f $filesrc/"$file.java" ]; then
               touch $filesrc/"$file.java"
               echo -e "class $file{\nprivate \npublic \n}" >> $filesrc/"$file.java"
               fi
            if [ "$code_files" = true ]; then
               code $filesrc/"$file.java"
               fi
         fi
         done
      fi
}
jvmake(){
   mkdir -p $fileout
   javac -d $fileout $filesrc/*.java
}

jvrun(){
   java $fileout/$@
}
jvtree(){
   tree -I target
}