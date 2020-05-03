import React from 'react';
import LibraryPage from './Pages/Library';
import MethodPage from './Pages/Method';
import TypePage from './Pages/Type';

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