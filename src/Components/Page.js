import React from 'react';
import LibraryPage from './Pages/Library';

function mapClass(c)
{
  switch(c)
  {
    case "library":
      return LibraryPage;
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