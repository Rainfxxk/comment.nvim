# Comment.Nvim
Conveniently add and delete comment in Neovim

Now, this plugin is very simple, and maybe there are many bugs. 

Although I just write this repo for learning neovim and just for fun, I'm very happy that you can make issue or contribute.

Currently, this plugin only support `.lua, .c, cpp, .v` file

## Installation

for linux, if I'm currect, you can install this plugin by executing this command. you can replace * for any legal directory name.

```shell
git clone https://github.com/Rainfxxk/comment.nvim.git ~/.config/nvim/pack/*/start/comment
```

And add this line into your init.lua, then boom! You can use it in your nvim.
```lua
require("comment")
```

when use Lazy.nvim

``` lua
    {
        "Rainfxxk/comment.nvim",
        name = "comment",
        config = function()
            require("comment")
        end
    }        
```

## Usage

After Installation, you can automatically add or del comment by useing `Ctrl+/`
