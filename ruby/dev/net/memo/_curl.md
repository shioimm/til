# curl
https://github.com/curl/curl/tree/master

```c
int main(int argc, char *argv[])
{
  CURLcode result = CURLE_OK;

  tool_init_stderr();

  if (main_checkfds()) {
    errorf("out of file descriptors");
    return CURLE_FAILED_INIT;
  }

  (void)signal(SIGPIPE, SIG_IGN);

  /* Initialize memory tracking */
  memory_tracking_init();

  /* Initialize the curl library - do not call any libcurl functions before this point */
  result = globalconf_init();

  if(!result) {
    /* Start our curl operation */
    result = operate(argc, argv);

    /* Perform the main cleanup */
    globalconf_free();
  }

  return (int)result;
}
```
