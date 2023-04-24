# `struct parser_params`

```c
// parse.y

struct parser_params {
  rb_imemo_tmpbuf_t *heap;

  // union YYSTYPE {
  //   VALUE val;
  //   NODE *node;
  //   ID id;
  //   int num;
  //   st_table *tbl;
  //   const struct vtable *vars;
  //   struct rb_strterm_struct *strterm;
  //   struct lex_context ctxt;
  // };
  YYSTYPE *lval; // yylval

  YYLTYPE *yylloc;

  struct {
    rb_strterm_t *strterm; // 文字列モード
    VALUE (*gets)(struct parser_params*,VALUE); // inputから行を取得して返す関数 (lex_getline())
    VALUE input;      // 入力全体を表すRubyオブジェクト
    VALUE lastline;   // 読み込み中の行
    VALUE nextline;   // 次の行
    const char *pbeg; // バッファの先頭
    const char *pcur; // カーソルの現在位置 (終点)
    const char *pend; // バッファの終端
    const char *ptok; // カーソルの現在位置 (始点)

    union {
      long ptr;
      VALUE (*call)(VALUE, int);
    } gets_;

    enum lex_state_e state; // スキャナの状態

    int paren_nest; // 任意の "()[]{}" のネストレベル
    int lpar_beg;   // tLAMBEG と keyword_do_LAMBDA の検出用
    int brace_nest; // "{}" のネストレベル
  } lex;

  stack_type cond_stack;   // while ... do などのdoの深さを維持するスタック
  stack_type cmdarg_stack; // foo ... do などのdoの深さを維持するスタック

  int tokidx; // バッファの先頭からトークンの末尾
  int toksiz; // バッファ長
  int tokline;

  char *tokenbuf; // バッファの先頭へのポインタ

  // ヒアドキュメント用
  int heredoc_end;
  int heredoc_indent;
  int heredoc_line_indent;

  struct local_vars *lvtbl; // 環境の情報を保存するテーブル
  st_table *pvtbl;
  st_table *pktbl;
  int line_count;
  int ruby_sourceline;          // 現在の行番号
  const char *ruby_sourcefile;  // 現在のソースファイル
  VALUE ruby_sourcefile_string; // 現在のソース文字列

  rb_encoding *enc;

  token_info *token_info;

  VALUE case_labels;
  VALUE compile_option;

  // デバッグ用
  VALUE debug_buffer;
  VALUE debug_output;

  struct {
    VALUE token;
    int beg_line;
    int beg_col;
    int end_line;
    int end_col;
  } delayed;

  ID cur_arg;

  rb_ast_t *ast;
  int node_id;

  int max_numparam;

  struct lex_context ctxt;

  unsigned int command_start:1;
  unsigned int eofp: 1;
  unsigned int ruby__end__seen: 1;
  unsigned int debug: 1;
  unsigned int has_shebang: 1;
  unsigned int token_seen: 1;
  unsigned int token_info_enabled: 1;

# if WARN_PAST_SCOPE
  unsigned int past_scope_enabled: 1;
# endif

  unsigned int error_p: 1;
  unsigned int cr_seen: 1;

#ifndef RIPPER
  /* Ruby core only */

  unsigned int do_print: 1;
  unsigned int do_loop: 1;
  unsigned int do_chomp: 1;
  unsigned int do_split: 1;
  unsigned int keep_script_lines: 1;
  unsigned int error_tolerant: 1;
  unsigned int keep_tokens: 1;

  NODE *eval_tree_begin;
  NODE *eval_tree;
  VALUE error_buffer;
  VALUE debug_lines;
  const struct rb_iseq_struct *parent_iseq;

  /* store specific keyword locations to generate dummy end token */
  VALUE end_expect_token_locations;
  /* id for terms */
  int token_id;
  /* Array for term tokens */
  VALUE tokens;

#else
  /* Ripper only */

  VALUE value;
  VALUE result;
  VALUE parsing_thread;

#endif
};
```

### `lvtbl`

```c
// parse.y

struct rb_strterm_struct {
  VALUE flags;
  union {
    rb_strterm_literal_t literal;
    rb_strterm_heredoc_t heredoc;
  } u;
};
```

```c
// parse.y

struct vtable {
  ID *tbl;
  int pos;
  int capa;
  struct vtable *prev;
};

struct local_vars {
  struct vtable *args;
  struct vtable *vars;
  struct vtable *used;

# if WARN_PAST_SCOPE
  struct vtable *past;
# endif

  struct local_vars *prev;

# ifndef RIPPER
  struct {
    NODE *outer, *inner, *current;
  } numparam;
# endif
};
```

```c
typedef struct token_info {
  const char *token;
  rb_code_position_t beg;
  int indent;
  int nonspc;
  struct token_info *next;
} token_info;
```

#### `lvtbl`の操作

```c
static void
local_push(struct parser_params *p, int toplevel_scope)
{
  struct local_vars *local; // p->lvtblに代入される情報
  int inherits_dvars = toplevel_scope && compile_for_eval;
  int warn_unused_vars = RTEST(ruby_verbose);

  local = ALLOC(struct local_vars);
  local->prev = p->lvtbl;
  local->args = vtable_alloc(0);
  local->vars = vtable_alloc(inherits_dvars ? DVARS_INHERIT : DVARS_TOPSCOPE);

#ifndef RIPPER
  if (toplevel_scope && compile_for_eval) warn_unused_vars = 0;
  if (toplevel_scope && e_option_supplied(p)) warn_unused_vars = 0;
  local->numparam.outer = 0;
  local->numparam.inner = 0;
  local->numparam.current = 0;
#endif

  local->used = warn_unused_vars ? vtable_alloc(0) : 0;

# if WARN_PAST_SCOPE
  local->past = 0;
# endif

  CMDARG_PUSH(0);
  COND_PUSH(0);
  p->lvtbl = local;
}
````
