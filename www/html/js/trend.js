function update(obj){
	var oya = obj.parentNode;
	var shinseki = oya.parentNode.childNodes;
	var itoko = shinseki[3].childNodes
	var shurui = itoko[0].id;
	var id = oya.id;
	var data = JSON.parse(sessionStorage.getItem("trend"));
	if(obj.checked == true){
		drawLine(data.eco_lserver,shurui,$("#"+id+" #graphtype").val());
	}else{
		drawLine(data.lserver,shurui,$("#"+id+" #graphtype").val());
	}
}


function drawLine(data,id,type){
	var category = data.category;
	var xText = data.xText;
	var yText = data.yText;
	var MAIN = data.series;
	if(type == "percent"){
		type = "column";
		option = "percent";
	}else{
		option = "normal";
	}
        var main = new Highcharts.Chart({
            chart: {
                renderTo: id,
                type: type,
				backgroundColor: '#FFFFFF'
            },
            title: {
                text: xText
            },
            xAxis: {
							categories: category
            },
            yAxis: {
                min: 0,
                title: {
                    text: yText
                }
            },
            legend: {
                layout: 'vertical',
                backgroundColor: '#FFFFFF',
                align: 'left',
                verticalAlign: 'top',
                x: 0,
                y: 0,
                floating: false,
                shadow: true
            },
            tooltip: {
                formatter: function() {
												if(option == "normal"){
                    			return ''+
                        	this.x +': '+ this.y +' '+data.unit;
												}else{
                    			return ''+
													this.series.name +': '+ this.y +' ('+ Math.round(this.percentage) +'%)';
												}
                }
            },
						plotOptions: {
								column: {
										stacking: option,
										pointPadding: -0.2,
										borderWidth: 0,
										grouping: false,
										dataLabels: {
											enabled: true,
											formatter: function (){
												if(option == "normal"){
                    			return ''+
													this.y;
												}else{
                    			return ''+
													this.y +' ('+ Math.round(this.percentage) +'%)';
												}
											},
											color: (Highcharts.theme && Highcharts.theme.dataLabelsColor) || 'white'
                    }
                }
						},
						series: MAIN
				});
}

