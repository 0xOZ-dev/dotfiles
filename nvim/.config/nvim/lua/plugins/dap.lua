return {
  -- nvim-dap: Debug Adapter Protocol client
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui", -- UI for nvim-dap
      "nvim-neotest/nvim-nio", -- dependency for nvim-dap-ui
      "jay-babu/mason-nvim-dap.nvim", -- Mason integration for DAP servers
      "theHamsta/nvim-dap-virtual-text", -- Virtual text for debugger
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      local mason_dap = require("mason-nvim-dap")
      local dap_virtual_text = require("nvim-dap-virtual-text")

      -- Initialize nvim-dap-virtual-text for inline variable display
      dap_virtual_text.setup()

      -- Configure mason-nvim-dap to automatically install cppdbg (LLDB's DAP adapter)
      mason_dap.setup({
        ensure_installed = { "cppdbg" }, -- Install the C/C++ debugger adapter
        automatic_installation = true,
        handlers = {
          function(config)
            -- Use the default setup for mason-nvim-dap
            require("mason-nvim-dap").default_setup(config)
          end,
        },
      })

      -- Configure nvim-dap adapters
      dap.adapters.cppdbg = {
        id = "cppdbg",
        type = "executable",
        -- Mason installs cppdbg in its bin directory.
        -- This path assumes default Mason installation. Adjust if yours is different.
        command = vim.fn.stdpath("data") .. "/mason/bin/OpenDebugAD7",
      }

      -- Configure DAP for C/C++ projects
      dap.configurations.c = {
        {
          name = "Launch file",
          type = "cppdbg",
          request = "launch",
          program = function()
            -- Prompt user for executable path
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopAtEntry = false,
          MIMode = "lldb", -- Specify LLDB as the debugger backend
          -- Uncomment and modify if you need to pass arguments to your program
          -- args = {},
        },
        -- You can add more configurations here, e.g., for attaching to a process
        -- {
        --   name = "Attach to process",
        --   type = "cppdbg",
        --   request = "attach",
        --   processId = function()
        --     return tonumber(vim.fn.input("Process ID: "))
        --   end,
        --   MIMode = "lldb",
        -- },
      }

      dap.configurations.cpp = dap.configurations.c -- Use same configurations for C++

      -- Configure nvim-dap-ui
      dapui.setup({
        icons = { expanded = "", collapsed = "", current_frame = "" },
        mappings = {
          -- Use default keymaps for the UI (e.g., to navigate windows)
          expand = { "<CR>", "<2-LeftMouse>" },
          open = { "<CR>", "<2-LeftMouse>" },
          remove = "<BS>",
          repl = { "q" },
        },
        sidebar = {
          -- Adjust these sizes as needed
          elements = {
            -- You can rearrange or remove elements as desired
            { "scopes", "breakpoints", "stacks", "watches" },
            { "repl", "console" },
          },
          size = 40,
          position = "left",
        },
        trouble = {
          -- Position for the trouble window (useful for errors/warnings during debugging)
          position = "bottom",
          size = 10,
        },
      })

      -- Autocommands to open/close DAP UI when debugging starts/stops
      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end

      -- Optional: Define custom signs for breakpoints (requires a nerdfont or similar)
      vim.fn.sign_define("DapBreakpoint", { text = "🐞", texthl = "DapBreakpoint", linehl = "", numhl = "" })
      vim.fn.sign_define("DapBreakpointStopped", { text = "🛑", texthl = "DapBreakpointStopped", linehl = "", numhl = "" })
    end,
    -- Lazy load dap when a .c or .cpp file is opened, or when a debug command is issued
    ft = { "c", "cpp" },
    keys = {
      -- Basic DAP keybindings (feel free to customize)
      { "<leader>dc", function() require("dap").continue() end, desc = "DAP: Continue" },
      { "<leader>dt", function() require("dap").toggle_breakpoint() end, desc = "DAP: Toggle Breakpoint" },
      { "<leader>dcr", function() require("dap").clear_breakpoints() end, desc = "DAP: Clear Breakpoints" },
      { "<leader>ds", function() require("dap").step_into() end, desc = "DAP: Step Into" },
      { "<leader>do", function() require("dap").step_over() end, desc = "DAP: Step Over" },
      { "<leader>du", function() require("dap").step_out() end, desc = "DAP: Step Out" },
      { "<leader>dr", function() require("dap").repl.toggle() end, desc = "DAP: Toggle REPL" },
      { "<leader>dl", function() require("dap").run_last() end, desc = "DAP: Run Last" },
      { "<leader>dx", function() require("dap").close() end, desc = "DAP: Close" },
      { "<leader>dS", function() require("dap.ui.widgets").scopes() end, desc = "DAP: Scopes" },
    },
  },
}
