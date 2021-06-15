import 'react-app-polyfill/ie9';
import React from 'react';
import ReactDOM from 'react-dom';
import './themes.scss';
import App from './App';
import * as serviceWorker from './serviceWorker';

let sidebarItems = [];
let pages = {};

if (!Object.entries) {
  Object.entries = function( obj ){
	var ownProps = Object.keys( obj ),
		i = ownProps.length,
		resArray = new Array(i); // preallocate the Array
	while (i--)
	  resArray[i] = [ownProps[i], obj[ownProps[i]]];

	return resArray;
  };
}

// Internet Explorer fix I guess
if (!String.prototype.includes) {
	String.prototype.includes = function(search, start) {
		if (search instanceof RegExp) {
			throw TypeError('first argument must not be a RegExp');
		}
		if (start === undefined) { start = 0; }
		return this.indexOf(search, start) !== -1;
	};
}

const SF_DOC = {
	AddPage: (name, type, iconType, icon, data, parent = "") =>
	{
		let path = name;
		if(parent !== "")
		{
			path = parent + "." + name;
		}

		data._path = path;
		data._children = [];
		data._class = type;

		const sidebarItem = {
			name: name,
			collapsed: true,
			iconType: iconType,
			icon: icon,
			hidden: false,
			type: type,
			children: []
		}
		const page = {
			name: name,
			type: type,
			data: data,
			sidebarItem: sidebarItem,
			path: path,
			class: type
		}
		pages[path.toLowerCase()] = page;

		if(parent !== "")
		{
			pages[parent.toLowerCase()].data._children.push(data);
			pages[parent.toLowerCase()].sidebarItem.children.push(sidebarItem);
		}
		else
		{
			sidebarItems.push(sidebarItem);
		}

	},
	BuildPages: (DocTable) =>
	{
		SF_DOC.AddPage("Libraries", "category", "", "", {}, "");
		SF_DOC.AddPage("Types", "category", "", "", {}, "");
		SF_DOC.AddPage("Hooks", "category", "", "", {}, "");
		SF_DOC.AddPage("Directives", "category", "", "", {}, "");
		SF_DOC.AddPage("Contributors", "contributors", "letter-simple", "🌟", {}, "");

		for (const [, lib] of Object.entries(DocTable.Libraries)) {

			let libData = {
				name: lib.name,
				realm: lib.realm,
				description: lib.description,
				ghpath: lib.path,
			};

			SF_DOC.AddPage(lib.name, "library", "realm", lib.realm, libData, "Libraries");

			const path = "Libraries."+lib.name
			for (const [, method] of Object.entries(lib.methods)) {
				let methodData = {
					name: method.name,
					description: method.description,
					realm: method.realm,
					parameters: method.params ?? [],
					returns: method.returns ?? [],
					parent: lib.name,
					ghpath: method.path,
					type: "library",
				}
				SF_DOC.AddPage(method.name, "method", "method-realm", method.realm, methodData, path);
			}

			for (const [, table] of Object.entries(lib.tables)) {
				let tableData = {
					name: table.name,
					description: table.description,
					realm: table.realm,
					fields: table.fields ?? [],
					parent: lib.name,
					ghpath: table.path,
					type: "table",
				}
				SF_DOC.AddPage(table.name, "table", "table-realm", table.realm, tableData, path);
			}
		}

		for (const [, hook] of Object.entries(DocTable.Hooks)) {
			let hookData = {
				name: hook.name,
				description: hook.description,
				realm: hook.realm,
				parameters: hook.params ?? [],
				returns: hook.returns ?? [],
				ghpath: hook.path,
			}
			SF_DOC.AddPage(hook.name, "hook", "realm", hook.realm, hookData, "Hooks");
		}

		for (const [, directive] of Object.entries(DocTable.Directives)) {
			SF_DOC.AddPage(directive.name, "markdown", "letter", "@", {
				title: "--@"+directive.name,
				content: directive.description
			}, "Directives");
		}
		for (const [, t] of Object.entries(DocTable.Types)) {
			let typeData = {
				name: t.name,
				realm: t.realm,
				description: t.description,
				ghpath: t.path,
			}

			SF_DOC.AddPage(t.name, "type", "realm", t.realm, typeData, "Types");

			const path = "Types."+t.name
			for (const [, method] of Object.entries(t.methods)) {
				let methodData = {
					name: method.name,
					description: method.description,
					realm: method.realm,
					parameters: method.params ?? [],
					returns: method.returns ?? [],
					parent: t.name,
					type: "type",
					ghpath: method.path,
				}
				SF_DOC.AddPage(method.name, "method", "realm", method.realm, methodData, path);
			}
		}

		SF_DOC.FinishSetup();
	},
	FinishSetup: () =>
	{
		ReactDOM.render(<App sidebarItems = {sidebarItems} pages={pages} />, document.getElementById("root"));
	}
}

var xmlhttp = new XMLHttpRequest();
xmlhttp.onreadystatechange = function() {
	if (this.readyState === 4 && this.status === 200) {
		let json = JSON.parse(this.responseText);

		window.SFVersion = json.Version;

		SF_DOC.BuildPages(json);
	} else {
		console.log("Couldn't find sf_doc.json!");
	}
};
xmlhttp.open("GET", "sf_doc.json", true);
xmlhttp.send();

window.SF_DOC = SF_DOC;

// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
serviceWorker.unregister();
