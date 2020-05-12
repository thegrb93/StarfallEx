import React from 'react';
import Icon from '../Icon';

export default function TypeCard(props)
{
    return (
        <React.Fragment>
            <h1 class="card-title"><Icon type="realm" value={props.realm} />{props.name}</h1>
            <p className="accept-newlines">
                {props.description}
            </p>
        </React.Fragment>
    )
}