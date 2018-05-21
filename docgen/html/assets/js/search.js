window.addEventListener('load', function () {
	var searchTable = null;

	function downloadJson() {
		var xhttp = new XMLHttpRequest();
		xhttp.onreadystatechange = function () {
			if (this.readyState == 4 && this.status == 200) {
				searchTable = JSON.parse(this.responseText);
				search()
			}
		};
		xhttp.open("GET", fromPath + "doc.json", true);
		xhttp.send();
	}

	downloadJson();

	var searchBox = document.getElementById("search_field");
	searchBox.oninput = search;

	var commonIndex = document.getElementById("common_index");
	var searchIndex = document.getElementById("search_index");

	function search() {
		if (searchTable == null) return;
		if (searchBox.value.length == 0) {
			commonIndex.style.display = "block";
			searchIndex.style.display = "none";
		}
		else {
			commonIndex.style.display = "none";
			searchIndex.style.display = "block";
			update(searchBox.value);
		}
	}

	var searchFunctionsUl = document.getElementById("search_functions");
	var searchMethodsUl = document.getElementById("search_methods");
	var searchHooksUl = document.getElementById("search_hooks");

	function update(phrase) {
		phrase = phrase.toLowerCase();

		// Libraries

		var functionsHtml = "";

		for (var library in searchTable.libraries) {
			var libTable = searchTable.libraries[library];
			if (libTable.functions) var entireLib = libTable.name.toLowerCase().indexOf(phrase) != -1;
			for (var funcId in libTable.functions) {
				if (typeof libTable.functions[funcId] == "string" &&
					(entireLib || libTable.functions[funcId].toLowerCase().indexOf(phrase) != -1)) {
					var name = libTable.functions[funcId];

					var funcTable = libTable.functions[name];
					var realm = funcTable.realm;

					functionsHtml +=
						'<li><span class="realm_' + realm +
						'">&nbsp;</span><a href="' + fromPath + 'libraries/' + library + '.html#' + library + '.' + (funcTable.fname||funcTable.name) + '">' +
						(library == "builtin" ? "" : library + '.') + name + '</a></li>';
				}
			}
		}

		searchFunctionsUl.innerHTML = functionsHtml;

		// Methods

		var methodsHtml = "";

		for (var className in searchTable.classes) {
			var classTable = searchTable.classes[className];

			if (classTable.methods)
				var entireClass = classTable.name.toLowerCase().indexOf(phrase) != -1;

			for (var funcId in classTable.methods) {
				if (typeof classTable.methods[funcId] == "string" &&
					(entireClass || classTable.methods[funcId].toLowerCase().indexOf(phrase) != -1)) {
					var name = classTable.methods[funcId];

					var funcTable = classTable.methods[name];
					var realm = funcTable.realm;

					methodsHtml +=
						'<li><span class="realm_' + realm +
						'">&nbsp;</span><a href="' + fromPath + 'classes/' + className + '.html#' + className + ':' + name + '">' +
						className + ':' + name + '</a></li>';
				}
			}
		}

		searchMethodsUl.innerHTML = methodsHtml;

		// Hooks

		var hooksHtml = "";

		for (var hookId in searchTable.hooks) {
			if (typeof searchTable.hooks[hookId] == "string" && searchTable.hooks[hookId].toLowerCase().indexOf(phrase) != -1) {
				var name = searchTable.hooks[hookId];

				var hookTable = searchTable.hooks[name];
				var realm = hookTable.realm;

				hooksHtml +=
					'<li><span class="realm_' + realm +
					'">&nbsp;</span><a href="' + fromPath + 'hooks.html#' + hookTable.name + '">' + name + '</a></li>';
			}
		}

		searchHooksUl.innerHTML = hooksHtml;
	}
});
