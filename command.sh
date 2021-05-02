#!/bin/bash

if [ -f "l.o" ] ; then
    rm "l.o"
fi

if [ -f "y.o" ] ; then
    rm "y.o"
fi

if [ -f "lex.yy.c" ] ; then
    rm "lex.yy.c"
fi

if [ -f "y.tab.c" ] ; then
    rm "y.tab.c"
fi

if [ -f "y.tab.h" ] ; then
    rm "y.tab.h"
fi

if [ -f "a.out" ] ; then
    rm "a.out"
fi

yacc -d -y 1705078.y
echo 'Generated the parser C file as well the header file'
g++ -w -c -o y.o y.tab.c
echo 'Generated the parser object file'
flex 1705078.l
echo 'Generated the scanner C file'
g++ -w -c -o l.o lex.yy.c
# if the above command doesn't work try g++ -fpermissive -w -c -o l.o lex.yy.c
echo 'Generated the scanner object file'
g++ y.o l.o -lfl
echo 'All ready, running'
./a.out $1
