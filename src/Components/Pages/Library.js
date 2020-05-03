import React from 'react';
import ClickAction from "../ClickAction";

export default function LibraryPage(props)
{
    const methods = [];

    for(const key in props.methods)
    {
      const value = props.methods[key];
      methods.push((
            <tr key = {key}>
                <td><ClickAction action={props.changePage} value ={props.path+"."+key}>{key}</ClickAction></td>
                <td>{value}</td>
            </tr>
        ));
    }
    
    return (
        <div className="page page-library">
            {props.path}
            <h1>{props.name}</h1>
            <span>{props.description}</span>

            <h3>Methods:</h3>
            <table>
                <tbody>
                {methods}
                </tbody>
            </table>
        </div>

    )
}