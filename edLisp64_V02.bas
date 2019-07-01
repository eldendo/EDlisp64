5 rem *** green on black ***
10 poke 53280,0:poke53281,0
20 print chr$(30);chr$(147);

100 print"  +----------------------------------+"
110 print"  !         edlisp64 v0.2 dev        !"
115 print"  !  a very minimal list processor   !"
120 print"  !  (c)2019 by ir. marc dendooven   !"
130 print"  +----------------------------------+"
140 print

150 print "(a .b) creates an empty atom (a.(empty.b))"
160 print "whitespace nok"

500 rem ***********************
504 rem *** system settings ***
505 rem ***   change here   ***
506 rem ***********************
507 rem
510 na=50: rem number of atoms
520 nb=50: rem number of consblocks
530 ns=50: rem number of stackelements
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
735 print
740 goto 710: rem loop
750 rem

2000 rem *** initialise ***
2010 dim at$(na-1):ap=0: rem atompointer
2020 dim car(nb-1),cdr(nb-1):bp=0: rem blockpointer
2030 dim s(ns-1):sp=0: rem stackpointer
2040 at$="nil":gosub 6500:nil=a
2090 return

3000 rem *** read ***
3010 input i$:if i$="" then 3010
3015 ip=1
3020 gosub 3200 : rem getch
3030 gosub 3300 : rem parse s-expr
3040 return

3100 rem *** skip whitespace ***
3110 if ch$=" " then gosub 3200:goto3110
3120 return

3200 rem *** getch ***
3205 if ip>len(i$) then ch$=chr$(13):goto 3220
3210 ch$=mid$(i$,ip,1):ip=ip+1
3220 print ch$;
3240 return

3300 rem *** parse s-expr ***
3310 gosub 3100: rem skip whitespace
3320 if ch$<>"(" then gosub 3600:return:rem parse atom
3330 gosub 3200: rem consume "("
3340 gosub 3700: rem parse list
3350 if ch$<>")" then print:print "parser error ')' expected":stop
3360 gosub 3200: rem consume ")"
3370 return

3600 rem *** parse atom ***
3610 at$=""
3620 if ch$=")" or ch$="(" or ch$="." or ch$=" " or ch$=chr$(13) then 3650
3630 at$=at$+ch$:gosub 3200
3640 goto 3620
3650 gosub 6500:se=a
3660 return

3700 rem *** parse list ***
3720 gosub 3100: rem skip whitespace
3730 if ch$=")" then se=nil: return
3740 gosub 3300:car=se: rem parse car
3745 s=car:gosub 6000:rem push car
3750 rem gosub 3100: rem skip ws !!! probleem met space
3760 if ch$=")" then cdr=nil:goto 3800
3770 if ch$="." then gosub 3200:gosub 3300:cdr=se:goto 3800
3780 if ch$=" " then gosub 3200:gosub 3700:cdr=se:goto 3800
3790 print:print "parser error: one of ')','.' or ' ' expected":stop 
3800 gosub 6400:se=b: rem consblock constructor
3810 gosub 6100:car=s: rem pull car
3820 car(se)=car:cdr(se)=cdr
3830 return


4000 rem *** eval ***
4010 print"no eval yet..."
4020 return

5000 rem *** print s-expr ***
5010 if se<0 then print at$(-se-1);:return
5020 print"(";:gosub 5100:print")";
5030 return

5100 rem *** print list ***
5110 s=se:gosub 6000
5120 se=car(se):gosub 5000
5130 gosub 6100:se=s
5140 se=cdr(se):
5150 if se=nil then return
5160 if se<0 then print".";at$(-se-1);:return
5170 print" ";:gosub 5100
5180 return

6000 rem *** push ***
6010 rem *** s -> stack
6020 if sp>=ns then print"stack overflow":stop
6030 s(sp)=s:sp=sp+1
6040 return

6100 rem *** pull ***
6110 rem *** stack -> s
6120 if sp<=0 then print"stack underflow":stop
6130 sp=sp-1:s=s(sp)
6140 return

6400 rem *** consblock constructor ***
6420 rem *** ( . ) -> b
6430 if bp>=nb then print "out of consblocks":stop
6470 b=bp:bp=bp+1
6480 return

6500 rem *** atom constructor *** 
6510 rem *** at$ -> a
6520 for i=0 to ap-1 
6530 if at$(i)=at$ then a=-i-1:goto 6570
6540 next i  
6550 if ap>=na then print "out of atoms":stop
6560 at$(ap)=at$:a=-ap-1:ap=ap+1
6570 return

9000 rem *** free memory ***
9010 print na-ap;"of";na;" atoms free"
9020 print nb-bp;"of";nb;" consblocks free"
9030 print ns-sp;"of";ns;" stackelements free"
9040 print fre(0)+2^16;" basic bytes free"
9050 print
9060 return

