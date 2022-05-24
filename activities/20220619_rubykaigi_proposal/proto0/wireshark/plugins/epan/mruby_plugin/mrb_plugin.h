#ifndef MRB_PLUGIN_H
#define MRB_PLUGIN_H
#include "config.h"
#include <epan/packet.h>

#include <stdlib.h>
#include <string.h>

#include <mruby.h>
#include <mruby/class.h>
#include <mruby/compile.h>
#include <mruby/numeric.h>
#include <mruby/string.h>
#include <mruby/value.h>
#include <mruby/variable.h>

#include "mrb_subtree.c"

#define PLUGIN_NAME_LENGTH    100
#define PROTOCOL_NAME_LENGTH  4

#define SUBTREE_FIELDS_SIZE   100

#define BIT_HANDLES_POOL_SIZE 1000
#define BIT_HANDLES_SIZE      100

typedef struct {
  char name[PLUGIN_NAME_LENGTH];
  char filter_name[PLUGIN_NAME_LENGTH];
  char protocol[PROTOCOL_NAME_LENGTH];
  unsigned int port;
  unsigned int subtree;
} plugin_t;

typedef enum {
  NORMAL,
  BITMASKED,
  BIT,
} PacketType;

typedef struct {
  char *format;
  void *value;
  char *fallback;
} column_info_t;

typedef struct {
  char *format;
  void *value;
  char *fallback;
} detail_info_t;

typedef struct {
  int handle;
  int size;
  int symbol;
  PacketType type;
  column_info_t cinfo;
  detail_info_t dinfo;
} field_t;

typedef struct {
  int field_size;
  int field_handles[SUBTREE_FIELDS_SIZE];
  field_t fields[SUBTREE_FIELDS_SIZE];
} subtree_t;

typedef struct {
  int size;
  int symbol;
  int offset;
} bit_handle_t;

static  int phandle   = -1;
static gint ett_state = -1;

static plugin_t  plugin;
static subtree_t subtree;

int bitmasked_fields_size = 0;
static int* bit_handles_pool[BIT_HANDLES_POOL_SIZE];
bit_handle_t bit_handles[BIT_HANDLES_SIZE];

mrb_value mrb_plugin_get_name(mrb_state *mrb, mrb_value self);
mrb_value mrb_plugin_get_filter_name(mrb_state *mrb, mrb_value self);
mrb_value mrb_plugin_get_protocol(mrb_state *mrb, mrb_value self);
mrb_value mrb_plugin_get_port(mrb_state *mrb, mrb_value self);

#endif
