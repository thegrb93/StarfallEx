import React from 'react';
import Icon from '../Icon';
import getGitSourceLink from '../../Modules/Links';

export default function FieldCard(props)
{
    let parentName = props.parent;
    let callSplitter = ".";
    if(parentName === "builtins")
    {
        parentName = "";
        callSplitter = "";
    }

    return (
        <React.Fragment>
            <h1 className="card-title">
                <Icon type="realm" value={props.realm} />
                {parentName}{callSplitter}{props.name}
            </h1>
            <a className="sf-src" href={getGitSourceLink(props)}>[src]</a>
            <p className="accept-newlines">{props.description}</p>
        </React.Fragment>
    )
}