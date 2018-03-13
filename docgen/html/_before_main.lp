<?lua
from = ""
pageTitle = "StarfallEx Reference"
pageTitleSign = " :: " .. pageTitle
if module_doc then
	from = "libraries/" .. module_doc.name
	pageTitle = "Library " .. module_doc.name .. pageTitleSign
elseif hook_doc then
	from = "hooks.html"
	pageTitle = "Hooks" .. pageTitleSign
elseif class_doc then
	from = "classes/.." .. class_doc.name
	pageTitle = class_doc.name .. pageTitleSign
elseif example_doc then
	from = "examples/.." .. example_doc.name
	pageTitle = example_doc.name .. pageTitleSign
end
?>

<!DOCTYPE html>
<html>
	<head>
		<title><?lua=pageTitle?></title>
		<link rel="stylesheet" href="<?lua=docletsfhtml.link("assets/stylesheet.css", from)?>" type="text/css">
		<script> fromPath = "<?lua=docletsfhtml.link("", from)?>"; </script>
		<script src="<?lua=docletsfhtml.link("assets/js/common.js", from)?>"></script>
		<script src="<?lua=docletsfhtml.link("assets/js/search.js", from)?>"></script>
	</head>
	<body>
		<nav>
			<section>
				<h1>StarfallEx Reference</h1>
				<ul>
					<li><a href="<?lua=docletsfhtml.link("index.html", from)?>">Home</a></li>
				</ul>
			</section>
			<section id="search">
				<input type="search" id="search_field" placeholder="Search...">
			</section>
			<section id="common_index">
				<section>
					<h1>Libraries</h1>
					<ul>
						<?lua 
						for _, name in ipairs(doc.libraries) do
							local link = not module_doc or module_doc.name ~= name?>
						<li><a<?lua if link then?> href="<?lua=docletsfhtml.module_link(name, doc, from)?>"<?lua end?>><?lua if doc.libraries[name].deprecated then?><del><?lua end?><?lua=name?><?lua if doc.libraries[name].deprecated then?></del><?lua end?></a></li><?lua end?>
					</ul>
				</section>
				<section>
					<h1>Types</h1>
					<ul>
						<?lua for _, name in ipairs(doc.classes) do
							local link = not class_doc or class_doc.name ~= name?>
						<li><a<?lua if link then?> href="<?lua=docletsfhtml.class_link(name, doc, from)?>"<?lua end?>><?lua if doc.classes[name].deprecated then?><del><?lua end?><?lua=name?><?lua if doc.classes[name].deprecated then?></del><?lua end?></a></li><?lua end?>
					</ul>
				</section>
				<section>
					<h1>Hooks</h1>
					<ul>
						<?lua for _, name in ipairs(doc.hooks) do?>
						<li><span class="realm_<?lua=doc.hooks[name].realm?>"></span><a href="<?lua=docletsfhtml.hook_link(name, doc, from)?>"><?lua=name?></a></li><?lua end?>
					</ul>
				</section>
				<section>
					<h1>Preprocessor directives</h1>
					<ul>
						<?lua for _, name in ipairs(doc.directives) do?>
						<li><a href="<?lua=docletsfhtml.directive_link(name, doc, from)?>">--@<?lua=name?></a></li><?lua end?>
					</ul>
				</section>
			</section>
			<section id="search_index" style="display: none;">
				<section>
					<h1>Functions</h1>
					<ul id="search_functions">
						
					</ul>
				</section>
				<section>
					<h1>Methods</h1>
					<ul id="search_methods">
						
					</ul>
				</section>
				<section>
					<h1>Hooks</h1>
					<ul id="search_hooks">
						
					</ul>
				</section>
			</section>
		</nav>
		<main>
