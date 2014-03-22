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

<h1>Preprocessor directives</h1>

<p>List of preprocessor directives</p>

<h2>List</h2>
<table class="hook_list">
<?lua for _, dir_name in ipairs(dir_doc.directives) do
	local dir_data = dir_doc.directives[dir_name]?>
	<tr>
	<td class="name" nowrap><a href="#<?lua=dir_data.name?>">--@<?lua=dir_name?></a>&nbsp;<?lua=table.concat(dir_data.param, ", ")?></td>
	<td class="summary"><?lua=dir_data.summary?></td>
	</tr>
<?lua end?>
</table>

<br/>
<br/>

<dl class="hook">
<?lua for _, dir_name in ipairs(dir_doc.directives) do?>
	<?lua local dir = dir_doc.directives[dir_name] ?>
	<dt><a name="<?lua=dir.name?>"></a><strong>--@<?lua=dir.name?></strong>&nbsp;<?lua=table.concat(dir.param, ", ")?></dt>
	<dd>
	<?lua=dir.description or ""?>

	<?lua if type( dir.param ) == "table" and #dir.param > 0 then?>
	<h3>Parameters:</h3>
	<ul>
		<li>
			<code><em><?lua=dir.param[1]?></em></code>: <?lua=dir.param[dir.param[1]] or ""?>
		</li>
	</ul>
	<?lua end?>

	<?lua if type(dir.usage) == "string" then?>
	<h3>Usage:</h3>
	<ul><pre class=example><?lua=dir.usage?></pre></ul>
	<?lua elseif type(dir.usage) == "table" then?>
	<h3>Usage:</h3>
	<ul>
		<?lua for _, usage in ipairs(dir.usage) do?>
		<li><pre class=example><?lua= usage ?></pre></li>
		<?lua end?>
	</ul>
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
