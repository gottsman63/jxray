NB. insert definition of primitives here

genid=: {{ y,":N=: N+1}}

wrapnm=: {{ 'Z',y }} NB. y: id

fixlrep=: {{
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
}}

fillinblanks=: {{
  ID=. x
  TEMPLATE=. m
  IMPLEMENTATION=. ;y
  SELF=. wrapnm ID
  PROLOG=. {{)n
    if.0>nc<'SELFHIST' do.SELFHIST=: SELFX=: SELFY=: SELFTIME0=: SELFTIME1=: '' end.
    SELFTIME0=: SELFTIME0,6!:1''
}} rplc 'SELF';SELF
  PROLOG3=. PROLOG,{{)n
  'SELFY';SELFY=:SELFY,<y
}} rplc 'SELF';SELF
  PROLOG4=. PROLOG3,{{)n
  'SELFX'; SELFX=: SELFX,<x
}} rplc 'SELF';SELF
  EPILOG=: LF-.~{{)n
    {{y[SELFTIME1=: SELFTIME1,6!:1''[SELFHIST=: SELFHIST,<y}}
}} rplc 'SELF';SELF
  TEMPLATE rplc 'SELF';SELF;'ID';ID;'IMPLEMENTATION';IMPLEMENTATION;'PROLOG4';PROLOG4;'PROLOG3';PROLOG3;'PROLOG';PROLOG;'EPILOG';EPILOG
}}

NB. substwrap=: rplc&(,primitives,.wrapnm primitives)

ncp=: {{ try. nc<'t'[".'t=. ',;y catch. _2 end. }}"0

wrap3=: {{)d
  nm=. wrapnm id=. genid x
  nminv=. wrapnm idinv=. id,'inv'
  ".'u=.',;y
  uinv=. u f. inv
  yinv=. fixlrep 5!:5<'uinv'
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

wrap1=: {{
  nm=. wrapnm id=. genid x
  (nm)=: 1 :(id {{)n
    PROLOG
    t=. u IMPLEMENTATION
    T=. <fixlrep '( ',') ',~5!:5<'t'
    select. nc<'t'
      case. 0 do. EPILOG t return.
      case. 1 do. r=.'IDa' wrap1 T
       r~
      case. 2 do. r=. 'IDc' wrap2 T
       r~
      case. 3 do. r=. 'IDv' wrap3 T
       r~
    end.
}} fillinblanks y)
  nm
}}

wrap2=: {{
  nm=. wrapnm id=. genid x
  (nm)=: 2 :(id {{)n
    PROLOG
    t=. u IMPLEMENTATION v
    T=. <fixlrep'( ',') ',~5!:5<'t'
    select. nc<'t'
      case. 0 do. EPILOG t return.
      case. 1 do. r=.'IDa' wrap1 T
       r~
      case. 2 do. r=. 'IDc' wrap2 T
       r~
      case. 3 do. r=. 'IDv' wrap3 T
       r~
    end.
}} fillinblanks y)
  nm
}}

wrapA=: {{
  select. ncp y
    case. 1 do. <'' wrap1;y NB. adverb
    case. 2 do. <'' wrap2;y NB. conjunction
    case. 3 do. <'' wrap3;y NB. verb
    case.   do. y
  end.
}}"0

require'debug/dissect'

wrapeval=: {{
  dissect y
  echo locale=: cocreate'' NB. until we have postmortem code, echo locale for developer to see
  coinsert__locale <'base'
  N__locale=: 0
  Zsentence__locale=: 'Zresult=: ',wrapA__locale&.;:y
  echo 'dissect_',locale,&":&;'_ Zsentence_',locale,&":&;'_'
  do__locale Zsentence__locale
  NB. postmortem
  NB. launching two dissects at the same time triggers a rendering bug in dissect
  NB. launching dissect from sys_timer_z_ can crash J
  Zresult__locale
  NB. coerase locale
}}

NB. J bug: remove the r=. and r~ bits from the wrap2 and wrap3 and try wrapeval '>:&.>i.2 2'

