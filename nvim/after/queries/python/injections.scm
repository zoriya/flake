;extends
(call
  function: (attribute attribute: (identifier) @id (#match? @id "execute|read_sql"))
  arguments: (argument_list
    (string (string_content) @injection.content (#set! injection.language "sql"))))

(string 
  (string_content) @injection.content
    (#match? @injection.content "^\n*\\s*(SELECT|CREATE|DROP|INSERT|UPDATE|ALTER|DELETE|select|create|drop|insert|update|alter|delete)\\W+")
    (#set! injection.language "sql"))
