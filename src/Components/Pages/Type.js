import React from 'react';

export default function TypePage(props)
{
    console.log("Rendering type "+JSON.stringify(props))
    const methods = [];

    for(const key in props.methods)
    {
      const value = props.methods[key];
      methods.push(<tr key = {key}><td>{key}</td><td>{value}</td></tr>);
    }
    
    return (
        <div className="page page-type">
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