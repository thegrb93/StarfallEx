

import React, { useState } from 'react';

export default function Version(props)
{
    const localVersion = window.SFVersion;
    const [latestVersion, setLatestVersion] = useState(localVersion === "master" ? "master" : "" );

    async function FetchVersion()
    {
        let version = "StarfallEx";
        const res = await fetch("https://api.github.com/repos/thegrb93/StarfallEx/commits");
        res
            .json()
            .then(res => {
                version = version + "_" + res[0].sha.substring(0, 7);

                setLatestVersion(version);
            });
    }

    let versionPart = null;
    if(localVersion === "master")
    {
        versionPart = <span className="updates-check">Master branch version</span>
    }
    else if(localVersion === latestVersion)
    {
        versionPart = <span className="updates-check">Running latest version</span>
    }
    else if(latestVersion === "")
    {
        versionPart = <span onClick = {FetchVersion} className="updates-check">(Check for updates)</span>
    }
    else if(latestVersion !== localVersion)
    {
        versionPart = <span className="updates-check">Latest version is {latestVersion}</span>
    }

    return (
        <div className = "version">
            <span className="version-label">Version:</span>
            <span className="version-text">{localVersion}</span>
            {versionPart}
        </div>
    )
}
