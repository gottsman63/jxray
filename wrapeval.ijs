NB. we'll be generating a sequence of related names
NB. this base id will be used to distinguish different sets of names
genid=: {{ y,":N=: N+1}}

NB. get the name given an id (from genid - maybe appended to something else)
wrapnm=: {{ 'Z',y }} NB. y: id

NB. 5!:5 almost serializes the definition of a name
NB. but it may give results which cannot be used in a sentence
NB. fix that 
NB. (and note that we'll be using it on local names, some of the time).
name2lrep=: ' (',') ',~{{
  lines=. cutLF y
  if. (;:')') = {: lines do.
    tokens=. ;:;{. lines
    pat=. ;:': 0'
    for_fix. {{<'( ',') ',~5!:5<'y'}};._2 }.lines do.
      ndx=. 1+pat {.@I.@E. tokens
      tokens=. fix ndx} tokens
    end.
    ;:inv tokens
  else.
    y
  end.
}}@(5!:5)@boxopen

NB. given a template for wrapping a definition,
NB.   and the text of the definition,
NB.   and the id for the constructed names to use
NB.   build the text of the wrapping (instrumentation) definition
fillinblanks=: {{
  ID=. x
  TEMPLATE=. m
  IMPLEMENTATION=. ;y
  DISPLAYTEXT=. quote;y
  SELF=. wrapnm ID
  PROLOG=. {{)n
    SELFDISP=: DISPLAYTEXT
    if.0>nc<'SELFHIST' do.SELFHIST=: SELFX=: SELFY=: SELFTIME0=: SELFTIME1=: '' end.
    SELFTIME0=: SELFTIME0,6!:1''
}} rplc 'SELF';SELF;'DISPLAYTEXT';DISPLAYTEXT
  PROLOG3=. PROLOG,{{)n
  'SELFY';SELFY=:SELFY,<y
}} rplc 'SELF';SELF
  PROLOG4=. PROLOG3,{{)n
  'SELFX'; SELFX=: SELFX,<x
}} rplc 'SELF';SELF
  EPILOG=: LF-.~{{)n
    {{y[SELFTIME1=: SELFTIME1,6!:1''[SELFHIST=: SELFHIST,<y}}
}} rplc 'SELF';SELF
  subst=. 'SELF';SELF;'ID';ID;'IMPLEMENTATION';IMPLEMENTATION
  subst=. subst,'PROLOG4';PROLOG4;'PROLOG3';PROLOG3;'PROLOG';PROLOG
  subst=. subst,'EPILOG';EPILOG
  TEMPLATE rplc subst
}}

NB. get the name class which a primitive token would give, if it were assigned to a name
ncp=: {{ try. nc<'t'[".'t=. ',;y catch. _2 end. }}"0

NB. generate instrumentation wrapper for an arbitrary verb
NB. y is the text of the verb's implementation
NB. result is the name of the wrapped definition
wrap3=: {{)d
  nm=. wrapnm id=. genid x
  nminv=. wrapnm idinv=. id,'inv'
  ".'u=.',;y
  uinv=. u f. inv
  yinv=. name2lrep 'uinv'
  rank=. u b. 0
  (nm)=: 3 :(id {{)n
    PROLOG3
    EPILOG IMPLEMENTATION y
:
    PROLOG4
    EPILOG x IMPLEMENTATION y
}} fillinblanks y) :. (3 :(idinv {{)n
    PROLOG3
    EPILOG IMPLEMENTATION y
:
    PROLOG4
    EPILOG x IMPLEMENTATION y
}} fillinblanks yinv))"rank
  (nminv)=: nm~ inv
  nm
}}

NB. generate instrumentation wrapper for an arbitrary adverb
NB. y is the text of the adverb's implementation
NB. result is the name of the wrapped definition
wrap1=: {{
  nm=. wrapnm id=. genid x
  (nm)=: 1 :(id {{)n
    PROLOG
    t=. u IMPLEMENTATION
    T=. name2lrep 't'
    select. nc<'t'
      case. 0 do. EPILOG t return.
      case. 1 do. ('IDa' wrap1 T)~
      case. 2 do. ('IDc' wrap2 T)~
      case. 3 do. ('IDv' wrap3 T)~
    end.
}} fillinblanks y)
  nm
}}

NB. generate instrumentation wrapper for an arbitrary conjunction
NB. y is the text of the conjunction's implementation
NB. result is the name of the wrapped definition
wrap2=: {{
  nm=. wrapnm id=. genid x
  (nm)=: 2 :(id {{)n
    PROLOG
    t=. u IMPLEMENTATION v
    T=. name2lrep 't'
    select. nc<'t'
      case. 0 do. EPILOG t return.
      case. 1 do. ('IDa' wrap1 T)~
      case. 2 do. ('IDc' wrap2 T)~
      case. 3 do. ('IDv' wrap3 T)~
    end.
}} fillinblanks y)
  nm
}}

NB. wrap "anything" in a sentence
NB. (but text representing nouns or punctuation does not get wrapped)
wrapA=: {{
  select. ncp y
    case. 1 do. <'' wrap1;y NB. adverb
    case. 2 do. <'' wrap2;y NB. conjunction
    case. 3 do. <'' wrap3;y NB. verb
    case.   do. y
  end.
}}

require'debug/dissect' NB. temporary hack

NB. in a new locale:
NB.   wrap the operations in a sentence
NB.   execute the resulting sentence
NB.   and leave room for postmortem
NB.   temporarily use dissect to sort of represent the postmortem process
wrapeval=: {{
  echo locale=: cocreate'' NB. until we have postmortem code, echo locale for developer to see
  coinsert__locale <'base'
  N__locale=: 0
  Zsentence__locale=: 'Zresult=: ',wrapA__locale"0&.;:y
  NB. dissect will do this for us, no need to execute twice:
  NB.   do__locale Zsentence__locale
  NB. but bring back this do__locale line when replacing dissect with some other postmortem mechanism
  NB.
  NB. postmortem
  NB. launching two dissects at the same time triggers a rendering bug in dissect
  NB. launching dissect from sys_timer_z_ can crash J
  echo 'dissect ',quote y
  dissect__locale Zsentence__locale
  Zresult__locale
  NB. coerase locale NB. in principle this would need to happen on closing the window representing the postmortem
}}
