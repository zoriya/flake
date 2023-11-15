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
	]
	(#set! injection.language "sql")
)

(
	((comment) @_comm (#match? @_comm "[Ss][Qq][Ll]"))
	.
	[
		((verbatim_string_literal) @injection.content)
		(_ ((verbatim_string_literal) @injection.content))
		(_ (_ ((verbatim_string_literal) @injection.content)))
		(_ (_ (_ ((verbatim_string_literal) @injection.content))))
		(_ (_ (_ (_ ((verbatim_string_literal) @injection.content)))))
		(_ (_ (_ (_ (_ ((verbatim_string_literal) @injection.content))))))
		(_ (_ (_ (_ (_ (_ ((verbatim_string_literal) @injection.content)))))))
		(_ (_ (_ (_ (_ (_ (_ ((verbatim_string_literal) @injection.content))))))))
		(_ (_ (_ (_ (_ (_ (_ (_ ((verbatim_string_literal) @injection.content)))))))))
		(_ (_ (_ (_ (_ (_ (_ (_ (_ ((verbatim_string_literal) @injection.content))))))))))
		(_ (_ (_ (_ (_ (_ (_ (_ (_ (_ ((verbatim_string_literal) @injection.content)))))))))))
		(_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ ((verbatim_string_literal) @injection.content))))))))))))
		(_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ ((verbatim_string_literal) @injection.content)))))))))))))
		(_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ ((verbatim_string_literal) @injection.content))))))))))))))
		(_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ ((verbatim_string_literal) @injection.content)))))))))))))))
		(_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ ((verbatim_string_literal) @injection.content))))))))))))))))
		(_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ ((verbatim_string_literal) @injection.content)))))))))))))))))
		(_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ ((verbatim_string_literal) @injection.content))))))))))))))))))
		(_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ ((verbatim_string_literal) @injection.content)))))))))))))))))))
		(_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ ((verbatim_string_literal) @injection.content))))))))))))))))))))
		(_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ (_ ((verbatim_string_literal) @injection.content)))))))))))))))))))))
	]
	((#offset! @injection.content 0 2 0 -1))
	(#set! injection.language "sql")
)

