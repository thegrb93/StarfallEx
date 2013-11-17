Starfall Scripting Environment
----------

 * More info: http://colonelthirtytwo.net/index.php/starfall/
 * Reference Page: http://colonelthirtytwo.net/sfdoc/
 * Development Thread: http://www.wiremod.com/forum/developers-showcase/22739-starfall-processor.html
 * Blog: http://blog.colonelthirtytwo.net/

Contributor information
----------


If you want to contribute to Starfall, you are required to abide to this set of rules, to make developing Starfall a pleasant experience for everyone and to keep up the quality.

**Commit messages**
- There should only ever be one logical change per commit.
- Commits must have descriptive commit messages. For example: Added function newFunction()
- New features are never pushed directly into the repo, make a pull request with your feature branch an another developer will review it

**Codestyle guidelines**
- No GLua-specific syntax. 
  - E.g. don't use `//`, `/**/`, `&&`, `||`, etc.
- Use tabs for indentation, don't use spaces or other whitespace characters.
- Use [LuaDoc-style](http://keplerproject.github.io/luadoc/manual.html) comments on external user API functions and libraries. Use reasonable documentation for internal API functions and libraries.
- Add comments when code functionality is not clear or when the purpose of the code is not obvious.
  - See: [http://http://www.codinghorror.com/blog/2008/07/coding-without-comments.html](http://http://www.codinghorror.com/blog/2008/07/coding-without-comments.html).
- Function and variable names are supposed to be in `camelCase`, constructor functions, however, are supposed to be in `CamelCase`.
- No parentheses around conditionals used for program logic.
  - E.g. if conditions/loop headers, unless absolutely necessary.
- Use spaces between parentheses and their enclosing body. 
  - E.g. `print( "Hello" )` & `function f ( args )` & `f( args )`.
- Use spaces before the argument list of a function definition. 
  - E.g. `fuction func (var1, var2)`.
- Use spaces after semicolons, as well as commas. 
  - E.g. `f( a1, a2, a3 ); f2( a1, a2, a3 )`.
- Use spaces before any unary operator; before and after any binary operator. 
  - E.g. `local var = 5 + 3` and `local var2 = -var + 3`.
- Use of one-liners/ single-line multi-statements is discouraged. 
  - E.g. `var = 5; var2 = 10; var3 = 15`.
- Do not use semicolons at the end of statements, unless required to separate single-line multi-statements.
- Short circuiting, `a = b and c or d`, is only permitted if used as a ternary operator. Do not use it for program logic. 
  - E.g. Good: `print( a and "Hello" or "Hi" )`; Bad: `a and print("Hello") or print("Hi")`;

**Release strategy**
- We are using [Semantic Versioning](http://semver.org) in the format of Major.Minor.Subminor
- Only changes in major version can break compatibility, backwards compatibility is guaranteed within the same major version
- Functions can be deprecated between minor versions and will then be removed in the next major release
- Every minor release will get its own branch. This branch will be tagged once it gets released. Hotfixes and patches will be added to the release branch and tagged
- Features never get added to a release branch once it got released
