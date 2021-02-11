import Chartist from 'chartist';
import ctPointLabels from 'chartist-plugin-pointlabels';

function analyticsDiagram(data, id) {
    const sortedKeys = Object.keys(data).sort();
    const series = sortedKeys.map(key => data[key]);

    var data = {
        // A labels array that can contain any sort of values
        labels: sortedKeys,
        // Our series array that contains series objects or in this case series data arrays
        series: [
            series
        ]
    };

    // Create a new line chart object where as first parameter we pass in a selector
    // that is resolving to our chart container element. The Second parameter
    // is the actual data object.
    new Chartist.Line(id, data, {
        plugins: [
            ctPointLabels({
                textAnchor: 'middle',
                // labelInterpolationFnc: function(value) {return '$' + value.toFixed(2)}
            })
        ]
    });
}

export default analyticsDiagram;
