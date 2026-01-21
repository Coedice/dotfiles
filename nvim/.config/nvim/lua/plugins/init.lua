return {
  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      -- Disable LSP diagnostic gutter signs (hide the red E, etc.)
      vim.diagnostic.config({ signs = false })

      -- Setup language servers using new vim.lsp.config API
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      
      -- Python
      vim.lsp.config.pyright = {
        cmd = { 'pyright-langserver', '--stdio' },
        filetypes = { 'python' },
        root_markers = { 'pyproject.toml', 'setup.py', 'requirements.txt', '.git' },
        capabilities = capabilities,
      }
      vim.lsp.enable('pyright')
      
      -- JavaScript/TypeScript
      vim.lsp.config.ts_ls = {
        cmd = { 'typescript-language-server', '--stdio' },
        filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
        root_markers = { 'package.json', 'tsconfig.json', 'jsconfig.json', '.git' },
        capabilities = capabilities,
      }
      vim.lsp.enable('ts_ls')
      
      -- Markdown (via ltex-ls for grammar/spell checking)
      vim.lsp.config.ltex = {
        cmd = { 'ltex-ls' },
        filetypes = { 'markdown', 'text' },
        root_markers = { '.git' },
        capabilities = capabilities,
      }
      vim.lsp.enable('ltex')
      
      -- Keybindings
      -- Smart gd: go to definition from usage, show references from definition
      vim.keymap.set('n', 'gd', function()
        local params = vim.lsp.util.make_position_params()
        vim.lsp.buf_request(0, 'textDocument/definition', params, function(err, result)
          if err or not result or vim.tbl_isempty(result) then
            -- No definition found, show references instead
            vim.lsp.buf.references()
          else
            -- Check if we're already at the definition
            local current_pos = vim.api.nvim_win_get_cursor(0)
            local def_uri = type(result) == 'table' and result[1] and result[1].uri or result.uri
            local def_range = type(result) == 'table' and result[1] and result[1].range or result.range
            local current_uri = vim.uri_from_bufnr(0)
            
            if def_uri == current_uri and def_range.start.line + 1 == current_pos[1] then
              -- Already at definition, show references
              vim.lsp.buf.references()
            else
              -- Go to definition
              vim.lsp.buf.definition()
            end
          end
        end)
      end, { desc = 'Go to definition or show references' })
      vim.keymap.set('n', 'gr', vim.lsp.buf.references, { desc = 'Find references' })
      -- Close quickfix list after jumping to a reference
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'qf',
        callback = function(event)
          -- Remap <CR> inside the quickfix buffer to open the item and close the list
          vim.keymap.set('n', '<CR>', function()
            -- Jump to the selected quickfix entry, then close the list
            vim.cmd('execute "cc " .. line(".")')
            vim.cmd('cclose')
          end, { buffer = event.buf })
        end,
      })
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = 'Hover documentation' })
      vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = 'Rename' })
    end,
  },

  -- Autocompletion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require('cmp')
      cmp.setup({
        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<Tab>'] = cmp.mapping.select_next_item(),
          ['<S-Tab>'] = cmp.mapping.select_prev_item(),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'buffer' },
          { name = 'path' },
        }),
      })
    end,
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    main = "nvim-treesitter.config",
    opts = {
      ensure_installed = { "lua", "vim", "javascript", "typescript", "python" },
      sync_install = false,
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
    },
  },

  -- Rainbow indents
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    config = function()
      local highlight = {
        "RainbowRed",
        "RainbowYellow",
        "RainbowBlue",
        "RainbowOrange",
        "RainbowGreen",
        "RainbowViolet",
        "RainbowCyan",
      }
      local hooks = require("ibl.hooks")
      hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
        vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
        vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
        vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
        vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
        vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
        vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })
      end)
      require("ibl").setup({
        indent = { highlight = highlight },
        scope = { enabled = false },
      })
    end,
  },

  -- Rainbow brackets
  {
    "HiPhish/rainbow-delimiters.nvim",
    config = function()
      require("rainbow-delimiters.setup")({
        strategy = {
          [""] = require("rainbow-delimiters").strategy["global"],
          vim = require("rainbow-delimiters").strategy["local"],
        },
        query = {
          [""] = "rainbow-delimiters",
          lua = "rainbow-blocks",
        },
        highlight = {
          "RainbowDelimiterRed",
          "RainbowDelimiterYellow",
          "RainbowDelimiterBlue",
          "RainbowDelimiterOrange",
          "RainbowDelimiterGreen",
          "RainbowDelimiterViolet",
          "RainbowDelimiterCyan",
        },
      })
    end,
  },

  -- Marks (visual indicators in gutter)
  {
    "chentoast/marks.nvim",
    config = function()
      require("marks").setup()
    end,
  },

  -- Telescope (Fuzzy Finder)
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { 
      "nvim-lua/plenary.nvim",
      "ahmedkhalf/project.nvim",
    },
    config = function()
      -- Setup project.nvim first
      require("project_nvim").setup({
        detection_methods = { "pattern", ".git" },
        patterns = { ".git", "package.json", "Makefile", "README.md" },
        silent_chdir = false,
        scope_chdir = 'global',
      })
      
      -- Load telescope project extension
      require('telescope').load_extension('projects')
      
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find files' })
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Live grep' })
      
      -- Project switcher: wipes buffers, cd into project, then prompts for a file in that project
      vim.keymap.set('n', '<leader>fp', function()
        local telescope = require('telescope')
        local action_state = require('telescope.actions.state')
        local actions = require('telescope.actions')
        local builtin_local = require('telescope.builtin')

        telescope.extensions.projects.projects({
          attach_mappings = function(prompt_bufnr, _)
            actions.select_default:replace(function()
              local selection = action_state.get_selected_entry()
              actions.close(prompt_bufnr)

              if selection then
                -- Wipe all buffers from the current session
                pcall(vim.cmd, 'silent! %bdelete!')

                -- Change directory to the chosen project
                vim.cmd('cd ' .. vim.fn.fnameescape(selection.value))

                -- Prompt to pick a file inside that project
                builtin_local.find_files({ cwd = selection.value })
              end
            end)
            return true
          end,
        })
      end, { desc = 'Switch project' })
    end,
  },

  -- Project management
  {
    "ahmedkhalf/project.nvim",
    lazy = true,
  },


  -- File Explorer
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("nvim-tree").setup({
        filters = {
          git_ignored = false,
          dotfiles = false,
        },
        actions = {
          open_file = {
            quit_on_open = true,
          },
        },
        view = {
          preserve_window_proportions = true,
        },
      })
      vim.keymap.set('n', '<C-n>', ':NvimTreeToggle<CR>', { desc = 'Toggle file explorer' })
    end,
  },

  -- Bufferline
  {
    "akinsho/bufferline.nvim",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      local bufferline = require("bufferline")
      bufferline.setup({
        highlights = {
          buffer_selected = {
            fg = "#000000", bg = "#ffffff", bold = true, italic = false, underline = false,
            ctermfg = 0, ctermbg = 15, cterm = { "bold" },
          },
          background = {
            fg = "#888888", bg = "#000000", ctermfg = 244, ctermbg = 0,
          },
          fill = { bg = "#000000", ctermbg = 0 },
          tab_selected = {
            fg = "#000000", bg = "#ffffff", bold = true, italic = false, underline = false,
            ctermfg = 0, ctermbg = 15, cterm = { "bold" },
          },
        },        options = {
          show_buffer_close_icons = true,
        },
      })

      -- Buffer/tabline navigation (Tab / Shift-Tab)
      vim.keymap.set('n', '<Tab>', function() bufferline.cycle(1) end, { desc = 'Next buffer' })
      vim.keymap.set('n', '<S-Tab>', function() bufferline.cycle(-1) end, { desc = 'Prev buffer' })
      vim.keymap.set('n', '<C-w>', function()
        -- Save if modified
        if vim.bo.modified then
          vim.cmd('silent! write')
        end
        local bufs = vim.fn.getbufinfo({ buflisted = 1 })
        if #bufs <= 1 then
          -- Last buffer: create new empty buffer, then delete the old one
          vim.cmd('enew')
          vim.cmd('silent! bwipeout #')
        else
          -- Multiple buffers: go to previous, then delete the one we were on
          vim.cmd('bp | bd #')
        end
      end, { desc = 'Delete buffer' })
    end,
  },

  -- Web Devicons (required by many plugins)
  {
    "nvim-tree/nvim-web-devicons",
  },

  -- Gitsigns
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require('gitsigns').setup()
    end,
  },

  -- Which-key
  {
    "folke/which-key.nvim",
    config = function()
      require("which-key").setup()
    end,
  },

  -- ToggleTerm
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({
        open_mapping = [[<C-j>]],
        direction = 'horizontal',
        size = function()
          return vim.o.lines * 0.5
        end,
        shell = 'zellij',
      })
    end,
  },

  -- Auto Pairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup()
    end,
  },

}
