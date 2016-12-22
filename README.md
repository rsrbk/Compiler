# GRAMMAR
<program> ::= program <name> var <vars> mark <marks> begin <statements> end
<name> ::= <id>
<vars> ::= <var> | <vars> <var>
<var> ::= <id>.
<marks> ::= <mark> | <marks>, <mark>
<mark> ::= <id>
<statements> ::= <statement> | <statements>\n<statement>
<statement> ::= <assign> | <read>(<vars>) | <write>(<vars>) | <loop> | <if> | <mark>:
<assign> ::= <id>=<expression>
<read> ::= read(<vars>)
<write> ::= write(<vars>)
<loop> ::= repeat <statements> until  <condition>
<if> ::= if <condition> then goto <mark>
<condition> ::= <CT> | <condition> or <CT>
<mark> ::= <id>:
<CT> ::= <CM> | <CT> and <CM>
<CM> ::= <ratio> | not <CM>
<ratio> ::= <expression><symbol><expression>
<symbol> ::= less | more | equals
<expression> ::= <T> | <expression> + <T> | <expression> - <T>
<T> ::= <M> | <T> * <M> | <T> / <M>
<M> ::= <id> | <constant> | (<expression>) 
<id> ::= <letter> | <id><letter> | <id><digit>
<constant> ::= <digit> | <constant><digit>
<letter> ::= a|b|.|z
<digit> ::= 0|1|.|9

# REFORMED GRAMMAR
<program> ::= program id var <vars> mark <marks> begin <statements> end
<vars> ::= {id.}
<marks> ::= {id~}
<statements> ::= <statement> {\n <statement>}
<statement> ::= id=<expression> | read(<vars>) | write(<vars>) |  repeat <statements> until  <condition> | if <condition> then goto id | id:
<expression> ::= <T> {+ <T>|- <T>}
<T> ::= <M> {* <M>|/ <M>}
<M> ::= id | const | (<expression>) 
<condition> ::= <CT> {or CT>}
<CT> ::= <CM> {and <CT>}
<CM> ::= <ratio> | not <CM>
<ratio> ::= <expression><symbol><expression>
<symbol> ::= less | more | equals