<?lua 
if module_doc then
	from = "libraries/"..module_doc.name
elseif hook_doc then
	from = "hooks.html"
elseif file_doc then
	from = "files/.."..file_doc.name
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


<!-- Module list -->
<?lua if not options.nolibs and #doc.libraries > 0 then?>
<h1>Libraries</h1>
<ul>
<?lua for _, modulename in ipairs(doc.libraries) do
	if module_doc and module_doc.name == modulename then?>
	<li><strong><?lua=modulename?></strong></li>
	<?lua else?>
	<li>
		<a href="<?lua=docletsfhtml.module_link(modulename, doc, from)?>"><?lua=modulename?></a>
	</li>
<?lua 	end
end?>
</ul>
<?lua end?>

<h1>Hooks</h1>
<ul>
<?lua for _, hookname in ipairs(doc.hooks) do
	if hook_doc and hook_doc.name == hookname then?>
	<li><strong><?lua=hookname?></strong></li>
	<?lua else?>
	<li>
		<a href="<?lua=docletsfhtml.hook_link(hookname, doc, from)?>#<?lua=hookname?>"><?lua=hookname?></a>
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



