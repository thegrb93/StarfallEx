<dt><a name="<?lua=tab.name?>"></a><strong><?lua=tab.name?></strong></dt>
<dd><?lua=tab.description?><br /><br />

<?lua if type(tab.field) == "table" and #tab.field > 0 then?>
<h3>Fields:</h3>
<ul>
	<?lua for p = 1, #tab.field do?>
	<li>
	  <code><em><?lua=tab.field[p]?></em></code>: <?lua=tab.field[tab.field[p]] or ""?>
	</li>
	<?lua end?>
</ul>
<?lua end?>

</dd>
