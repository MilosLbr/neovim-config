; Custom indent queries for C# (c_sharp).
; nvim-treesitter does not ship indents.scm for c_sharp,
; so treesitter-based indentation falls back to column 0.
; Ported from the C language indent queries, adapted to C# node types.
; Node names verified via vim.treesitter.query.parse().
; Place in: <nvim config>/queries/c_sharp/indents.scm

; Primary indent containers
[
  (block)
  (declaration_list)
  (switch_body)
  (switch_section)
  (enum_member_declaration_list)
  (accessor_list)
  (initializer_expression)
] @indent.begin

; Expression statements (narrowed to avoid issues with ERROR nodes)
(expression_statement
  (_) @indent.begin
  ";" @indent.end)

; Braceless for/foreach/while/do
((for_statement
  body: (_) @_body) @indent.begin
  (#not-kind-eq? @_body "block"))

((foreach_statement
  body: (_) @_body) @indent.begin
  (#not-kind-eq? @_body "block"))

((while_statement
  body: (_) @_body) @indent.begin
  (#not-kind-eq? @_body "block"))

((do_statement
  body: (_) @_body) @indent.begin
  (#not-kind-eq? @_body "block"))

; If/else
(if_statement
  condition: (_) @indent.begin)

(if_statement
  consequence: (_
    ";" @indent.end) @_consequence
  (#not-kind-eq? @_consequence "block")) @indent.begin

; Try/catch/finally
((try_statement
  body: (_) @_body) @indent.begin
  (#not-kind-eq? @_body "block"))

((catch_clause
  body: (_) @_body) @indent.begin
  (#not-kind-eq? @_body "block"))

((finally_clause
  (_) @_body) @indent.begin
  (#not-kind-eq? @_body "block"))

; Lambda
(lambda_expression
  body: (_) @indent.begin)

; Switch expression arms
(switch_expression_arm) @indent.begin

; End of blocks
(block
  "}" @indent.end)

; Branch nodes (dedent themselves)
[
  ")"
  "}"
] @indent.branch

; Align arguments/parameters within parentheses
([
  (argument_list)
  (parameter_list)
] @indent.align
  (#set! indent.open_delimiter "(")
  (#set! indent.close_delimiter ")"))

; Ignore strings
[
  (string_literal)
  (interpolated_string_expression)
] @indent.ignore

(comment) @indent.auto

