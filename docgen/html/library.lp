<?lua=docletsfhtml.include("_before_main.lp", { doc = doc, module_doc = module_doc })?>
<h1>Library <tt><?lua=module_doc.name?></tt></h1>
<p><?lua=module_doc.description?></p>
<?lua if module_doc.deprecated then?>
<blockquote class="deprecation">
	This library has been deprecated and will be removed in the future<?lua=module_doc.deprecated and " for the following reason: ".. module_doc.deprecated or ""?>.
</blockquote><?lua end?>
<?lua if module_doc.copyright then?>
<p><strong>Copyright</strong> &copy; <?lua=module_doc.copyright?></p><?lua end?>
<?lua if module_doc.author then?>
<p>
	<strong>Author<?lua=#module_doc.author>1 and "s" or ""?>:</strong>
	<ul>
	<?lua for _, name in ipairs(module_doc.author) do?>
		<li><?lua= name ?></li><?lua end?>
	</ul>
</p><?lua end?>
<?lua if module_doc.release then?>
<p><strong>Release:</strong> <?lua=module_doc.release?></p><?lua end?>
<?lua if #module_doc.functions > 0 then?>
<section class="functions">
	<h2>Functions</h2>
	<table class="list">
	<?lua for _, name in ipairs(module_doc.functions) do
		local data = module_doc.functions[name]?>
		<tr>
			<td class="name"><span class="realm_<?lua=data.realm?>"></span><?lua if data.deprecated then?><del><?lua end?><?lua=data.private and "local " or ""?><a href="#<?lua=data.classlib and data.classlib .. ":" .. data.fname or data.library and data.library .. "." .. data.fname or data.name?>"><?lua=name?></a>( <?lua=table.concat(module_doc.functions[name].param, ", ")?>&nbsp;)<?lua if data.deprecated then?></del><?lua end?></td>
			<td class="summary"><?lua=module_doc.functions[name].summary?></td>
		</tr><?lua end?>
	</table>
</section><?lua end?>
<?lua if module_doc.tables and #module_doc.tables > 0 then?>
<section class="tables">
	<h2>Tables</h2>
	<table class="list">
		<?lua for _, name in ipairs(module_doc.tables) do
			local data = module_doc.tables[name]?>
		<tr>
		<td class="name"><a href="#<?lua=data.classlib and data.classlib .. ":" .. data.tname or data.library and data.library .. "." .. data.tname or data.name?>"><?lua=name?></a></td>
		<td class="summary"><?lua=module_doc.tables[name].summary?></td>
		</tr><?lua end?>
	</table>
</section><?lua end?>
<?lua if module_doc.fields and #module_doc.fields > 0 then?>
<section class="fields">
	<h2>Fields</h2>
	<table class="list">
		<?lua for _, name in ipairs(module_doc.fields) do
			local data = module_doc.fields[name]?>
		<tr>
			<td class="name"><a href="#<?lua=data.name?>"><?lua=name?></a></td>
			<td class="summary"><?lua=module_doc.fields[name].summary?></td>
		</tr><?lua end?>
	</table>
</section><?lua end?>
<?lua if #module_doc.functions > 0 then?>
<section class="functions_def">
	<h2><a name="functions_def"></a>Functions definition</h2>
	<dl>
		<?lua for _, name in ipairs(module_doc.functions) do?>
		<?lua=docletsfhtml.include("function.lp", { doc = doc, module_doc = module_doc, func = module_doc.functions[name] })?><?lua end?>
	</dl>
</section><?lua end?>
<?lua if module_doc.tables and #module_doc.tables > 0 then?>
<section class="tables_def">
	<h2><a name="tables_def"></a>Tables definition</h2>
	<dl>
		<?lua for _, name in ipairs(module_doc.tables) do?>
		<?lua=docletsfhtml.include("table.lp", { doc = doc, module_doc = module_doc, tab = module_doc.tables[name] })?><?lua end?>
	</dl>
</section><?lua end?>
<?lua=docletsfhtml.include("_after_main.lp", { doc = doc })?>