// Enhance the existing navigation; all links remain available without JavaScript.
const menuToggle = document.querySelector('.menu-toggle');
const navigation = document.querySelector('#primary-navigation');
const compactLayout = window.matchMedia('(max-width: 960px)');

if (menuToggle && navigation) {
  const setMenuOpen = (open) => {
    menuToggle.setAttribute('aria-expanded', String(open));
    navigation.hidden = !open;
  };

  const syncLayout = () => {
    const compact = compactLayout.matches;
    // Keep keyboard focus visible when resizing between layouts.
    if (compact && navigation.contains(document.activeElement)) {
      menuToggle.hidden = false;
      menuToggle.focus();
    } else if (!compact && document.activeElement === menuToggle) {
      navigation.hidden = false;
      navigation.querySelector('a').focus();
    }
    menuToggle.hidden = !compact;
    setMenuOpen(!compact);
  };

  menuToggle.addEventListener('click', () => {
    setMenuOpen(menuToggle.getAttribute('aria-expanded') !== 'true');
  });

  document.addEventListener('keydown', (event) => {
    if (event.key === 'Escape' && compactLayout.matches && !navigation.hidden) {
      setMenuOpen(false);
      menuToggle.focus();
    }
  });

  compactLayout.addEventListener('change', syncLayout);
  syncLayout();
}

document.querySelectorAll('[data-year]').forEach((element) => {
  element.textContent = new Date().getFullYear();
});
