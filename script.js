document.addEventListener("DOMContentLoaded", function () {
    
    const querymaster = document.getElementById("querymaster");

    if (!querymaster) {
        return;
    }

    querymaster.addEventListener("click", function (event) {

        const date = new Date();

        const formattedDate = date.toLocaleString('de-DE');

        event.target.dispatchEvent(new CustomEvent("notify", {
            bubbles: true,
            detail: {
                text: formattedDate + " - QueryMaster!"
            },
        }));

    });

});
