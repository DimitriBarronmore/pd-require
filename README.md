# require.lua

This is a reimplementation of vanilla Lua's `require` function for the [Playdate](https://play.date/) Lua SDK.

On account of the Playdate not having very much user-facing filesystem code at the time it was added, the standard way to split code between multiple files and use third party libraries in the Lua SDK is to use the included `import` statement. While `import` is useful for simple modules that only need to be loaded once, it lacks the semantics needed by most general-purpose Lua libraries. This makes it difficult to use or write libraries which are larger than a single file in scope.

This file reimplements Lua's `require` from scratch, with all the semantics necessary for plain *.lua* modules to be loaded correctly and limited support for extension. This should make it compatible with all pure-Lua libraries which don't require advanced manipulation of the *package* table. 

# Usage

Just import the file into your Playdate project and use `require` as normal.

```lua
import "require"
require "my_module"
```

# Technical Notes & Expansion

The implementation in this module is similar enough to vanilla `require` to be compatible with the majority of existing code, but it's not completely identical. This is mostly for practical reasons, because the Playdate SDK provides a lot less room for file loading than standard Lua environments.

Just as in standard Lua, you can change where `require` looks for files by changing the *package.path* variable. By default the value of *package.path* is *"./?.lua;./?/init.lua"*. Note that any instances of *'.lua'* in the path will be automatically replaced with *'.pdz'*. For example, the following snippet adds support for implicitly searching in /libraries/ and /libs/:

```lua
for _, str in ipairs{"./libraries/", "./libs"} do
    package.path = package.path .. (";%s/?.lua;%s/?/init.lua"):format(str, str)
end
```

Similar to standard Lua, you can create new file loaders by adding functions to *package.searchers*. Unlike standard Lua, searchers must directly return a function which will be executed to run the loaded file. In the default searcher, this is the return value of `playdate.file.load(filepath)`. This is mostly because the SDK's compilation tools already detect invalid syntax at compile time, so for standard *.lua* files there's no point in checking for it at runtime. If you are implementing your own file parser, just check for errors before returning the chunk.

Unlike standard Lua, you cannot mock out packages by putting custom loaders in *package.preload*. This is because the only real use for this behavior is integrating C libraries in embedded environments, but the Playdate SDK already handles this behavior explicitly. If you really want this behavior, you can still create a searcher which responds to specific filenames or pre-populate *package.loaded*.
