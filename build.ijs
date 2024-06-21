cocurrent'jztrace'
(bootstrap=: {{
  p=: (] #~ [ < +/\.@e.&'/\'@])&((4!:3''){::~4!:4<'bootstrap')@[ , ]
  scripttext=: ;fread@(0 p ,&'.ijs')L:0 cut y
  filename=: 1 p 'jztrace.ijs'
  echo filename,~': ',~":filename fwrite~ scripttext
}})'show trace tracewrap'