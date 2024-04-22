
var sortBy = tablesSortBy;
var sortOrder = tablesSortOrder;
var limit;
setLimit(tablelimit);
setPaginator(tablepage);


// Global function to run the Query and reload the table
async function runQuery() {
    const resulttable = document.getElementById("resulttable");
    resulttable.classList.add("qm-waiting");
    var searchvalue = document.getElementById("searchField").value;
    var query = `searchvalue=${searchvalue}`;
    query = attachFiltersToQuery(query);

    var test = await fetch(`https://apps.test/apps/querymaster/search?${query}`);
    resulttable.innerHTML = await test.text();
    window.history.pushState({}, '', `/apps/querymaster?${query}`);

    resulttable.classList.remove("qm-waiting");
    restyleAllSortables(sortBy, sortOrder);
    restyleOverflows();
}

function attachFiltersToQuery(querystring) {
    var query = querystring;
    
    Array.from(filternames).forEach((filter) => {
        var select = document.getElementById(`select${filter}`);
        var selected = [];
        Array.from(select.selectedOptions).forEach((option) => {
            selected.push(option.value);
        });
        if(selected.length > 0) {
            query+=`${(query.charAt(query.length - 1) === "&" || query.length === 0) ? "" : "&"}filter[${filter}]=${JSON.stringify(selected)}`; 
        }
    });

    if(sortBy && sortOrder) {
        query+=`${(query.charAt(query.length - 1) === "&" || query.length === 0) ? "" : "&"}sortBy=${sortBy}`;
        query+=`${(query.charAt(query.length - 1) === "&" || query.length === 0) ? "" : "&"}sortOrder=${sortOrder}`;
    }
    if(limit != "null") {
        query+=`${(query.charAt(query.length - 1) === "&" || query.length === 0) ? "" : "&"}limit=${limit}`;
    }
    query+=`${(query.charAt(query.length - 1) === "&" || query.length === 0) ? "" : "&"}page=${tablepage}`;
    return query;
}


function setLimit(value) {
    if(limit != value) {
        if(document.getElementById("limitselect").value != value && value != "") {
            document.getElementById("limitselect").value = value;
        }
        if(value == "null") {
            console.log("Limit ist null");
            document.getElementById("paginator").classList.add("qm-hidden");
            setPaginator(1);
        } else {
            console.log("Limit ist nicht null");
            document.getElementById("paginator").classList.remove("qm-hidden");
            setPaginator(1);
        }
        if(tableresults < tablelimit) {
            document.getElementById("pageup").classList.add("qm-hidden");
        }
        limit = value;
        return true;
    }
    return false;
}

