"""
Global EV Mobility & Adoption Intelligence Portal
A modernized analytics gateway providing executive metrics and deep-dive
market indicators across electric powertrain categories and global OEM networks.
"""

from flask import Flask, render_template, jsonify

app = Flask(__name__)

# Core benchmark indicators & portfolio metrics
MOBILITY_METRICS = {
    "oem_count": "200+",
    "catalog_models": "17,980",
    "gross_volume_sales": "$1,550.7M",
    "fleet_satisfaction_score": "4.0 / 5.0",
    "mean_autonomy_range": "324.5 km",
    "mean_pack_capacity": "78.2 kWh",
    "total_co2_abatement": "4.8M Metric Tons",
    "fast_charge_average": "42 mins"
}

@app.route("/")
def dashboard_view():
    """Serves the primary intelligence interface and embedded analytical workbook."""
    return render_template("index.html", metrics=MOBILITY_METRICS)

@app.route("/api/v1/telemetry")
def telemetry_endpoint():
    """Provides high-level KPI telemetry for downstream dashboards."""
    return jsonify({
        "status": "success",
        "dataset_scope": "200,000 Records",
        "data": MOBILITY_METRICS
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
