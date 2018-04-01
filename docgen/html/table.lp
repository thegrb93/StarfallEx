<?lua
	local tname = tab.name
	if tab.classlib then
		tname = tab.classlib .. ":" .. tab.tname
	elseif tab.library then
		tname = tab.library .. "." .. tab.tname
	end
?>
<dt><a name="<?lua=tname?>"></a><?lua=tname?></dt>
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