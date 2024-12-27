// Function to highlight all occurrences of strings in a list
// Function to generate a content identifier for the page
window.generateContentFingerprint = function() {
  var mainContent =document.title;
  console.log('logggg'+mainContent);
  // var hash = 0, i, chr;
  // for (i = 0; i < mainContent.length; i++) {
  //   chr = mainContent.charCodeAt(i);
  //   hash = ((hash << 5) - hash) + chr;
  //   hash |= 0; // Convert to 32bit integer
  // }

  return mainContent.toString();
};
window.highlightContent = function(stringsToHighlight) {
    if (!Array.isArray(stringsToHighlight)) {
      console.error('Invalid input: stringsToHighlight must be an array of strings.');
      return;
    }
  
    // Create a style tag for the highlights if it doesn't exist
    if (!document.querySelector('#highlight-style')) {
      const style = document.createElement('style');
      style.id = 'highlight-style';
      style.textContent = '.highlighted { background-color: yellow; color: black; }';
      document.head.appendChild(style);
    }
  
    // Highlight logic
    stringsToHighlight.forEach(function(term) {
      if (!term) return; // Skip empty terms
  
      // Create a RegExp to match the term (case-insensitive)
      const regex = new RegExp(`(${term.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')})`, 'gi');
  
      // Highlight matches in all text nodes
      const walker = document.createTreeWalker(document.body, NodeFilter.SHOW_TEXT);
      const textNodes = [];
      while (walker.nextNode()) {
        textNodes.push(walker.currentNode);
      }
  
      textNodes.forEach(function(node) {
        const parent = node.parentNode;
        if (!parent || parent.classList.contains('highlighted')) return;
  
        const content = node.nodeValue;
        const highlightedHTML = content.replace(regex, '<span class="highlighted">$1</span>');
        if (highlightedHTML !== content) {
          const tempElement = document.createElement('div');
          tempElement.innerHTML = highlightedHTML;
  
          while (tempElement.firstChild) {
            parent.insertBefore(tempElement.firstChild, node);
          }
          parent.removeChild(node);
        }
      });
    });
  };
  
  // Function to remove all highlights
  window.removeHighlights = function() {
    const highlights = document.querySelectorAll('.highlighted');
    highlights.forEach(function(span) {
      const parent = span.parentNode;
      if (parent) {
        while (span.firstChild) {
          parent.insertBefore(span.firstChild, span);
        }
        parent.removeChild(span);
      }
    });
  };
  