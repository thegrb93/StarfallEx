<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
   "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
<head>
    <title>Reference</title>
    <link rel="stylesheet" href="<?lua=docletsfhtml.link('luadoc.css', 'files/'..file_doc.name)?>" type="text/css" />
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
<?lua=docletsfhtml.include("menu.lp", { doc=doc, file_doc=file_doc })?>

</div> <!-- id="navigation" -->

<div id="content">

<h1>File <code><?lua=file_doc.name?></code></h1>

<?lua if file_doc.description then?>
<p><?lua=file_doc.description?></p>
<?lua end?>
<?lua if file_doc.author then?>
<p><b><?lua= #file_doc.author>1 and "Authors" or "Author" ?>:</b>
<table class="authors_list">
<?lua for _, author in ipairs(file_doc.author) do?>
	<tr><td class="name"><?lua= author ?></td></tr>
<?lua end?>
</table>
</p>
<?lua end?>
<?lua if file_doc.copyright then?>
<p>Copyright &copy;<?lua=file_doc.copyright?></p>
<?lua end?>
<?lua if file_doc.release then?>
<p><small><b>Release:</b> <?lua=file_doc.release?></small></p>
<?lua end?>

<?lua if #file_doc.functions > 0 then?>
<h2>Functions</h2>
<table class="function_list">
<?lua for _, func_name in ipairs(file_doc.functions) do
  local func_data = file_doc.functions[func_name]?>
	<tr>
	<td class="name" nowrap><?lua=func_data.deprecated and "<del>" or ""?><?lua=func_data.private and "local " or ""?><a href="#<?lua=func_name?>"><?lua=func_name?></a>&nbsp;(<?lua=table.concat(func_data.param, ", ")?>)<?lua=func_data.deprecated and "</del>" or ""?></td>
	<td class="summary"><?lua=func_data.summary?></td>
	</tr>
<?lua end?>
</table>
<?lua end?>


<?lua if #file_doc.tables > 0 then?>
<h2>Tables</h2>
<table class="table_list">
<?lua for _, tab_name in ipairs(file_doc.tables) do?>
	<tr>
	<td class="name" nowrap><a href="#<?lua=tab_name?>"><?lua=tab_name?></a></td>
	<td class="summary"><?lua=file_doc.tables[tab_name].summary?></td>
	</tr>
<?lua end?>
</table>
<?lua end?>


<br/>
<br/>



<?lua if #file_doc.functions > 0 then?>
<h2><a name="functions"></a>Functions</h2>
<dl class="function">
<?lua for _, func_name in ipairs(file_doc.functions) do?>
<?lua=docletsfhtml.include("function.lp", { doc=doc, file_doc=file_doc, func=file_doc.functions[func_name] })?>
<?lua end?>
</dl>
<?lua end?>


<?lua if #file_doc.tables > 0 then?>
<h2><a name="tables"></a>Tables</h2>
<dl class="table">
<?lua for _, tab_name in ipairs(file_doc.tables) do?>
<?lua=docletsfhtml.include("table.lp", { doc=doc, file_doc=file_doc, tab=file_doc.tables[tab_name] })?>
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
