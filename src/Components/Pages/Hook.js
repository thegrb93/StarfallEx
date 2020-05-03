import React from 'react';
import Icon from '../Icon';

export default function HookPage(props)
{
    const callParams = props.parameters.map(x => x.name).join(",\xa0");   

    const titlePart = (<h1 className="hook-title"><Icon type="realm" value={props.realm} />{props.name}({callParams})</h1>);

    let paramPart = null;
    const paramList = props.parameters.map(x => 
        (<li key={x.name}><span>{x.name}</span> - <span className="accept-newlines">{x.description}</span></li>)
    );
    if(paramList.length > 0)
    {
        paramPart = (
            <div className="parameters">
                <h2>Parameters</h2>
                <ul className="parameters-list">
                {paramList}
                </ul>
            </div>
        );
    }

    const returnsList = props.returns.map((x, index)=> <li key={index} className="accept-newlines">{x}</li>);
    let returnsPart = null;
    if(returnsList.length > 0)
    {
        returnsPart = (
        <div className="returns">
            <h2>Returns</h2>
            <ul clasName="returns-list">
                {returnsList}
            </ul>
        </div>
        );
    }

    return (
        <div className="page page-hook">
            {titlePart}
            <span className="description accept-newlines">{props.description}</span>
            {paramPart}
            {returnsPart}
        </div>

    );
}