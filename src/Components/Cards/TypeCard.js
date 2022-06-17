import React from 'react';
import Icon from '../Icon';
import getGitSourceLink from '../../Modules/Links';

export default function TypeCard(props)
{
    return (
        <React.Fragment>
            <h1 class="card-title">
                <Icon type="realm" value={props.realm} />
                {props.name}
            </h1>
            <a className="sf-src" href={getGitSourceLink(props)}>[src]</a>

            <p className="accept-newlines description">
                {props.description}
            </p>
        </React.Fragment>
    )
}