#!/bin/bash
fileinclude="include"
filesrc="src"
Project_name=""

cppproject(){
   local test=false
   while getopts "t" opt;do
      case $opt in
         t)
            test=true;
            ;;
         *)
            exit 1
            ;;
      esac
   done
   shift $((OPTIND - 1))
   if [ $# -eq 0 ]; then
      echo 'podaj nazwę projektu'
      exit 1
   else
      local Project_name=$1
      mkdir $Project_name
      cd $Project_name
      #creting project folder
      touch README.md
      mkdir $fileinclude $filesrc build
      if $test; then
         mkdir tests
      fi
      touch "Main.cpp"
      #code "Main.cpp"
      if [ $utilityfolder != "" ];then
         cp "$utilityfolder/defaultCMake" CMakeLists.txt
         sed -i -E "s/^project\(([^)]+)\)/project(${Project_name})/" "CMakeLists.txt"
      fi
      code .
      ls
   fi
}

cppfile(){
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
      mkdir -p $fileinclude $filesrc
      for file in "$@"; do
         local defines=$(echo "${file^^}_H" | tr -cs 'A-Z0-9' '_')
         if [ "$remove_files" = true ]; then
            read -p "are you sure to delete $file? (y/n) " -n 1 -r
            echo  ""
            if [[ $REPLY =~ ^[Yy]$ ]]; then
               rm -f $filesrc/"$file.cpp" $fileinclude/"$file.h"
            fi
         else
            # $file.h
            if [ ! -f $fileinclude/"$file.h" ]; then
               touch $fileinclude/"$file.h"
               echo -e "#ifndef $defines\n#define $defines\n" > $fileinclude/"$file.h"
               echo -e "class $file{\nprotected:\nprivate:\npublic:\n};\n#endif" >> $fileinclude/"$file.h"
               fi
            # $file.cpp
            if [ ! -f $filesrc/"$file.cpp" ]; then
               touch $filesrc/"$file.cpp"
               echo -e "#include \"$file.h\"\n" > $filesrc/"$file.cpp"
               fi
            # code
            if [ "$code_files" = true ]; then
               code $filesrc/"$file.cpp"
               code $fileinclude/"$file.h"
               fi   
            fi
         done
      fi
}

cppmake(){
      if [ ! -f CMakeLists.txt ];then
         echo 'brak pliku CMakeLists.txt'
      else
         # for now make as executable from ${PROJECT_NAME}
         local projectname=$(grep -Eo 'project\(([^)]+)\)' CMakeLists.txt | cut -d'(' -f2 | cut -d')' -f1)
         if [ ! -d build ];then
            mkdir build
         fi
         # subshell
         (
         cd build
         if [ ! -f Makefile ];then
            cmake ..  > /dev/null
         fi
         make > /dev/null && ./${projectname} "$@"
         )
      fi
}

cpptree(){
   tree -I 'build' .
}
cpprmbuild(){
   if [ -d build ];then
      rm -rf build/*
   fi
   if [ "$(basename "$(pwd)")" == "build" ]; then
      rm -rf *
   fi
}
cpptar(){
   tar --exclude='build' -czvf project.tar.gz *
}
cpprun(){
   if [ ! -d build ]; then
      mkdir build
   fi
   g++ Main.cpp -o build/Main
   ./build/Main
}

