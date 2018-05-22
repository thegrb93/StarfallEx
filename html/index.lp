<?lua=docletsfhtml.include("_before_main.lp", { doc = doc })?>
<h1>StarfallEx Reference</h1>
<div class="star star-large"></div>
<section class="libraries">
	<h2>Libraries</h2>
	<table class="list">
		<?lua for _, name in ipairs(doc.libraries) do?>
		<tr>
			<td class="name"><a href="<?lua=docletsfhtml.module_link(name, doc)?>"><?lua if doc.libraries[name].deprecated then ?><del><?lua end?><?lua=name?><?lua if doc.libraries[name].deprecated then ?></del><?lua end?></a></td>
			<td class="summary"><?lua=doc.libraries[name].summary?></td>
		</tr><?lua end?>
	</table>
</section>
<section class="hooks">
	<h2>Hooks</h2>
	<table class="list">
		<?lua for _, name in ipairs(doc.hooks) do?>
		<tr>
			<td class="name"><span class="realm_<?lua=doc.hooks[name].realm?>"></span><a href="<?lua=docletsfhtml.hook_link(name, doc)?>"><?lua=name?></a></td>
			<td class="summary"><?lua=doc.hooks[name].summary?></td>
		</tr><?lua end?>
	</table>
</section>
<?lua=docletsfhtml.include("_after_main.lp", { doc = doc })?>