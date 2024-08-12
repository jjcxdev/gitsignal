# Git Signal - Neovim Plugin

![Git Signal](https://github.com/jjcxdev/gitsignal/blob/main/screenshot.png)

**Git Signal** is a lightweight Neovim plugin designed to help you avoid committing unsaved files. It provides a visual signal in a floating window that lists all unsaved files in your current workspace, ensuring that you don't accidentally leave any changes uncommitted.

## Features

- **Auto-updating Signal**: The floating window automatically updates as you edit and save files.
- **Minimal Interface**: A clean and simple UI that blends seamlessly with your Neovim setup.
- **Customizable Appearance**: Choose your colors for the border and text.
- **Flexible**: Works across all file types and buffers, ensuring that no unsaved file is overlooked.

## Installation

### Using [Lazy.nvim](https://github.com/folke/lazy.nvim)

Add the following to your Lazy.nvim plugin list:

```lua
return {
    "jjcxdev/gitsignal",
}
```

### Using [Packer.nvim](https://github.com/wbthomason/packer.nvim)

Add the following to your `packer.nvim` configuration:

``` lua
use "jjcxdev/gitsignal"

```
## Configuration

No additional configuration is required. Once installed, Git Signal will automatically display a floating window with unsaved files when Neovim starts.

However, if you'd like to customize the behavior, you can manually call the plugin's functions:

### Commands

- `:Gitsignal`  
  Manually open the floating window listing unsaved files.

- `:CloseGitsignal`  
  Close the Git Signal floating window.

### Customization

You can change the appearance of the floating window by modifying the highlight groups in your Neovim configuration:

```lua
vim.api.nvim_set_hl(0, "GitSignalNormalFloat", { bg = "NONE", fg = "NONE" })
vim.api.nvim_set_hl(0, "GitSignalFloatBorder", { bg = "NONE", fg = "#9d00ff" }) -- vibrant purple
vim.api.nvim_set_hl(0, "GitSignalUnsaved", { fg = "#e06c75", bold = true })
```

## How It Works

- **Unsaved Files Detection**: Git Signal scans all open buffers in your Neovim session for unsaved changes and lists them in a floating window.
- **Auto-Updates**: The floating window automatically updates when files are modified or saved.
- **Visual Signal**: The window's vibrant border color and simple layout make it easy to notice unsaved files at a glance.

## Contributing

Contributions are welcome! If you have ideas for improvements or have found a bug, feel free to open an issue or submit a pull request.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Credits

- Created by [jjcx](https://github.com/jjcxdev).
- Inspired by the need to prevent accidental commits with unsaved files.
