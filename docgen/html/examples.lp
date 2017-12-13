<?lua=docletsfhtml.include("_before_main.lp", { doc = doc, example_doc = example_doc })?>
<h1><?lua=example_doc.name?></h1>
<section>
	<h2>SF code</h2>
	<code><?lua=example_doc.code?></code>
</section>
<?lua=docletsfhtml.include("_after_main.lp", { doc = doc })?>