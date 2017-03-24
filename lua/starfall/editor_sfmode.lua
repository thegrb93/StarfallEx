if not WireTextEditor then return end
local table_concat = table.concat
local string_sub = string.sub
local string_gmatch = string.gmatch
local string_gsub = string.gsub

local EDITOR = {}

local function istype(tp)
  return false
end

-- keywords[name][nextchar!="("]
local keywords = {
  -- keywords that can be followed by a "(":
  ["if"] = { [true] = true, [false] = true },
  ["elseif"] = { [true] = true, [false] = true },
  ["while"] = { [true] = true, [false] = true },
  ["for"] = { [true] = true, [false] = true },
  ["foreach"] = { [true] = true, [false] = true },
  ["function"] = { [true] = true, [false] = true },

  -- keywords that cannot be followed by a "(":
  ["else"] = { [true] = true },
  ["break"] = { [true] = true },
  ["continue"] = { [true] = true },
  ["then"] = { [true] = true },
  ["end"] = { [true] = true },
  ["in"] = { [true] = true },
  ["return"] = { [true] = true },
  ["local"] = { [true] = true },
}

-- fallback for nonexistant entries:
setmetatable(keywords, { __index=function(tbl,index) return {} end })

local directives = {
  ["@name"] = 0, -- all yellow
  ["@author"] = 0,
  ["@include"] = 0,
  ["@shared"] = 1, -- directive yellow, types orange, rest normal
}

local colors = {
  ["keyword"] = { Color(249, 38, 114), false},
  ["directive"] = { Color(130, 130, 255), false},
  ["comment"] = { Color(117, 113, 94), false},
  ["string"] = { Color(230, 219, 116), false},
  ["number"] = { Color(174, 129, 225), false}, -- light red

  ["function"] = { Color(160, 160, 240), false}, -- blue
  ["notfound"] = { Color(255, 255, 255), false}, -- dark red
  ["variable"] = { Color(160, 240, 160), false}, -- light green
  ["operator"] = { Color(224, 224, 224), false}, -- white
  ["ppcommand"] = { Color(240, 96, 240), false}, -- purple
  ["typename"] = { Color(240, 160, 96), false}, -- orange
  ["constant"] = { Color(240, 160, 240), false}, -- pink
  ["userfunction"] = { Color(102, 122, 102), false}, -- dark grayish-green
}

function EDITOR:GetSyntaxColor(name)
  return colors[name][1]
end

function EDITOR:SetSyntaxColor( colorname, colr )
  if not colors[colorname] then return end
  colors[colorname][1] = colr
end

-- cols[n] = { tokendata, color }
local cols = {}
local lastcol
local function addToken(tokenname, tokendata)
  local color = colors[tokenname]
  if lastcol and color == lastcol[2] then
    lastcol[1] = lastcol[1] .. tokendata
  else
    cols[#cols + 1] = { tokendata, color, tokenname }
    lastcol = cols[#cols]
  end
end

function EDITOR:ResetTokenizer(row)
  if row == self.Scroll[1] then

    -- This code checks if the visible code is inside a string or a block comment
    self.blockcomment = nil
    self.multilinestring = nil
    local singlelinecomment = false

    local str = string_gsub( table_concat( self.Rows, "\n", 1, self.Scroll[1]-1 ), "\r", "" )

    for before, char, after in string_gmatch( str, '()([%-"\n])()' ) do
      local before = string_sub( str, before-1, before-1 )
      local after = string_sub( str, after, after )
      if not self.blockcomment and not self.multilinestring and not singlelinecomment then
        if char == '"' then
          self.multilinestring = true
        elseif char == "#" and after == "[" then
          self.blockcomment = true
        elseif after=="-" and char == "-" then
          singlelinecomment = true
        end
      elseif self.multilinestring and char == ']' and after == "]" and before ~= "\\" then
        self.multilinestring = nil
      elseif self.blockcomment and char == "]" and before == "]" then
        self.blockcomment = nil
      elseif singlelinecomment and char == "\n" then
        singlelinecomment = false
      end
    end
  end

  for k,v in pairs( self.e2fs_functions ) do
    if v == row then
      self.e2fs_functions[k] = nil
    end
  end
end

function EDITOR:SyntaxColorLine(row)
  cols,lastcol = {}, nil

  self:ResetTokenizer(row)
  self:NextCharacter()

  -- 0=name 1=port 2=trigger 3=foreach
  local highlightmode = nil

  if self.blockcomment then -- Closing block comments
    if self:NextPattern(".-%]%]") then
      self.blockcomment = nil
    else
      self:NextPattern(".*")
    end

    addToken("comment", self.tokendata)
  elseif self.multilinestring then
    while self.character do -- Find the ending ]]
      if self:NextPattern(".-%]%]") then
        self.multilinestring = nil
        self:NextCharacter()
        break
      end
      if self.character == "\\" then self:NextCharacter() end
      self:NextCharacter()
    end

    addToken("string", self.tokendata)
  end

  local found = self:SkipPattern( "( *function)" )
  if found then
    addToken( "keyword", found ) -- Add "function"
    self.tokendata = "" -- Reset tokendata

    local spaces = self:SkipPattern( " *" )
    if spaces then addToken( "comment", spaces ) end

    if self:NextPattern( "%s*[a-zA-Z][a-zA-Z0-9_]*" ) then -- function THIS()

      local spaces, funcname = self.tokendata:match( "(%s*)(%a[a-zA-Z0-9_]*)" )
      addToken( "userfunction", funcname )

      if not wire_expression2_funclist[funcname] then
        self.e2fs_functions[funcname] = row
      end
    end
    self.tokendata = ""

    if self:NextPattern( "%(" ) then -- We found a bracket
      -- Color the bracket
      addToken( "operator", self.tokendata )

      while self.character and self.character ~= ")" and false do -- Loop until the ending bracket
        self.tokendata = ""

        local spaces = self:SkipPattern( " *" )
        if spaces then addToken( "comment", spaces ) end

        if self:NextPattern( "%[" ) then -- Found a [
          -- Color the bracket
          addToken( "operator", self.tokendata )
          self.tokendata = ""

          local spaces = self:SkipPattern( " *" )
          if spaces then addToken( "comment", spaces ) end
        end

        if self:NextPattern( "%]" ) then
          addToken( "operator", "]" )
          self.tokendata = ""
        end

        if self:NextPattern( ":" ) then -- Check for the colon
          addToken( "operator", ":" )
          self.tokendata = ""
        end

        local spaces = self:SkipPattern( " *" )
        if spaces then addToken( "comment", spaces ) end

        -- If we found a comma, skip it
        if self.character == "," then addToken( "operator", "," ) self:NextCharacter() end
      end
    end

    self.tokendata = ""
    if self:NextPattern( "%) *{?" ) then -- check for ending bracket (and perhaps an ending {?)
      addToken( "operator", self.tokendata )
    end
  end

  while self.character do
    local tokenname = ""
    self.tokendata = ""

    -- eat all spaces
    local spaces = self:SkipPattern(" *")
    if spaces then addToken("operator", spaces) end
    if not self.character then break end

    -- eat next token

    if self:NextPattern("^0[xb][0-9A-F]+") then
      tokenname = "number"
    elseif self:NextPattern("^[0-9][0-9.e]*") then
      tokenname = "number"

    elseif self:NextPattern("^[a-zA-Z][a-zA-Z0-9_]*") then
      local sstr = self.tokendata

      -- is this a keyword or a function?
      local char = self.character or ""
      local keyword = char ~= "("

      local spaces = self:SkipPattern(" *") or ""

      if keywords[sstr][keyword] then
        tokenname = "keyword"
      elseif wire_expression2_funclist[sstr] and false then --Gotta convert to SF func list
        tokenname = "function"

      elseif self.e2fs_functions[sstr] then
        tokenname = "userfunction"

      else
        tokenname = "notfound"
      end
      addToken(tokenname, self.tokendata)
      tokenname = "comment"
      self.tokendata = spaces

    elseif self:NextPattern("%[%[") then -- Multiline strings
      self:NextCharacter()
      while self.character do -- Find the ending ]] if it isnt really multline(who does that?! Shame on you!)
        if self:NextPattern("%]%]") then
          tokenname = "string"
          break
        end
        if self.character == "\\" then self:NextCharacter() end
        self:NextCharacter()
      end

      if tokenname == "" then -- If no ending ]] was found...
        self.multilinestring = true
        tokenname = "string"
      else
        self:NextCharacter()
      end
      --"string"
    elseif self.character == '"' then -- Singleline "string"
      self:NextCharacter()
      while self.character do -- Find the ending "
        if self.character == '"' then
          tokenname = "string"
          break
        end
        if self.character == "\\" then self:NextCharacter() end
        self:NextCharacter()
      end

      if tokenname == "" then -- If no ending " was found...
        --self.multilinestring = true
        tokenname = "string"
      else
        self:NextCharacter()
      end
    elseif self.character == "'" then -- Singleline 'string'
      self:NextCharacter()
      while self.character do -- Find the ending "
        if self.character == "'" then
          tokenname = "string"
          break
        end
        if self.character == "\\" then self:NextCharacter() end
        self:NextCharacter()
      end

      if tokenname == "" then -- If no ending " was found...
        --self.multilinestring = true
        tokenname = "string"
      else
        self:NextCharacter()
      end
    elseif self:NextPattern("%-%-") then -- Comments

      if self.character == "[" and self:NextPattern("%[%[") then -- Check if there is a [[ directly after the --
        while self.character do -- Find the ending ]
          if self.character == "]" then
            self:NextCharacter()
            if self.character == "]" then -- Check if ] is double
              tokenname = "comment"
              break
            end
          end
          if self.character == "\\" then self:NextCharacter() end
          self:NextCharacter()
        end
        if tokenname == "" then -- If no ending ]] was found...
          self.blockcomment = true
          tokenname = "comment"
        else
          self:NextCharacter()
        end
      end

      if tokenname == "" then
        tokenname = "comment"
        self:NextPattern("[^@]*") -- Skip everything BEFORE @
				addToken(tokenname, self.tokendata)
				self.tokendata ="" -- we dont need that anymore as we already added it
				
				self:NextPattern("[%S]*") -- Find first word
        if directives[self.tokendata] then --Directive
          tokenname = "directive"
        end
        self:NextPattern(".*") -- Rest of comment/directive
      end
    else
      self:NextCharacter()

      tokenname = "operator"
    end

    addToken(tokenname, self.tokendata)
  end

  return cols
end

WireTextEditor.Modes.Starfall = EDITOR
