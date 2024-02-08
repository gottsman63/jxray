show_pattern=: {{
  if. y<#PTactions do.
    echo 'pattern  ',y{::PTactions
  end.
  EMPTY
}}

show_mask=: {{
  echo 'mask  ',":y
  EMPTY
}}

show_subexpression=: {{
  echo ' '"_`(~.@i.&(3{,":a:)@])`]}"1~1 1}._1 _1}.":'subexpression ';y
  echo ''
  EMPTY
}}