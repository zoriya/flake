return {
	settings = {
		basedpyright = {
			analysis = {
				diagnosticMode = "workspace",
				diagnosticSeverityOverrides = {
					reportUnannotatedClassAttribute = "false",
					enableTypeIgnoreComments = "true",
					reportIgnoreCommentWithoutRule = "false",
					reportUnknownArgumentType = "false",
					reportUnknownVariableType = "false",
					reportMissingParameterType = "false",
					reportUnknownParameterType = "false",
					reportUnknownMemberType = "false",
					reportAny = "false",
					reportExplicitAny = "false",
					reportMissingTypeStubs = "false",
					reportUnknownLambdaType = "false",
				}
			},
		}
	}
}
