100 print"  +----------------------------------+"
110 print"  !         edlisp64 v0.1 dev        !"
115 print"  !  a very minimal list processor   !"
120 print"  !  (c)2019 by ir. marc dendooven   !"
130 print"  +----------------------------------+"
140 print

500 rem ***********************
504 rem *** system settings ***
505 rem ***   change here   ***
506 rem ***********************
507 rem
510 na=1: rem number of atoms
520 nb=1: rem number of consblocks
530 ns=1: rem number of stackelements
540 rem
550 rem ***********************
560 rem

600 gosub 2000: rem initialise
610 rem

700 rem *** repl ***
705 rem
710 gosub 3000: rem read
720 gosub 4000: rem eval
730 gosub 5000: rem print
735 print"loop stopped for testing..."
740 stop: goto 710: rem loop
750 rem
 
2000 rem *** initialise ***
2010 dim at$(na-1):ap=0: rem atompointer
2020 dim car(nb-1),cdr(nb-1):bp=0: rem blockpointer
2030 dim s(ns-1):sp=0: rem stackpointer
2040 return

3000 rem *** read ***
3010 print"no input yet..."
3020 return

4000 rem *** eval ***
4010 print"no eval yet..."
4020 return

5000 rem *** print ***
5010 print"no print yet..."
5030 return
