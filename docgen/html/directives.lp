<?lua=docletsfhtml.include("_before_main.lp", { doc = doc, dir_doc = dir_doc })?>
<h1>Preprocessor directives</h1>
<p>List of preprocessor directives that are put on SF script's top.</p>
<section class="directives">
	<h2>List</h2>
	<table class="list">
		<?lua for _, name in ipairs(dir_doc.directives) do
			local data = dir_doc.directives[name]?>
		<tr>
			<td class="name" nowrap><a href="#<?lua=data.name?>">--@<?lua=name?></a> <?lua=table.concat(data.param, ", ")?></td>
			<td class="summary"><?lua=data.summary?></td>
		</tr><?lua end?>
	</table>
</section>
<dl class="directives">
	<?lua for _, name in ipairs(dir_doc.directives) do
		local dir = dir_doc.directives[name]?>
	<dt><a name="<?lua=dir.name?>"></a><strong>--@<?lua=dir.name?></strong> <?lua=table.concat(dir.param, ", ")?></dt>
	<dd>
		<p><?lua=dir.description or ""?></p>
		<?lua if type(dir.param) == "table" and #dir.param > 0 then?>
		<section class="parameters">
			<h3>Parameters</h3>
			<ul>
				<?lua for p = 1, #dir.param do?>
				<li>
					<tt><?lua=dir.param[p]?></tt><?lua if dir.param[dir.param[p]] then?> ― <?lua=dir.param[dir.param[p]]?><?lua end?>
				</li>
				<?lua end?>
			</ul>
		</section><?lua end?>
		<section class="usage">
			<h3>Usage</h3>
			<?lua if type(dir.usage) == "string" then?>
			<p><pre class="example"><?lua=dir.usage?></pre></p>
			<?lua elseif type(dir.usage) == "table" then?>
			<ul>
				<?lua for _, usage in ipairs(dir.usage) do?>
				<li><pre class="example"><?lua=usage?></pre></li><?lua end?>
			</ul><?lua end?>
		</section>
	</dd><?lua end?>
</dl>
<?lua=docletsfhtml.include("_after_main.lp", { doc = doc })?>