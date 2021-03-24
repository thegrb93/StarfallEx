import React from 'react';
import Icon from '../Icon';
import getElementsFromType from '../../Modules/SFTypes';
import getGitSourceLink from '../../Modules/Links';

export default function HookCard(props)
{
    let callParams = props.parameters.map((x, index) =>
        <div>
            {getElementsFromType(x.type)} {x.name}
            {index === props.parameters.length - 1 ? "" : ",\xa0"}
        </div>
    )

    const titlePart = (
        <h1 className="card-title">
            <Icon type="realm" value={props.realm} />
            {props.parent}{props.name}({callParams})
        </h1>
    );
    let paramPart = null;
    const paramList = props.parameters.map(x =>
        <li key={x.name}>
            {getElementsFromType(x.type)} <span className="sf-paramname">{x.name}</span>
            <ul>
                <span className="accept-newlines">{x.description}</span>
            </ul>
        </li>
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

    const returnsList = props.returns.map((x, index)=>
        <li key={index}>
            {getElementsFromType(x.type)}
            <ul>
                <span className="accept-newlines">{x.description}</span>
            </ul>
        </li>
    );
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
            <a className="sf-src" href={getGitSourceLink(props)}>[src]</a>

            <p className="description accept-newlines">{props.description}</p>
            {paramPart}
            {returnsPart}
        </React.Fragment>

    );
}