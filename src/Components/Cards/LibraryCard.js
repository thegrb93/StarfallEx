import React from 'react';
import Icon from '../Icon';

export default function LibraryCard(props)
{
    return (
        <React.Fragment>
            <h1 className="card-title"><Icon type="realm" value={props.realm} />{props.name}</h1>
            <p className="accept-newlines">
                {props.description}
            </p>
        </React.Fragment>
    )
}