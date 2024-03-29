; extends
((pipe_table_cell) @my_cell (#lua-match? @my_cell "TODO")) @comment.todo
((pipe_table_cell) @my_cell (#lua-match? @my_cell "IN PROGRESS")) @comment.hint
((pipe_table_cell) @my_cell (#lua-match? @my_cell "DONE")) @comment

((pipe_table_cell) @my_cell (#lua-match? @my_cell "HIGH")) @comment.error
((pipe_table_cell) @my_cell (#lua-match? @my_cell "MEDIUM")) @comment.info
((pipe_table_cell) @my_cell (#lua-match? @my_cell "LOW")) @comment.note
