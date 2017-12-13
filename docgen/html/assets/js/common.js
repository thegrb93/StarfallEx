function randInt(min, max) {
	return Math.floor(Math.random() * (max - min + 1)) + min;
}

window.addEventListener('load', function () {
	var stars = document.querySelectorAll('.star');
	for (var i = 0; i < stars.length; i++) {
		stars[i].style.transform = 'rotate(' + randInt(0, 359) + 'deg) scale(' + (0.5 + Math.random() / 2) + ')'
		stars[i].style.WebkitFilter = 'brightness(' + randInt(35, 50) + '%) sepia(100%) hue-rotate(' + randInt(155, 180) + 'deg) contrast(500%)';
	}
});