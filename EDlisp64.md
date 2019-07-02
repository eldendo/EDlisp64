#EDlisp64
### A Very Minimal List Processor for the Commodore 64

**(c)2019 by ir. Marc 'EL Dendo' Dendooven**

This is a draft... Please endulge my poor english. 

##Part I: Introduction
LISP is one of the oldest computer languages, but a very interesting one. The study of the internals of a **LIS**t **P**rocessor gives a very interesting new insight in computing. It shouldn't surprise us that a lot of interesting books about computing use **LISP** or **SCHEME** (a dialect of LISP) as language. A good example is the so called 'wizard book' aka [Structure and Interpretation of Computer Programs](https://mitpress.mit.edu/sites/default/files/sicp/index.html) **(SICP)** by Abelson and Sussman.

Building a List Processor is a very interesting task. But almost every book about LISP builds its own as a metacircular interpreter, that is a LISP interpreter build in LISP. Indeed this is very simple to explain since a lot of machine dependent functionality (like a parser, printer and memory management) are simply inherited from the mother system. Building a lisp interpreter from scratch in an imperative language is almost always left as an exercise to the reader. 

It looked particulary interesting to build a List Processor for the c64, since here all low level items should be build from scratch, since there are no libraries for standard functionality like memory alocation etc...

So I intend to write a series of articles where I will build a minimal list processor. Each article will end with a piece of executable code. Hope you like it.

In this first part I will give a small introduction to a minimal LISP and write a framework for further exploitation.
### A simple LISP explained
Lisp has two low level datatypes: **ATOMs** and **ORDERED PAIRs**.

ATOMs are unique identifiers. They consist of an non-empty string of readable characters excluding '(', ')', '.' and space. Examples are:

- HELLO
- ATOM1
- ELDENDO
- +++

An ORDERED PAIR takes the form **(a.b)** where a en b are references to ATOMs or other ordered pairs

An ordered pair is sometimes called a **BLOCK** or a **CONSBLOCK**.

This permits us to create complicated data structures:  
(insert picture)

We can note this structure as:

**((HELLO.ATOM1).(AAA.(ELDENDO.+++)))**

LISTs take a special place in LISP:

They can be build as a linked list by using ordered pairs in a linear fashion:
(insert picture)

**(A.(B.(C.(D.E))))**

wich is equivalent as the notation:

**(A B C D.E)**

This is called an improper list. A poper list can be construct using a special ATOM called **NIL**.

**(A B C D.NIL)** 

is equivalent with the notation for a proper list 

**(A B C D)**

