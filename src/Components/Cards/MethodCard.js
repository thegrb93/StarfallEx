import React from 'react';
import Icon from '../Icon';

export default function MethodCard(props)
{
    let callParams = props.parameters.map(x => x.name).join(",\xa0");
    let callSplitter = props.type==="library" ? "." : ":";
    let parentName = props.parent;
    
    if(parentName === "builtins")
    {
        parentName = "";
        callSplitter = "";
    }


    const titlePart = (<h1 className="card-title"><Icon type="realm" value={props.realm} />{parentName}{callSplitter}{props.name}({callParams})</h1>);

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

    const returnsList = props.returns.map((x, index)=> <li key={index}>{x}</li>);
    let returnsPart = null;
    if(returnsList.length > 0)
    {
        returnsPart = (
        <div className="returns">
            <h2>Returns</h2>
            <ul className="returns-list">
                {returnsList}
            </ul>
        </div>
        );
    }

    return (
        <React.Fragment>
            {titlePart}
            <p className="description accept-newlines">{props.description}</p>
            {paramPart}
            {returnsPart}
        </React.Fragment>

    );
}