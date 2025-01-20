// Handles keyboard shortcuts for monster training
document.addEventListener('keydown', function(e) {
  // Only handle keypresses if user isn't typing in an input field
  if (e.target.tagName === 'INPUT' || e.target.tagName === 'TEXTAREA') return;

  switch(e.key.toLowerCase()) {
    case 'p':
      document.querySelector('[data-training="power"]')?.click();
      break;
    case 'd':
      document.querySelector('[data-training="defense"]')?.click();
      break;
    case 's':
      document.querySelector('[data-training="speed"]')?.click();
      break;
    case 'h':
      document.querySelector('[data-training="health"]')?.click();
      break;
    case 'r':
      document.querySelector('[data-training="rest"]')?.click();
      break;
  }
});