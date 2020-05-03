import React from 'react';
import LibraryPage from './Pages/Library';
import MethodPage from './Pages/Method';
import TypePage from './Pages/Type';
import HookPage from './Pages/Hook';

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
    default:
      return null;
  }
}

export default function Page(props)
{
  const MappedPage = mapClass(props.class);
  if(MappedPage !== null)
  {
    return <MappedPage {...props.data} /> 
  }
  return <div className="page"></div>;
}