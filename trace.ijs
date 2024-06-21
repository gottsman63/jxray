NB. general/misc/trace.ijs
NB. Execution trace utilities
NB. version: 1.0.0

cocurrent 'jztrace'

Note 0
The main functions are "trace" and "paren".

x trace y   trace sentence y to x levels of function calls
trace y     same as  _ trace y

For example:
   trace '3+i.4'
 --------------- 1 Monad ------
 i.
 4
 0 1 2 3
 --------------- 2 Dyad -------
 3
 +
 0 1 2 3
 3 4 5 6
 ==============================
3 4 5 6

Tracing provides information on results within a line;
the action labels 0 monad, 1 monad, 9 paren, etc.,
are from the parse table in Section II.E of the J dictionary.


paren y     fully parenthesize sentence y

For example:
   paren '+/i.4'
((+/)(i.4))
   paren '(3 4$i.12)+/ .**:i.4'
((3 4$(i.12))((+/) .*)(*:(i.4)))

================= Lexicon ==================

class type bitmasks:
	noun		1
	verb		2
	adv		4
	avn		7	adv + verb + noun
	conj		8
	cavn		15	conj + adv + verb + noun
	lpar		16
	rpar		32
	asgn		64
	name		128
	mark		256
	edge		336	mark + asgn + lpar
	any		_1	(any of the above)

bwand		bitwise and (integer domain)

class		returns power-of-2 class type bitmask for y
depth		variable noun: parameter limiting detail (nesting depth) of "current" trace
equals		variable noun: obsolete indentation flag for show
execute		variable verb: executep or executet
executep		execute rule x for stack y for "paren"
executet		execute rule x for stack y for "trace"
indent		variable noun: semi-obsolete (misused by conceptually valid) indent level for show
isname		is token a name - basically: {{ _2 < nc <'y' }}
move		variable verb: movep or movet
movep		move from queue to stack for "paren"
movet		move from queue to stack for "trace"
paren		top level entry point: parse expression, fully parenthesizing it.
parse		expression parsing utility used by "paren" and "trace"
prespace		add a leading space to token if it begins with '.' or ':'
PTactions		names of parsing rules
PTpatterns	type class sets for top four stack entries for parsing rules
PTsubj		bitmask selecting active elements of stack for parsing rules
queue		variable noun: remaining unparsed tokens during parsing
show		echo with indent
stack		tokens or productions under consideration during parsing
t_b		mask selecting active part of stack for current parsing rule
t_c		class type of most resent result of parsing rule
t_d		parameter for parse: nesting depth of current parsing rule
t_i		index of currently active parsing rule (in PTactions/PTpatterns/PTsubj)
t_mode		parameter for parse: 'trace' or 'paren' depending on which kind of parsing we're doing
t_sent		parameter for parse: text (character sequence) of the sentence being parsed
t_x		representation of parameter of parsed entity (x parameter in 'show', or part of stack selected by t_b in 'execute')
t_y		representation of y parameter in show
t_z		result of executing current parsing rule
trace		top level entry point: parse expression, displaying selected patterns and intermediate reults
userlocale	locale user used for execution of sentence (matters for name resolution)
)

(x)=: 2^i.#x=. ;:'noun verb adv conj lpar rpar asgn name mark'
any =: _1
avn =: adv + verb + noun
cavn=: conj + adv + verb + noun
edge=: mark + asgn + lpar

x=. ,: (edge,       verb,       noun, any      ); 0 1 1 0; '0 Monad'
x=. x, ((edge+avn), verb,       verb, noun     ); 0 0 1 1; '1 Monad'
x=. x, ((edge+avn), noun,       verb, noun     ); 0 1 1 1; '2 Dyad'
x=. x, ((edge+avn), (verb+noun),adv,  any      ); 0 1 1 0; '3 Adverb'
x=. x, ((edge+avn), (verb+noun),conj, verb+noun); 0 1 1 1; '4 Conj'
x=. x, ((edge+avn), (verb+noun),verb, verb     ); 0 1 1 1; '5 Trident'
x=. x, (edge,       cavn,       cavn, cavn     ); 0 1 1 1; '6 Trident'
x=. x, (edge,       cavn,       cavn, any      ); 0 1 1 0; '7 Bident'
x=. x, ((name+noun),asgn,       cavn, any      ); 1 1 1 0; '8 Is'
x=. x, (lpar,       cavn,       rpar, any      ); 1 1 1 0; '9 Paren'

PTpatterns=: >0{"1 x  NB. parse table - patterns
PTsubj    =: >1{"1 x  NB. "subject to" masks
PTactions =:  2{"1 x  NB. actions

bwand     =: 17 b.    NB. bitwise and

prespace=: ,~ e.&'.:'@{. $ ' '"_
                      NB. preface a space to a word beginning with . or :

isname=: ({: e. '.:'"_) < {. e. (a.{~,(i.26)+/65 97)"_
                      NB. 1 iff a string y from the result of ;: is is a name

class=: 3 : 0         NB. the class of the word represented by string y
 if. y-:mark do. mark return. end.
 if. isname y do. name return. end.
 if. 10>i=. (;:'=: =. ( ) m n u v x y')i.<y do.
  i{asgn,asgn,lpar,rpar,6#name return.
 end.
 (nc__userlocale <'x' [ do__userlocale'x=. ',y){noun,adv,conj,verb
)

show=: {{
 echo 1 1}._1 _1}.": <y
 y
}}

executet=: 4 : 0      NB. execute rule x for stack y for "trace"
 show_start userlocale
 t_b=. x{PTsubj
 t_x=. t_b # , 4 _1{.y
 t_c=. >t_b # , 4 1{.y
 show 30{.(15$'-'),' ',(>x{PTactions),' ',15$'-'
 show_padded1&> (2=t_c) userlocale&unwrap_jztrace_@]^:[&.> t_x
 if. 8 =x do. t_x=. (<'=:') 1}t_x end.
 if. 7>:x do. t_x=. (<'( '),&.>t_x,&.><' )' end.
 do__userlocale't_z=. ', ; (1<t_c) userlocale tracewrap@]^:[&.> t_x
 t_c=. (nc__userlocale <'t_z'){noun,adv,conj,verb
 show_end userlocale
 if. noun=t_c do.
  t_z=. 5!:5 <'t_z' [ show t_z
 else.
  show userlocale unwrap_jztrace_ t_z=. 5!:5 <'t_z'
 end.
 ((t_b i. 1){.y),(t_c;t_z),(1+t_b i: 1)}.y  NB. new stack
)

executep=: 4 : 0      NB. execute rule x for stack y for "paren"
 t_b=. x{PTsubj
 t_x=. t_b # , 4 _1{.y
 select. x
  case. 0;1;2;5 do.
   t_c=. noun [ t_x=. '(',(;:^:_1 t_x),')'
  fcase. 8 do.
   t_x=. (<'=:') 1}t_x
  case. 3;4;7 do.
   do__userlocale 't_z=. ',t_x=. '(',(;:^:_1 t_x),')'
   t_c=. (nc__userlocale <'t_z'){noun,adv,conj,verb
  case. 9 do.
   t_c=. >1{t_b#,4 1{.y [ t_x=. >1{t_x
 end.
 ((t_b i. 1){.y),(t_c;t_x),(1+t_b i: 1)}.y  NB. new stack
)

movet=: 3 : 0         NB. move from queue to stack for "trace"
 'queue stack'=. y
  't_c t_x'=.{:queue
 if. (name~:t_c)+.asgn=0 0{::stack do.
  stack=. ({:queue),stack
 else.
  t_c=. (nc__userlocale <t_x){noun,adv,conj,verb
  if. t_c~:verb do. t_x=. 5!:5 <t_x end.
  stack=. (t_c;t_x),stack
 end.
 (}:queue);<stack
)

movep=: 3 : 0         NB. move from queue to stack for "paren"
 'queue stack'=. y
 't_c t_x'=.{:queue
 if. (name~:t_c)+.asgn=0 0{::stack do.
  stack=. ({:queue),stack
 else.
  t_c=. (nc__userlocale <t_x){noun,adv,conj,verb
  stack=. (t_c;t_x),stack
 end.
 (}:queue);<stack
)

NB. stack=: parse mode;depth;sentence
NB.  mode:     'trace' or 'paren'
NB.  depth:    depth of function calls to trace
NB.  sentence: string of the sentence to be parsed
NB.  stack:    stack at the end of the parse

parse=: 3 : 0
 't_mode t_d t_sent'=. y
 queue =. (mark;'') , (class&.> ,. prespace&.>) ;: t_sent
 stack =. 4 2$mark;''
 depth =: 1+t_d
 Zindent=: 0
 equals=: 0
 if. 'trace' -: t_mode do.
  execute=. executet
  move   =. movet
 else.
  execute=. executep
  move   =. movep
 end.
 while. 1 do.
  t_i=. 1 1 1 1 i.~ * PTpatterns bwand"1 ,>4 1{.stack
  if. t_i<#PTpatterns do.        NB. a pattern fits; execute the action
   stack=. t_i execute stack
  else.                          NB. no pattern fits; move from queue to stack
   if. 0=#queue do. break. end.
   'queue stack'=. move queue;<stack
  end.
 end.
 assert. * (mark+cavn,0) bwand >(<1 2;0){stack [ 'stack must be empty or has a single noun, verb, adverb, or conj'
 show 30$'='
 stack
)

trace=: 3 : 0         NB. trace sentence y to depth x (_ default)
 u=. coname
 userlocale=: u.''
 userlocale genid _1
 do__userlocale >(<1 1){parse 'trace';_;y
 :
 u=. coname
 userlocale=: u.''
 do__userlocale >(<1 1){parse 'trace';x;y
)

paren=: 3 : 0         NB. fully parenthesize sentence y
 u=. coname
 userlocale=: u.''
 >(<1 1){parse 'paren';__;y
)

trace_z_=: trace_jztrace_
paren_z_=: paren_jztrace_
