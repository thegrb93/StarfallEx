import React from 'react';

export default function Icon(props)
{
    const {type, value} = props;
    switch(type)
    {
        case "realm":
            return <RealmIcon value={value} />;
        default:
            return null;
    }
}


function RealmIcon(props)
{
    const {value} = props;

    return (
        <div className={"realm-icon realm-icon-"+value}></div>
    )
}