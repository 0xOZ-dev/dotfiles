return {
	"neovim/nvim-lspconfig",
	dependencies = {
		"stevearc/conform.nvim",
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-path",
		"hrsh7th/cmp-cmdline",
		"hrsh7th/nvim-cmp",
		"L3MON4D3/LuaSnip",
		"saadparwaiz1/cmp_luasnip",
		"j-hui/fidget.nvim",
	},

	config = function()
		require("conform").setup({
			formatters_by_ft = {
				lua = { "stylua" }, -- Example: Add stylua for Lua files
				python = { "black", "isort" }, -- Example: Add black and isort for Python
				-- Add clang-format for C, C++, Objective-C
				c = { "clang-format" },
				cpp = { "clang-format" },
				objc = { "clang-format" },
				objcpp = { "clang-format" },
                rust = {"rustfmt"}
				-- You can also specify an array of formatters, and Conform will try them in order
				-- or allow you to choose if you map a key for it.
				-- Example:
				-- cpp = { "clang-format", "another_cpp_formatter" },
			},
			-- Optional: You can configure custom formatters here if they're not built-in
			-- formatters = {
			--     my_custom_formatter = {
			--         command = "my-formatter-cli",
			--         args = { "$FILENAME" },
			--     },
			-- },
		})
		-- Autocmd to format on save using conform.nvim
		vim.api.nvim_create_autocmd("BufWritePre", {
			group = vim.api.nvim_create_augroup("ConformFormat", { clear = true }),
			pattern = "*", -- Apply to all buffers
			callback = function(args)
				local conform = require("conform")
				local bufnr = args.buf

				-- Simply try to format. Conform.nvim's `format` function
				-- is designed to handle cases where no formatter is configured
				-- for the current filetype gracefully (it will just do nothing).
				conform.format({
					bufnr = bufnr,
					lsp_fallback = true, -- Optional: allows LSP formatters to run if conform doesn't find one
					async = true,
					timeout_ms = 1000,
				})
			end,
		})
		local cmp = require("cmp")
		local cmp_lsp = require("cmp_nvim_lsp")
		local capabilities = vim.tbl_deep_extend(
			"force",
			{},
			vim.lsp.protocol.make_client_capabilities(),
			cmp_lsp.default_capabilities()
		)

		require("fidget").setup({})
		require("mason").setup()
		require("mason-lspconfig").setup({
			ensure_installed = {
				"lua_ls",
				"rust_analyzer",
				"gopls",
				"clangd",
                "cmake",
			},
			handlers = {
				function(server_name) -- default handler (optional)
					require("lspconfig")[server_name].setup({
						capabilities = capabilities,
					})
				end,

				clangd = function()
					require("lspconfig").clangd.setup({
						capabilities = capabilities, -- Pass your shared capabilities
						-- Common clangd settings go here
						settings = {
							clangd = {
								-- Example: Add custom arguments to clangd
								-- These are arguments clangd itself understands,
								-- often related to compilation flags or includes.
								arguments = {
									"--compile-commands-dir=build", -- Assuming your compile_commands.json is in a 'build' directory
									"--clang-tidy", -- Enable clang-tidy integration
									"--background-index", -- Index files in the background
									"--suggest-missing-includes", -- Suggest missing #includes
									-- "--header-insertion=iwyu", -- Use include-what-you-use style header insertions
									-- "-std=c++20", -- Specify C++ standard (if not handled by compile_commands.json)
								},
								-- Other clangd-specific settings
								fallbackFlags = {
									-- These flags are used if no compile_commands.json is found for a file
									"--std=c++17",
									"-I/usr/local/include", -- Example include path
								},
							},
						},
						-- Optional: Custom on_attach for clangd (e.g., keymaps specific to C/C++)
						on_attach = function(client, bufnr)
							-- Call your default on_attach if you have one, or add clangd-specific keymaps
							-- For example, switching between source/header files:
							vim.keymap.set(
								"n",
								"<leader>ch",
								"<cmd>ClangdSwitchSourceHeader<CR>",
								{ buffer = bufnr, desc = "Switch C/C++ Source/Header" }
							)
							-- You can also enable inlay hints here if desired, though often already covered by default
							-- vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
						end,
						-- root_dir for clangd often relies on compile_commands.json or other markers
						-- The default in nvim-lspconfig is usually sufficient, but you can override:
						-- root_dir = require('lspconfig.util').root_pattern(
						--     'compile_commands.json', '.git', 'Makefile', 'CMakeLists.txt'
						-- )
					})
				end,
				zls = function()
					local lspconfig = require("lspconfig")
					lspconfig.zls.setup({
						root_dir = lspconfig.util.root_pattern(".git", "build.zig", "zls.json"),
						settings = {
							zls = {
								enable_inlay_hints = true,
								enable_snippets = true,
								warn_style = true,
							},
						},
					})
					vim.g.zig_fmt_parse_errors = 0
					vim.g.zig_fmt_autosave = 0
				end,
				["rust_analyzer"] = function()
					local lspconfig = require("lspconfig")
					lspconfig.rust_analyzer.setup({
						on_attach = function(client, bufnr)
							vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
						end,
						settings = {
							["rust_analyzer"] = {
								cargo = {
									features = "all", -- This ensures all features are enabled in cargo
								},
								checkOnSave = {
									command = "clippy", -- Optional: Enables clippy checks on save
								},
								procMacro = {
									enable = true, -- Enable procedural macros, which could affect things like `println!`
								},
							},
						},
						-- capabilities = capabilities
					})
				end,
				["lua_ls"] = function()
					local lspconfig = require("lspconfig")
					lspconfig.lua_ls.setup({
						capabilities = capabilities,
						settings = {
							Lua = {
								runtime = { version = "Lua 5.4" },
								diagnostics = {
									globals = { "bit", "vim", "it", "describe", "before_each", "after_each" },
								},
							},
						},
					})
				end,
			},
		})

		local cmp_select = { behavior = cmp.SelectBehavior.Select }

		cmp.setup({
			snippet = {
				expand = function(args)
					require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
				end,
			},
			mapping = cmp.mapping.preset.insert({
				["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
				["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
				["<C-y>"] = cmp.mapping.confirm({ select = true }),
				["<C-Space>"] = cmp.mapping.complete(),
			}),
			sources = cmp.config.sources({
				{ name = "nvim_lsp" },
				{ name = "luasnip" }, -- For luasnip users.
			}, {
				{ name = "buffer" },
			}),
		})
        vim.diagnostic.config({
            virtual_text = {
                spacing = 4,
                prefix = "●", -- You can use "●", "■", "▎", "●", or "" for no prefix
            },
            signs = true,       -- Also show signs in the gutter (left column)
            underline = true,   -- Underline offending code
            update_in_insert = false,
            severity_sort = true,

            float = {
                focusable = false,
                style = "minimal",
                border = "rounded",
                source = "always",
                header = "",
                prefix = "",
            },
        })
	end,
}
