ENT.Type            = "anim"
ENT.Base            = "base_wire_entity"

ENT.PrintName       = "Starfall Processor"
ENT.Author          = "Colonel Thirty Two"
ENT.Contact         = "initrd.gz@gmail.com"
ENT.Purpose         = ""
ENT.Instructions    = ""

ENT.Spawnable       = false
ENT.AdminSpawnable  = false


include("compiler/preprocessor.lua")
include("compiler/tokenizer.lua")
include("compiler/parser.lua")
include("compiler/compiler.lua")