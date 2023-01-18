# `qcall()`

```c
static NODE *new_qcall(
  struct parser_params* p,
  ID     atype,
  NODE  *recv,
  ID     mid,
  NODE  *args,
  const YYLTYPE *op_loc,
  const YYLTYPE *loc
)
{
  NODE *qcall = NEW_QCALL(atype, recv, mid, args, loc);
  nd_set_line(qcall, op_loc->beg_pos.lineno);
  return qcall;
}
```
