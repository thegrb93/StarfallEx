<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
   "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
<head>
    <title>Reference</title>
    <link rel="stylesheet" href="<?lua=docletsfhtml.link( 'luadoc.css', 'classes/' .. class_doc.name )?>" type="text/css" />
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
<?lua=docletsfhtml.include( "menu.lp", { doc=doc, class_doc=class_doc } )?>

</div><!-- id="navigation" -->

<div id="content">

<h1>Type <code><?lua=class_doc.name?></code></h1>

<p><?lua=class_doc.description?></p>
<?lua=class_doc.deprecated and "<strong><font color=red>This type has been deprecated and will be removed in the future for the following reason:</font> " .. class_doc.deprecated .. "</strong>" or ""?>
<?lua if class_doc.copyright then?>
<p>Copyright &copy; <?lua=class_doc.copyright?></p>
<?lua end?>
<?lua if class_doc.author then?>
<p><b><?lua= #class_doc.author > 1 and "Authors" or "Author" ?>:</b>
<table class="authors_list">
<?lua for _, author in ipairs( class_doc.author ) do?>
	<tr><td class="name"><?lua= author ?></td></tr>
<?lua end?>
</table>
</p>
<?lua end?>

<?lua if class_doc.release then?>
<p><b>Release:</b> <?lua=class_doc.release?>
</p>
<?lua end?>

<?lua if #class_doc.methods > 0 then?>
<h2>Methods</h2>
<table class="function_list">
<?lua for _, method_name in ipairs( class_doc.methods ) do
  local method_data = class_doc.methods[ method_name ]?>
	<tr>
		<td class="name" nowrap><span class="realm_<?lua=method_data.realm?>">&nbsp;</span><?lua=method_data.deprecated and "<del>" or ""?><?lua=method_data.private and "local " or ""?><a href="#<?lua=method_data.name?>"><?lua=method_name?></a>&nbsp;(<?lua=table.concat( class_doc.methods[ method_name ].param, ", " )?>)<?lua=method_data.deprecated and "</del>" or ""?></td>
		<td class="summary"><?lua=class_doc.methods[ method_name ].summary?></td>
	</tr>
<?lua end?>
</table>
<?lua end?>


<br/>
<br/>

<?lua if #class_doc.methods > 0 then?>
<h2><a name="methods"></a>Methods</h2>
<dl class="function">
<?lua for _, method_name in ipairs( class_doc.methods ) do?>
<?lua=docletsfhtml.include( "function.lp", { doc=doc, module_doc=class_doc, func=class_doc.methods[method_name] } )?>
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
