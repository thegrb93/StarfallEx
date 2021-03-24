import React from 'react';

//It is a lie, it's supposed to be markdown in future, for now its just simply title and text, but shh
export default function MarkdownCard(props)
{
    return (
        <React.Fragment>
            <h1 className="card-title">{props.title}</h1>
            <p className="description accept-newlines">{props.content}</p>
        </React.Fragment>

    );
}