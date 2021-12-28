<template>
    <p class="text-muted">Note: forecasts require manual <a href="#" v-on:click="buildCharts">refresh</a>, because of this computations required to update the forecasts.</p>
    <h3>Forecasted temperature</h3>
    <canvas id="myChart" width="400" height="100"></canvas>
    <p class="my-5"></p>
    <h3>Forecasted country emissions</h3>
    <canvas id="countryChart" width="400" height="100"></canvas>
    <p class="my-3"></p>
    <button class="btn btn-secondary" v-on:click="buildCharts">Refresh</button>
</template>

<script>
import Chart from 'chart.js/auto';

const axios = require('axios');

export default {
    name: "Forecast",
    data() {
        return {
            countryChart: {},
            earthChart: {},
        }
    },
    props: {
        countryID: String
    },
    methods: {
        buildCharts() {    
            axios.get(`${this.STW_API_ENDPOINT}/game/${this.countryID}/forecast`)
            .then(response => {
                if (this.countryChart.data) {
                    this.countryChart.destroy();
                }

                if (this.earthChart.data) {
                    this.earthChart.destroy();
                }

                const labels = response.data.map(value => { return value.year })
                const temps = response.data.map(value => { return value.currentTemperature })
                const emissions = response.data.map(value => { return value.countryEmissions * 1000 })


                const earthChartData = {
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
                                backgroundColor: [
                                    'rgba(255,0,0,0.5)'
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
                this.earthChart = new Chart(ctx, earthChartData);

                const countryChartData = {
                    type: "line",
                    data: {
                        "labels": labels,
                        datasets: [
                            {
                                label: "Emissions",
                                data: emissions,
                                borderColor: [
                                    'rgba(0,0,0,1)'
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
                                    text: "Million tonnes Carbon",
                                }
                            }
                        }
                    }
                    
                }
                const countryCtx = document.getElementById('countryChart');
                this.countryChart = new Chart(countryCtx, countryChartData);
            })
            .catch(e => {
                console.log(e);
            })
        }
    },
    mounted() {
        this.buildCharts();
    }
}
</script>

<style>

</style>