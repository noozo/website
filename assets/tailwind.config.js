module.exports = {
    mode: 'jit',
    purge: [
        "../lib/**/*.ex",
        "../lib/**/*.leex",
        "../lib/**/*.eex",
        "./js/**/*.js"
    ],
    darkMode: false, // or 'media' or 'class'
    theme: {
        extend: {
            typography: {
                DEFAULT: {
                    css: {
                        color: '#000000'
                    }
                }
            }
        }
    },
    variants: {
        extend: {}
    },
    plugins: [
        // ...
        require('@tailwindcss/forms'),
        require('@tailwindcss/typography')
      ]
};
