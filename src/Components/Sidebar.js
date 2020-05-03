import React, { useReducer, useEffect } from 'react';
import logo from '../logo.png'
import Icon from "./Icon"
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
    item.path = pathRoot + "." + item.name;
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
  if(text == "")
  {
    item.collapsed = true;
  }

  return expanded;
}

function renderElements(items, dispatch, currentPage)
{
  const output = [];

  const sortedItems = items.sort((a,b)=>{
    const name1 = a.name.toUpperCase();
    const name2 = b.name.toUpperCase();

    if(name1 < name2)
    {
      return -1;
    }
    else if(name1 > name2)
    {
      return 1;
    }
    return 0;
  }) 

  for(const item of sortedItems)
  {
    if(item.hidden) { continue; }
    output.push((
      <SidebarElement key={item.path} path={item.path} name={item.name} collapsed={item.collapsed} dispatch={dispatch} icon = {item.icon} iconType = {item.iconType} selected={item.path === currentPage}>
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
    searchText: ""
  };
  function reducer(state, action)
  {
    console.log("ACTION", action);
    let newState = cloneState(state);
    switch(action.type)
    {
      case "SEARCH":
        for(const key in newState.items)
        {
          performSearch(newState.items[key], action.value);
        }
        return {
          ...newState,
          searchText: action.value
        };
      case "TOGGLE_COLLAPSE":
        const path = action.value;
        newState.flatMap[path].collapsed = !newState.flatMap[path].collapsed;
        return newState;
      case "CHANGE_PAGE":
        if(action.value === props.currentPage) //For some reason it can be called twice?
        {
          return state;
        }
        props.changePage(action.value);
        return state;
      default:
        return state;
    
    }
  }

  assignPaths(initialState.items);

  const [state, dispatch] = useReducer(reducer, initialState);

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
      <div className = "version">
          <span className="version-label">Version:</span>
          <span className="version-text">StarfallEx_Sevi&amp;NameBestShip</span>
          <span className="updates-check">(Check for updates)</span>
      </div>
    </div>
  )
}

function SidebarElement(props)
{
    const {collapsed, name, path, children, dispatch, icon, iconType, selected} = props;

    const hasChildren = children && children.length > 0;

    return (
        <div className = "sidebar-item">
          <div className="sidebar-item-content">
            {
              hasChildren &&
              (
                <div className = {"collapse " + (collapsed ? "collapsed" : "expanded")} onClick = {() => dispatch({type:"TOGGLE_COLLAPSE", value: path})}>
                <span>
                {collapsed ? "-" : "+"}
                </span>
              </div>  
              )
            }           
            <Icon type={iconType} value={icon} />
            <div className = {"name" + (selected ? " name-selected" : "")} onClick = {() => dispatch({type:"CHANGE_PAGE", value: path})}>
              {name}
            </div>
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