// Common script for all pages

function randInt(min, max) {
	return Math.floor(Math.random() * (max - min + 1)) + min;
}

function processMarkup(element) {
	var html = element.innerHTML;

	var ttPattern = new RegExp('`(.*?)`', 'g');
	html = html.replace(ttPattern, '<tt>$1</tt>');

	var urlPattern = new RegExp('(^|[\\s\\(])(https?:\\/\\/)[-a-zA-Z0-9@:%\\._\\+~#=]{2,256}\\.[a-z]{2,6}(\\/[^\\s\\)<]+)?', 'g');
	html = html.replace(urlPattern, function (match, p1, p2) {
		return p1 + '<a href="' + match.substring(p1.length) + '">' + match.substring(p1.length + p2.length) + '</a>';
	});

	element.innerHTML = html;
}

window.addEventListener('load', function () {

	// Perform markup replacements in main text
	var blocks = document.querySelector('main').querySelectorAll('p, li, td');
	for (var i = 0; i < blocks.length; i++) {
		processMarkup(blocks[i]);
	}

	// Randomly transform and colorize stars
	var stars = document.querySelectorAll('.star');
	for (var i = 0; i < stars.length; i++) {
		stars[i].style.transform = 'rotate(' + randInt(0, 359) + 'deg) scale(' + (0.5 + Math.random() / 2) + ')'
		stars[i].style.WebkitFilter = 'brightness(' + randInt(35, 50) + '%) sepia(100%) hue-rotate(' + randInt(155, 180) + 'deg) contrast(500%)';
	}

});