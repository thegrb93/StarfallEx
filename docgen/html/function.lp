<?lua
local fname = func.name
if func.classlib then
	fname = func.classlib .. ":" .. func.fname
elseif func.library then
	fname = func.library .. "." .. func.fname
end
?>
<dt><span class="realm_<?lua=func.realm?>"></span><?lua if func.deprecated then?><del><?lua end?><?lua=func.private and "local " or ""?><a name="<?lua=fname?>"></a><strong><?lua=fname?></strong>( <?lua=table.concat(func.param, ", ")?>&nbsp;)<?lua if func.deprecated then?></del><?lua end?></dt>
<dd>
	<p><?lua=func.description or ""?></p>
	<?lua if func.deprecated then?>
	<blockquote class="deprecation">
		Deprecated: <?lua=func.deprecated?>
	</blockquote><?lua end?>
	<?lua if type(func.param) == "table" and #func.param > 0 then?>
	<section class="parameters">
		<h3>Parameters</h3>
		<ul>
			<?lua for p = 1, #func.param do?>
			<li><tt><?lua=func.param[p]?></tt><?lua if func.param[func.param[p]] then?> ― <?lua=func.param[func.param[p]]?><?lua end?></li><?lua end?>
		</ul>
	</section><?lua end?>
	<?lua if func.usage then?>
	<section class="usage">
		<h3>Usage</h3>
		<?lua if type(func.usage) == "string" then?>
		<p><pre class="example"><?lua=func.usage?></pre></p>
		<?lua elseif type(func.usage) == "table" then?>
		<ul>
			<?lua for _, usage in ipairs(func.usage) do?>
			<li><pre class="example"><?lua=usage?></pre></li><?lua end?>
		</ul><?lua end?>
	</section><?lua end?>
	<?lua if func.ret then?>
	<section class="return">
		<h3>Returns</h3>
		<?lua if type(func.ret) == "string" then?>
		<p><?lua=func.ret?></p>
		<?lua elseif type(func.ret) == "table" then?>
		<ol>
			<?lua for _, ret in ipairs(func.ret) do?>
			<li><?lua=ret?></li><?lua end?>
		</ol><?lua end?>
	</section><?lua end?>
	<?lua if func.bug then?>
	<section class="known_bug">
		<h3>Known bug</h3>
		<p><?lua=func.bug?></p>
	</section><?lua end?>
	<?lua if func.see then?>
	<section class="see_also">
		<h3>See also</h3>
		<?lua if type(func.see) == "string" then ?>
		<p><a href="#<?lua=func.see?>"><?lua=func.see?></a></p>
		<?lua elseif type(func.see) == "table" and #func.see > 0 then ?>
		<ul>
			<?lua for i = 1, #func.see do?>
			<li><a href="#<?lua=func.see[i]?>"><?lua=func.see[i]?></a></li><?lua end?>
		</ul><?lua end?>
	</section><?lua end?>
</dd>