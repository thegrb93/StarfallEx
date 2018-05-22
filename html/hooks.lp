<?lua=docletsfhtml.include("_before_main.lp", { doc = doc, hook_doc = hook_doc })?>
<h1>Hooks</h1>
<p>List of hooks available to Starfall scripts.</p>
<section class="hooks">
	<h2>List</h2>
	<table class="list">
		<?lua for _, name in ipairs(hook_doc.hooks) do
			local data = hook_doc.hooks[name]?>
		<tr>
			<td class="name"><span class="realm_<?lua=data.realm?>"></span><a href="#<?lua=data.name?>"><?lua=name?></a>( <?lua=table.concat(data.param, ", " )?>&nbsp;)</td>
			<td class="summary"><?lua=data.summary?></td>
		</tr><?lua end?>
	</table>
</section>
<dl class="hooks">
	<?lua for _, name in ipairs(hook_doc.hooks) do
		local hook = hook_doc.hooks[name]?>
	<dt><a name="<?lua=hook.name?>"></a><span class="realm_<?lua=hook.realm?>"></span><strong><?lua=hook.name?></strong>( <?lua=table.concat(hook.param, ", ")?>&nbsp;)</dt>
	<dd>
		<p><?lua=hook.description or ""?></p>
		<?lua if type(hook.param) == "table" and #hook.param > 0 then?>
		<section class="parameters">
			<h3>Parameters</h3>
			<ul>
				<?lua for p = 1, #hook.param do?>
				<li>
					<tt><?lua=hook.param[p]?></tt><?lua if hook.param[hook.param[p]] then?> ― <?lua=hook.param[hook.param[p]]?><?lua end?>
				</li><?lua end?>
			</ul>
		</section><?lua end?>
		<?lua if hook.usage then?>
		<section class="usage">
			<h3>Usage</h3>
			<?lua if type(hook.usage) == "string" then?>
			<p><pre class="example"><?lua=hook.usage?></pre></p>
			<?lua elseif type(hook.usage) == "table" then?>
			<ul>
				<?lua for _, usage in ipairs(hook.usage) do?>
				<li><pre class="example"><?lua=usage?></pre></li><?lua end?>
			</ul><?lua end?>
		</section><?lua end?>
		<?lua if hook.ret then?>
		<section class="return">
			<h3>Return inside callback</h3>
			<?lua if type(hook.ret) == "string" then?>
			<p><?lua=hook.ret?></p>
			<?lua elseif type(hook.ret) == "table" then?>
			<ol>
				<?lua for _, ret in ipairs(hook.ret) do?>
				<li><?lua=ret?></li><?lua end?>
			</ol><?lua end?>
		</section><?lua end?>
	</dd><?lua end?>
</dl>
<?lua=docletsfhtml.include("_after_main.lp", { doc = doc })?>