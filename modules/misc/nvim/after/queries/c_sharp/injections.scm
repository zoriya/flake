; extends

(
	((comment) @_comm (#match? @_comm "[Ss][Qq][Ll]"))
	.
	[
		((string_literal_fragment) @injection.content)
		(_ ((string_literal_fragment) @injection.content))
		(_ (_ ((string_literal_fragment) @injection.content)))
		(_ (_ (_ ((string_literal_fragment) @injection.content))))
		(_ (_ (_ (_ ((string_literal_fragment) @injection.content)))))
		(_ (_ (_ (_ (_ ((string_literal_fragment) @injection.content))))))
		(_ (_ (_ (_ (_ (_ ((string_literal_fragment) @injection.content)))))))
		(_ (_ (_ (_ (_ (_ (_ ((string_literal_fragment) @injection.content))))))))
		(_ (_ (_ (_ (_ (_ (_ (_ ((string_literal_fragment) @injection.content)))))))))
		(_ (_ (_ (_ (_ (_ (_ (_ (_ ((string_literal_fragment) @injection.content))))))))))
		(_ (_ (_ (_ (_ (_ (_ (_ (_ (_ ((string_literal_fragment) @injection.content)))))))))))
		(_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ ((string_literal_fragment) @injection.content))))))))))))
		(_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ ((string_literal_fragment) @injection.content)))))))))))))
		(_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ ((string_literal_fragment) @injection.content))))))))))))))
		(_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ ((string_literal_fragment) @injection.content)))))))))))))))
		(_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ ((string_literal_fragment) @injection.content))))))))))))))))
		(_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ ((string_literal_fragment) @injection.content)))))))))))))))))
		(_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ ((string_literal_fragment) @injection.content))))))))))))))))))
		(_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ ((string_literal_fragment) @injection.content)))))))))))))))))))
		(_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ ((string_literal_fragment) @injection.content))))))))))))))))))))
		(_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ ((string_literal_fragment) @injection.content)))))))))))))))))))))
		; ((string_literal) @sql)
		; (argument ((string_literal) @sql))
		; (local_declaration_statement
		; 	(variable_declaration
		; 		(variable_declarator
		; 			(equals_value_clause ((string_literal) @sql)))))
		; (local_declaration_statement
		; 	(variable_declaration
		; 		(variable_declarator
		; 			(equals_value_clause ((string_literal) @sql)))))
	]
	(#set! injection.language "sql")
)

