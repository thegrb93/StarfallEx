import React from 'react';
import LibraryPage from './Pages/Library';
import MethodPage from './Pages/Method';
import TypePage from './Pages/Type';
import HookPage from './Pages/Hook';
import TablePage from './Pages/Table';
import MarkdownPage from './Pages/MarkdownPage';
import ContributorsPage from './Pages/Contributors';

function mapClass(c)
{
  switch(c)
  {
    case "library":
      return LibraryPage;
    case "method":
      return MethodPage;
    case "type":
      return TypePage;
    case "hook":
      return HookPage;
    case "table":
      return TablePage;
    case "markdown":
      return MarkdownPage;
    case "contributors":
      return ContributorsPage;
    default:
      return null;
  }
}

export default function Page(props)
{
  const MappedPage = mapClass(props.class);
  if(MappedPage !== null)
  {
    return <MappedPage {...props.data} path = {props.path} changePage = {props.changePage} /> 
  }
  return <div className="page"></div>;
}