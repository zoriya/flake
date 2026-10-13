// opencode tui side: when the session on screen lives in a jj workspace that was deleted by
// hand, move it back to `default/` (where the agent's instructions make it create a new one)
// instead of asking which directory to use.
import { existsSync } from "node:fs"
import path from "node:path"
import { createEffect, createRoot } from "solid-js"

export default {
	id: "zoriya.jj-workspace-missing",
	setup(ctx: any) {
		const moving = new Set<string>()
		return createRoot((dispose) => {
			createEffect(() => {
				const route = ctx.ui.router.current()
				if (route.type !== "session") return
				const directory: string | undefined = ctx.data.session.get(route.sessionID)?.location.directory
				if (!directory || existsSync(directory) || moving.has(route.sessionID)) return

				const parents: string[] = []
				for (let dir = path.dirname(directory); !parents.includes(dir); dir = path.dirname(dir)) parents.push(dir)
				const root = parents.find((dir) => existsSync(path.join(dir, ".wsp-root")))
				if (!root) return
				const target = existsSync(path.join(root, "default")) ? path.join(root, "default") : root

				const sessionID = route.sessionID
				moving.add(sessionID)
				ctx.client.session
					.move({ sessionID, directory: target })
					.then(() =>
						ctx.ui.toast.show({
							message: `${ctx.ui.format.path(directory)} is gone, moved the session to ${ctx.ui.format.path(target)}`,
							variant: "info",
						}),
					)
					.catch((error: Error) =>
						ctx.ui.toast.show({ title: "Failed to move session", message: error.message, variant: "error" }),
					)
					.finally(() => moving.delete(sessionID))
			})
			return dispose
		})
	},
}
