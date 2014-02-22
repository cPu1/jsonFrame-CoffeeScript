// ==UserScript==
// @name        res
// @namespace   res
// @include     http://mahresult.nic.in/hscOct2013/mahHscoctresult13.asp
// @version     1
// @grant       none
// @require http://cdnjs.cloudflare.com/ajax/libs/d3/2.10.0/d3.v2.min.js
// ==/UserScript==

var subs = [],
	marks = [],
    styleRules = {
        'background-color': '#4682B4',
        'min-height': '10px',
        'min-width': '20px',
        'text-align': 'right',
        'margin-bottom': '5px',
        'color': 'white'
    },
    result;


d3.selectAll('table:nth-child(4) tr.usertextM td:not(:first-child)')
	.each(function (d, i) {
		var content = this.innerHTML;
		if(i && i & 1) return marks.push(content);
		subs.push(content);
	});

result = subs.map(function (sub, i) {
	return {subject: sub, marks: marks[i]}
});

console.log(result);
document.body.innerHTML = '';

d3.select('body')
				.selectAll('div.bar')
				.data(result)
				.enter()
				.append('div')
				.classed('bar', true)
                .style(styleRules)
				.style('width', function (res) {
                    var marks = res.marks;
                    return isNaN(marks)? '200px' : marks * 10 + 'px';
				})
				.text(function (res) {
					return res.subject;
				})
				.append('span');

				d3.selectAll('div.bar span')
					.text(function (res) {
						return ' (#marks) '.replace('#marks', res.marks);
					});


window.onerror = console.log
