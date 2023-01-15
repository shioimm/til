# `yycompile()` (parse.y)

```c
rb_ast_t*
rb_parser_compile_file_path(VALUE vparser, VALUE fname, VALUE file, int start)
{
  struct parser_params *p;

  TypedData_Get_Struct(vparser, struct parser_params, &parser_data_type, p);

  // pにソースコードを読み込むために必要な情報を渡す
  // (io.c) VALUE rb_io_gets_internal(VALUE io);
  p->lex.gets = lex_io_gets;
  p->lex.input = file;
  p->lex.pbeg = p->lex.pcur = p->lex.pend = 0;

  return yycompile(vparser, p, fname, start);
}
```

```c
static rb_ast_t *
yycompile(VALUE vparser, struct parser_params *p, VALUE fname, int line)
{
  rb_ast_t *ast;

  // pにソースコードを読み込むために必要な情報を渡す
  if (NIL_P(fname)) {
    p->ruby_sourcefile_string = Qnil;
    p->ruby_sourcefile = "(none)";
  }
  else {
    // (string.c) RUBY_FUNC_EXPORTED VALUE rb_fstring(VALUE str);
    p->ruby_sourcefile_string = rb_fstring(fname);
    p->ruby_sourcefile = StringValueCStr(fname);
  }

  p->ruby_sourceline = line - 1;
  p->lvtbl = NULL;
  p->ast = ast = rb_ast_new(); // 新しい rb_ast_t ast を作成

  // (vm_trace.c) VALUE rb_suppress_tracing(VALUE (*func)(VALUE), VALUE arg)
  // rb_suppress_tracing() 内で yycompile0() が呼び出される
  rb_suppress_tracing(yycompile0, (VALUE)p);

  p->ast = 0;
  RB_GC_GUARD(vparser); /* prohibit tail call optimization */

  while (p->lvtbl) local_pop(p);

  return ast;
}
```

```c
yycompile0(VALUE arg)
{
  int n;
  NODE *tree;
  struct parser_params *p = (struct parser_params *)arg;
  VALUE cov = Qfalse;

  if (!compile_for_eval && !NIL_P(p->ruby_sourcefile_string)) {
    p->debug_lines = debug_lines(p->ruby_sourcefile_string);
    if (p->debug_lines && p->ruby_sourceline > 0)  // ...
    if (!e_option_supplied(p))  // ...
  }

  if (p->keep_script_lines || ruby_vm_keep_script_lines) {
    if (!p->debug_lines) // ...
    RB_OBJ_WRITE(p->ast, &p->ast->body.script_lines, p->debug_lines);
  }

  parser_prepare(p);

  #define RUBY_DTRACE_PARSE_HOOK(name) \
    if (RUBY_DTRACE_PARSE_##name##_ENABLED()) { \
      RUBY_DTRACE_PARSE_##name(p->ruby_sourcefile, p->ruby_sourceline); \
    }

  RUBY_DTRACE_PARSE_HOOK(BEGIN);
  n = yyparse(p); // parse.c の yyparse() を呼び出す
  RUBY_DTRACE_PARSE_HOOK(END);

  p->debug_lines = 0;
  p->lex.strterm = 0;
  p->lex.pcur = p->lex.pbeg = p->lex.pend = 0;

  if (n || p->error_p) // ...

  tree = p->eval_tree;

  if (!tree) {
    tree = NEW_NIL(&NULL_LOC);
  } else {
    VALUE opt = p->compile_option;
    VALUE tokens = p->tokens;
    NODE *prelude;
    NODE *body = parser_append_options(p, tree->nd_body);

    if (!opt) // ...

    rb_hash_aset(opt, rb_sym_intern_ascii_cstr("coverage_enabled"), cov);
    prelude = block_append(p, p->eval_tree_begin, body);
    tree->nd_body = prelude;
    RB_OBJ_WRITE(p->ast, &p->ast->body.compile_option, opt);

    if (p->keep_tokens) // ...
  }

  p->ast->body.root = tree;
  if (!p->ast->body.script_lines) p->ast->body.script_lines = INT2FIX(p->line_count);

  return TRUE;
}
```
