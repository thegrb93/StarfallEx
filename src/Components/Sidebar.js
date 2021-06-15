import React, { useReducer } from 'react';
import logo from '../logo.png'
import Icon from "./Icon"
import Version from "./Version"
import {Link} from 'react-router-dom';
const _ = require('lodash');

function cloneState(state)
{
	const newState = _.cloneDeep(state);
	newState.flatMap = buildFlatMap(newState.items);
	assignPaths(newState.items);
	return newState;
}

function assignPaths(items, pathRoot="")
{
	for(const key in items)
	{
		const item = items[key];
		if(pathRoot !== "")
		{
			item.path = pathRoot + "." + item.name;
		}
		else{
			item.path = item.name;
		}
		if(item.children && item.children.length > 0)
		{
			assignPaths(item.children, item.path);
		}
	}
}

function buildFlatMap(items)
{
	let map = {};

	for(const key in items)
	{
		const item = items[key];
		map[item.path] = item;
		if(item.children && item.children.length > 0)
		{
			map = {...map, ...buildFlatMap(item.children)};
		}
	}
	return map;
}

function performSearch(item, text)
{
	let expanded = false;
	if(item.children && item.children.length > 0)
	{
		for(const key in item.children)
		{
			if(performSearch(item.children[key], text))
			{
				expanded = true;
			}
		}
	}
	expanded = expanded || item.path.toUpperCase().includes(text.toUpperCase());
	item.hidden = !expanded;
	item.collapsed = !expanded;
	if(text === "") item.collapsed = true;

	return expanded;
}

function unfoldPage(item, text)
{
	let expanded = false;
	if(item.children && item.children.length > 0)
	{
		for(const key in item.children)
		{
			if(unfoldPage(item.children[key], text))
			{
				expanded = true;
			}
		}
	}

	expanded = expanded || item.path.toUpperCase().includes(text.toUpperCase());
	item.collapsed = !(expanded || !item.collapsed);
	if(text === "") item.collapsed = true;

	return expanded;
}

function renderElements(items, dispatch, currentPage)
{
	const output = [];

	const sortedItems = items.sort((a,b)=>{
			const name1 = a.name.toUpperCase();
			const name2 = b.name.toUpperCase();
			if((a.type === "category" || a.type === "contributors") && (b.type === "category" || b.type === "contributors")) //Categories are equal, don't sort them by name, just leave add-order
			{
				return 0;
			}
			if(name1 < name2)
			{
				return -1;
			}
			else if(name1 > name2)
			{
				return 1;
			}
			return 0;
		});

	for(const item of sortedItems)
	{
		if(item.hidden) { continue; }
		output.push((
			<SidebarElement key={item.path} path={item.path} name={item.name} collapsed={item.collapsed} dispatch={dispatch} icon = {item.icon} iconType = {item.iconType} type = {item.type} selected={item.path.toLowerCase() === currentPage}>
				{
					items && items.length > 0 && renderElements(item.children, dispatch, currentPage)
				}
			</SidebarElement>
		));

	}
	return output;
}

export default function Sidebar(props)
{
	const initialState = {
		items: props.items,
		flatMap: buildFlatMap(props.items),
		searchText: "",
		curForcedUnfold: props.currentPage
	};
	function reducer(state, action)
	{
		let newState = cloneState(state);
		switch(action.type)
		{
			case "SEARCH":
				if(action.value.length>2 || action.value.length === 0) {
					for(const key in newState.items)
					{
						performSearch(newState.items[key], action.value);
					}
				}
				return {
					...newState,
					searchText: action.value
				};
			case "FORCE_UNFOLD":
				for(const key in newState.items)
				{
					unfoldPage(newState.items[key], action.value);
				}
				return {
					...newState,
					curForcedUnfold: action.value
				}

			case "TOGGLE_COLLAPSE":
				const path = action.value;
				newState.flatMap[path].collapsed = !newState.flatMap[path].collapsed;
				return newState;
			default:
				return state;
		
		}
	}

	assignPaths(initialState.items);

	const [state, dispatch] = useReducer(reducer, initialState);
	if(state.curForcedUnfold !== props.currentPage)
	{
		setTimeout(() => {
			dispatch({type: "FORCE_UNFOLD", value: props.currentPage});
		}, 1);
	}
	return (
		<div className = "sidebar">
			<div className="logo">
				<img alt="" src={logo} />
				<span className="text">
				StarfallEx
				</span>
			</div>
			<div className="search">
				<input placeholder="Search.." onChange={(ev) => dispatch({type: "SEARCH", value: ev.target.value})} value = {state.searchText} />
			</div>
			<div className = "sidebar-children">
				{ renderElements(state.items, dispatch, props.currentPage) }          
			</div>
			<Version />
		</div>
	)
}

function SidebarElement(props)
{
		const {collapsed, name, path, children, dispatch, icon, iconType, selected, type} = props;

		const hasChildren = children && children.length > 0;
		let linkElement = (
			<div className = {"name" + (selected ? " name-selected": "")} onClick = {() => dispatch({type:"TOGGLE_COLLAPSE", value: path})}>
			{name}
			</div>
		);
		if(!selected && type !== "category")
		{
			linkElement = (
				<Link to = {path} className="name">
						{name}
				</Link>
			);
		}

		return (
				<div className = "sidebar-item">
					<div className="sidebar-item-content">
						{
							hasChildren ?
							(
								<div className = {"collapse " + (collapsed ? "collapsed" : "expanded")} onClick = {() => dispatch({type:"TOGGLE_COLLAPSE", value: path})}>
									<span>{collapsed ? "-" : "+"}</span>
								</div>
							)
							:
							(
								<div className = "collapse-placeholder"></div>
							)
						}
						<Icon type={iconType} value={icon} />
						{linkElement}
					</div>
					{!collapsed && hasChildren &&
					(
						<div className = "sidebar-item-children">
							{children}
						</div>
					)}
				</div>

		);
}