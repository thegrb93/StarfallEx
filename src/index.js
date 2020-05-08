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

if (!String.prototype.includes) {
  String.prototype.includes = function(search, start) {
    'use strict';

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
        if(parent!=="")
        {
            parent = "." + parent;
        }
        const path = parent + "." + name;
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
        pages[path] = page;

        if(parent !== "")
        {
            pages[parent].sidebarItem.children.push(sidebarItem);
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

        for (const [_, lib] of Object.entries(DocTable.Libraries)) {

            let libData = {
                name: lib.name,
                realm: lib.realm,
                description: lib.description,
                methods: [],
                tables: []
            };

            for (const [_, method] of Object.entries(lib.methods)) {
                libData.methods[method.name] = method.description;
            }

            for (const [_, table] of Object.entries(lib.tables)) {
                libData.tables[table.name] = table.description;
            }

            SF_DOC.AddPage(lib.name, "library", "realm", lib.realm, libData, "Libraries");

            const path = "Libraries."+lib.name
            for (const [_, method] of Object.entries(lib.methods)) {
                let methodData = {
                    name: method.name,
                    description: method.description,
                    realm: method.realm,
                    description: method.description,
                    parameters: method.params ?? [],
                    returns: method.returns ?? [],
                    parent: lib.name,
                    type: "library",
                }
                SF_DOC.AddPage(method.name, "method", "method-realm", method.realm, methodData, path);
            }

            for (const [_, table] of Object.entries(lib.tables)) {
                let tableData = {
                    name: table.name,
                    description: table.description,
                    realm: table.realm,
                    description: table.description,
                    fields: table.fields ?? [],
                    parent: lib.name,
                    type: "table",
                }
                SF_DOC.AddPage(table.name, "table", "table-realm", table.realm, tableData, path);
            }
        }

        for (const [_, hook] of Object.entries(DocTable.Hooks)) {
            let hookData = {
                name: hook.name,
                description: hook.description,
                realm: hook.realm,
                description: hook.description,
                parameters: hook.params ?? [],
                returns: hook.returns ?? []
            }
            SF_DOC.AddPage(hook.name, "hook", "realm", hook.realm, hookData, "Hooks");
        }

        for (const [_, directive] of Object.entries(DocTable.Directives)) {
            SF_DOC.AddPage(directive.name, "markdown", "letter", "@", {
                title: "--@"+directive.name,
                content: directive.description
            }, "Directives");
        }
        for (const [_, t] of Object.entries(DocTable.Types)) {
            let typeData = {
                name: t.name,
                realm: t.realm,
                description: t.description,
                methods: []
            }

            for (const [_, method] of Object.entries(t.methods)) {
                typeData.methods[method.name] = method.description;
            }
            
            SF_DOC.AddPage(t.name, "type", "realm", t.realm, typeData, "Types");

            const path = "Types."+t.name
            for (const [_, method] of Object.entries(t.methods)) {
                let methodData = {
                    name: method.name,
                    description: method.description,
                    realm: method.realm,
                    description: method.description,
                    parameters: method.params ?? [],
                    returns: method.returns ?? [],
                    parent: t.name,
                    type: "type",
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
  }
};
xmlhttp.open("GET", "sf_doc.json", true);
xmlhttp.send();

window.SF_DOC = SF_DOC;

// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
serviceWorker.unregister();
