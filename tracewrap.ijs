cocurrent'jztrace' NB. for development (wouldn't need for prod)

Note''
Limitations:
   wrapped operations may need to perform assignments in the implied locale
   to achieve this, all wrapped operations exist in the implied locale
   specifically, wrapped operations have names prefixed with 'Z'
   And, all names begining with that prefix are erased during cleanup
   cleanup happens at the begining of a trace and after a trace completes

   (a different prefix could be used - possibly multiple characters)


Names introduced here:

  fillinblanks                replace template variables in definition text with values
  fiximplementation           include absolute locale reference in names in sentence
  genid                       allocate next variable name prefix
  name2lrep                   given name, get (sentence) which generates its value
  ncp                         "name" class for primitive expressions
  traceeval                   wrap primitives in a sentence such that evaluating will show intermediate results
  unwrap                      replace synthetic names in sentence with the phrase they replaced
  wrap1                       wrap an adverb (name class 1)
  wrap2                       wrap a conjunction (name class 2)
  wrap3                       wrap a verb (name class 3)
  wrapA                       wrap any primitive (but not nouns nor punctuation)
  wraplocale                  obsolete: locale holding wrappers
  wrapnm                      given a wrap id, return the base (prefix) name
  Zindent                     indent level for showing intermediate results
  Zn                          seed for generating next wrap id
  Zsentence                   sentence being wrapped
)

NB. we'll be generating a sequence of related names
NB. this base id will be used to distinguish different sets of names
NB. conceptually, this gets used like a numeric locale
NB. except it will be contained inside one locale
genid=: {{
  if. y -: _1 do.
    erase__m 'Z' nl__m ''
    Zindent__m=: 1+Zn__m=: 0
    EMPTY
  else.
    ":Zn__m=: Zn__m+1
  end.
}}



NB. get the name given an id (from genid - maybe appended to something else)
wrapnm=: {{ 'Z',y,'_',(;m),'_' }} NB. y: id

NB. 5!:5 almost serializes the definition of a name
NB. but it may give results which cannot be used in a sentence
NB. fix that 
NB. (and note that we'll be using it on local names, some of the time).
name2lrep=: '(',')',~{{
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
  tokens=. ;: y
  names=. _2<nc tokens
  absolute=. ('_'={:@>tokens) * 2 <: +/ .=&'_'@> tokens
  indirect=. +./@('__'&E.)@>tokens
  fix=. names * -. indirect +. absolute
  ;:inv fix ,&('_',LOCALE,'_') each@]^:["0 tokens
}}

NB. replace wrapeval surrogates in sentence with their a representation of their original forms
unwrap=: {{
  (coname'') unwrap y
:
  sfx=. '_',(;x),'_'
  N=. -#sfx
  r=. ''
  for_tok.;: y do.
    token=. ;tok
    if. 'Z'={.token do.
      if. sfx-: N{.token do.
        display=. ".(N}.token),'ORIG',sfx
        if. #display do.
          if. ({.display) e. '.:' do. display=. ' ',display end.
          if. 1 < #;: display do. display=. display end.
          r=. r, display continue.
        end.
      end.
    elseif. ({.token)e.'.:' do.
      token=. ' ',token
    end.
    r=. r, token
  end.
}}

NB. given a template for wrapping a definition,
NB.   and the text of the definition,
NB.   and the id for the constructed names to use
NB.   build the text of the wrapping (instrumentation) definition
fillinblanks=: {{
  ID=. x
  LOCALE=. m
  LOCALEsuffix=. '_',(;m),'_'
  LOCALEarg=. '(<',(quote;m),')'
  TEMPLATE=. n
  IMPLEMENTATION=. LOCALE fiximplementation_jztrace_;y
  ORIGTEXT=. LOCALE unwrap_jztrace_;y
  (LOCALE wrapnm_jztrace_ ID,'ORIG')=: ORIGTEXT
  SELF=. LOCALE wrapnm_jztrace_ ID
  subst=. 'SELF';SELF;'ID';ID;'IMPLEMENTATION';IMPLEMENTATION;'ORIGCODE';ORIGTEXT
  subst=. subst,'__LOCALE';LOCALEsuffix;'LOCALE';LOCALEarg;'ORIGTEXT';quote ORIGTEXT
  PROLOG=. 'Zindent__LOCALE=: 1+([ LOCALE&show_indent_jztrace_) indent=. Zindent__LOCALE' rplc subst
  EPILOG=. 'r [ LOCALE show_indent_jztrace_ Zindent=: indent [ indent LOCALE show_padded_jztrace_ r=. ' rplc subst
  subst=. subst,'PROLOG';PROLOG;'EPILOG';EPILOG
  TEMPLATE rplc subst
}}


NB. get the name class which a primitive token would give, if it were assigned to a name
ncp=: {{ if. '[:' -: ;y do. _3 else. try. nc__m<'t'[do__m't=. ',;y catch. _2 end. end. }}

NB. generate instrumentation wrapper for an arbitrary verb
NB. y is the text of the verb's implementation
NB. result is the name of the wrapped definition
wrap3=: {{
  nm=. m wrapnm_jztrace_ id=. m genid_jztrace_ ''
  nminv=. m wrapnm_jztrace_ idinv=. id,'inv'
  ".'u=.',;y
  uinv=. u inv NB. the name u is special and is dereferenced here
  yinv=. name2lrep_jztrace_ 'uinv'
  rank=. u b. 0
  Def=. id m fillinblanks_jztrace_ FILLING3_jztrace_ y
  iDef=. idinv m fillinblanks_jztrace_ FILLING3_jztrace_ yinv
  (nm)=: 3 : Def :. (3 :iDef)"rank
  (nminv)=: nm~ inv
  nm
}}

NB. fillinblanks template for wrapped verbs
FILLING3=: {{)n
    NB. verb: ORIGCODE
    PROLOG
    Zindent LOCALE show_padded_jztrace_&> ORIGTEXT;<y
    EPILOG IMPLEMENTATION y
:
    PROLOG
    Zindent LOCALE show_padded_jztrace_&> x;ORIGTEXT;<y
    EPILOG x IMPLEMENTATION y
}}

NB. generate instrumentation wrapper for an arbitrary adverb
NB. y is the text of the adverb's implementation
NB. result is the name of the wrapped definition
wrap1=: {{
  LOCALE=. m
  nm=. LOCALE wrapnm_jztrace_ id=. LOCALE genid_jztrace_ ''
  (nm)=: 1 :(id m fillinblanks_jztrace_ FILLING1_jztrace_ y)
  nm
}}

NB. fillinblanks template for wrapped adverbs
FILLING1=: {{)n
    NB. adverb: ORIGCODE
    PROLOG
    Zindent LOCALE show_padded_jztrace_&> (LOCALE unwrap_jztrace_ 5!:5<'u');ORIGTEXT 
    do__LOCALE 'u=. u {{ u ( ',ORIGTEXT,' ) }}'
    t=. name2lrep_jztrace_'u'
    if. 0=nc<'u' do.
      indent LOCALE show_padded_jztrace_ m
    else.
      indent LOCALE show_padded_jztrace_ LOCALE unwrap_jztrace_ t
    end.
    LOCALE show_indent_jztrace_ Zindent=: indent
    select. nc<'u'
      case. 0 do. m return.
      case. 1 do. name=. LOCALE wrap1_jztrace_ t
      case. 2 do. name=. LOCALE wrap2_jztrace_ t
      case. 3 do. name=. LOCALE wrap3_jztrace_ t
    end.
    name~
}}

NB. generate instrumentation wrapper for an arbitrary conjunction
NB. y is the text of the conjunction's implementation
NB. result is the name of the wrapped definition
wrap2=: {{
  LOCALE=. m
  nm=. LOCALE wrapnm_jztrace_ id=. LOCALE genid_jztrace_ ''
  (nm)=: 2 :(id LOCALE fillinblanks_jztrace_ FILLING2_jztrace_ y)
  nm
}}

NB. fillinblanks template for wrapped conjunctions
FILLING2=: {{)n
    NB. conjuction: ORIGCODE
    PROLOG
    Zindent LOCALE show_padded_jztrace_&> (LOCALE unwrap_jztrace_ 5!:5<'u');ORIGTEXT;LOCALE unwrap_jztrace_ 5!:5<'v'
    do__LOCALE 'u=. u {{  u ( ',ORIGTEXT,' ) v }} v'
    t=. name2lrep_jztrace_'u'
    if. 0=nc<'u' do.
      indent LOCALE show_padded_jztrace_ m
    else.
      indent LOCALE show_padded_jztrace_ LOCALE unwrap_jztrace_ t
    end.
    LOCALE show_indent_jztrace_ Zindent=: indent
    select. nc<'u'
      case. 0 do. m return.
      case. 1 do. name=. LOCALE wrap1_jztrace_ t
      case. 2 do. name=. LOCALE wrap2_jztrace_ t
      case. 3 do. name=. LOCALE wrap3_jztrace_ t
    end.
    name~
}}

NB. wrap "anything" in a sentence
NB. (but text representing nouns or punctuation does not get wrapped)
wrapA=: {{
  suffix=. '_',(;m),'_'
  if. suffix-:(-#suffix){.;y do. y return. end.
  select. m ncp y
    case. 1 do. <m wrap1;y NB. adverb
    case. 2 do. <m wrap2;y NB. conjunction
    case. 3 do. <m wrap3;y NB. verb
    case.   do. y
  end.
}}


NB. in a new locale:
NB.   wrap the operations in a sentence
NB.   execute the resulting sentence
NB.   wrapped operations will show intermediate results
tracewrap=: {{
  userlocale=. m
  tokes=. ;: y
  mask=. tokes e.'=:';'=.'
  names=. _1<:nc tokes
  varmask=. names*}.mask,0
  for_i.I.varmask do. NB. weakness here, if name was quoted
    name=. i{tokes
    varmask=. 1 (i<.I. tokes e. name)} varmask
  end.
  wrapmask=. -.varmask NB. token names which must be predefined
  Zsentence=: ;:inv wrapmask userlocale wrapA@]^:["0 tokes
}}
