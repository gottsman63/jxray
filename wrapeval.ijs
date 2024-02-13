cocurrent'watchj' NB. for development (wouldn't need for prod)

NB. we'll be generating a sequence of related names
NB. this base id will be used to distinguish different sets of names
genid=: {{
  Zparents=: Zparents__x, y
  ":Zn__x=: Zn__x+1
}}

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

NB. fix locale relative names in sentence y to be absolute names in locale x
fiximplementation=: {{
  LOCALE=. ;x
  suffix=. '_',LOCALE,'_'
  sentence=. ;:inv^:L. y
  tokens=. tokenize sentence
  names=. _2<nc tokens
  iffy=. 2 <: +/ .=&'_'@> tokens
  maybe=. '_'={:@>tokens
  yeah=. +./@('__'&E.)@>tokens
  fix=. names * -. yeah +. iffy*maybe
  ;fix ,&suffix each@]^:["0 tokens
}}

getdisp=: {{
  r=. ''
  for_token.tokenize y do.
    token=. ;token
    if. 'Z'={.token do.
      if. '_'={:token do.
        nm=. ;coname''
        sfx=. '_',nm,'_'
        if. sfx-: (-#sfx){.token do.
          display=. ".rplc&(sfx;'DISP_',nm,'_') token
          if. #display do.
            r=. r, display continue.
          end.
        end.
      end.
    end.
    r=. r, token
  end.
  r
}}

NB. given a template for wrapping a definition,
NB.   and the text of the definition,
NB.   and the id for the constructed names to use
NB.   build the text of the wrapping (instrumentation) definition
fillinblanks=: {{
  ID=. x
  LOCALE=. m
  TEMPLATE=. n
  IMPLEMENTATION=. LOCALE fiximplementation ;y
  DISPLAYTEXT=. getdisp;y
  SELF=. wrapnm ID
  for_suffix.>;:'HAS HIST TIME0 TIME1 X Y' do.
    (SELF,suffix)=: '' NB. for future use by wrapper being created
  end.
  (SELF,'DISP')=: DISPLAYTEXT
  PROLOG=. {{)n
    SELFTIME0=: SELFTIME0,gettime''
}} rplc 'SELF';SELF
  PROLOG3=. PROLOG,{{)n
  'SELFY';SELFY=:SELFY,<y
}} rplc 'SELF';SELF
  PROLOG4=. PROLOG3,{{)n
  'SELFX'; SELFX=: SELFX,<x
}} rplc 'SELF';SELF
  EPILOG=: LF-.~{{)n
    {{y[SELFTIME1=: SELFTIME1,gettime''[SELFHIST=: SELFHIST,<y}}
}} rplc 'SELF';SELF
  subst=. 'SELF';SELF;'ID';ID;'IMPLEMENTATION';IMPLEMENTATION
  subst=. subst,'PROLOG4';PROLOG4;'PROLOG3';PROLOG3;'PROLOG';PROLOG
  subst=. subst,'EPILOG';EPILOG
  TEMPLATE rplc subst
}}

TIME=: 0
gettime=: {{ NB. hack for imprecise 6!:1
  TIME=: (6!:1'')>.TIME+1e_7
}}


NB. get the name class which a primitive token would give, if it were assigned to a name
ncp=: {{ try. nc<'t'[".'t=. ',;y catch. _2 end. }}"0


NB. generate instrumentation wrapper for an arbitrary verb
NB. y is the text of the verb's implementation
NB. result is the name of the wrapped definition
wrap3=: {{)d
  wraplocale=. coname''
  nm=. wrapnm id=. wraplocale genid x
  nminv=. wrapnm idinv=. id,'inv'
  ".'u=.',;y
  uinv=. u inv NB. the name u is special and is dereferenced here
  yinv=. name2lrep 'uinv'
  rank=. u b. 0
  sep=: ':',LF
  Def=: id Zuserlocale fillinblanks {{)n
    PROLOG3
    EPILOG IMPLEMENTATION y
:
    PROLOG4
    EPILOG x IMPLEMENTATION y
}} y
  iDef=: idinv Zuserlocale fillinblanks {{)n
    PROLOG3
    EPILOG IMPLEMENTATION y
:
    PROLOG4
    EPILOG x IMPLEMENTATION y
}} yinv
  (nm)=: 3 : Def :. (3 :iDef)"rank
  (nminv)=: nm~ inv
  nm,'_',(;coname''),'_'
}}

NB. generate instrumentation wrapper for an arbitrary adverb
NB. y is the text of the adverb's implementation
NB. result is the name of the wrapped definition
wrap1=: {{
  wraplocale=. coname''
  nm=. wrapnm id=. wraplocale genid x
  (nm)=: 1 :(id Zuserlocale fillinblanks {{)n
    PROLOG
    t=. u IMPLEMENTATION
    T=. name2lrep 't'
    select. nc<'t'
      case. 0 do. EPILOG t return.
      case. 1 do. name=. ID wrap1 T
      case. 2 do. name=. ID wrap2 T
      case. 3 do. name=. ID wrap3 T
    end.
    SELFHAS=: SELFHAS,<name NB. remember name(s) of delegate(s)
    name~
}} y)
  (nm,'HAS')=: ''
  nm,'_',(;coname''),'_'
}}

NB. generate instrumentation wrapper for an arbitrary conjunction
NB. y is the text of the conjunction's implementation
NB. result is the name of the wrapped definition
wrap2=: {{
  wraplocale=. coname''
  nm=. wrapnm id=. wraplocale genid x
  (nm)=: 2 :(id Zuserlocale fillinblanks {{)n
    PROLOG
    t=. u IMPLEMENTATION v
    T=. name2lrep 't'
    select. nc<'t'
      case. 0 do. EPILOG t return.
      case. 1 do. name=. ID wrap1 T
      case. 2 do. name=. ID wrap2 T
      case. 3 do. name=. ID wrap3 T
    end.
    SELFHAS=: SELFHAS,<name NB. remember name(s) of delegate(s)
    name~
}} y)
  (nm,'HAS')=: ''
  nm,'_',(;coname''),'_'
}}

NB. wrap "anything" in a sentence
NB. (but text representing nouns or punctuation does not get wrapped)
wrapA=: {{
  suffix=. '_',(;coname''),'_'
  if. suffix-:(#suffix){.y do. y return. end.
  select. ncp y
    case. 1 do. <0 wrap1;y NB. adverb
    case. 2 do. <0 wrap2;y NB. conjunction
    case. 3 do. <0 wrap3;y NB. verb
    case.   do. y
  end.
}}

NB. require'debug/dissect' NB. temporary hack

NB. in a new locale:
NB.   wrap the operations in a sentence
NB.   execute the resulting sentence
NB.   and leave room for postmortem
NB.   temporarily use dissect to sort of represent the postmortem process
wrapeval=: {{
NB. for interactive/dev use - prefer using dyad from code
  echo }."1}:"1}.}:":'wrapeval locale ';' ',;wraplocale=: cocreate''
  Zparents__wraplocale=: ,0
  Zn__wraplocale=: 1
  coinsert__wraplocale 'base'
  wraplocale wrapeval y
:
  wraplocale=. x
  tokes=. tokenize y
  mask=. tokes e.'=:';'=.'
  names=. _1<:nc tokes
  varmask=. names*}.mask,0
  for_i.I.varmask do. NB. weakness here, if name was quoted
    name=. i{tokes
    varmask=. 1 (i<.I. tokes e. name)} varmask
  end.
  wrapmask=. -.varmask NB. token names which must be predefined
  Zsentence__wraplocale=: ;:inv wrapmask wrapA__wraplocale@]^:["0 tokes
  do__wraplocale 'Zresult=: ',Zsentence__wraplocale
}}


wrapeval_z_=: wrapeval_watchj_
