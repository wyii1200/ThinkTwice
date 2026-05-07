# How to Run ThinkTwice AI Service

## 1. Open Terminal

Navigate into AI folder:

```bash
cd AI
```

---

## 2. Create Virtual Environment (First Time Only)

```bash
python -m venv venv
```

---

## 3. Activate Virtual Environment

### Windows

```bash
venv\Scripts\activate
```

### Mac/Linux

```bash
source venv/bin/activate
```

---

## 4. Install Dependencies

```bash
pip install -r requirements.txt
```

If requirements.txt is not ready yet:

```bash
pip install fastapi uvicorn pydantic pandas numpy scikit-learn
```

---

## 5. Run FastAPI Server

```bash
uvicorn main:app --reload
```

---

## 6. Open Swagger UI

Open browser:

```text
http://127.0.0.1:8000/docs
```

Swagger UI allows:
- testing AI endpoints
- sending transaction JSON
- viewing AI analysis responses

---

# Main Endpoint

## POST `/analyze-risk`

Used to:
- analyse spending behaviour
- generate nudges
- trigger Smart Radar
- generate notification payloads
- update learning loop

---

# Test Cases

Reusable test JSON files are located in:

```text
test_cases/
```

Available:
- low_risk.json
- medium_risk.json
- high_risk.json

Copy JSON into Swagger UI request body to test AI flows.

---

# Stop Server

Press:

```bash
CTRL + C
```