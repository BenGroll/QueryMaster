function openPopUp(object) {
    var popup = document.getElementById("popup");
    popup.classList.toggle("show");
}

function getSelectedOf(object) {
    var id = object.id;
    var values = Array.prototype.slice.call(document.querySelectorAll(`#${id} option:checked`), 0).map(function(v,i,a) {
        return v.value;
    });
    return values;
}
// Attach click listener to all collapsibles
Array.from(document.getElementsByClassName("collapsible")).forEach((collapsible) => {
    collapsible.addEventListener("click", function() {
      this.classList.toggle("active");
      var content = this.nextElementSibling;
      if (content.style.maxHeight){
        content.style.maxHeight = null;
      } else {
        content.style.maxHeight = content.scrollHeight + "px";
      }
    });
  });
  

function toggleExpand(elem) {
    var flexbox = Array.from(elem.children)[0];
    var textbox = Array.from(flexbox.children)[0];
    elem.classList.toggle("oneline");
    elem.classList.toggle("expanded");
    flexbox.classList.toggle("oneline");
    flexbox.classList.toggle("expanded");
    textbox.classList.toggle("oneline");
    textbox.classList.toggle("expanded");
}

function toggleSort(triggeredElement) {
    if (sortBy == triggeredElement) {
        if(sortOrder == "ascending") {
            sortOrder = "descending";
        } else if(sortOrder == "descending") {
            sortOrder = null;
            sortBy = null;
        } else {
            sortOrder = "ascending";
        }
    } else {
        sortBy = triggeredElement;
        sortOrder = "ascending";
    }
    styleSortables();
}

function styleSortables() {
    var sortableElements = document.getElementsByClassName("sortable");
    
    Array.from(sortableElements).forEach((element) => {
        element.classList.remove("sort-descending");
        element.classList.remove("sort-ascending");
    });
    if(sortBy != null) {
        sortBy.classList.add(`sort-${sortOrder}`);
    }
}
function isOverflown(element){
    return element.scrollHeight > element.clientHeight || element.scrollWidth > element.clientWidth;
}
  
var expandButtons = document.getElementsByClassName("expandButton");
Array.from(expandButtons).forEach((element) => {
    var parent = element.parentElement;
    var textbox = Array.from(parent.children)[0];
    if (isOverflown(textbox)) {
        element.classList.remove("hide");
        parent.classList.add("pointercursor");
    }
});
