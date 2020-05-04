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
                <td className="accept-newlines">{value}</td>
            </tr>
        ));
    }
    
    let tablePart = null;
    const tables = [];

    for(const key in props.tables)
    {
      const value = props.tables[key];
      tables.push((
            <tr key = {key}>
                <td><ClickAction action={props.changePage} value ={props.path+"."+key}>{key}</ClickAction></td>
                <td className="accept-newlines">{value}</td>
            </tr>
        ));
    }
    if(tables.length > 0)
    {
        tablePart = (
            <div className="tables">
                <h3>Tables:</h3>
                <table>
                    <tbody>
                    {tables}
                    </tbody>
                </table>
            </div>
        )
    }


    return (
        <div className="page page-library">
            <h1>{props.name}</h1>
            <p className="accept-newlines">{props.description}</p>

            <h3>Methods:</h3>
            <table>
                <tbody>
                {methods}
                </tbody>
            </table>

            {tablePart}
        </div>

    )
}