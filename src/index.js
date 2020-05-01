import 'react-app-polyfill/ie9';
import React from 'react';
import ReactDOM from 'react-dom';
import './themes.scss';
import App from './App';
import * as serviceWorker from './serviceWorker';

let sidebarItems = [];
let pages = {};

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
            collapsed: false,
            iconType: iconType,
            icon: icon,
            hidden: false,
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
        this.AddPage("Libraries", "category", "", "", {}, "");
        this.AddPage("Types", "category", "", "", {}, "");
        this.AddPage("Hooks", "category", "", "", {}, "");

        for (const libkey in DocTable.Libraries) {
            const lib = DocTable.Libraries[libkey];

            var libData = {
                name: lib.name,
                realm: lib.realm,
                description: lib.description,
                methods: []
            };

            for (const methodkey in lib.methods) {
                const method = lib.methods[methodkey];
                libData.methods[method.name] = method.description;
            }

            this.AddPage(lib.name, "library", "realm", lib.realm, libData, "Libraries");

            const path = "Libraries."+lib.name
            for (const methodkey in lib.methods) {
                const method = lib.methods[methodkey];
                this.AddPage(method.name, "method", "realm", method.realm, {}, path);
            }
        }

        for (const hookkey in DocTable.Hooks) {
            const hook = DocTable.Hooks[hookkey];
            this.AddPage(hook.name, "hook", "realm", hook.realm, {}, "Hooks");
        }

        for (const typekey in DocTable.Types) {
            const t = DocTable.Types[typekey];
            this.AddPage(t.name, "type", "realm", t.realm, {}, "Types");
        }

        this.FinishSetup();
    },
    FinishSetup: () =>
    {
        ReactDOM.render(<App sidebarItems = {sidebarItems} pages={pages} />, document.getElementById("root"));
    }
}

var xmlhttp = new XMLHttpRequest();
xmlhttp.onreadystatechange = function() {
  if (this.readyState == 4 && this.status == 200) {
    SF_DOC.BuildPages(JSON.parse(this.responseText));
  }
};
xmlhttp.open("GET", "sf_docs.json", true);
xmlhttp.send();

window.SF_DOC = SF_DOC;

// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
serviceWorker.unregister();
