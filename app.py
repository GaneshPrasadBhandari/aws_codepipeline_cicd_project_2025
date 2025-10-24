from flask import Flask, request, jsonify, render_template
from src.pipeline.predict_pipeline import CustomData, PredictPipeline

app = Flask(__name__)

# ---- Health for CI/CD probes ----
@app.get("/health")
def health():
    return jsonify(status="ok"), 200

# ---- Landing page ----
@app.get("/")
def index():
    return render_template("index.html")

# ---- HTML form flow (kept for UI demo) ----
@app.route("/predictdata", methods=["GET", "POST"])
def predict_datapoint():
    if request.method == "GET":
        return render_template("home.html")
    else:
        # NOTE: fixed swapped fields below
        data = CustomData(
            gender=request.form.get("gender"),
            race_ethnicity=request.form.get("ethnicity"),
            parental_level_of_education=request.form.get("parental_level_of_education"),
            lunch=request.form.get("lunch"),
            test_preparation_course=request.form.get("test_preparation_course"),
            reading_score=float(request.form.get("reading_score")),
            writing_score=float(request.form.get("writing_score")),
        )
        pred_df = data.get_data_as_data_frame()
        prediction = PredictPipeline().predict(pred_df)
        return render_template("home.html", results=prediction[0])

# ---- JSON API flow (for tests & automation) ----
@app.post("/predict")
def predict_api():
    """
    JSON body example:
    {
      "gender": "male",
      "ethnicity": "group B",
      "parental_level_of_education": "bachelor's degree",
      "lunch": "standard",
      "test_preparation_course": "none",
      "reading_score": 72,
      "writing_score": 70
    }
    """
    payload = request.get_json(force=True)
    data = CustomData(**payload)
    pred_df = data.get_data_as_data_frame()
    prediction = PredictPipeline().predict(pred_df)
    return jsonify(prediction=prediction[0]), 200

# Local dev only; prod uses gunicorn wsgi:application
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
