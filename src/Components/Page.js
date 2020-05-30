import React from 'react';
import Card from './Card';

export default function Page(props)
{
  return (<div className="page">
    <Card {...props} /> 
  </div>);
}