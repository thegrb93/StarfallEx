<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
   "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
<head>
    <title>Reference</title>
    <link rel="stylesheet" href="<?lua= docletsfhtml.link('luadoc.css', 'hooks.html')?>" type="text/css" />
	<!--meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/-->
</head>

<body>
<div id="container">

<div id="product">
	<div id="product_logo"></div>
	<div id="product_name"><big><b></b></big></div>
	<div id="product_description"></div>
</div> <!-- id="product" -->

<div id="main">

<div id="navigation">
<?lua=docletsfhtml.include("menu.lp", { doc=doc, hook_doc=hook_doc })?>

</div><!-- id="navigation" -->

<div id="content">

<h1>Hooks</h1>

<p>List of hooks available to SF scripts</p>

<h2>List</h2>
<table class="hook_list">
<?lua for _, hook_name in ipairs(hook_doc.hooks) do
	local hook_data = hook_doc.hooks[hook_name]?>
	<tr>
	<td class="name" nowrap><a href="#<?lua=hook_data.name?>"><?lua=hook_name?></a>&nbsp;(<?lua=table.concat(hook_data.param, ", ")?>)</td>
	<td class="summary"><?lua=hook_data.summary?></td>
	</tr>
<?lua end?>
</table>

<br/>
<br/>

<dl class="hook">
<?lua for _, hook_name in ipairs(hook_doc.hooks) do?>
	<?lua local hook = hook_doc.hooks[hook_name] ?>
	<dt><a name="<?lua=hook.name?>"></a><strong><?lua=hook.name?></strong>&nbsp;(<?lua=table.concat(hook.param, ", ")?>)</dt>
	<dd>
	<?lua=hook.description or ""?>

	<?lua if type(hook.param) == "table" and #hook.param > 0 then?>
	<h3>Parameters:</h3>
	<ul>
		<?lua for p = 1, #hook.param do?>
		<li>
		  <code><em><?lua=hook.param[p]?></em></code>: <?lua=hook.param[hook.param[p]] or ""?>
		</li>
		<?lua end?>
	</ul>
	<?lua end?>

	<?lua if type(hook.usage) == "string" then?>
	<h3>Usage:</h3>
	<ul><pre class=example><?lua=hook.usage?></pre></ul>
	<?lua elseif type(hook.usage) == "table" then?>
	<h3>Usage:</h3>
	<ul>
		<?lua for _, usage in ipairs(hook.usage) do?>
		<li><pre class=example><?lua= usage ?></pre></li>
		<?lua end?>
	</ul>
	<?lua end?>

	<?lua if type(hook.ret) == "string" then?>
	<h3>Return value:</h3>
	<ul><?lua=hook.ret?></ul>
	<?lua elseif type(hook.ret) == "table" then?>
	<h3>Return values:</h3>
	<ol>
		<?lua for _, ret in ipairs(hook.ret) do?>
		<li><?lua= ret ?></li>
		<?lua end?>
	</ol>
	<?lua end?>

	</dd>
<?lua end?>
</dl>

</div> <!-- id="content" -->

</div> <!-- id="main" -->

<div id="about">
	<p><a href="http://validator.w3.org/check?uri=referer"><img src="http://www.w3.org/Icons/valid-xhtml10" alt="Valid XHTML 1.0!" height="31" width="88" /></a></p>
</div> <!-- id="about" -->

</div> <!-- id="container" -->	
</body>
</html>
