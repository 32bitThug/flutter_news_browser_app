
function modifyPage() {
  try {
    const header = document.querySelector('header');
    const footer = document.querySelector('footer');
    const container = document.getElementById("containerMain");
    const bottomMenu = document.querySelector('.bottomMenu');
    const adds = document.querySelector('.bottomFixAd'); // Uncomment if you need this
    
    // Log the values of header, footer, bottomMenu, and adds
  
    let removed = 0;

    // Remove header if found
    // if (header) {
    //   header.remove();     
    // }

    // Remove footer if found
    if (footer) {
      footer.remove();
    }

    // Remove bottom menu if found
    if (bottomMenu) {
      bottomMenu.remove();
    }

    // Remove adds if found and uncommented
    if (adds) {
      adds.hidden = true; // Instead of removing, you’re hiding this element
    }

    // Adjust container margin
    if (container) {
      container.style.marginTop = "0";
    }

    // Return a result object
    return {
      success: true,
      removed: removed,
      containerAdjusted: !!container
    };
  } catch (error) {
    console.error('Error in modifyPage:', error);
    return {
      success: false,
      error: error.toString()
    };
  }
}

// Function to remove elements by ID
function removeElementsUsingRulesJs(elementsToRemove, type, isHidden) {
  // console.log(elementsToRemove, type, isHidden); // Log elementsToRemove to debug
  var elements;
  elementsToRemove.forEach(element => {
    console.log(`Attempting to modify element with id/class: ${element}`);

    if (type === "Id") {
      const htmlElement = document.getElementById(element);
      elements = htmlElement ? [htmlElement] : []; // Wrap in array for consistent handling
    } else if (type === "Class") {
      elements = document.querySelectorAll(`.${element}`);
    } else {
      console.log("Invalid type. Expected 'Id' or 'Class'.");
      return;
    }

    // Process the selected elements
    if (elements.length > 0) {
      console.log(elements.length);
      elements.forEach(el => {
        el.hidden = isHidden; // Use `el` here, not `id`
        console.log(`Modified element with ${type.toLowerCase()}: ${element}`);
      });
    } else {
      console.log(`No elements found with ${type.toLowerCase()}: ${element}`);
    }
  });
}


