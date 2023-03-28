// ==UserScript==
// @name			9Anime Cleanup
// @namespace		https://wolfe.tech
// @updateURL		https://github.com/AbyssalWolfe/scripts/raw/main/user.js/9anime-cleanup.user.js
// @downloadURL		https://github.com/AbyssalWolfe/scripts/raw/main/user.js/9anime-cleanup.user.js
// @version			1.0.0
// @description		Cleans up 9Anime. Companion uBlock filter located here: https://github.com/AbyssalWolfe/scripts/blob/main/uBlock%20Filters/9anime-cleanup.txt
// @author			Abyssal Wolfe
// @license			unlicense
// @match			*://9anime.to/watch/*
// @match			*://9anime.pl/watch/*
// @match			*://9anime.id/watch/*
// @match			*://9anime.gs/watch/*
// @icon			https://icons.duckduckgo.com/ip3/9anime.me.ico
// @require			http://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js
// @require			https://gist.github.com/raw/2625891/waitForKeyElements.js
// @grant			none
// @run-at			document-end
// ==/UserScript==

(() => {
	waitForKeyElements(".synopsis .toggle", () => {
		let toggle = document.querySelector(".synopsis .toggle");
		let sidebar = document.querySelector("#watch-main > .watch-container.container > .aside-wrapper > .sidebar");
		let dropdown = document.querySelector("#w-related > .head > .dropdown > .dropdown-menu");
		let related = document.querySelector("#w-related > .body");

		toggle.click();
		toggle.remove();

		sidebar.setAttribute("style", "min-height: " + (((related.children[0].children[0].children[0].children.length / 4) >= 1) ? (157 + (103 * (Math.ceil(related.children[0].children[0].children[0].children.length / 4)) - 1)):157) + "px !important");

		for (let i = 0; i < dropdown.children.length; i++) {
			dropdown.children[i].addEventListener("click", () => {
				sidebar.setAttribute("style", "min-height: " + (((related.children[i].children[0].children[0].children.length / 4) >= 1) ? (157 + (103 * (Math.ceil(related.children[i].children[0].children[0].children.length / 4) - 1))):157) + "px !important");
			});
		}
	});
})();
