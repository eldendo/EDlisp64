5 rem *** green on black, clearscreen ***
10 poke 53280,0:poke 53281,0
20 print chr$(30);chr$(147);

100 print"  +----------------------------------+"
110 print"  !         edlisp64 v0.7 dev        !"
115 print"  !  a very minimal list processor   !"
120 print"  !  (c)2019 by ir. marc dendooven   !"
130 print"  +----------------------------------+"
140 print
150 print"-development version 0.7"
180 print"-no garbage collection"
190 print"-change memory settings"
200 print" at basic line 500-550"
210 print

500 rem ***********************
504 rem *** memory settings ***
505 rem ***   change here   ***
506 rem ***********************
507 rem
510 na=50: rem number of atoms
520 nb=50: rem number of consblocks
530 ns=10: rem number of stackelements
540 rem
550 rem ***********************
560 rem

600 gosub 2000: rem initialise
610 gosub 9000: rem print free mem

700 rem *** repl ***
710 gosub 3000: rem read
720 gosub 4000: rem eval
730 gosub 5000: rem print
740 goto 710: rem loop

2000 rem *** initialise ***
2010 dim at$(na-1):ap=0: rem atoms and atompointer
2020 dim car(nb-1),cdr(nb-1):bp=0: rem blocks and blockpointer
2030 dim s(ns-1):sp=0: rem stack and stackpointer
2035 rem --- define buildin atoms ---
2040 at$="nil":gosub 6500:nil=a
2042 at$="#t":gosub 6500:true=a
2044 at$="quote":gosub 6500:quote=a
2046 at$="cond":gosub 6500:co=a
2048 at$="car":gosub 6500:ar=a
2050 at$="cdr":gosub 6500:dr=a
2052 at$="cons":gosub 6500:cs=a
2054 at$="atom?":gosub 6500:at=a
2056 at$="eq?":gosub 6500:eq=a
2058 at$="lambda":gosub 6500:lambda=a
2156 at$="define":gosub 6500:df=a
2158 at$="context":gosub 6500:cx=a
2160 at$="exit":gosub 6500:exit=a
2165 at$="free":gosub 6500:fr=a
2170 rem --- other ---
2180 al=nil: rem association list
2190 return

2400 rem *** build association list ***
2405 if cdr(se)<0 then print:print"define needs 2 parameters":return
2407 if cdr(cdr(se))<0 then print:print"define needs 2 parameters":return
2410 gosub 6400: rem cons
2420 car(b)=car(cdr(se))
2430 cdr(b)=car(cdr(cdr(se)))
2440 se=b
2450 gosub 6400: rem cons
2460 car(b)=se
2470 cdr(b)=al
2480 al=b
2490 return

2500 rem *** show association list ***
2510 se=al
2520 gosub 5000: rem print
2530 print
2540 return

2600 rem *** search in assoc list ***
2610 rem se -> se or cast error
2610 cp=al: rem context pointer
2620 if cp=nil then er$=at$(-se-1)+" is unbound":goto 6700
2630 if car(car(cp))=se then se=cdr(car(cp)):return
2640 cp=cdr(cp)
2650 goto 2620 

2700 rem *** evcon ***
2710 se=cdr(se)
2720 if se=nil then return
2730 s=se:gosub 6000 : rem push
2740 se=car(car(se)):gosub 4000: rem eval
2750 gosub 6100 : rem pull
2760 if se<>nil then se=car(cdr(car(s))):gosub 4000:return: rem eval
2770 se=cdr(s): goto 2720: rem next condition

3000 rem *** read ***
3010 print: i$=""
3015 er=0: rem reset error condtion
3020 input i$:if i$="" then 3020
3030 ip=1: rem index pointer in i$ 
3040 gosub 3200 : rem getch
3050 gosub 3300 : rem parse s-expr
3055 if er then sp=0:goto 3000: rem error detected
3060 if se<0 then 3090
3070 if car(se)=df then gosub 2400:goto 3000
3080 if car(se)=exit then print:print"bye":end
3085 if car(se)=fr then gosub 9000: goto 3000
3087 if car(se)=cx then gosub 2500: goto 3000
3090 return

3100 rem *** skip whitespace ***
3110 if ch$=" " then gosub 3200:goto3110
3120 return

3200 rem *** getch ***
3205 if ip>len(i$) then ch$=chr$(13):goto 3220: rem end of line
3210 ch$=mid$(i$,ip,1):ip=ip+1: rem lookahead character
3220 print ch$; : rem echo input
3240 return

3300 rem *** parse s-expr ***
3310 gosub 3100: rem skip ws
3315 if ch$="." or ch$=")" or ch$=chr$(13) then er$="s-expr expected":goto 6700
3317 if ch$=chr$(13) then er$="unexpected end of line":goto 6700
3320 if ch$<>"(" then gosub 3600:return:rem parse atom
3330 gosub 3200: rem consume "("
3340 gosub 3700: rem parse list
3345 gosub 3100: rem skip ws
3350 if ch$<>")" then er$="')' expected":goto 6700
3360 gosub 3200:rem consume ")"
3370 return

3600 rem *** parse atom ***
3610 at$=""
3620 if ch$=")" or ch$="(" or ch$="." or ch$=" " or ch$=chr$(13) then 3650
3630 at$=at$+ch$:gosub 3200: rem getch$
3640 goto 3620
3650 gosub 6500:se=a: rem atom constructor
3660 return

3700 rem *** parse list ***
3720 gosub 3100: rem skip ws
3730 if ch$=")" then se=nil: return:rem empty list
3740 gosub 3300:car=se: rem parse s-expr -> car
3745 s=car:gosub 6000:rem push car
3760 gosub 3100: rem skip ws
3770 if ch$=")" then cdr=nil:goto 3800: rem proper list (nil terminated)
3780 if ch$="." then gosub 3200:gosub 3300:cdr=se:goto 3800:rem improper list
3782 rem (prev line) consume "." and parse s-expr -> cdr
3783 if ch$=chr$(13) then er$="unexpected end of line":goto 6700
3785 gosub 3700:cdr=se:goto 3800: rem parse rest of list -> cdr
3800 gosub 6400:se=b: rem consblock constructor
3810 gosub 6100:car=s: rem pull car
3820 car(se)=car:cdr(se)=cdr
3830 return







4000 rem *** eval *** /// error push vars before recursive call to 4000
4001 rem errors in eval should fall back to input routine !!!!
4010 print"...evaluating..."
4020 if se>=0 then 4050: rem list
4030 if se=nil or se=true then return
4040 gosub 2600:return:rem search in assoc list
4050 if car(se)=quote then se=car(cdr(se)):return:rem check if cdr is list
4060 if car(se)=co then goto 2700: rem evcon
4070 f=car(se):x=cdr(se)
4090 if x=nil then xe=nil: goto 4200: rem apply
4100 gosub 6400:xe=b:xi=xe: rem cons
4110 se=car(x):
4114 s=f:gosub 6000:s=x:gosub 6000:s=xe:gosub 6000:s=xi:gosub 6000
4115 gosub 4000:rem eval
4116 gosub 6100:xi=s:gosub 6100:xe=s:gosub 6100:x=s:gosub 6100:f=s
4118 car(xi)=se
4120 if cdr(x)=nil then cdr(xi)=nil: goto 4200: rem apply
4130 gosub 6400:cdr(xi)=b: rem cons
4140 x=cdr(x):xi=b
4150 goto 4110

4200 rem *** apply ***
4205 print"...applying..."
4207 if f>=0 then 4300: rem not atomic
4210 if f=ar then se=car(car(xe)):return: rem car
4220 if f=dr then se=cdr(car(xe)):return: rem cdr
4230 if f=cs then gosub 6400: car(b)=car(xe):cdr(b)=car(cdr(xe)):se=b:return
4240 if f<>eq then 4250
4242 if car(xe)=car(cdr(xe)) then se=true:return
4244 se=nil:return
4250 if f<>at then 4260 
4252 if car(xe)<0 then se=true: return
4254 se=nil: return

4260 se=f:gosub 2600:if er=1 then return:rem search in context
4265 f=se
4270 goto 4200: rem apply

4300 rem *** not atomic ***
4310 if car(f) <> lambda then er$="unknown function": goto 6700
4320 ta=al: rem temporary association list
4330 y=car(cdr(f)):rem formal parameter list
4332 se=y:gosub 5000
4334 se=xe:gosub 5000
4340 if xe=nil then 4500
4350 if y=nil then er$="formal and actual parameters do not match":goto 6700
4360 gosub 6400: rem cons
4370 car(b)=car(y):cdr(b)=car(xe):t=b
4380 gosub 6400: rem cons
4390 car(b)=t:cdr(b)=al:al=b
4400 xe=cdr(xe):y=cdr(y)
4410 goto 4332

4500 if y<>nil then er$="formal and actual parameters do not match":goto 6700
4510 se=car(cdr(cdr(f))):gosub 4000:al=ta:return


5000 rem *** print s-expr ***
5010 if se<0 then print at$(-se-1);:return: rem print atom 
5020 print"(";:gosub 5100:print")"; : rem print (list)
5030 return

5100 rem *** print list ***
5110 s=se:gosub 6000: rem push list
5120 se=car(se):gosub 5000: rem print car (s-expr)
5130 gosub 6100:se=s: rem pull list back
5140 se=cdr(se): rem treat cdr
5150 if se=nil then return: rem list ended by nil
5160 if se<0 then print".";at$(-se-1);:return: rem list ended by other atom
5170 print" ";:gosub 5100: rem print the remainer of the list
5180 return

6000 rem *** push ***
6010 rem *** s -> stack
6020 if sp>=ns then er$="stack overflow":goto 6600
6030 s(sp)=s:sp=sp+1
6040 return

6100 rem *** pull ***
6110 rem *** stack -> s
6120 if sp<=0 then er$="stack underflow":goto 6600
6130 sp=sp-1:s=s(sp)
6140 return

6400 rem *** consblock constructor ***
6420 rem *** ( . ) -> b
6430 if bp>=nb then er$="out of consblocks":goto 6600
6470 b=bp:bp=bp+1
6480 return

6500 rem *** atom constructor *** 
6510 rem *** at$ -> a
6520 for i=0 to ap-1 
6530 if at$(i)=at$ then a=-i-1:goto 6570
6540 next i 
6545 if at$="" then er$="empty atom not allowed":goto 6700 
6550 if ap>=na then er$="out of atoms":goto 6600
6560 at$(ap)=at$:a=-ap-1:ap=ap+1
6570 return

6600 rem *** fatal error ***
6610 print:print "fatal error: ";er$
6620 gosub 9000
6630 print "exit to basic"
6640 print "change memory settings in line 500-550"
6650 end

6700 rem *** recoverable error ***
6705 rem *** should be called by goto, not gosub
6710 print:print "error: ";er$
6720 er=1: rem set error condition
6730 return

9000 rem *** print free memory ***
9010 print na-ap;"of";na;" atoms free"
9020 print nb-bp;"of";nb;" consblocks free"
9030 print ns-sp;"of";ns;" stackelements free"
9040 print fre(0)-65536*(fre(0)<0);" basic bytes free"
9050 print
9060 return

