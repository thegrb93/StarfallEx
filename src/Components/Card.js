import React from 'react';
import LibraryCard from './Cards/LibraryCard';
import MethodCard from './Cards/MethodCard';
import HookCard from './Cards/HookCard';
import TableCard from './Cards/TableCard';
import TypeCard from './Cards/TypeCard';
import MarkdownCard from './Cards/MarkdownCard';
import ContributorsCard from './Cards/ContributorsCard';

function UnknownCard(props)
{
    if(props._class)
    {
        return <div>Unknown card:{props._class}</div>

    }
    else{
        return null;
    }
}

function mapClass(c)
{
  switch(c)
  {
    case "library":
      return LibraryCard;
    case "method":
        return MethodCard;
    case "hook":
        return HookCard;
    case "table":
        return TableCard;
    case "type":
        return TypeCard;
    case "markdown":
        return MarkdownCard;
    case "contributors":
        return ContributorsCard;
    default:
      return UnknownCard;
  }
}

export default function Card(props)
{
    const cardClass = props.data._class;
    const changePage = props.changePage;
    const MappedCard = mapClass(cardClass);
    const children = props.data._children.map(x => <Card changePage = {changePage} data={x} />);

    return (
        <div className = {"card card-" + cardClass }>
            <MappedCard changePage = {changePage} {...props.data} />
            <div className ="card-children">
                {children}
            </div>
        </div>
    )
}