NB. regular expression support mostly from
NB. https://code.jsoftware.com/wiki/Essays/RegularExpressions/NondeterministicFiniteAutomata

ch=: a.&i.
NB. regular expression matching a character (or set of characters)
chf=: (,0) ,&< {{ ,: (<,1) (ch y) }256#a: }}

NB. regular expression matching a range of characters (like '0' through '9')
thru=: <. + {{i.0>.1+y-x}}
through=: thru&.ch
rangef=: chf@through

NB. regular expression y follows regular expression x
seqf=: {{
  NB. y starts match up with x transitions
  NB. x starts remain (but remove any operations from x)
  NB. (and incorporate [adjusted] y starts for optional x)
  'Xs Xt' =. x ~.@:<.L:0#Xt ['Xs Xt'=. x
  'Ys Yt'=. y+L:0 Xn=. #Xt
  Rs=. ~.Xs,(Xn e. Xs)#Ys
  Rs;<(~.@,&Ys^:(Xn&e.)L:0 Xt),Yt
}}

NB. string to regular expression
stringf=: seqf/@:(chf"0)

NB. relatively compact display of regular expression state transitions
NB. rows: initial state, columns: subsequent state
NB. state is represented as a list of indices into the transition array
disp=: <@(#&a.)"1@(1&|:)@:(((e.~i.)1+0>.>./)@>)^:L.L:1

NB. if either regular expression x or y would match,
NB. then result would match
orf=: {{
  'Xs Xt'=. x ['Ys Yt'=. y
   adjX=: (+(#Yt)*(#Xt)&<:)L:0
   adjY=: (#Xt)&+L:0
   (~. (adjX Xs),adjY Ys) ;< (adjX Xt),adjY Yt
}}

NB. regular expression which may be repeated indefinitely
repf=: {{ Ys;<(~.@(0&,)^:((#Yt)&e.))L:0 Yt ['Ys Yt'=. y}}

NB. regular expression which also matches the empty string
optf=: {{ (~.Ys,#Yt);<Yt ['Ys Yt'=.y }}
match=: {{
  i=. i.#t ['s t'=. y
  for_c. a.i.x do.
    s=. ~.;c{"1 t#~ i e. s
  end.
  (#t)e.s
}}

kleenestar=: optf@repf
anything=: kleenestar chf a.
contained=: anything seqf anything seqf~ ]

assert (disp chf'a')-:,L:0]0;<,:'';'a'
assert (disp 'a' seqf&chf 'b')-:,L:0]0;<('';'a'),:'';'';'b'
assert (disp 'a' orf&chf 'bc')-:0 1;<a:,.a:,.;:'a bc'
assert (disp optf chf 'a')-:,L:0]0 1;<,:'';'a'
assert (disp repf chf 'a')-:,L:0]0;<,:'a';'a'
assert 'abc' match stringf 'abc'
assert 'aaab' match (repf chf 'a') seqf chf 'b'
assert 'aaab' match (repf optf chf 'a') seqf chf 'b'
assert 'b' match (repf optf chf 'a') seqf chf 'b'
assert -.'aaabb' match (repf optf chf 'a') seqf chf 'b'

NB. end of content from essay
NB. ------------------------------------------
digit=: chf DIG=: '_','0' through '9'
letter=: chf LET=: ('A' through 'Z'),'a' through 'z'

OPCODES=: {{(y)=:i.#y}};:'TOKEN VECTOR WS COMMENT NUVOC NUVOCnoun NUVOCend'
operation=: {{
  'Ys Yt'=. y
  op=. x+N=. #Yt
  op N{{~.(m<.y),(m e.y)#x}}L:0 y
}}

comment=: COMMENT operation stringf 'NB.'
number=: VECTOR operation digit seqf kleenestar chf DIG,'.',LET
whitespace=: WS operation repf chf ' '
nuvoc=: NUVOC operation stringf '{{'
nuvocnoun=: NUVOCnoun operation stringf '{{)n'
nuvocend=: NUVOCend operation stringf '}}'
word=: letter seqf kleenestar chf DIG,LET
inflect=: kleenestar chf '.:'
token=: TOKEN operation inflect seqf~ ('!' rangef '~') orf number orf word
token=: token orf comment orf whitespace orf number
token=: token orf nuvoc orf nuvocnoun orf nuvocend

NB. repeatedly: find longest match as next token
NB. (with special operations for certain kinds of tokens)
NB. ((hopefully there's a more elegant way of doing this...))
tokenize=: token {{
  lim=. <:#y
  i=. i.#t['s t'=. m
  N=. #t [ S=. s
  ops=. N+OPCODES
  mode=. lastopcode=. vecstart=. vectype=. opcode=. end=. __
  stack=. EMPTY
  r=. i.prevec=. start=. j=. 0
  while. j<:#y do.
    if. j=#y do.
      s=. ''
    else.
      c=. a.i.j{y
      s=. ~.;c{"1 t#~ i e. s
    end.
    if. 0=#s do.
      if. (mode=VECTOR)*opcode=TOKEN do. mode=. TOKEN end.
      select. opcode>.mode
        case. TOKEN do.
        case. VECTOR do.
          if. vectype= VECTOR do.
            start=. vecstart
            r=. prevec{.r NB. extend existing vector
          else.
            prevec=. #r
          end.
          vecstart=. start
        case. WS do.
          opcode=. vectype NB. whitespace gets included in numeric vector
        case. COMMENT do.
          r,<start}.y return.
        case. NUVOC do.
          if. NUVOC=opcode do.
            mode=. NUVOC
            stack=. stack, start,#r
          end.
        case. NUVOCnoun do.
          if. NUVOCnoun=opcode do.
            mode=. NUVOCnoun
            vecstart=. start
            prevec=. #r
          end.
        case. NUVOCend do.
          select. mode 
            case. NUVOC do.
              'start prestack'=. {: stack
              stack=. }: stack
              r=. prestack{.r NB. extend existing definition
              mode=. NUVOC*0<#stack
            case. NUVOCnoun do.
              if. (-.LF e. y{~vecstart thru start)+.LF=(start-1){y do.
                start=. vecstart
                r=. prevec{.r NB. extend existing definition
                mode=. TOKEN
              end.
            case. do. NB. error, unmatched delimiter
          end.
      end.
      r=. r,(start<#y)#<y{~start thru end<.lim
      vectype=. opcode
      opcode=. TOKEN
      s=. S
      j=. start=. end=. end+1
    elseif. 1 e. ops e. s do.
      opcode=. >./N-~s ([-.-.) ops
      end=. j
      j=. j+1
    else.
      j=. j+1
    end.
  end.
  r
}}

assert (;: -: (<'  ')-.~ tokenize) '(+/%#)2 3 5  7:a.'
NB. need more tests
