// ==UserScript==
// @name			YouTube Cleanup
// @namespace		https://wolfe.tech
// @updateURL		https://github.com/AbyssalWolfe/scripts/raw/main/userscripts/youtube-cleanup.user.js
// @downloadURL		https://github.com/AbyssalWolfe/scripts/raw/main/userscripts/youtube-cleanup.user.js
// @version			1.0.0
// @description		Cleans up YouTube. Companion uBlock filter located here: https://github.com/AbyssalWolfe/scripts/blob/main/uBlock%20Filters/youtube-cleanup.txt
// @author			Abyssal Wolfe
// @license			unlicense
// @match			*://*.youtube.com/*
// @icon			https://icons.duckduckgo.com/ip3/youtube.com.ico
// @require			http://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js
// @require			https://gist.github.com/raw/2625891/waitForKeyElements.js
// @grant			none
// @run-at			document-end
// ==/UserScript==

(() => {
	waitForKeyElements("ytd-guide-collapsible-entry-renderer.style-scope > #expander-item > a:nth-child(1) > tp-yt-paper-item:nth-child(1)", () => {
		document.querySelector("ytd-guide-collapsible-entry-renderer.style-scope > #expander-item > a:nth-child(1) > tp-yt-paper-item:nth-child(1)").click();
	});
})();
