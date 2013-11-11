Starfall Scripting Environment
==============================

 * More info: http://colonelthirtytwo.net/index.php/starfall/
 * Reference Page: http://colonelthirtytwo.net/sfdoc/
 * Development Thread: http://www.wiremod.com/forum/developers-showcase/22739-starfall-processor.html
 * Blog: http://blog.colonelthirtytwo.net/

Contribor information
======================================================

If you want to contribute to Starfall, you are required to abide to this set of rules, to make developing Starfall a pleasant experience for everyone and to keep up the quality.

**Commit messages**
- There should only ever be one logical change per commit.
- Commits must have descriptive commit messages. For example: Added function newFunction()
- New features are never pushed directly into the repo, make a pull request with your feature branch an another developer will review it

**Codestyle guidelines**
- No GLua-specific syntax. For example, don't use // or /**/ to comment, do not use &&, ||, etc
- Use tabs for indentation, don't use spaces or other whitespace characters
- Use LuaDoc-style comments on API functions and libraries. Use reasonable documentation for internal functions
- Add comments in your code if it is not obvious what it does. As a rule of thumb: If it took you more than 5 seconds to figure the line out, add a comment
- Function and variable names are supposed to be in camelCase, constructor functions, however, are supposed to be in CamelCase
- No parantheses around if conditions/loop headers unless necessary
- Use spaces inside parantheses. For example: print( "Hello" )
- Use spaces before the argument list of a function. For example: fuction func (var1, var2)
- Use spaces after semicolons
- Use spaces before any operator and after any binary operator
- Do not use semicolons at the end of statements
- Short circuiting (a = b and c or d) is ok if used as ternary operator. Do not use it for logic.

**Release strategy**
- We are using [Semantic Versioning](http://semver.org) in the format of Major.Minor.Subminor
- Only changes in major version can break compatibility, backwards compatibility is guaranteed within the same major version
- Functions can be deprecated between minor versions and will then be removed in the next major release
- Every minor release will get its own branch. This branch will be tagged once it gets released. Hotfixes and patches will be added to the release branch and tagged
- Features never get added to a release branch once it got released
