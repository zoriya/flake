// opencode server side for jj workspace roots (see jj-workspace-init): a worktree strategy where
// worktree_create adds a jj workspace beside `default/` and worktree_remove snapshots it before
// forgetting it.
import { execFile } from "node:child_process"
import { existsSync } from "node:fs"
import { rm } from "node:fs/promises"
import path from "node:path"
import { promisify } from "node:util"

const exec = promisify(execFile)

function wspRoot(directory: string) {
	for (let dir = directory; ; dir = path.dirname(dir)) {
		if (existsSync(path.join(dir, ".wsp-root"))) return dir
		if (dir === path.dirname(dir)) return undefined
	}
}

async function workspaces(cwd: string, signal: AbortSignal) {
	const { stdout } = await exec("@jj@", ["workspace", "list", "-T", 'name ++ "\\t" ++ root ++ "\\n"'], { cwd, signal })
	return stdout
		.split("\n")
		.filter(Boolean)
		.map((line) => {
			const [name, root] = line.split("\t")
			return { name, root }
		})
}

export default {
	id: "zoriya.jj-worktree",
	async setup(ctx: any) {
		if (!wspRoot(ctx.location.directory)) return
		await ctx.worktree.transform((editor: any) => {
			editor.add({
				id: "jj",
				async create(input: { sourceDirectory: string; directory: string; branch?: string }, { signal }: { signal: AbortSignal }) {
					const root = wspRoot(input.sourceDirectory)
					if (!root) throw new Error(`${input.sourceDirectory} is not inside a jj workspace root`)
					// opencode suggests a path under its data dir, only keep the name it picked.
					const name = path.basename(input.directory)
					let directory = path.join(root, name)
					for (let i = 2; existsSync(directory); i++) directory = path.join(root, `${name}-${i}`)
					// start from the human's state: their uncommitted work if any, else their last real commit.
					await exec("@jj@", ["workspace", "add", "-r", input.branch ?? "latest(::default@ ~ empty())", directory], {
						cwd: root,
						signal,
					})
					return { directory }
				},
				async remove(input: { directory: string; force: boolean }, { signal }: { signal: AbortSignal }) {
					const root = wspRoot(input.directory)
					if (!root) throw new Error(`${input.directory} is not inside a jj workspace root`)
					const workspace = (await workspaces(root, signal)).find((x) => x.root === input.directory)
					if (!workspace) throw new Error(`${input.directory} is not a jj workspace`)
					if (workspace.name === "root" || workspace.name === "default")
						throw new Error(`refusing to remove the ${workspace.name} workspace`)
					// record the files in the working-copy commit so forgetting the workspace loses nothing,
					// which is also why `force` is irrelevant here.
					await exec("@jj@", ["util", "snapshot"], { cwd: input.directory, signal })
					await exec("@jj@", ["workspace", "forget", workspace.name], { cwd: root, signal })
					await rm(input.directory, { recursive: true, force: true })
				},
				async list(sourceDirectory: string, { signal }: { signal: AbortSignal }) {
					const root = wspRoot(sourceDirectory)
					if (!root) return []
					return (await workspaces(root, signal)).map((x) => ({
						directory: x.root,
						type: x.name === "root" || x.name === "default" ? "root" : "worktree",
					}))
				},
			})
		})
	},
}
