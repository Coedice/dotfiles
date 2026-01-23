return {
  -- Colorscheme
  {
    "navarasu/onedark.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require('onedark').setup {
        style = 'darker',
        transparent = false,
        term_colors = true,
        ending_tildes = false,
        cmp_itemkind_reverse = false,
        toggle_style_key = nil,
        toggle_style_list = {'dark', 'darker', 'cool', 'deep', 'warm', 'warmer', 'light'},
        code_style = {
          comments = 'italic',
          keywords = 'none',
          functions = 'none',
          strings = 'none',
          variables = 'none'
        },
        lualine = {
          transparent = false,
        },
        diagnostics = {
          darker = true,
          background = true,
        },
      }
      require('onedark').load()
    end,
  },

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
      
      -- Go
      vim.lsp.config.gopls = {
        cmd = { 'gopls' },
        filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
        root_markers = { 'go.mod', '.git' },
        capabilities = capabilities,
      }
      vim.lsp.enable('gopls')
      
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
      ensure_installed = { "lua", "vim", "javascript", "typescript", "python", "go" },
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
        vim.api.nvim_set_hl(0, "RainbowRed",    { bg = "#4f2629" })
        vim.api.nvim_set_hl(0, "RainbowYellow", { bg = "#4a3f28" })
        vim.api.nvim_set_hl(0, "RainbowBlue",   { bg = "#1f324a" })
        vim.api.nvim_set_hl(0, "RainbowOrange", { bg = "#4a3723" })
        vim.api.nvim_set_hl(0, "RainbowGreen",  { bg = "#263f32" })
        vim.api.nvim_set_hl(0, "RainbowViolet", { bg = "#3f274d" })
        vim.api.nvim_set_hl(0, "RainbowCyan",   { bg = "#1e3f43" })
      end)
      require("ibl").setup({
        indent = { highlight = highlight, char = '' },
        whitespace = {
          highlight = highlight,
          remove_blankline_trail = false,
        },
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
      vim.keymap.set('n', '<C-r>', function()
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

                -- Open nvim-tree full screen with new project root
                require('nvim-tree.api').tree.change_root(selection.value)
                require('nvim-tree.api').tree.open()
                vim.cmd('NvimTreeFocus')
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
      require('gitsigns').setup({
        current_line_blame = true, -- Toggle with `:Gitsigns toggle_current_line_blame`
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
          delay = 1000,
          ignore_whitespace = false,
        },
        current_line_blame_formatter = ' <author>, <author_time:%Y-%m-%d> - <summary>',
      })
    end,
  },

  -- Scrollbar with git integration
  {
    "petertriho/nvim-scrollbar",
    config = function()
      require("scrollbar").setup({
        show = true,
        show_in_active_only = false,
        set_highlights = true,
        handle = {
          text = " ",
          color = nil,
          cterm = nil,
          highlight = "CursorColumn",
          hide_if_all_visible = true,
        },
        marks = {
          Cursor = {
            text = "•",
            priority = 0,
            color = nil,
            cterm = nil,
            highlight = "Normal",
          },
          Search = {
            text = { "-", "=" },
            priority = 1,
            color = nil,
            cterm = nil,
            highlight = "Search",
          },
          Error = {
            text = { "-", "=" },
            priority = 2,
            color = nil,
            cterm = nil,
            highlight = "DiagnosticVirtualTextError",
          },
          Warn = {
            text = { "-", "=" },
            priority = 3,
            color = nil,
            cterm = nil,
            highlight = "DiagnosticVirtualTextWarn",
          },
          Info = {
            text = { "-", "=" },
            priority = 4,
            color = nil,
            cterm = nil,
            highlight = "DiagnosticVirtualTextInfo",
          },
          Hint = {
            text = { "-", "=" },
            priority = 5,
            color = nil,
            cterm = nil,
            highlight = "DiagnosticVirtualTextHint",
          },
          Misc = {
            text = { "-", "=" },
            priority = 6,
            color = nil,
            cterm = nil,
            highlight = "Normal",
          },
          GitAdd = {
            text = "┆",
            priority = 7,
            color = nil,
            cterm = nil,
            highlight = "GitSignsAdd",
          },
          GitChange = {
            text = "┆",
            priority = 7,
            color = nil,
            cterm = nil,
            highlight = "GitSignsChange",
          },
          GitDelete = {
            text = "▁",
            priority = 7,
            color = nil,
            cterm = nil,
            highlight = "GitSignsDelete",
          },
        },
        excluded_buftypes = {
          "terminal",
          "nofile",
        },
        excluded_filetypes = {
          "prompt",
          "TelescopePrompt",
          "NvimTree",
        },
        autocmd = {
          render = {
            "BufWinEnter",
            "TabEnter",
            "TermEnter",
            "WinEnter",
            "CmdwinLeave",
            "TextChanged",
            "VimResized",
            "WinScrolled",
          },
          clear = {
            "BufWinLeave",
            "TabLeave",
            "TermLeave",
            "WinLeave",
          },
        },
        handlers = {
          cursor = true,
          diagnostic = true,
          gitsigns = true, -- Enable git integration (requires gitsigns.nvim)
          handle = true,
          search = false, -- Disable search by default (requires nvim-hlslens)
          ale = false,
        },
      })

      -- Setup gitsigns handler for scrollbar
      require("scrollbar.handlers.gitsigns").setup()
    end,
  },

  -- Fugitive for git commands
  {
    "tpope/vim-fugitive",
    lazy = false,
    config = function()
      -- Keybinding for git diff
      vim.keymap.set('n', '<leader>gd', '<cmd>Gdiff<cr>', { desc = 'Git diff' })
      
      -- When starting diff, focus the working tree side
      vim.api.nvim_create_autocmd('BufWinEnter', {
        pattern = '*',
        callback = function()
          -- Check if we're in a diff with fugitive buffers
          local wins = vim.api.nvim_list_wins()
          local has_fugitive = false
          local working_win = nil
          
          for _, win in ipairs(wins) do
            local buf = vim.api.nvim_win_get_buf(win)
            local name = vim.api.nvim_buf_get_name(buf)
            if name:match('fugitive://') then
              has_fugitive = true
            else
              working_win = win
            end
          end
          
          -- If we found fugitive buffers and a working tree, switch to working tree
          if has_fugitive and working_win then
            vim.defer_fn(function()
              vim.api.nvim_set_current_win(working_win)
            end, 100)
          end
        end,
      })
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
        shell = '~/.config/zellij/zellij-toggleterm.sh',
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

  -- Comment.nvim
  {
    "numToStr/Comment.nvim",
    lazy = false,
    config = function()
      require("Comment").setup()
      vim.keymap.set('v', '<C-/>', '<Plug>(comment_toggle_linewise_visual)', { desc = 'Toggle comment selection' })
    end,
  },

  -- Highlight other uses of word under cursor
  {
    "RRethy/vim-illuminate",
    event = "VeryLazy",
    config = function()
      require('illuminate').configure({
        -- Delay in milliseconds before highlighting
        delay = 100,
        -- Underline instead of highlight
        under_cursor = true,
        -- Only highlight when not in insert mode
        modes_allowlist = { 'n', 'v' },
        -- Filetypes to disable
        filetypes_denylist = {
          'dirvish',
          'fugitive',
          'alpha',
          'NvimTree',
          'toggleterm',
        },
        -- Highlight groups for different types
        providers = {
          'lsp',
          'treesitter',
          'regex',
        },
      })
    end,
  },

  -- LazyGit
  {
    "kdheepak/lazygit.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      -- Setup lazygit floating terminal
      vim.g.lazygit_floating_window_winblend = 0 -- transparency
      vim.g.lazygit_floating_window_scaling_factor = 0.9 -- scaling factor for floating window
      vim.g.lazygit_floating_window_border_chars = {'╭','─','╮','│','╯','─','╰','│'} -- customize lazygit popup window border characters
      vim.g.lazygit_use_neovim_remote = 1 -- for neovim-remote support

      -- Keybinding for lazygit
      vim.keymap.set('n', '<C-g>', '<cmd>LazyGit<CR>', { desc = 'LazyGit' })
    end,
  },

}
