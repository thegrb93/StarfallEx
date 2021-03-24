import React from 'react';

const GENERIC_LUA_TYPES = {
    ["boolean"] : true,
    ["number"] : true,
    ["string"] : true,
    ["table"] : true,
    ["..."] : true,
    ["any"] : true,
    ["function"] : true,
    ["thread"] : true
}

// Gets each arg from a multi-type. number|Angle|Vector -> ["number", "Angle", "Vector"]
function getTypes(s) {
    return s.split("|");
}

// Returns the URL local to the current url (SFHelper) to get to a type.
// "Vector" would give you #Types.Vector
function getTypeAnchor(type) {
    return "#Types." + type;
}

// From something like 'number' or 'Vector', returns an <a> object that has an href
// To the class path as long as it starts with an uppercase letter (Identify if it's an SF type)
function getTypeHTML(type) {
    if (GENERIC_LUA_TYPES[type] != null) {
        // Generic lua type. Don't have a link to it.
        return <a className="sf-reference">{type}</a>
    }else {
        return <a className="sf-reference" href={getTypeAnchor(type)}>{type}</a>
    }
}

// Turns something like ...number? -> ["...", <a>number</a>, "?"]
function getElementsFromSingleType(single_type) {
    if(GENERIC_LUA_TYPES[single_type] != null) return getTypeHTML(single_type);
    let out = [];
    let _, vararg, type, nullable;
    [_, vararg, type, nullable] = single_type.match(/(\.{3})?(\w+)(\?)?/);

    if (vararg != null) out.push(vararg);
    out.push( getTypeHTML(type) );
    if (nullable != null) out.push(nullable);
    return out;
}

// Like getElementsFromSingleType, but takes a full type. Full types might have types inside of them
// number|Vector|Angle.
export default function getElementsFromType(full_type) {
    let types = getTypes(full_type);
    let multi_type = types.length>1;
    if (multi_type) {
        let out = [];
        types.forEach( (type, ind) => {
            out.push( getElementsFromSingleType(type) );
            if (ind != types.length-1) out.push(' or ');
        });
        return out;
    }else {
        return [ getElementsFromSingleType( types[0] ) ];
    }
}