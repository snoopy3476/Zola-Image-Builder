Array.prototype.slice.call(document.getElementsByClassName('menu-dropdown-trigger'))
    .forEach(function(elem) {
        
        // when mouse leave
        elem.addEventListener('mouseleave', function() {
            elem.classList.remove("dropdown-force-hide");
        });

        // when click to collapse during mouse hover
        {
            let checkboxCandidate0 = elem.previousElementSibling;
            let checkboxCandidate1 = elem.previousElementSibling.previousElementSibling;
            
            let checkbox = null;
            if (checkboxCandidate0.classList.contains('menu-dropdown-toggle')) {
                checkbox = checkboxCandidate0;
            } else if (checkboxCandidate1.classList.contains('menu-dropdown-toggle')) {
                checkbox = checkboxCandidate1;
            } else {
                return;
            }
            
            checkbox.addEventListener('change', function() {
                if (!checkbox.checked) {
                    elem.classList.add("dropdown-force-hide");
                }
            });
        }
    })
