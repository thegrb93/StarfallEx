<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
   "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
<head>
    <title>Reference</title>
    <link rel="stylesheet" href="<?lua=docletsfhtml.link("luadoc.css")?>" type="text/css" />
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
<?lua=docletsfhtml.include("menu.lp", { doc=doc })?>

</div> <!-- id="navigation" -->

<div id="content">


<?lua if not options.nomodules and #doc.libraries > 0 then?>
<h2>Libraries</h2>
<table class="module_list">
<!--<tr><td colspan="2">Modules</td></tr>-->
<?lua for _, modulename in ipairs(doc.libraries) do?>
	<tr>
		<td class="name"><a href="<?lua=docletsfhtml.module_link(modulename, doc)?>"><?lua=modulename?></a></td>
		<td class="summary"><?lua=doc.libraries[modulename].summary?></td>
	</tr>
<?lua end?>
</table>
<?lua end?>

<h2>Hooks</h2>
<table class="hook_list">
<?lua for _, hookname in ipairs(doc.hooks) do?>
	<tr>
		<td class="name"><a href="<?lua=docletsfhtml.hook_link(hookname, doc)?>"><?lua=hookname?></a></td>
		<td class="summary"><?lua=doc.hooks[hookname].summary?></td>
	</tr>
<?lua end?>
</table>

<?lua if not options.nofiles and #doc.files > 0 then?>
<h2>Files</h2>
<table class="file_list">
<!--<tr><td colspan="2">Files</td></tr>-->
<?lua for _, filepath in ipairs(doc.files) do?>
	<tr>
		<td class="name"><a href="<?lua=docletsfhtml.file_link(filepath)?>"><?lua=filepath?></a></td>
		<td class="summary"></td>
	</tr>
<?lua end?>
</table>
<?lua end?>

</div> <!-- id="content" -->

</div> <!-- id="main" -->

<div id="about">
	<p><a href="http://validator.w3.org/check?uri=referer"><img src="http://www.w3.org/Icons/valid-xhtml10" alt="Valid XHTML 1.0!" height="31" width="88" /></a></p>
</div> <!-- id="about" -->

</div> <!-- id="container" -->	
</body>
</html>
