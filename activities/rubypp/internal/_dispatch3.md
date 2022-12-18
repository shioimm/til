# "#define dispatch3"

```c
// compiling ripper.c
// ripper.y:2476:64:
// error: called object type 'NODE *' (aka 'struct RNode *') is not a function or function pointer
// {
//   VALUE v1,v2,v3,v4;
//   v1=(yyvsp[-2].val);
//   v2=(yyvsp[0].val);
//   v3=x(); <------------ (called object type 'NODE *' is not a function or function pointer)
//   v4=dispatch3(opassign,v1,v2,v3);
//   (yyval.val)=v4;
//  }
```

```c
#define dispatch3(n,a,b,c)  ripper_dispatch3(p, TOKEN_PASTE(ripper_id_, n), (a), (b), (c))
```
