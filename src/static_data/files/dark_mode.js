document.addEventListener('DOMContentLoaded', function() {
    const toggleLink = document.getElementById('dark-mode-toggle');
    const rootElement = document.documentElement;

    // Function to toggle dark mode
    function toggleDarkMode(event) {
        event.preventDefault(); // Prevent default link behavior
        rootElement.classList.toggle('dark-mode');
        // Save the user's preference in localStorage
        localStorage.setItem('darkMode', rootElement.classList.contains('dark-mode'));
    }

    // Apply the user's preference from localStorage
    if (localStorage.getItem('darkMode') === 'true') {
        rootElement.classList.add('dark-mode');
    }

    // Add event listener to the toggle link
    toggleLink.addEventListener('click', toggleDarkMode);
});
