show_pattern=: {{
  if. y<#PTactions do.
    echo 30$(15 1#'- '),(;y{PTactions),' '
  end.
}}

show_mask=: {{
NB.   echo 'mask  ',":y
  EMPTY
}}

show_subexpression=: {{
  show_a"0 y
NB.   echo ' '"_`(~.@i.&(3{,":a:)@])`]}"1~1 1}._1 _1}.":'subexpression ';y
NB.   echo ''
  EMPTY
}}

show_a=:{{
  1 show_a y
:
  N=. -#sfx=. '_',(;coname''),'_'
  if. 1 e.sfx E. ;y do.
    text=. ''
    for_wd. ;:;y do.
      text=. text,(*#text)#' '
      if. sfx-: N{.;wd do.
        text=. text, ((N}.;wd),'DISP',sfx)~
      end.
    end.
    echo (x#' '),dlb text
  else.
    echo (x#' '),dlb ;y
  end.
}}

show_indent=: {{
  if. y +. Zold_indent > y do.
    echo '=|'{~(1+y*3)=i.64
  end.
  Zpad=: (1+3*y)#' '
  *Zold_indent=: y
}}

show_padded=: {{
  echo Zpad,"1]1 1}._1 _1}.":<y
}}