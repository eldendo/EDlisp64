5 rem *** green on black ***
10 poke 53280,0:poke53281,0
20 print chr$(30);chr$(147);

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
510 na=5: rem number of atoms
520 nb=5: rem number of consblocks
530 ns=5: rem number of stackelements
540 rem
550 rem ***********************
560 rem

600 gosub 2000: rem initialise
605 gosub 9000: rem print free mem
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

6000 rem *** push ***
6010 rem *** ts -> stack
6020 if sp>=ns then print"stack overflow":stop
6030 s(sp)=ts:sp=sp+1
6040 return

6100 rem *** pull ***
6110 rem *** stack -> ts
6120 if sp<=0 then print"stack underflow":stop
6130 sp=sp-1:ts=s(sp)
6140 return

6400 rem *** consblock constructor ***
6420 rem *** (new block) -> se
6430 if bp>=nb then print "out of consblocks":stop
6440 se=bp:bp=bp+1
6450 return

6500 rem *** atom constructor *** 
6510 rem *** at$ -> se
6520 for i=0 to ap-1 
6530 if at$(i)=at$ then se=-i-1:return
6540 next i  
6550 if ap>=na then print "out of atoms":stop
6560 at$(ap)=at$:se=-ap-1:ap=ap+1
6570 return

9000 rem *** free memory ***
9010 print na-ap;"of";na;" atoms free"
9020 print nb-bp;"of";nb;" consblocks free"
9030 print ns-sp;"of";ns;" stackelements free"
9040 print fre(0)+2^16;" basic bytes free"
9050 print
9060 return
