<?lua 
if module_doc then
	from = "libraries/"..module_doc.name
elseif file_doc then
	from = "files/.."..file_doc.name
else
	from = ""
end
?>

<dt><?lua=func.private and "local " or ""?><a name="<?lua=func.name?>"></a><strong><?lua=func.name?></strong>&nbsp;(<?lua=table.concat(func.param, ", ")?>)</dt>
<dd>
<?lua=func.description or ""?>

<?lua if type(func.param) == "table" and #func.param > 0 then?>
<h3>Parameters:</h3>
<ul>
	<?lua for p = 1, #func.param do?>
	<li>
	  <code><em><?lua=func.param[p]?></em></code>: <?lua=func.param[func.param[p]] or ""?>
	</li>
	<?lua end?>
</ul>
<?lua end?>


<?lua if type(func.usage) == "string" then?>
<h3>Usage:</h3>
<ul><pre class=example><?lua=func.usage?></pre></ul>
<?lua elseif type(func.usage) == "table" then?>
<h3>Usage:</h3>
<ul>
	<?lua for _, usage in ipairs(func.usage) do?>
	<li><pre class=example><?lua= usage ?></pre></li>
	<?lua end?>
</ul>
<?lua end?>

<?lua if type(func.ret) == "string" then?>
<h3>Return value:</h3>
<ul><?lua=func.ret?></ul>
<?lua elseif type(func.ret) == "table" then?>
<h3>Return values:</h3>
<ol>
	<?lua for _, ret in ipairs(func.ret) do?>
	<li><?lua= ret ?></li>
	<?lua end?>
</ol>
<?lua end?>

<?lua if type(func.see) == "string" then ?>
<h3>See also:</h3>
	<ul><a href="#<?lua=func.see?>"><?lua=func.see?></a></ul>
<?lua elseif type(func.see) == "table" and #func.see > 0 then ?>
<h3>See also:</h3>
<ul>
	<?lua for i = 1, #func.see do?>
	<!-- <li><a href="#<?lua=docletsfhtml.symbol_link(func.see[i], doc, module_doc, file_doc, from)?><?lua=func.see[i]?>"> -->
	<li><a href="#<?lua=func.see[i]?>">
		<?lua=func.see[i]?></li>
	</a>
	<?lua end?>
</ul>
<?lua end?>
</dd>
