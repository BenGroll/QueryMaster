function openPopUp(object) {
    var popup = document.getElementById("popup");
    popup.classList.toggle("qm-show");
}

function getSelectedOf(object) {
    var id = object.id;
    var values = Array.prototype.slice.call(document.querySelectorAll(`#${id} option:checked`), 0).map(function(v,i,a) {
        return v.value;
    });
    return values;
}
// Attach click listener to all collapsibles
Array.from(document.getElementsByClassName("qm-collapsible")).forEach((collapsible) => {
    collapsible.addEventListener("click", function() {
      this.classList.toggle("qm-active");
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
    elem.classList.toggle("qm-oneline");
    elem.classList.toggle("qm-expanded");
    flexbox.classList.toggle("qm-oneline");
    flexbox.classList.toggle("qm-expanded");
    textbox.classList.toggle("qm-oneline");
    textbox.classList.toggle("qm-expanded");
}


  
function setPaginator(amount) {
  if(amount >= 0 && limit != null) {
      document.getElementById("currentPage").innerHTML = "" + amount + "";
      tablepage = amount;
      if(amount == 1) {
        document.getElementById("pagedown").classList.add("qm-hidden");
      } else {
        // document.getElementById("pagedown").classList.remove("qm-hidden");
      }
      return true;
  }
  return false;
}

function toggleSortState(element) {
  if(element.id == sortBy) {
      if(sortOrder == "ascending") {
          sortOrder = "descending";
      } else {
          sortOrder = null;
          sortBy = null;
      }
  } else {
      sortBy = element.id;
      sortOrder = "ascending"; 
  }   
  runQuery();
}
