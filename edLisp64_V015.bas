10 gosub 10000: rem install computed goto/gosub

30 rem *** green on black ***
40 poke 53280,0:poke 53281,0
50 print chr$(30);chr$(147);

100 print"  +----------------------------------+"
110 print"  !         edlisp64 v0.15 dev       !"
115 print"  !  a very minimal list processor   !"
120 print"  !  (c)2019 by ir. marc dendooven   !"
130 print"  +----------------------------------+"
140 print

200 rem *** labels ***
210 atcns=1300:cns=1200:pop=1100:push=1000:xret=1400

500 rem ***********************
504 rem *** system settings ***
505 rem ***   change here   ***
506 rem ***********************
507 rem
510 na=200: rem number of atoms
520 nb=2000: rem number of consblocks
530 ns=100: rem number of stackelements
535 bs=2048: rem input buffer size
540 rem
550 rem ***********************
560 rem

600 gosub 9000: rem initialise
605 gosub 9200: rem print free mem

700 rem *** repl ***
705 rem
710 gosub 2000: rem read
715 if sp<>0 then er$="memory leak after read !":goto 9300
720 s=730:gosub push:goto 4000: rem eval
730 if sp<>0 then er$="memory leak after eval !":goto 9300
731 s=740:gosub push:goto 3000: rem print
740 if sp<>0 then er$="memory leak after print !":goto 9300
742 print:print "stat: max stack used was:";ss
745 goto 710: rem loop

750 rem --------------------------------------------------------------

1000 rem *** push ***
1010 rem *** s -> stack
1015 rem print "***push";s;"***";
1020 if sp>=ns then er$="stack overflow":goto 9300
1030 s(sp)=s:sp=sp+1
1035 if sp>ss then ss=sp: rem statistiek
1040 return

1100 rem *** pop ***
1110 rem *** stack -> s
1120 if sp<=0 then er$="stack underflow":goto 9300
1130 sp=sp-1:s=s(sp)
1135 rem print "***pop";s;"***";
1140 return

1200 rem *** consblock constructor (cns) ***
1220 rem *** ( . ) -> b
1230 if bp>=nb then er$="out of consblocks":goto 9300
1270 b=bp:bp=bp+1
1280 return

1300 rem *** atom constructor (atcns) *** 
1310 rem *** at$ -> a
1320 for i=0 to ap-1 
1330 if at$(i)=at$ then a=-i-1:goto 1370
1340 next i  
1350 if ap>=na then er$="out of atoms":goto 9300
1360 at$(ap)=at$:a=-ap-1:ap=ap+1
1370 return

1400 gosub pop:goto s
1410 rem *** line before: xret

1490 rem -------------------------------------------------------------

2000 rem *** read ***
2010 print:
2015 er=0: rem reset error condtion
2020 gosub 8000: rem input routine
2025 ip=0
2040 gosub 2200 : rem getch
2050 s=2055:gosub push: goto 2300 : rem parse s-expr
2055 if sp<>0 then er$="memory leak in read":goto 9300
2056 if er then sp=0:goto 2000: rem error detected
2060 if se<0 then 2090
2070 if car(se)=df then gosub 3400:goto 2000
2080 if car(se)=exit then print:print"bye":end
2085 if car(se)=fr then gosub 9200: goto 2000
2087 if car(se)=cx then gosub 3500: goto 2000
2090 return

2100 rem *** skip whitespace ***
2110 if ch$=" " then gosub 2200:goto 2110
2120 return

2200 rem *** getch ***
2205 if ip>=bs then print:"input buffer overflow":stop
2210 ch$=chr$(ib%(ip)):ip=ip+1: rem lookahead character
2220 print ch$; : rem echo input
2240 return

2300 rem *** parse s-expr ***
2310 gosub 2100: rem skip ws
2315 if ch$="." or ch$=")" or ch$=chr$(13) then er$="s-expr expected":goto 9400
2317 if ch$=chr$(13) then er$="unexpected end of line":goto 9400
2320 if ch$<>"(" then gosub 2600:goto 2370:rem parse atom
2330 gosub 2200: rem consume "("
2340 s=2345:gosub push:goto 2700: rem parse list
2345 gosub 2100: rem skip ws
2350 if ch$<>")" then er$="')' expected":goto 9400
2360 gosub 2200:rem consume ")"
2370 goto xret

2600 rem *** parse atom ***
2610 at$=""
2620 if ch$=")" or ch$="(" or ch$="." or ch$=" " or ch$=chr$(13) then 2650
2630 at$=at$+ch$:gosub 2200: rem getch$
2640 goto 2620
2650 gosub atcns:se=a: rem atom constructor
2660 return

2700 rem *** parse list ***
2720 gosub 2100: rem skip ws
2730 if ch$=")" then se=nil: goto 2830 :rem empty list
2740 s=2745:gosub push:goto 2300: rem parse s-expr -> car
2745 car=se:s=car:gosub push:rem push car
2760 gosub 2100: rem skip ws
2770 if ch$=")" then cdr=nil:goto 2800: rem proper list (nil terminated)
2780 if ch$<>"." then 2790 
2782 gosub 2200:s=2784:gosub push:goto 2300:
2784 cdr=se:goto 2800:rem improper list
2785 rem (prev lines) consume "." and parse s-expr -> cdr
2790 if ch$=chr$(13) then gosub pop:er$="unexpected end of line":goto 9400
2791 rem prev line: pop 1 el of stack before return on error
2795 s=2796:gosub push:goto 2700
2796 cdr=se: rem parse rest of list -> cdr
2800 gosub cns:se=b: rem consblock constructor
2810 gosub pop:car=s: rem pop car
2820 car(se)=car:cdr(se)=cdr
2830 goto xret

2900 rem -------------------------------------------------------------

3000 rem *** print s-expr ***
3010 if se<0 then print at$(-se-1);:goto xret: rem print atom 
3020 print"(";
3030 s=3040:gosub push:goto 3100: rem print (list)
3040 print")"; 
3050 goto xret

3100 rem *** print list ***
3110 s=se:gosub push: rem push list
3120 se=car(se):s=3130:gosub push:goto 3000: rem print car (s-expr)
3130 gosub pop:se=s: rem pop list back
3140 se=cdr(se): rem treat cdr
3150 if se=nil then goto xret: rem list ended by nil
3160 if se<0 then print".";at$(-se-1);:goto xret: rem list ended by other atom
3170 print" ";:s=3180:gosub push:goto 3100: rem print the remainer of the list
3180 goto xret

3300 rem -------------------------------------------------------------

3400 rem *** build association list ***
3405 if cdr(se)<0 then print:print"define needs 2 parameters":return
3407 if cdr(cdr(se))<0 then print:print"define needs 2 parameters":return
3410 gosub cns: rem cons
3420 car(b)=car(cdr(se))
3430 cdr(b)=car(cdr(cdr(se)))
3440 se=b
3450 gosub cns: rem cons
3460 car(b)=se
3470 cdr(b)=al
3480 al=b
3490 return

3500 rem *** show association list ***
3510 se=al
3520 s=3530:gosub push:goto 3000: rem print
3530 print
3540 return

3600 rem *** search in assoc list ***
3610 rem se -> se or cast error
3610 cp=al: rem context pointer
3620 if cp=nil then er$=at$(-se-1)+" is unbound":goto 9400
3630 if car(car(cp))=se then se=cdr(car(cp)):return
3640 cp=cdr(cp)
3650 goto 3620 

3700 rem *** evcon ***
3710 se=cdr(se)
3720 if se=nil then goto xret
3730 s=se:gosub push : rem push
3740 se=car(car(se)):s=3750:gosub push:goto 4000: rem eval
3750 gosub pop : rem pull
3760 if se=nil then se=cdr(s): goto 3720: rem next condition
3770 se=car(cdr(car(s))):s=3780:gosub push:goto 4000: rem eval
3780 goto xret
3790 rem se=car(cdr(car(s))):goto 4000: rem eval tail

3800 rem ------------------------------------------------------------

4000 rem *** eval *** 
4001 rem errors in eval should fall back to input routine !!!!
4010 rem print"...evaluating..."
4020 if se>=0 then 4050: rem list
4030 if se=nil or se=true then goto xret
4040 gosub 3600:goto xret:rem search in assoc list
4050 if car(se)=quote then se=car(cdr(se)):goto xret:rem check if cdr=list
4060 if car(se)=co then goto 3700: rem evcon
4070 f=car(se):x=cdr(se)
4090 if x=nil then xe=nil: goto 4200: rem apply
4100 gosub cns:xe=b:xi=xe: rem cons
4110 se=car(x):
4114 s=f:gosub push:s=x:gosub push:s=xe:gosub push:s=xi:gosub push
4115 s=4116:gosub push:goto 4000:rem eval
4116 gosub pop:xi=s:gosub pop:xe=s:gosub pop:x=s:gosub pop:f=s
4118 car(xi)=se
4120 if cdr(x)=nil then cdr(xi)=nil: goto 4200: rem apply
4130 gosub cns:cdr(xi)=b: rem cons
4140 x=cdr(x):xi=b
4150 goto 4110
4160 goto xret

4190 rem ------------------------------------------------------------

4200 rem *** apply ***
4205 rem print"...applying..."
4207 if f>=0 then 4300: rem not atomic
4210 if f=ar then se=car(car(xe)):goto xret: rem car
4220 if f=dr then se=cdr(car(xe)):goto xret: rem cdr
4230 if f=cs then gosub cns: car(b)=car(xe):cdr(b)=car(cdr(xe)):se=b:goto xret
4240 if f<>eq then 4250
4242 if car(xe)=car(cdr(xe)) then se=true:goto xret
4244 se=nil:goto xret
4250 if f<>ia then 4260
4252 if car(xe)<0 then se=true: goto xret
4254 se=nil: goto xret

4260 se=f:gosub 3600:if er=1 then return:rem search in context
4265 f=se
4270 goto 4200: rem apply

4300 rem *** not atomic ***
4310 if car(f) <> lambda then er$="unknown function": goto 9400
4320 ta=al: rem temporary association list
4330 y=car(cdr(f)):rem formal parameter list
4332 rem debug: se=y:gosub 3000 
4334 rem debug: se=xe:gosub 3000 
4340 if xe=nil then 4500
4350 if y=nil then er$="formal and actual parameters do not match":goto 9400
4360 gosub cns: rem cons
4370 car(b)=car(y):cdr(b)=car(xe):t=b
4380 gosub cns: rem cons
4390 car(b)=t:cdr(b)=al:al=b
4400 xe=cdr(xe):y=cdr(y)
4410 goto 4332

4500 if y<>nil then er$="formal and actual parameters do not match":goto 9400
4505 se=car(cdr(cdr(f)))
4510 s=ta:gosub push:s=4520:gosub push:goto 4000
4520 gosub pop:ta=s:al=ta:goto xret

7999 rem -------------------------------------------------------------

8000 rem *** input routine ***
8010 print ">";: ip=0
8020 print chr$(164);" ";chr$(157);chr$(157); :rem cursor,space,<-,<-
8030 get in$: if in$="" then 8030
8040 in=asc(in$)
8050 if in=20 and ip>0  then ip=ip-1:print chr$(157);" ";chr$(157);:goto 8020
8060 if (in<32 or in>127) and in<>13  then 8030
8070 if ip>=bs then 8030
8080 ib%(ip)=in:ip=ip+1:print in$;
8085 if in=13 then return
8090 goto 8020

8999 rem -------------------------------------------------------------

9000 rem *** initialise ***
9010 dim at$(na-1):ap=0: rem atompointer
9020 dim car(nb-1),cdr(nb-1):bp=0: rem blockpointer
9030 dim s(ns-1):sp=0: rem stackpointer
9035 dim ib%(bs-1):ip=0: rem input buffer/pointer
9040 rem --- define buildin atoms ---
9050 at$="nil":gosub atcns:nil=a
9060 at$="#t":gosub atcns:true=a
9070 at$="quote":gosub atcns:quote=a
9080 at$="cond":gosub atcns:co=a
9090 at$="car":gosub atcns:ar=a
9100 at$="cdr":gosub atcns:dr=a
9110 at$="cons":gosub atcns:cs=a
9120 at$="atom?":gosub atcns:ia=a :rem changed from at to ia
9130 at$="eq?":gosub atcns:eq=a
9140 at$="lambda":gosub atcns:lambda=a
9150 at$="define":gosub atcns:df=a
9160 at$="ctx":gosub atcns:cx=a
9170 at$="exit":gosub atcns:exit=a
9180 at$="free":gosub atcns:fr=a
9185 rem --- other ---
9190 al=nil: rem association list
9195 return

9200 rem *** free memory ***
9210 print na-ap;"of";na;" atoms free"
9220 print nb-bp;"of";nb;" consblocks free"
9230 print ns-sp;"of";ns;" stackelements free"
9235 print bs;" positions in input buffer"
9240 print fre(0)-65536*(fre(0)<0);" basic bytes free"
9250 print
9260 return

9300 rem *** fatal error ***
9310 print:print "fatal error: ";er$
9320 gosub 9200
9330 print "exit to basic"
9340 print "change memory settings in line 500-550"
9350 end

9400 rem *** recoverable error ***
9405 rem *** should be called by goto, not gosub
9410 print:print "error: ";er$
9420 er=1: rem set error condition
9430 goto xret


10000 rem *** install computed goto/gosub ***
10005 if peek(1) = 54 then 10200: rem already installed
10010 print "  +-------------------------------+"
10020 print "  !   simple computed goto/gosub  !"
10040 print "  +-------------------------------+"
10050 print
10060 print "copying basic rom to underlying ram"
10070 for a=40960 to 49151 
10080 poke a, peek(a) 
10090 if int(a/100)*100=a then print".";
10100 next a
10110 print:print "done"
10120 print "modifying basic in ram"
10130 poke 43169,192: poke 43170,2
10135 print "installing helproutine at address 704"
10140 poke 704,32: poke 705,138: poke 706,173
10150 poke 707,76: poke 708,247: poke 709,183 
10160 print "done"
10170 print "switching to ram" 
10180 poke 1,54
10190 print "done"
10200 print "computed goto/gosub installed"
10210 return
