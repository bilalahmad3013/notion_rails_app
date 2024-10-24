import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["chartCanvas", "xAxisSelect", "yAxisSelect", "chartTypeSelect", "dataDisplay", "message", "chartContainer"]

  connect() {
    this.chart = null;
    this.updateChart();
  }

  updateChart() {
    const xAxis = this.xAxisSelectTarget.value;
    const yAxis = this.yAxisSelectTarget.value;
    const chartType = this.chartTypeSelectTarget.value;

    if (!xAxis || !yAxis || !chartType) {
      this.messageTarget.style.display = "block";
      this.chartCanvasTarget.style.display = "none";
      this.chartContainerTarget.style.display = "none";
      return;
    }

    this.messageTarget.style.display = "none";
    this.chartCanvasTarget.style.display = "block";
    this.chartContainerTarget.style.display = "flex";

    let data;
    try {
      data = JSON.parse(this.dataDisplayTarget.value);
    } catch (error) {
      console.error("Invalid JSON data", error);
      data = [];
    }

    if (this.chart) {
      this.chart.destroy();
    }

    const labels = data.map(item => item[xAxis]);
    const values = data.map(item => item[yAxis]);

    const ctx = this.chartCanvasTarget.getContext("2d");
    this.chart = new Chart(ctx, {
      type: chartType,
      data: {
        labels: labels,
        datasets: [{
          label: yAxis,
          data: values,
          backgroundColor: "rgba(75, 192, 192, 0.2)",
          borderColor: "rgba(75, 192, 192, 1)",
          borderWidth: 1
        }]
      },
      options: {
        scales: {
          y: {
            beginAtZero: true
          }
        }
      }
    });
  }
}
