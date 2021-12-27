<template>
    <h3>Forecasted temperature</h3>
    <canvas id="myChart" width="400" height="100"></canvas>
    
</template>

<script>
import Chart from 'chart.js/auto';

// const mychardata  = {
//     type: 'line',
//     data: {
//         labels: ['Red', 'Blue', 'Yellow', 'Green', 'Purple', 'Orange'],
//         datasets: [{
//             label: '# of Votes',
//             data: [12, 19, 3, 5, 2, 3],
//             backgroundColor: [
//                 'rgba(255, 99, 132, 0.2)',
//                 'rgba(54, 162, 235, 0.2)',
//                 'rgba(255, 206, 86, 0.2)',
//                 'rgba(75, 192, 192, 0.2)',
//                 'rgba(153, 102, 255, 0.2)',
//                 'rgba(255, 159, 64, 0.2)'
//             ],
//             borderColor: [
//                 'rgba(255, 99, 132, 1)',
//                 'rgba(54, 162, 235, 1)',
//                 'rgba(255, 206, 86, 1)',
//                 'rgba(75, 192, 192, 1)',
//                 'rgba(153, 102, 255, 1)',
//                 'rgba(255, 159, 64, 1)'
//             ],
//             borderWidth: 1
//         }]
//     },
//     options: {
//         scales: {
//             y: {
//                 beginAtZero: true
//             }
//         }
//     }
// }

const axios = require('axios');

export default {
    name: "Forecast",
    data() {
        return {
            chart: {}
        }
    },
    props: {
        countryID: String
    },
    methods: {
        refresh() {
            axios.get(`${this.STW_API_ENDPOINT}/game/${this.countryID}/forecast`)
            .then(response => {
                //console.log(response.data);

                const labels = response.data.map(value => { return value.year })
                const temps = response.data.map(value => { return value.currentTemperature })

                const chartData = {
                    type: "line",
                    data: {
                        "labels": labels,
                        datasets: [
                            {
                                label: "Average temperature",
                                data: temps,
                                borderColor: [
                                    'rgba(255,0,0,1)'
                                ],
                                borderWidth: 1
                            }
                        ]
                    },
                    options: {
                        scales: {
                            y: {
                                title: {
                                    display: true,
                                    text: "Degrees °C",
                                }
                            }
                        }
                    }
                    
                }

                const ctx = document.getElementById('myChart');
                this.chart = new Chart(ctx, chartData);
            })
            .catch(e => {
                console.log(`error: ${e}`);
            })
        }
    },
    mounted() {
        this.refresh();
    }
}
</script>

<style>

</style>