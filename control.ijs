checkstack=: {{
  assert. (,0)-:~.#@$@>{."1 Zstack
}}

nextstep=: animate`plan`execute`move {{
echo y
echo Zstack
  for_f. m do.
    echo f
    if. f`:6 y do. EMPTY return. end.
  end.
  'done'
}}

animate=: {{
  0
}}

plan=: {{
  0
}}

NB. may want to separate out each of these lines into separate progress mechanisms.
execute=: {{
  show_pattern Zndx=. 1 1 1 1 i.~ * PTpatterns bwand"1 ,>4 1{.Zstack
  if. Zndx <#PTpatterns do.
    show_mask Zmask=. Zndx{PTsubj
    (coname'') wrapeval build_subexpression Zndx NB. FIXME (need both wraplocale and userlocale and this currently gets both wrong)
    update_stack Zmask
  else.
    0
  end.
}}

build_subexpression=: {{
  action=. (y{PTactions)-.L:0":i.10
  mask=. y{PTsubj
  show_subexpression elements=. mask#,4 _1{.Zstack
  if. action=<'Is' do. elements=. elements 1}~ <'=:' end.
  if. action e. ;:'Monad Dyad' do. elements=. elements _2}~ encall&.;:&.> _2{elements end.
  if. -. action e. ;:'Is Paren' do. elements=. '( '&,@,&' )'L:0"0 elements end.
  'Zresult=:',;elements 
}}

NB. fixme: wrapeval should give name of result?
NB. and we should use extract an executable representation of it from there?
update_stack=: {{
  type=. nc__userlocale <'Zresult'
  drop=. 1+y i:1
  keep=. y i.1
  representation=. 5!:6<'Zresult'
  Zstack=: (keep{.Zstack),(type;(<'FIXME update_stack');representation),drop}.Zstack
  checkstack''
}}

move=: {{
  if. #Zqueue do.
    'class loc val'=. {:Zqueue
    isasgn=. asgn=0 0{::Zstack
    if. asgn+.name-:class do.
      Zstack=: ({:Zqueue),Zstack
      checkstack''
    else.
      class=. (nc__userlocale <val){noun,adv,conj,verb
      if. verb~:class do. val=. 5!:5<'val' end.
      Zstack=. (class;loc;val),Zstack
      checkstack''
    end.
    Zqueue=: }: Zqueue
    1
  else.
    0
  end.
}}