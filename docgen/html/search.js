window.onload = function () {
	var jsonDoc = null;

	function downloadJson() {
		var xhttp = new XMLHttpRequest();
		xhttp.onreadystatechange = function () {
			if (this.readyState == 4 && this.status == 200) {
				jsonDoc = JSON.parse(this.responseText);
				onkeyup()
			}
		};
		xhttp.open("GET", fromPath+"doc.json", true);
		xhttp.send();
	}

	downloadJson();

	var searchBox = document.getElementById("search");
	searchBox.onkeyup = onkeyup;

	var defaultIndex = document.getElementById("default_index");
	var searchResultsDiv = document.getElementById("search_results");

	function onkeyup() {
		if (jsonDoc == null)
			return;

		if (searchBox.value.length == 0) {
			defaultIndex.style.display = "block";
			searchResultsDiv.style.display = "none";
			return;
		}

		defaultIndex.style.display = "none";
		searchResultsDiv.style.display = "block";

		update(searchBox.value);
	}

	var searchFunctionsUl = document.getElementById("search_functions");
	var searchMethodsUl = document.getElementById("search_methods");
	var searchHooksUl = document.getElementById("search_hooks");

	function update(phrase) {
		phrase = phrase.toLowerCase();

		// Libraries

		var functionsHtml = "";

		for (var library in jsonDoc.libraries) {
			var libTable = jsonDoc.libraries[library];

			if (libTable.functions)
				var entireLib = libTable.name.toLowerCase().indexOf(phrase) != -1;

			for (var funcId in libTable.functions) {
				if (typeof libTable.functions[funcId] == "string" &&
					(entireLib || libTable.functions[funcId].toLowerCase().indexOf(phrase) != -1)) {
					var name = libTable.functions[funcId];

					var funcTable = libTable.functions[name];
					var realm = funcTable.realm;

					functionsHtml +=
						'<li><span class="realm_' + realm +
						'">&nbsp;</span><a href="' + fromPath + 'libraries/' + library + '.html#' + funcTable.name + '">' +
						(library == "builtin" ? "" : library + '.') + name + '</a></li>';
				}
			}
		}

		searchFunctionsUl.innerHTML = functionsHtml;

		// Methods

		var methodsHtml = "";

		for (var className in jsonDoc.classes) {
			var classTable = jsonDoc.classes[className];

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
						'">&nbsp;</span><a href="' + fromPath + 'classes/' + className + '.html#' + funcTable.name + '">' +
						className + ':' + name + '</a></li>';
				}
			}
		}

		searchMethodsUl.innerHTML = methodsHtml;

		// Hooks

		var hooksHtml = "";

		for (var hookId in jsonDoc.hooks) {
			if (typeof jsonDoc.hooks[hookId] == "string" && jsonDoc.hooks[hookId].toLowerCase().indexOf(phrase) != -1) {
				var name = jsonDoc.hooks[hookId];

				var hookTable = jsonDoc.hooks[name];
				var realm = hookTable.realm;

				hooksHtml +=
					'<li><span class="realm_' + realm +
					'">&nbsp;</span><a href="' + fromPath + 'hooks.html#' + hookTable.name + '">' + name + '</a></li>';
			}
		}

		searchHooksUl.innerHTML = hooksHtml;
	}
}