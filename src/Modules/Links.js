import React from 'react';

// Returns a link to the github's starfall source code so that the
// local url given can be used.
// You get 'properties' from the cards initial args/
// 'relative' may be something like: libs_sh/math.lua#L124
export default function getGitSourceLink(properties) {
    let relative = properties.ghpath;
    return "https://github.com/thegrb93/StarfallEx/blob/master/lua/starfall/" + relative;
}