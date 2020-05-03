import React from 'react';

export default function Icon(props)
{
    return (
        <span className="click-action" onClick = {() => props.action(props.value)}>
            {props.children}
        </span>
    )
}