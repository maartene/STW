<template>
    <p class="text-muted">Note: forecasts require manual <a href="#" v-on:click="buildCharts">refresh</a>, because of this computations required to update the forecasts.</p>
    <h3>Earth forecasts</h3>
    <canvas id="myChart" width="400" height="100"></canvas>
    <p class="my-5"></p>
    <h3>Country forecasts</h3>
    <div class="row">
        <div class="col"><canvas id="countryChart" width="100" height="100"></canvas></div>
        <div class="col"><canvas id="countryWealthChart" width="100" height="100"></canvas></div>
    </div>
    <div class="row my-3">
        <div class="col"><canvas id="countryGiniChart" width="100" height="100"></canvas></div>
        <div class="col"><canvas id="countryEdiChart" width="100" height="100"></canvas></div>
    </div>
    <div class="row my-3">
        <div class="col"><canvas id="countryBudgetChart" width="100" height="100"></canvas></div>
        <div class="col">t.b.d.</div>
    </div>
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
            wealthChart: {},
            giniChart: {},
            ediChart: {},
            budgetChart: {}
        }
    },
    props: {
        token: String
    },
    methods: {
        buildCharts() {    
            axios.get(`${this.STW_API_ENDPOINT}/game/country/forecast`, {
                headers: {
                    "Authorization": `bearer ${this.token}`
                }
            })
            .then(response => {
                if (this.countryChart.data) {
                    this.countryChart.destroy();
                }

                if (this.earthChart.data) {
                    this.earthChart.destroy();
                }

                if (this.wealthChart.data) {
                    this.wealthChart.destroy();
                }
                if (this.giniChart.data) {
                    this.giniChart.destroy();
                }
                if (this.ediChart.data) {
                    this.ediChart.destroy();
                }

                if (this.budgetChart.data) {
                    this.budgetChart.destroy();
                }

                const labels = response.data.map(value => { return value.year })
                const temps = response.data.map(value => { return value.currentTemperature })
                const emissions = response.data.map(value => { return value.countryEmissionsPerCapita * 1000000000 })
                const wealths = response.data.map(value => { return value.countryWealthPerCapita })
                const ginis = response.data.map(value => { return value.countryGini })
                const edis = response.data.map(value => { return value.countryEDI })
                const budgets = response.data.map(value => { return value.countryBudget })

                const oneHalfDegrees = temps.map(() => { return 16.15})
                const twoDegrees = temps.map(() => { return 16.65})

                const earthChartData = {
                    type: "line",
                    data: {
                        "labels": labels,
                        datasets: [
                            {
                                label: "Average temperature",
                                data: temps,
                                borderColor: [
                                    'rgba(255,50,50,1)'
                                ],
                                backgroundColor: [
                                    'rgba(255,50,50,0.5)'
                                ],
                                borderWidth: 1
                            },
                            {
                                label: "1.5 degrees rise",
                                data: oneHalfDegrees,
                                borderColor: [
                                    'rgba(200,200,0,0.5)'
                                ],
                                backgroundColor: [
                                    'rgba(200,200,0,0.5)'
                                ],
                                pointRadius: 0,
                                borderWidth: 3
                            },
                            {
                                label: "2 degrees rise",
                                data: twoDegrees,
                                borderColor: [
                                    'rgba(150,100,0,0.5)'
                                ],
                                backgroundColor: [
                                    'rgba(150,100,0,0.5)'
                                ],
                                pointRadius: 0,
                                borderWidth: 3
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
                        },
                        plugins: {
                            title: {
                                display: true,
                                text: 'Average Earth temperature',
                            }
                        }
                    }
                    
                }

                const ctx = document.getElementById('myChart');
                this.earthChart = new Chart(ctx, earthChartData);

                const emissionS = emissions.map(() => { return -4 });
                const emissionA = emissions.map(() => { return 0 });
                const emissionB = emissions.map(() => { return 1 });
                const emissionC = emissions.map(() => { return 2 });
                const emissionD = emissions.map(() => { return 5 });
                const emissionE = emissions.map(() => { return 10 });
                
                const countryChartData = {
                    type: "line",
                    data: {
                        "labels": labels,
                        datasets: [
                            {
                                label: "Emissions Per Capita",
                                data: emissions,
                                borderColor: [
                                    'rgba(150,150,150,1)'
                                ],
                                borderWidth: 3
                            },
                            {
                                label: "S",
                                data: emissionS,
                                borderColor: ['rgba(0,255,0,0.5)'],
                                backgroundColor: [
                                    'rgba(0,255,0,0.25)'
                                ],
                                pointRadius: 0,
                                borderWidth: 2
                            },
                            {
                                label: "A",
                                data: emissionA,
                                borderColor: ['rgba(0,180,0,0.5)'],
                                backgroundColor: [
                                    'rgba(0,180,0,0.25)'
                                ],
                                pointRadius: 0,
                                borderWidth: 2
                            },
                            {
                                label: "B",
                                data: emissionB,
                                borderColor: ['rgba(180,180,0.5)'],
                                backgroundColor: ['rgba(180,180,0,0.25'],
                                pointRadius: 0,
                                borderWidth: 2
                            },
                            {
                                label: "C",
                                data: emissionC,
                                borderColor: ['rgba(200,150,0,0.5)'],
                                backgroundColor: ['rgba(200,150,0,0.25'],
                                pointRadius: 0,
                                borderWidth: 2
                            },
                            {
                                label: "D",
                                data: emissionD,
                                borderColor: ['rgba(200,50,0,0.5)'],
                                backgroundColor: ['rgba(200,50,0,0.25'],
                                pointRadius: 0,
                                borderWidth: 2
                            },
                            {
                                label: "E",
                                data: emissionE,
                                borderColor: ['rgba(255,0,0,0.5)'],
                                backgroundColor: ['rgba(255,0,0,0.25'],
                                pointRadius: 0,
                                borderWidth: 2
                            }
                        ]
                    },
                    options: {
                        scales: {
                            y: {
                                title: {
                                    display: true,
                                    text: "Tonnes Carbon",
                                }
                            }
                        },
                        plugins: {
                            title: {
                                display: true,
                                text: 'Forecasted emissions for country',
                            }
                        }
                    }
                    
                }
                const countryCtx = document.getElementById('countryChart');
                this.countryChart = new Chart(countryCtx, countryChartData);


                const wealthS = wealths.map(() => { return 200 });
                const wealthA = wealths.map(() => { return 120 });
                const wealthB = wealths.map(() => { return 40 });
                const wealthC = wealths.map(() => { return 15 });
                const wealthD = wealths.map(() => { return 5.5 });
                const wealthE = wealths.map(() => { return 3.2 });
                
                const countryWealthChartData = {
                    type: "line",
                    data: {
                        "labels": labels,
                        datasets: [
                            {
                                label: "Wealth Per Capita",
                                data: wealths,
                                borderColor: [
                                    'rgba(50,150,50,1)'
                                ],
                                backgroundColor: [
                                    'rgba(150,255,150,0.5)'
                                ],
                                borderWidth: 3
                            },
                            {
                                label: "S",
                                data: wealthS,
                                borderColor: ['rgba(0,255,0,0.25)'],
                                backgroundColor: [
                                    'rgba(0,255,0,0.25)'
                                ],
                                pointRadius: 0,
                                borderWidth: 2
                            },
                            {
                                label: "A",
                                data: wealthA,
                                borderColor: ['rgba(0,180,0,0.5)'],
                                backgroundColor: [
                                    'rgba(0,180,0,0.25)'
                                ],
                                pointRadius: 0,
                                borderWidth: 2
                            },
                            {
                                label: "B",
                                data: wealthB,
                                borderColor: ['rgba(180,180,0,0.5)'],
                                backgroundColor: ['rgba(180,180,0,0.25'],
                                pointRadius: 0,
                                borderWidth: 2
                            },
                            {
                                label: "C",
                                data: wealthC,
                                borderColor: ['rgba(200,150,0,0.5)'],
                                backgroundColor: ['rgba(200,150,0,0.25'],
                                pointRadius: 0,
                                borderWidth: 2
                            },
                            {
                                label: "D",
                                data: wealthD,
                                borderColor: ['rgba(200,50,0,0.5)'],
                                backgroundColor: ['rgba(200,50,0,0.25'],
                                pointRadius: 0,
                                borderWidth: 2
                            },
                            {
                                label: "E",
                                data: wealthE,
                                borderColor: ['rgba(255,0,0,0.5)'],
                                backgroundColor: ['rgba(255,0,0,0.25'],
                                pointRadius: 0,
                                borderWidth: 2
                            }
                        ]
                    },
                    options: {
                        scales: {
                            y: {
                                title: {
                                    display: true,
                                    text: "US$",
                                }
                            }
                        },
                        plugins: {
                            title: {
                                display: true,
                                text: 'Forecasted per capita wealth for country',
                            }
                        }
                    }
                    
                }
                const wealthCtx = document.getElementById('countryWealthChart');
                this.wealthChart = new Chart(wealthCtx, countryWealthChartData);


                const giniS = ginis.map(() => { return 25 });
                const giniA = ginis.map(() => { return 30 });
                const giniB = ginis.map(() => { return 37.5 });
                const giniC = ginis.map(() => { return 40 });
                const giniD = ginis.map(() => { return 45 });
                const giniE = ginis.map(() => { return 50 });
                
                const countryGiniChartData = {
                    type: "line",
                    data: {
                        "labels": labels,
                        datasets: [
                            {
                                label: "Equality score",
                                data: ginis,
                                borderColor: [
                                    'rgba(50,50,150,1)'
                                ],
                                backgroundColor: [
                                    'rgba(50,50,150,0.5)'
                                ],
                                borderWidth: 3
                            },
                            {
                                label: "S",
                                data: giniS,
                                borderColor: ['rgba(0,255,0,0.25)'],
                                backgroundColor: [
                                    'rgba(0,255,0,0.25)'
                                ],
                                pointRadius: 0,
                                borderWidth: 2
                            },
                            {
                                label: "A",
                                data: giniA,
                                borderColor: ['rgba(0,180,0,0.5)'],
                                backgroundColor: [
                                    'rgba(0,180,0,0.25)'
                                ],
                                pointRadius: 0,
                                borderWidth: 2
                            },
                            {
                                label: "B",
                                data: giniB,
                                borderColor: ['rgba(180,180,0,0.5)'],
                                backgroundColor: ['rgba(180,180,0,0.25'],
                                pointRadius: 0,
                                borderWidth: 2
                            },
                            {
                                label: "C",
                                data: giniC,
                                borderColor: ['rgba(200,150,0,0.5)'],
                                backgroundColor: ['rgba(200,150,0,0.25'],
                                pointRadius: 0,
                                borderWidth: 2
                            },
                            {
                                label: "D",
                                data: giniD,
                                borderColor: ['rgba(200,50,0,0.5)'],
                                backgroundColor: ['rgba(200,50,0,0.25'],
                                pointRadius: 0,
                                borderWidth: 2
                            },
                            {
                                label: "E",
                                data: giniE,
                                borderColor: ['rgba(255,0,0,0.5)'],
                                backgroundColor: ['rgba(255,0,0,0.25'],
                                pointRadius: 0,
                                borderWidth: 2
                            }
                        ]
                    },
                    options: {
                        scales: {
                            y: {
                                title: {
                                    display: true,
                                    text: "gini",
                                }
                            }
                        },
                        plugins: {
                            title: {
                                display: true,
                                text: 'Forecasted equality for country',
                            }
                        }
                    }
                    
                }
                const giniCtx = document.getElementById('countryGiniChart');
                this.giniChart = new Chart(giniCtx, countryGiniChartData);


                //
                // MARK: EDI
                //

                const ediS = edis.map(() => { return 0.99 });
                const ediA = edis.map(() => { return 0.95 });
                const ediB = edis.map(() => { return 0.9 });
                const ediC = edis.map(() => { return 0.8 });
                const ediD = edis.map(() => { return 0.7 });
                const ediE = edis.map(() => { return 0.6 });
                
                const countryEdiChartData = {
                    type: "line",
                    data: {
                        "labels": labels,
                        datasets: [
                            {
                                label: "Education Development Index",
                                data: edis,
                                borderColor: [
                                    'rgba(50,150,150,1)'
                                ],
                                backgroundColor: [
                                    'rgba(50,150,150,0.5)'
                                ],
                                borderWidth: 3
                            },
                            {
                                label: "S",
                                data: ediS,
                                borderColor: ['rgba(0,255,0,0.25)'],
                                backgroundColor: [
                                    'rgba(0,255,0,0.25)'
                                ],
                                pointRadius: 0,
                                borderWidth: 2
                            },
                            {
                                label: "A",
                                data: ediA,
                                borderColor: ['rgba(0,180,0,0.5)'],
                                backgroundColor: [
                                    'rgba(0,180,0,0.25)'
                                ],
                                pointRadius: 0,
                                borderWidth: 2
                            },
                            {
                                label: "B",
                                data: ediB,
                                borderColor: ['rgba(180,180,0,0.5)'],
                                backgroundColor: ['rgba(180,180,0,0.25'],
                                pointRadius: 0,
                                borderWidth: 2
                            },
                            {
                                label: "C",
                                data: ediC,
                                borderColor: ['rgba(200,150,0,0.5)'],
                                backgroundColor: ['rgba(200,150,0,0.25'],
                                pointRadius: 0,
                                borderWidth: 2
                            },
                            {
                                label: "D",
                                data: ediD,
                                borderColor: ['rgba(200,50,0,0.5)'],
                                backgroundColor: ['rgba(200,50,0,0.25'],
                                pointRadius: 0,
                                borderWidth: 2
                            },
                            {
                                label: "E",
                                data: ediE,
                                borderColor: ['rgba(255,0,0,0.5)'],
                                backgroundColor: ['rgba(255,0,0,0.25'],
                                pointRadius: 0,
                                borderWidth: 2
                            }
                        ]
                    },
                    options: {
                        scales: {
                            y: {
                                title: {
                                    display: true,
                                    text: "EDI index",
                                }
                            }
                        },
                        plugins: {
                            title: {
                                display: true,
                                text: 'Forecasted education development for country',
                            }
                        }
                    }
                    
                }
                const ediCtx = document.getElementById('countryEdiChart');
                this.ediChart = new Chart(ediCtx, countryEdiChartData);

                //
                // MARK: BUDGET
                //

                const budgetS = budgets.map(() => { return 5 });
                const budgetA = budgets.map(() => { return 0 });
                const budgetB = budgets.map(() => { return -2.5 });
                const budgetC = budgets.map(() => { return -5 });
                const budgetD = budgets.map(() => { return -7.5 });
                const budgetE = budgets.map(() => { return -10 });
                
                const countryBudgetChartData = {
                    type: "line",
                    data: {
                        "labels": labels,
                        datasets: [
                            {
                                label: "Budget surplus/deficit",
                                data: budgets,
                                borderColor: [
                                    'rgba(50,150,50,1)'
                                ],
                                backgroundColor: [
                                    'rgba(50,150,50,0.5)'
                                ],
                                borderWidth: 3
                            },
                            {
                                label: "S",
                                data: budgetS,
                                borderColor: ['rgba(0,255,0,0.25)'],
                                backgroundColor: [
                                    'rgba(0,255,0,0.25)'
                                ],
                                pointRadius: 0,
                                borderWidth: 2
                            },
                            {
                                label: "A",
                                data: budgetA,
                                borderColor: ['rgba(0,180,0,0.5)'],
                                backgroundColor: [
                                    'rgba(0,180,0,0.25)'
                                ],
                                pointRadius: 0,
                                borderWidth: 2
                            },
                            {
                                label: "B",
                                data: budgetB,
                                borderColor: ['rgba(180,180,0,0.5)'],
                                backgroundColor: ['rgba(180,180,0,0.25'],
                                pointRadius: 0,
                                borderWidth: 2
                            },
                            {
                                label: "C",
                                data: budgetC,
                                borderColor: ['rgba(200,150,0,0.5)'],
                                backgroundColor: ['rgba(200,150,0,0.25'],
                                pointRadius: 0,
                                borderWidth: 2
                            },
                            {
                                label: "D",
                                data: budgetD,
                                borderColor: ['rgba(200,50,0,0.5)'],
                                backgroundColor: ['rgba(200,50,0,0.25'],
                                pointRadius: 0,
                                borderWidth: 2
                            },
                            {
                                label: "E",
                                data: budgetE,
                                borderColor: ['rgba(255,0,0,0.5)'],
                                backgroundColor: ['rgba(255,0,0,0.25'],
                                pointRadius: 0,
                                borderWidth: 2
                            }
                        ]
                    },
                    options: {
                        scales: {
                            y: {
                                title: {
                                    display: true,
                                    text: "% of GDP",
                                }
                            }
                        },
                        plugins: {
                            title: {
                                display: true,
                                text: 'Forecasted budget surplus/deficit for country',
                            }
                        }
                    }
                    
                }
                const budgetCtx = document.getElementById('countryBudgetChart');
                this.budgetChart = new Chart(budgetCtx, countryBudgetChartData);
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