<?lua=docletsfhtml.include("_before_main.lp", { doc = doc, class_doc = class_doc })?>
<h1><tt><?lua=class_doc.name?></tt> type</h1>
<p><?lua=class_doc.description?></p>
<?lua if class_doc.deprecated then?>
<blockquote class="deprecation">
	This type has been deprecated and will be removed in the future<?lua=class_doc.deprecated and " for the following reason: ".. class_doc.deprecated or ""?>.
</blockquote><?lua end?>
<?lua if class_doc.copyright then?>
<p><strong>Copyright</strong> &copy; <?lua=class_doc.copyright?></p><?lua end?>
<?lua if class_doc.author then?>
<p>
	<strong>Author<?lua=#class_doc.author>1 and "s" or ""?>:</strong>
	<ul>
	<?lua for _, name in ipairs(class_doc.author) do?>
		<li><?lua= name ?></li><?lua end?>
	</ul>
</p><?lua end?>
<?lua if class_doc.release then?>
<p><strong>Release:</strong> <?lua=class_doc.release?></p><?lua end?>
<?lua if #class_doc.methods > 0 then?>
<section class="methods">
	<h2>Methods</h2>
	<table class="list">
		<?lua for _, name in ipairs( class_doc.methods ) do
			local data = class_doc.methods[name]?>
		<tr>
			<td class="name"><span class="realm_<?lua=data.realm?>"></span><?lua if data.deprecated then?><del><?lua end?><?lua=data.private and "local " or ""?><a href="#<?lua=class_doc.methods[name].classlib?>:<?lua=class_doc.methods[name].fname?>"><?lua=name?></a>( <?lua=table.concat( class_doc.methods[name].param, ", " )?>&nbsp;)<?lua if data.deprecated then?></del><?lua end?></td>
			<td class="summary"><?lua=class_doc.methods[name].summary?></td>
		</tr><?lua end?>
	</table>
</section>
<section class="methods_def">
	<h2><a name="methods_def"></a>Methods definition</h2>
	<dl>
		<?lua for _, name in ipairs( class_doc.methods ) do?>
		<?lua=docletsfhtml.include( "function.lp", { doc=doc, class_doc=class_doc, func=class_doc.methods[name] } )?><?lua end?>
	</dl>
</section><?lua end?>
<?lua=docletsfhtml.include("_after_main.lp", { doc = doc })?>