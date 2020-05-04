import React from 'react';
import Icon from '../Icon';

//It is a lie, it's supposed to be markdown in future, for now its just simply title and text, but shh
export default function MarkdownPage(props)
{
    return (
        <div className="page page-markdown">
            <h1>{props.title}</h1>
            <p className="description accept-newlines">{props.content}</p>
        </div>

    );
}