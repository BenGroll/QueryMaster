// Global function to run the Query and reload the table
async function runQuery() {
    const resulttable = document.getElementById("resulttable");
    const loading = document.getElementById("loading");

    // resulttable.classList.add("opaque");
    // loading.classList.remove("opaque");
    var query = `searchvalue=${document.getElementById("searchField").value}`;
    query = attachFiltersToQuery(query);

    var request = await fetch(`https://apps.test/apps/querymaster/query?${query}`);
    var data = await request.text();

    resulttable.innerHTML = data;
    // resulttable.classList.remove("opaque");
    // loading.classList.add("opaque");

    window.history.pushState({}, '', `/apps/querymaster?${query}`);
}

function attachFiltersToQuery(querystring) {
    var query = querystring;
    
    Object.keys(filtercheckboxesdata).forEach(key => {
        const select = document.getElementById(`select${key}`);
        var values = getSelectedOf(select);
        if(values.length > 0) {
            query+=`${(query.charAt(query.length - 1) === "&" || query.length === 0) ? "" : "&"}filter[${key}]=${JSON.stringify(values)}`; 
        }
    });
    return query;
}

async function getSnippet(name) {
    var test = await fetch('querymaster/htmlsnippets?name=' + name);
    return await test.text();
}

async function searchAllColumns(searchvalue) {

    var query = `searchvalue=${searchvalue}`;
    query = attachFiltersToQuery(query);
    console.log(`https://apps.test/apps/querymaster/search?${query}`);

    var test = await fetch(`https://apps.test/apps/querymaster/search?${query}`);

    const resulttable = document.getElementById("resulttable");
    resulttable.innerHTML = await test.text();
    window.history.pushState({}, '', `/apps/querymaster?${query}`);
}
