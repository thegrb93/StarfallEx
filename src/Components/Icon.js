import React from 'react';

export default function Icon(props)
{
    const {type, value} = props;
    switch(type)
    {
        case "realm":
            return <RealmIcon value={value} />;
        case "table-realm":
            return <RealmIconTable value = {value} />
        case "method-realm":
            return <RealmIconMethod value = {value} />
        case "letter":
            return <LetterIcon value = {value} />
        case "letter-simple":
            return <LetterSimpleIcon value = {value} />
        default:
            return <div className="icon-placeholder"> </div>;
    }
}


function RealmIcon(props)
{
    const {value} = props;

    return (
        <div className={"realm-icon realm-icon-"+value}></div>
    )
}

function RealmIconTable(props)
{
    const {value} = props;

    return (
        <div className={"realm-icon realm-icon-"+value}>T</div>
    )
}

function RealmIconMethod(props)
{
    const {value} = props;

    return (
        <div className={"realm-icon realm-icon-"+value}>M</div>
    )
}

function LetterIcon(props)
{
    const {value} = props;

    return (
        <div className={"letter-icon"}>{value}</div>
    )
}
function LetterSimpleIcon(props)
{
    const {value} = props;

    return (
        <div>{value}</div>
    )
}