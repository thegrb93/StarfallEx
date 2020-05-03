import React from 'react';
import Icon from '../Icon';

export default function MethodPage(props)
{
    console.log("Rendering method "+JSON.stringify(props))



    const callParams = props.parameters.map(x => x.name).join(",\xa0");
    const callSplitter = props.type==="library" ? "." : ":";
    

    const titlePart = (<h1 class="method-title"><Icon type="realm" value={props.realm} />{props.parent}{callSplitter}{props.name}({callParams})</h1>);

    let paramPart = null;
    const paramList = props.parameters.map(x => 
        (<li key={x.name}><span>{x.name}</span> - <span>{x.description}</span></li>)
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

    const returnsList = props.returns.map((x, index)=> <li key={index}>{x}</li>);
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
        <div className="page page-method">
            {titlePart}
            <span className="description">{props.description}</span>
            {paramPart}
            {returnsPart}
        </div>

    );
}