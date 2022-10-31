require "ripper"
code = <<STR
  i = 1
  i++
STR

pp Ripper.lex(code)

# [[[1, 0], :on_sp, "  ", BEG],
#  [[1, 2], :on_ident, "i", CMDARG],
#  [[1, 3], :on_sp, " ", CMDARG],
#  [[1, 4], :on_op, "=", BEG],
#  [[1, 5], :on_sp, " ", BEG],
#  [[1, 6], :on_int, "1", END],
#  [[1, 7], :on_nl, "\n", BEG],
#  [[2, 0], :on_sp, "  ", BEG],
#  [[2, 2], :on_ident, "i", END|LABEL],
#  [[2, 3], :on_op, "+", BEG],
#  [[2, 4], :on_op, "+", BEG],
#  [[2, 5], :on_ignored_nl, "\n", BEG]]
