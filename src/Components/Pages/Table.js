import React from 'react';
import ClickAction from "../ClickAction";

export default function TablePage(props)
{
    const fields = props.fields.map(x => (
        <tr key = {x.name}>
            <td>{x.name}</td>
            <td className="accept-newlines">{x.description}</td>
        </tr>

    ));

    return (
        <div className="page page-table">
            <h1>{props.name}</h1>
            <p className="accept-newlines">{props.description}</p>

            <table>
                <tbody>
                {fields}
                </tbody>
            </table>
        </div>

    )
}