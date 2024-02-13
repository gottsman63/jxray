NB. this is named 'run.ijs' to take advantage
NB. of jqt's "project" system. With this as
NB. the current open project, hitting F9 will
NB. load this file.

NB. that said, while convenient, the project subsystem
NB. could use more documentation.

NB. One way to approach cloning this project (possibly not the best, but it works):
NB. create a project named watchj in J, then
NB. shut down J, and erase the directory, then
NB. use git clone to recreate the directory.
NB. restart J and use Project>Open (watchj)
NB. from that point forward, use git for code updates

NB. locales:
NB.    userlocale: usually 'base' where names of sentence live
NB.    watchlocale: numeric (temporary) inherits from 'watchj jtrace z'
NB.            watchlocale names begin with 'Z' for each recognition
require'trace' NB. for patterns
cocurrent'watchj'
coinsert 'jtrace'

watch=: {{)v
  NB. wrapwval needs a locale for intermediate results
  NB. use 'Z' prefix for (temp) internals (so they stand out when reading)
  w=. cocreate ''
  NB. u. resolves in caller's locale
  u=. coname
  userlocale__w=: Zuserlocale__w=: u.'' NB. userlocale__w for backwards compatibility with jtrace
  Zparents__w=: ,0
  Zn__w=: 1
  Zstack__w=: 4 2$mark;''
  Ztokens__w=: tokenize Zsentence__w=: y
  coinsert__w 'watchj jtrace'
  Zqueue__w=: (mark;0;''),(class__w&.>,. (2 <\ 0 +/\@, #@>) ,.prespace__w&.>) Ztokens__w
  while. EMPTY-:nextstep__w'' do. end. NB. plan on eventually replacing this line with a timer/ui event
}}

NB. now that we have a definition, we can use that
NB. to find necessary related code.
{{
  if. -. (<'WatchJ') e. ,UserFolders_j_ do.
    fnam=. ;(4!:3''){~4!:4<'watch'
    dnam=. fnam{.~<./i:&'/\'fnam
    UserFolders_j_=: UserFolders_j_,'WatchJ';dnam
  end.
}}''    

NB. load rather than require for easier development
load {{'~WatchJ/',y,'.ijs'}}&.>&.;: 'control show tokenize wrapeval'

watch '(+/%#)p:i.3 3'