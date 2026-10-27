-- Language server installation via Mason. Two independent pins keep both machines identical:
--   * registry snapshot (below)  -> freezes package *metadata* (sources, checksums, asset names)
--   * `packages` table (below)   -> freezes the installed *versions*; a mismatch is reinstalled
-- The Mason plugin itself is pinned by nvim-pack-lock.json.
-- To bump: pick a release from https://github.com/mason-org/mason-registry/releases, set
-- REGISTRY_TAG, then update versions to match (`:Mason` shows the registry's versions).
local REGISTRY_TAG = "2026-09-30-thick-shock"

-- Mason package name -> exact version. Runtime needs: node (npm packages), go (gopls), python3+venv (robotcode).
local packages = {
	["clangd"] = "23.1.0",
	["ruff"] = "0.16.9",
	["pyright"] = "1.1.414",
	["rust-analyzer"] = "2026-09-28",
	["gopls"] = "v0.23.0",
	["texlab"] = "v5.26.0",
	["bash-language-server"] = "5.8.1",
	["lua-language-server"] = "3.19.1",
	["typescript-language-server"] = "6.0.1",
	-- html/css/json all ship in the one vscode-langservers-extracted npm package
	["html-lsp"] = "4.10.0",
	["css-lsp"] = "4.10.0",
	["json-lsp"] = "4.10.0",
	-- Robot Framework: PyPI package, installed by Mason into its own venv (needs python3 + venv module)
	["robotcode"] = "2.7.0",
}

require("mason").setup({
	registries = { "github:mason-org/mason-registry@" .. REGISTRY_TAG },
	ui = { border = "rounded" },
})

local registry = require("mason-registry")

local function ensure(name, version)
	local ok, pkg = pcall(registry.get_package, name)
	if not ok then
		vim.notify(("mason: unknown package '%s' in registry %s"):format(name, REGISTRY_TAG), vim.log.levels.WARN)
		return
	end
	if pkg:is_installed() and select(2, pcall(pkg.get_installed_version, pkg)) == version then
		return
	end
	vim.notify(("mason: installing %s@%s"):format(name, version))
	pkg:install({ version = version }, function(success, err)
		vim.schedule(function()
			if success then
				vim.notify(("mason: installed %s@%s (restart nvim to use)"):format(name, version))
			else
				vim.notify(("mason: failed %s@%s: %s"):format(name, version, tostring(err)), vim.log.levels.ERROR)
			end
		end)
	end)
end

-- Registry download is async on first run; installing must wait until it is available.
registry.refresh(function()
	vim.schedule(function()
		for name, version in pairs(packages) do
			ensure(name, version)
		end
	end)
end)
