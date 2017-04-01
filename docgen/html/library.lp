<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
   "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
<head>
    <title>Reference</title>
    <link rel="stylesheet" href="<?lua= docletsfhtml.link('luadoc.css', 'libraries/'..module_doc.name)?>" type="text/css" />
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
<?lua=docletsfhtml.include("menu.lp", { doc=doc, module_doc=module_doc })?>

</div><!-- id="navigation" -->

<div id="content">

<h1>Library <code><?lua=module_doc.name?></code></h1>

<p><?lua=module_doc.description?></p>
<?lua=module_doc.deprecated and "<strong><font color=red>This library has been deprecated and will be removed in the future for the following reason:</font> " .. module_doc.deprecated .. "</strong>" or ""?>
<?lua if module_doc.copyright then?>
<p>Copyright &copy; <?lua=module_doc.copyright?></p>
<?lua end?>
<?lua if module_doc.author then?>
<p><b><?lua= #module_doc.author>1 and "Authors" or "Author" ?>:</b>
<table class="authors_list">
<?lua for _, author in ipairs(module_doc.author) do?>
	<tr><td class="name"><?lua= author ?></td></tr>
<?lua end?>
</table>
</p>
<?lua end?>

<?lua if module_doc.release then?>
<p><b>Release:</b> <?lua=module_doc.release?>
</p>
<?lua end?>

<?lua if #module_doc.functions > 0 then?>
<h2>Functions</h2>
<table class="function_list">
<?lua for _, func_name in ipairs(module_doc.functions) do
  local func_data = module_doc.functions[func_name]?>
	<tr>
	<td class="name" nowrap><span class="realm_<?lua=func_data.realm?>">&nbsp;</span><?lua=func_data.deprecated and "<del>" or ""?><?lua=func_data.private and "local " or ""?><a href="#<?lua=func_data.name?>"><?lua=func_name?></a>&nbsp;(<?lua=table.concat(module_doc.functions[func_name].param, ", ")?>)<?lua=func_data.deprecated and "</del>" or ""?></td>
	<td class="summary"><?lua=module_doc.functions[func_name].summary?></td>
	</tr>
<?lua end?>
</table>
<?lua end?>

<?lua if module_doc.tables and #module_doc.tables > 0 then?>
<h2>Tables</h2>
<table class="table_list">
<?lua for _, tab_name in ipairs(module_doc.tables) do
	local tab_data = module_doc.tables[tab_name]?>
	<tr>
	<td class="name" nowrap><a href="#<?lua=tab_data.name?>"><?lua=tab_name?></a></td>
	<td class="summary"><?lua=module_doc.tables[tab_name].summary?></td>
	</tr>
<?lua end?>
</table>
<?lua end?>

<?lua if module_doc.fields and #module_doc.fields > 0 then?>
<h2>Fields</h2>
<table class="table_list">
<?lua for _, field_name in ipairs(module_doc.fields) do
	local field_data = module_doc.fields[field_name]?>
	<tr>
	<td class="name" nowrap><a href="#<?lua=field_data.name?>"><?lua=field_name?></a></td>
	<td class="summary"><?lua=module_doc.fields[field_name].summary?></td>
	</tr>
<?lua end?>
</table>
<?lua end?>


<br/>
<br/>


<?lua if #module_doc.functions > 0 then?>
<h2><a name="functions"></a>Functions</h2>
<dl class="function">
<?lua for _, func_name in ipairs(module_doc.functions) do?>
<?lua=docletsfhtml.include("function.lp", { doc=doc, module_doc=module_doc, func=module_doc.functions[func_name] })?>
<?lua end?>
</dl>
<?lua end?>


<?lua if module_doc.tables and #module_doc.tables > 0 then?>
<h2><a name="tables"></a>Tables</h2>
<dl class="table">
<?lua for _, tab_name in ipairs(module_doc.tables) do?>
<?lua=docletsfhtml.include("table.lp", { doc=doc, module_doc=module_doc, tab=module_doc.tables[tab_name] })?>
<?lua end?>
</dl>
<?lua end?>


</div> <!-- id="content" -->

</div> <!-- id="main" -->

<div id="about">
	<p><a href="http://validator.w3.org/check?uri=referer"><img src="http://www.w3.org/Icons/valid-xhtml10" alt="Valid XHTML 1.0!" height="31" width="88" /></a></p>
</div> <!-- id="about" -->

</div> <!-- id="container" -->	
</body>
</html>
