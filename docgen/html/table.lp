<dt><a name="<?lua=tab.name?>"></a><?lua=tab.name?></dt>
<dd>
	<p><?lua=tab.description?></p>
	<?lua if type(tab.field) == "table" and #tab.field > 0 then?>
	<section class="fields">
		<h3>Fields</h3>
		<ul>
			<?lua for p = 1, #tab.field do?>
			<li><tt><?lua=tab.field[p]?></tt><?lua if tab.field[tab.field[p]] then?> ― <?lua=tab.field[tab.field[p]]?><?lua end?></li><?lua end?>
		</ul>
	</section><?lua end?>
</dd>