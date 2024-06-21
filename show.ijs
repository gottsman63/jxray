show_start=: {{
  Zindent_text__y=: ''
  Zcount__y=: 0
  Zindent__y=: 1
  Zout__y=: ''
}}

show_end=: {{
  if. 2 < Zcount__y do.
    echo@> Zout__y
  end.
  show_start y
}}

emit=: {{
  Zout__x=: Zout__x,<y
  EMPTY
}}

NB. show separator indicating indent level but only if previous line is different
show_indent=: {{
  indent_text=. '...','-|'{~(_2+y*3)=i.61
  if. -. Zindent_text__x -: indent_text do.
    Zcount__x=: Zcount__x+1
    x emit_jztrace_ indent_text
  end.
  Zindent_text__x=: indent_text
}}

show_padded=: {{
  Zindent_text__m=: ''
  pad=. '...',3}.(0>.2+3*x)#' '
  m emit_jztrace_ pad,"1]1 1}._1 _1}.":<y
}}

show_padded1=: {{
  Zindent_text=: ''
  pad=. '    '
  echo pad,"1]1 1}._1 _1}.":<y
}}

showZ=: {{ NB. introspection for postmortem debugging
   N=. 2+i.Zn
   echo (,. ".@,&'ORIG'each) 'Z',&":each N
}}
