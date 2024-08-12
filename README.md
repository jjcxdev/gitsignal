<div align="center">

# GitSignal
##### Never Commit Unsaved.

[![Lua](https://img.shields.io/badge/Lua-blue.svg?style=for-the-badge&logo=lua)](http://www.lua.org)
[![Neovim](https://img.shields.io/badge/Neovim%200.8+-green.svg?style=for-the-badge&logo=neovim)](https://neovim.io)

![Git Signal](https://github.com/jjcxdev/gitsignal/blob/main/assets/screenshot.png)
</div>


## ⇁ TOC
* [The Problems](#-The-Problems)
* [The Solutions](#-The-Solutions)
* [Installation](#-Installation)
* [Getting Started](#-Getting-Started)
* [API](#-API)
    * [Config](#config)
    * [Settings](#settings)
* [Contribution](#-Contribution)
* [Social](#-Social)

## ⇁ The Problem

Committing unsaved files is a common issue that can lead to incomplete commits, missed changes, and potential bugs. Developers often overlook unsaved files, especially in large projects with multiple buffers open in their editor. This can cause significant delays and complications in the development process.

## ⇁ The Solutions

GitSignal addresses this problem by providing a clear, visual indication of all unsaved files in the current Neovim session. By listing these files in a floating window, GitSignal helps you ensure that all changes are saved before committing, reducing the likelihood of incomplete commits and improving overall code quality.

## ⇁ Installation

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
## ⇁ Getting Started

No additional configuration is required. Once installed, GitSignal will automatically display a floating window with unsaved files when Neovim starts.

However, if you'd like to customize the behavior, you can manually call the plugin's functions:

### Commands

- `:Gitsignal`  
  Manually open the floating window listing unsaved files.

- `:CloseGitsignal`  
  Close the Git Signal floating window.


## ⇁ API

### Config

Currently, GitSignal doesn't require any additional configuration. It works out of the box, but you can customize its appearance.

### Settings

You can change the appearance of the floating window by modifying the highlight groups in your Neovim configuration:

``` lua
vim.api.nvim_set_hl(0, "GitSignalNormalFloat", { bg = "NONE", fg = "NONE" })
vim.api.nvim_set_hl(0, "GitSignalFloatBorder", { bg = "NONE", fg = "#9d00ff" }) -- vibrant purple
vim.api.nvim_set_hl(0, "GitSignalUnsaved", { fg = "#e06c75", bold = true })
```

## ⇁ Contribution

Contributions are welcome! If you have ideas for improvements or have found a bug, feel free to open an issue or submit a pull request.

## ⇁ Social

For questions about GitSignal reach out to me on X.
* [X](https://x.com/jjcxdev)
