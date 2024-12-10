console.log("Running custom JavaScript...");
try {
  const textToHighlightList = window.textToHighlightList || [];
  // console.log('list ', textToHighlightList);
  const paragraphs = document.querySelectorAll('p');

  // Function to escape special characters for RegExp
  function escapeRegExp(string) {
    return string.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  }

  // Function to escape HTML special characters
  function escapeHtml(unsafe) {
    return unsafe
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#039;");
  }

  paragraphs.forEach(paragraph => {
    let paragraphText = paragraph.innerHTML;

    textToHighlightList.forEach(textToHighlight => {
      const escapedTextToHighlight = escapeRegExp(textToHighlight);
      const regex = new RegExp(escapedTextToHighlight, 'g');

      // Highlight the text safely
      paragraphText = paragraphText.replace(regex, (match) => {
        return `<span style="background-color: yellow;">${escapeHtml(match)}</span>`;
      });
    });

    paragraph.innerHTML = paragraphText;
  });

  console.log("Custom JavaScript executed successfully.");
} catch (error) {
  console.error("Error executing custom JavaScript:", error);
}
