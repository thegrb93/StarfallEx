<?lua 
if module_doc then
	from = "libraries/"..module_doc.name
elseif hook_doc then
	from = "hooks.html"
elseif file_doc then
	from = "files/.."..file_doc.name
elseif class_doc then
	from = "classes/.." .. class_doc.name
elseif dir_doc then
	from = "directives/.." .. dir_doc.name
elseif example_doc then
	from = "examples/.." .. example_doc.name
else
	from = ""
end
?>

<h1>LuaDoc</h1>
<ul>
	<?lua if not module_doc and not file_doc then?>
	<li><strong>Index</strong></li>
	<?lua else?>
	<li><a href="<?lua=docletsfhtml.link("index.html", from)?>">Index</a></li>
	<?lua end?>
</ul>


<h1>Preprocessor directives</h1>
<ul>
<?lua for _, directive in ipairs(doc.directives) do
	if dir_doc and dir_doc.name == directive then?>
	<li><strong><?lua=directive?></strong></li>
	<?lua else?>
	<li>
		<a href="<?lua=docletsfhtml.directive_link( directive, doc, from )?>#<?lua=directive?>">--@<?lua=directive?></a>
	</li>
<?lua 	end
end?>
</ul>

<!-- Module list -->
<?lua if not options.nolibs and #doc.libraries > 0 then?>
<h1>Libraries</h1>
<ul>
<?lua for _, modulename in ipairs(doc.libraries) do
	local module_data = doc.libraries[modulename]
	if module_doc and module_doc.name == modulename then?>
		<li><strong><?lua=module_data.deprecated and "<del>" or ""?><?lua=modulename?><?lua=module_data.deprecated and "</del>" or ""?></strong></li>
	<?lua else?>
	<li>
		<a href="<?lua=docletsfhtml.module_link(modulename, doc, from)?>"><?lua=module_data.deprecated and "<del>" or ""?><?lua=modulename?><?lua=module_data.deprecated and "</del>" or ""?></a>
	</li>
<?lua 	end
end?>
</ul>
<?lua end?>

<h1>Types</h1>
<ul>
	<?lua for _, typename in ipairs( doc.classes ) do
		local class_data = doc.classes[ typename ]
		if class_doc and class_doc.name == typename then?>
			<li><strong><?lua=class_data.deprecated and "<del>" or ""?><?lua=typename?><?lua=class_data.deprecated and "</del>" or ""?></strong></li>
		<?lua else ?>
			<li><a href="<?lua=docletsfhtml.class_link( typename, doc, from )?>"><?lua=class_data.deprecated and "<del>" or ""?><?lua=typename?><?lua=class_data.deprecated and "</del>" or ""?></a></li>
		<?lua end
	end ?>
</ul>

<h1>Hooks</h1>
<ul>
<?lua for _, hookname in ipairs(doc.hooks) do
	if hook_doc and hook_doc.name == hookname then?>
	<li><strong><?lua=hookname?></strong></li>
	<?lua else?>
	<li>
		<span class="realm_<?lua=doc.hooks[hookname].realm?>">&nbsp;</span><a href="<?lua=docletsfhtml.hook_link( hookname, doc, from )?>#<?lua=hookname?>"><?lua=hookname?></a>
	</li>
<?lua 	end
end?>
</ul>

<h1>Examples</h1>
<ul>
<?lua for name, example in pairs(doc.examples) do
	if example_doc and example_doc.name == name then?>
	<li><strong><?lua=name?></strong></li>
	<?lua else?>
	<li>
		<a href="<?lua=docletsfhtml.example_link( name, doc, from )?>"><?lua=name?></a>
	</li>
<?lua 	end
end?>
</ul>

<!-- File list -->
<?lua if not options.nofiles and #doc.files > 0 then?>
<h1>Files</h1>
<ul>
<?lua for _, filepath in ipairs(doc.files) do
	if file_doc and file_doc.name == filepath then?>
	<li><strong><?lua=filepath?></strong></li>
	<?lua else?>
	<li>
		<a href="<?lua=docletsfhtml.file_link(filepath, from)?>"><?lua=filepath?></a>
	</li>
<?lua 	end
end?>
</ul>
<?lua end?>



