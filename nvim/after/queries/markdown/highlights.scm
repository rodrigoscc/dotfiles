; extends
((pipe_table_cell) @my_cell (#lua-match? @my_cell "TODO")) @markdown.todo
((pipe_table_cell) @my_cell (#lua-match? @my_cell "IN PROGRESS")) @markdown.in_progress
((pipe_table_cell) @my_cell (#lua-match? @my_cell "DONE")) @markdown.done

((pipe_table_cell) @my_cell (#lua-match? @my_cell "HIGH")) @markdown.high
((pipe_table_cell) @my_cell (#lua-match? @my_cell "MEDIUM")) @markdown.medium
((pipe_table_cell) @my_cell (#lua-match? @my_cell "LOW")) @markdown.low
