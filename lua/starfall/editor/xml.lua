--[[
    Lua XML parser. Originally created by Paul Chakravarti (paulc@passtheaardvark.com).
    Modified to work with Garry's Mod.

    This code is freely distributable under the terms of the Lua license
    (http://www.lua.org/copyright.html)
]]

local function simpleTreeHandler()

    local obj = {}
    obj.root = { _name = "root" }
    obj.current = obj.root
    obj.options = { noreduce = {} }
    obj.stack = { }

    obj.starttag = function(self, name, attribs)
        if not self.current.children then
            self.current.children = { }
        end

        self.current.children[#self.current.children + 1] = {
            name = name,
        }

        self.stack[#self.stack + 1] = self.current.children[#self.current.children]
        self.current = self.current.children[#self.current.children]
    end

    obj.endtag = function(self, name, attribs)
        table.remove(self.stack, #self.stack)
        self.current = self.stack[#self.stack]
    end

    obj.text = function(self, text)
        self.current.value = text
    end

    obj.cdata = obj.text

    return obj
end

SF.Editor.Themes.CreateXMLParser = function()

    local obj = {}

    -- Public attributes

    obj.options = { stripWS = 1,
                    expandEntities = 1,
                    errorHandler = function(err, pos)
                                       error(string.format("%s [char=%d]\n",
                                               err or "Parse Error", pos))
                                   end,
                  }

    -- Public methods

    obj.parse = function(self, string)
        local match, endmatch, pos = 0, 0, 1
        local text, endt1, endt2, tagstr, tagname, attrs, starttext, endtext
        local errstart, errend, extstart, extend
        while match do
            -- Get next tag (first pass - fix exceptions below)
            match, endmatch, text, endt1, tagstr, endt2 = string.find(string, self._XML, pos)
            if not match then
                if string.find(string, self._WS, pos) then
                    -- No more text - check document complete
                    if table.getn(self._stack) ~= 0 then
                        self:_err(self._errstr.incompleteXmlErr, pos)
                    else
                        break
                    end
                else
                    -- Unparsable text
                    self:_err(self._errstr.xmlErr, pos)
                end
            end
            -- Handle leading text
            starttext = match
            endtext = match + string.len(text) - 1
            match = match + string.len(text)
            text = self:_parseEntities(self:_stripWS(text))
            if text ~= "" and self._handler.text then
                self._handler:text(text, nil, match, endtext)
            end
            -- Test for tag type
            if string.find(string.sub(tagstr, 1, 5), "?xml%s") then
                -- XML Declaration
                match, endmatch, text = string.find(string, self._PI, pos)
                if not match then
                    self:_err(self._errstr.declErr, pos)
                end
                if match ~= 1 then
                    -- Must be at start of doc if present
                    self:_err(self._errstr.declStartErr, pos)
                end
                tagname, attrs = self:_parseTag(text)
                -- TODO: Check attributes are valid
                -- Check for version (mandatory)
                if attrs.version == nil then
                    self:_err(self._errstr.declAttrErr, pos)
                end
                if self._handler.decl then
                    self._handler:decl(tagname, attrs, match, endmatch)
                end
            elseif string.sub(tagstr, 1, 1) == "?" then
                -- Processing Instruction
                match, endmatch, text = string.find(string, self._PI, pos)
                if not match then
                    self:_err(self._errstr.piErr, pos)
                end
                if self._handler.pi then
                    -- Parse PI attributes & text
                    tagname, attrs = self:_parseTag(text)
                    local pi = string.sub(text, string.len(tagname) + 1)
                    if pi ~= "" then
                        if attrs then
                            attrs._text = pi
                        else
                            attrs = { _text = pi }
                        end
                    end
                    self._handler:pi(tagname, attrs, match, endmatch)
                end
            elseif string.sub(tagstr, 1, 3) == "!--" then
                -- Comment
                match, endmatch, text = string.find(string, self._COMMENT, pos)
                if not match then
                    self:_err(self._errstr.commentErr, pos)
                end
                if self._handler.comment then
                    text = self:_parseEntities(self:_stripWS(text))
                    self._handler:comment(text, next, match, endmatch)
                end
            elseif string.sub(tagstr, 1, 8) == "!DOCTYPE" then
                -- DTD
                match, endmatch, attrs = self:_parseDTD(string, pos)
                if not match then
                    self:_err(self._errstr.dtdErr, pos)
                end
                if self._handler.dtd then
                    self._handler:dtd(attrs._root, attrs, match, endmatch)
                end
            elseif string.sub(tagstr, 1, 8) == "![CDATA[" then
                -- CDATA
                match, endmatch, text = string.find(string, self._CDATA, pos)
                if not match then
                    self:_err(self._errstr.cdataErr, pos)
                end
                if self._handler.cdata then
                    self._handler:cdata(text, nil, match, endmatch)
                end
            else
                -- Normal tag

                -- Need theck for embedded '>' in attribute value and extend
                -- match recursively if necessary eg. <tag attr="123>456">

                while 1 do
                    errstart, errend = string.find(tagstr, self._ATTRERR1)
                    if errend == nil then
                        errstart, errend = string.find(tagstr, self._ATTRERR2)
                        if errend == nil then
                            break
                        end
                    end
                    extstart, extend, endt2 = string.find(string, self._TAGEXT, endmatch + 1)
                    tagstr = tagstr .. string.sub(string, endmatch, extend-1)
                    if not match then
                        self:_err(self._errstr.xmlErr, pos)
                    end
                    endmatch = extend
                end

                -- Extract tagname/attrs

                tagname, attrs = self:_parseTag(tagstr)

                if (endt1=="/") then
                    -- End tag
                    if self._handler.endtag then
                        if attrs then
                            -- Shouldnt have any attributes in endtag
                            self:_err(string.format("%s (/%s)",
                                             self._errstr.endTagErr,
                                             tagname)
                                        , pos)
                        end
                        if table.remove(self._stack) ~= tagname then
                            self:_err(string.format("%s (/%s)",
                                             self._errstr.unmatchedTagErr,
                                             tagname)
                                        , pos)
                        end
                        self._handler:endtag(tagname, nil, match, endmatch)
                    end
                else
                    -- Start Tag
                    table.insert(self._stack, tagname)
                    if self._handler.starttag then
                        self._handler:starttag(tagname, attrs, match, endmatch)
                    end
                    -- Self-Closing Tag
                    if (endt2=="/") then
                        table.remove(self._stack)
                        if self._handler.endtag then
                            self._handler:endtag(tagname, nil, match, endmatch)
                        end
                    end
                end
            end
            pos = endmatch + 1
        end
    end

    -- Private attrobures/functions

    obj._handler    = simpleTreeHandler()
    obj._stack      = {}

    obj._XML        = '^([^<]*)<(%/?)([^>]-)(%/?)>'
    obj._ATTR1      = '([%w-:_]+)%s*=%s*"(.-)"'
    obj._ATTR2      = '([%w-:_]+)%s*=%s*\'(.-)\''
    obj._CDATA      = '<%!%[CDATA%[(.-)%]%]>'
    obj._PI         = '<%?(.-)%?>'
    obj._COMMENT    = '<!%-%-(.-)%-%->'
    obj._TAG        = '^(.-)%s.*'
    obj._LEADINGWS  = '^%s+'
    obj._TRAILINGWS = '%s+$'
    obj._WS         = '^%s*$'
    obj._DTD1       = '<!DOCTYPE%s+(.-)%s+(SYSTEM)%s+["\'](.-)["\']%s*(%b[])%s*>'
    obj._DTD2       = '<!DOCTYPE%s+(.-)%s+(PUBLIC)%s+["\'](.-)["\']%s+["\'](.-)["\']%s*(%b[])%s*>'
    obj._DTD3       = '<!DOCTYPE%s+(.-)%s*(%b[])%s*>'
    obj._DTD4       = '<!DOCTYPE%s+(.-)%s+(SYSTEM)%s+["\'](.-)["\']%s*>'
    obj._DTD5       = '<!DOCTYPE%s+(.-)%s+(PUBLIC)%s+["\'](.-)["\']%s+["\'](.-)["\']%s*>'

    obj._ATTRERR1   = '=%s*"[^"]*$'
    obj._ATTRERR2   = '=%s*\'[^\']*$'
    obj._TAGEXT     = '(%/?)>'

    obj._ENTITIES = { ["&lt;"] = "<",
                      ["&gt;"] = ">",
                      ["&amp;"] = "&",
                      ["&quot;"] = '"',
                      ["&apos;"] = "'",
                      ["&#(%d+);"] = function (x)
                                        local d = tonumber(x)
                                        if d >= 0 and d < 256 then
                                            return string.char(d)
                                        else
                                            return "&#"..d..";"
                                        end
                                     end,
                      ["&#x(%x+);"] = function (x)
                                        local d = tonumber(x, 16)
                                        if d >= 0 and d < 256 then
                                            return string.char(d)
                                        else
                                            return "&#x"..x..";"
                                        end
                                      end,
                    }

    obj._err = function(self, err, pos)
                   if self.options.errorHandler then
                       self.options.errorHandler(err, pos)
                   end
               end

    obj._errstr = { xmlErr = "Error Parsing XML",
                    declErr = "Error Parsing XMLDecl",
                    declStartErr = "XMLDecl not at start of document",
                    declAttrErr = "Invalid XMLDecl attributes",
                    piErr = "Error Parsing Processing Instruction",
                    commentErr = "Error Parsing Comment",
                    cdataErr = "Error Parsing CDATA",
                    dtdErr = "Error Parsing DTD",
                    endTagErr = "End Tag Attributes Invalid",
                    unmatchedTagErr = "Unbalanced Tag",
                    incompleteXmlErr = "Incomplete XML Document",
                  }

    obj._stripWS = function(self, s)
        if self.options.stripWS then
            s = string.gsub(s, '^%s+', '')
            s = string.gsub(s, '%s+$', '')
        end
        return s
    end

    obj._parseEntities = function(self, s)
        if self.options.expandEntities then
            for k, v in pairs(self._ENTITIES) do
                s = string.gsub(s, k, v)
            end
        end
        return s
    end

    obj._parseDTD = function(self, s, pos)
        -- match,endmatch,root,type,name,uri,internal
        local m, e, r, t, n, u, i
        m, e, r, t, u, i = string.find(s, self._DTD1, pos)
        if m then
            return m, e, { _root = r, _type = t, _uri = u, _internal = i }
        end
        m, e, r, t, n, u, i = string.find(s, self._DTD2, pos)
        if m then
            return m, e, { _root = r, _type = t, _name = n, _uri = u, _internal = i }
        end
        m, e, r, i = string.find(s, self._DTD3, pos)
        if m then
            return m, e, { _root = r, _internal = i }
        end
        m, e, r, t, u = string.find(s, self._DTD4, pos)
        if m then
            return m, e, { _root = r, _type = t, _uri = u }
        end
        m, e, r, t, n, u = string.find(s, self._DTD5, pos)
        if m then
            return m, e, { _root = r, _type = t, _name = n, _uri = u }
        end
        return nil
    end

    obj._parseTag = function(self, s)
        local attrs = {}
        local tagname = string.gsub(s, self._TAG, '%1')
        string.gsub(s, self._ATTR1, function (k, v)
                                attrs[string.lower(k)] = self:_parseEntities(v)
                                attrs._ = 1
                           end)
        string.gsub(s, self._ATTR2, function (k, v)
                                attrs[string.lower(k)] = self:_parseEntities(v)
                                attrs._ = 1
                           end)
        if attrs._ then
            attrs._ = nil
        else
            attrs = nil
        end
        return tagname, attrs
    end

    return obj

end
